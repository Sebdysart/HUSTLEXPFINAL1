"use client";

import { useEffect, useRef, useState, type FormEvent } from "react";
import { trpc } from "@/lib/trpc";
import { capture } from "@/lib/analytics";
import { LocalAvailability } from "@/components/local-availability";
import { DispatchSection } from "@/components/dispatch-section";
import {
  FUNDING_STORAGE_KEY,
  readPersistedFunding,
  type PersistedFunding,
} from "@/components/funding-step";

// Front-of-funnel chip IDs. These are designed for the homepage and do NOT
// match backend template slugs 1:1 — many real tasks (dump runs, errands,
// yard work, event setup, assembly) all collapse onto the small set of
// backend templates the manifest exposes. Mapping is explicit below so the
// procedure only ever receives a slug it accepts.
const CATEGORIES = [
  { id: "moving", label: "Moving help" },
  { id: "assembly", label: "Furniture assembly" },
  { id: "dump", label: "Dump runs" },
  { id: "yard", label: "Yard cleanup" },
  { id: "errands", label: "Errands" },
  { id: "event", label: "Event setup" },
] as const;

export type CategoryId = (typeof CATEGORIES)[number]["id"];

// Maps homepage chip → backend template slug from getManifest().
// Anything not in the manifest goes to standard_physical, the default
// muscle-work template — the safest fallback for a poster funnel.
const CHIP_TO_BACKEND_SLUG: Record<CategoryId, string> = {
  moving: "standard_physical",
  assembly: "in_home",
  dump: "standard_physical",
  yard: "standard_physical",
  errands: "standard_physical",
  event: "event_appearance",
};

// Eastside-only beta zips. Honest scope — if a Poster's zip isn't here,
// we say so directly instead of pretending to serve them.
const EASTSIDE_ZIPS = new Set([
  // Redmond
  "98052", "98053", "98073",
  // Sammamish
  "98074", "98075",
  // Bellevue
  "98004", "98005", "98006", "98007", "98008", "98009", "98015",
  // Kirkland
  "98033", "98034",
  // Issaquah
  "98027", "98029",
]);

const DRAFT_STORAGE_KEY = "hustlexp.draft.v1";
const CREATED_TASK_STORAGE_KEY = "hustlexp.lastTaskId.v1";
const DRAFT_TTL_MS = 24 * 60 * 60 * 1000; // 24h

type PersistedLastTask = {
  id: string;
  createdAt: string;
};

function readPersistedLastTask(): PersistedLastTask | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(CREATED_TASK_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as PersistedLastTask;
    if (!parsed?.id || !parsed?.createdAt) {
      window.localStorage.removeItem(CREATED_TASK_STORAGE_KEY);
      return null;
    }
    const ageMs = Date.now() - new Date(parsed.createdAt).getTime();
    if (!Number.isFinite(ageMs) || ageMs > DRAFT_TTL_MS) {
      window.localStorage.removeItem(CREATED_TASK_STORAGE_KEY);
      return null;
    }
    return parsed;
  } catch {
    try {
      window.localStorage.removeItem(CREATED_TASK_STORAGE_KEY);
    } catch {
      /* ignore */
    }
    return null;
  }
}

type DraftResult = {
  title: string;
  cleanedDescription: string;
  category: string;
  recommendedPriceCents: number;
  estimatedDurationMinutes: number;
  requiredTools: string[];
  urgency: "low" | "normal" | "high";
  safetyNotes: string[];
  followUpQuestions: string[];
};

type PersistedDraft = {
  input: { description: string; category?: string; zip?: string };
  result: DraftResult;
  createdAt: string;
};

function readPersistedDraft(): PersistedDraft | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(DRAFT_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as PersistedDraft;
    if (
      !parsed?.result ||
      typeof parsed.result.recommendedPriceCents !== "number" ||
      typeof parsed.createdAt !== "string"
    ) {
      window.localStorage.removeItem(DRAFT_STORAGE_KEY);
      return null;
    }
    const ageMs = Date.now() - new Date(parsed.createdAt).getTime();
    if (!Number.isFinite(ageMs) || ageMs > DRAFT_TTL_MS) {
      window.localStorage.removeItem(DRAFT_STORAGE_KEY);
      return null;
    }
    return parsed;
  } catch {
    window.localStorage.removeItem(DRAFT_STORAGE_KEY);
    return null;
  }
}

function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatDuration(minutes: number): string {
  if (minutes < 60) return `${minutes} min`;
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  return rest === 0 ? `${hours} hr` : `${hours} hr ${rest} min`;
}

export function FunnelForm({
  initialZip = "",
  initialCategory = null,
}: {
  /**
   * Optional ZIP prefill — used by the C9 local landing pages (e.g. /redmond)
   * so a visitor who already declared their area lands in the funnel with the
   * field filled. A restored localStorage draft still takes precedence (see
   * the mount effect below), so an in-flight estimate is never clobbered.
   */
  initialZip?: string;
  /**
   * Optional category prefill — used by the C9 category landing pages
   * (e.g. /moving-help). Same precedence rule as initialZip.
   */
  initialCategory?: CategoryId | null;
} = {}) {
  const [task, setTask] = useState("");
  const [zip, setZip] = useState(initialZip);
  const [category, setCategory] = useState<CategoryId | null>(initialCategory);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<DraftResult | null>(null);
  const [savedBackendCategory, setSavedBackendCategory] = useState<
    string | undefined
  >(undefined);
  const [savedZip, setSavedZip] = useState<string>("");
  const [taskCreated, setTaskCreated] = useState(false);
  const [resumeCreated, setResumeCreated] = useState<{
    id: string;
    title: string;
  } | null>(null);
  const [resumeFunding, setResumeFunding] = useState<PersistedFunding | null>(
    null,
  );

  // One-shot analytics guards: fire each funnel-entry event at most once per
  // mounted form so React Strict Mode / re-renders don't double-count.
  const inputStartedRef = useRef(false);
  const zipTrackedRef = useRef(false);

  const draftEstimate = trpc.task.draftEstimate.useMutation();

  // Restore a saved draft on mount.
  //
  // useEffect is the right tool here even though the lint rule discourages
  // setState in an effect: localStorage is only available client-side, and
  // doing this in a useState lazy initializer would cause an SSR/CSR
  // hydration mismatch (server renders an empty form, client a populated one).
  // React's docs explicitly recommend exactly this pattern for hydrating
  // from a client-only store.
  useEffect(() => {
    const persisted = readPersistedDraft();
    if (!persisted) return;
    /* eslint-disable react-hooks/set-state-in-effect */
    setTask(persisted.input.description);
    setZip(persisted.input.zip ?? "");
    setSavedZip(persisted.input.zip ?? "");
    setSavedBackendCategory(persisted.input.category);
    const chip = CATEGORIES.find(
      (c) => CHIP_TO_BACKEND_SLUG[c.id] === persisted.input.category,
    );
    if (chip) setCategory(chip.id);
    setResult(persisted.result);

    // C7 resume: if a funding session is in flight for the last-created task,
    // land back in the post-create panel with the FundingStep ready to
    // continue. The persisted entries are matched by task id so a stale
    // session from a different task can't hijack the resume.
    const lastTask = readPersistedLastTask();
    const funding = readPersistedFunding();
    if (lastTask && funding && funding.taskId === lastTask.id && funding.status !== "funded") {
      setResumeCreated({ id: lastTask.id, title: persisted.result.title });
      setResumeFunding(funding);
      setTaskCreated(true);
    }
    /* eslint-enable react-hooks/set-state-in-effect */
  }, []);

  const trimmedTask = task.trim();
  const zipLooksValid = /^\d{5}$/.test(zip);
  const canSubmit = trimmedTask.length >= 8 && zipLooksValid;
  const isLoading = draftEstimate.isPending;
  const isEastsideZip = zipLooksValid && EASTSIDE_ZIPS.has(zip);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!canSubmit) {
      setError(
        "Add a description (at least 8 characters) and a 5-digit ZIP.",
      );
      return;
    }
    if (!EASTSIDE_ZIPS.has(zip)) {
      setError(
        "We're starting Eastside-only — Redmond, Sammamish, Bellevue, Kirkland, Issaquah. We'll text you when we cover your area.",
      );
      return;
    }

    const backendCategory = category
      ? CHIP_TO_BACKEND_SLUG[category]
      : undefined;

    capture("draft_estimate_started", {
      city_or_zip: zip,
      category: backendCategory,
    });

    try {
      const response = await draftEstimate.mutateAsync({
        description: trimmedTask,
        category: backendCategory,
        zip,
      });
      setResult(response);
      setSavedBackendCategory(backendCategory);
      setSavedZip(zip);
      capture("draft_estimate_succeeded", {
        city_or_zip: zip,
        category: backendCategory,
        task_price_cents: response.recommendedPriceCents,
      });
      try {
        window.localStorage.setItem(
          DRAFT_STORAGE_KEY,
          JSON.stringify({
            input: {
              description: trimmedTask,
              category: backendCategory,
              zip,
            },
            result: response,
            createdAt: new Date().toISOString(),
          } satisfies PersistedDraft),
        );
      } catch {
        // localStorage may be unavailable (private mode quota); the draft
        // still renders in-memory for this session.
      }
    } catch (err: unknown) {
      const code =
        (err as { data?: { code?: string } } | undefined)?.data?.code ?? "";
      const message =
        (err as { message?: string } | undefined)?.message ??
        "Something went wrong. Try again in a moment.";
      capture("draft_estimate_failed", {
        city_or_zip: zip,
        error_code: code || undefined,
      });
      if (code === "TOO_MANY_REQUESTS") {
        setError(
          "You've made a lot of requests — try again in a minute.",
        );
      } else if (code === "SERVICE_UNAVAILABLE") {
        setError(
          "Our estimator is taking a breath — please try in a bit.",
        );
      } else {
        setError(message);
      }
    }
  }

  function onStartOver() {
    setResult(null);
    setError(null);
    setTask("");
    setZip("");
    setCategory(null);
    setSavedBackendCategory(undefined);
    setSavedZip("");
    setTaskCreated(false);
    setResumeCreated(null);
    setResumeFunding(null);
    // Start Over is the user's explicit reset — clear ALL session storage so
    // they don't get resumed back into a stale funding flow.
    try {
      window.localStorage.removeItem(DRAFT_STORAGE_KEY);
      window.localStorage.removeItem(CREATED_TASK_STORAGE_KEY);
      window.localStorage.removeItem(FUNDING_STORAGE_KEY);
    } catch {
      // ignore
    }
  }

  // Called from <DispatchSection> after task.create succeeds. C7: the draft
  // is intentionally NOT cleared yet — funding hasn't happened. The draft
  // and lastTaskId persist through the funding step so a refresh mid-payment
  // resumes coherently.
  function onTaskCreated() {
    setTaskCreated(true);
  }

  // Called from <DispatchSection> → <FundingStep> after the backend confirms
  // escrow state === 'FUNDED'. Only NOW is it safe to clear the draft and
  // the funding session storage — the user has reached the terminal happy
  // state for this task.
  function onTaskFunded() {
    try {
      window.localStorage.removeItem(DRAFT_STORAGE_KEY);
      window.localStorage.removeItem(FUNDING_STORAGE_KEY);
      // Intentionally KEEP CREATED_TASK_STORAGE_KEY so future visits know the
      // task exists. Clearing the funding session is enough — the funded
      // panel will render via the FundingStep's terminal 'funded' phase.
    } catch {
      // ignore
    }
  }

  if (result) {
    return (
      <div
        role="status"
        aria-live="polite"
        className="hx-reveal rounded-2xl border border-brand-purple/40 bg-elevated/60 p-5 text-left shadow-[0_0_60px_-30px_rgba(91,45,255,0.6)]"
      >
        <p className="text-sm font-semibold uppercase tracking-wide text-brand-purple-glow">
          Estimate
        </p>
        <h2 className="mt-2 text-xl font-semibold text-text-primary">
          {result.title}
        </h2>
        <dl className="mt-4 grid grid-cols-2 gap-x-4 gap-y-3 text-sm">
          <div>
            <dt className="text-text-muted">Recommended price</dt>
            <dd className="text-text-primary font-medium">
              {formatPrice(result.recommendedPriceCents)}
            </dd>
          </div>
          <div>
            <dt className="text-text-muted">Estimated duration</dt>
            <dd className="text-text-primary font-medium">
              {formatDuration(result.estimatedDurationMinutes)}
            </dd>
          </div>
          <div>
            <dt className="text-text-muted">Category</dt>
            <dd className="text-text-primary">{result.category}</dd>
          </div>
          <div>
            <dt className="text-text-muted">Urgency</dt>
            <dd className="text-text-primary capitalize">{result.urgency}</dd>
          </div>
        </dl>

        <div className="mt-4">
          <p className="text-text-muted text-xs uppercase tracking-wide">
            Cleaned description
          </p>
          <p className="mt-1 text-text-secondary text-sm">
            {result.cleanedDescription}
          </p>
        </div>

        {result.requiredTools.length > 0 && (
          <div className="mt-4">
            <p className="text-text-muted text-xs uppercase tracking-wide">
              Likely tools
            </p>
            <ul className="mt-1 flex flex-wrap gap-2 text-sm text-text-secondary">
              {result.requiredTools.map((tool) => (
                <li
                  key={tool}
                  className="rounded-full border border-white/10 bg-elevated px-3 py-1"
                >
                  {tool}
                </li>
              ))}
            </ul>
          </div>
        )}

        {result.safetyNotes.length > 0 && (
          <div className="mt-4">
            <p className="text-text-muted text-xs uppercase tracking-wide">
              Safety notes
            </p>
            <ul className="mt-1 list-disc pl-5 text-sm text-text-secondary">
              {result.safetyNotes.map((note) => (
                <li key={note}>{note}</li>
              ))}
            </ul>
          </div>
        )}

        {result.followUpQuestions.length > 0 && (
          <div className="mt-4">
            <p className="text-text-muted text-xs uppercase tracking-wide">
              Before you post
            </p>
            <ul className="mt-1 list-disc pl-5 text-sm text-text-secondary">
              {result.followUpQuestions.map((q) => (
                <li key={q}>{q}</li>
              ))}
            </ul>
          </div>
        )}

        <p className="mt-4 text-xs text-text-muted">
          Estimates are AI-generated suggestions. Final price is yours.
        </p>

        <DispatchSection
          draft={{
            title: result.title,
            cleanedDescription: result.cleanedDescription,
            category: result.category,
            recommendedPriceCents: result.recommendedPriceCents,
            zip: savedZip,
            templateSlug: savedBackendCategory,
          }}
          onCreated={onTaskCreated}
          onFunded={onTaskFunded}
          resumeCreated={resumeCreated ?? undefined}
          resumeFunding={
            resumeFunding
              ? {
                  escrowId: resumeFunding.escrowId,
                  paymentIntentId: resumeFunding.paymentIntentId,
                  clientSecret: resumeFunding.clientSecret,
                }
              : undefined
          }
        />

        {!taskCreated && (
          <button
            type="button"
            onClick={onStartOver}
            className="mt-4 rounded-lg border border-white/15 px-4 py-2 text-sm font-medium text-text-secondary hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
          >
            Start over
          </button>
        )}
      </div>
    );
  }

  return (
    <form
      onSubmit={onSubmit}
      noValidate
      className="flex w-full flex-col gap-6 text-left"
    >
      <div className="flex flex-col gap-2">
        <label
          htmlFor="task"
          className="text-base font-semibold text-text-primary"
        >
          What do you need done?
        </label>
        <textarea
          id="task"
          name="task"
          rows={3}
          value={task}
          onChange={(e) => {
            const next = e.target.value;
            setTask(next);
            if (next.trim().length > 0 && !inputStartedRef.current) {
              inputStartedRef.current = true;
              capture("task_input_started");
            }
          }}
          placeholder="What do you need done? e.g., move a couch from my apartment to a storage unit"
          className="w-full resize-none rounded-2xl border border-white/10 bg-elevated px-5 py-5 text-lg text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:rows-2 sm:text-xl"
        />
      </div>

      <div className="flex flex-col gap-2">
        <label
          htmlFor="zip"
          className="text-base font-semibold text-text-primary"
        >
          Your ZIP code
        </label>
        <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
          <input
            id="zip"
            name="zip"
            type="text"
            inputMode="numeric"
            autoComplete="postal-code"
            pattern="[0-9]{5}"
            maxLength={5}
            value={zip}
            onChange={(e) => {
              const next = e.target.value.replace(/\D/g, "");
              setZip(next);
              if (next.length === 5 && !zipTrackedRef.current) {
                zipTrackedRef.current = true;
                capture("zip_entered", { city_or_zip: next });
              }
            }}
            placeholder="ZIP code"
            className="w-full rounded-xl border border-white/10 bg-elevated px-5 py-3.5 text-lg text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:w-44"
          />
          <p className="text-xs text-text-muted sm:ml-1">
            Eastside only for now.
          </p>
        </div>
      </div>

      <fieldset>
        <legend className="text-sm font-semibold text-text-primary">
          Add a category{" "}
          <span className="font-normal text-text-muted">(optional)</span>
        </legend>
        <div className="mt-3 flex flex-wrap gap-2">
          {CATEGORIES.map((c) => {
            const selected = c.id === category;
            return (
              <button
                key={c.id}
                type="button"
                aria-pressed={selected}
                onClick={() => {
                  const next = selected ? null : c.id;
                  setCategory(next);
                  if (next) capture("category_selected", { category: next });
                }}
                className={
                  "rounded-full border px-5 py-2.5 text-[0.95rem] font-medium transition focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple " +
                  (selected
                    ? "border-brand-purple bg-brand-purple text-text-primary"
                    : "border-white/10 bg-elevated text-text-secondary hover:border-white/30")
                }
              >
                {c.label}
              </button>
            );
          })}
        </div>
      </fieldset>

      <button
        type="submit"
        disabled={!canSubmit || isLoading}
        aria-busy={isLoading}
        className="hx-shimmer mt-1 inline-flex w-full items-center justify-center rounded-2xl bg-brand-purple px-8 py-5 text-lg font-semibold text-text-primary shadow-[0_18px_50px_-16px_rgba(91,45,255,0.9)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-50"
      >
        {isLoading ? "Estimating…" : "Get estimate"}
      </button>

      {error && (
        <p
          role="alert"
          className="flex items-start gap-2.5 rounded-xl border border-error-red/30 bg-error-red/10 px-4 py-3 text-sm text-error-red"
        >
          <svg
            aria-hidden
            viewBox="0 0 20 20"
            className="mt-0.5 h-4 w-4 flex-none"
            fill="none"
            stroke="currentColor"
            strokeWidth={1.7}
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <circle cx="10" cy="10" r="7.5" />
            <path d="M10 6.5v4" />
            <path d="M10 13.5h.01" />
          </svg>
          <span>{error}</span>
        </p>
      )}

      <LocalAvailability zip={zip} enabled={isEastsideZip} />
    </form>
  );
}
