"use client";

import { useRef, useState, type FormEvent } from "react";
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  type AuthError,
} from "firebase/auth";
import { firebaseAuth, getIdToken } from "@/lib/firebase";
import { trpc } from "@/lib/trpc";
import { useAuth } from "@/providers/auth-provider";
import { FundingStep } from "@/components/funding-step";
import { capture } from "@/lib/analytics";

// C6: Dispatch section. Lives at the bottom of the C4 result panel.
//
// Flow:
//   1. Anonymous user has a draft (from C4) in the result panel.
//   2. Click "Dispatch task" → if not signed in, show auth gate.
//   3. Auth gate collects email/password (+ name/DOB on sign-up), requires
//      Terms/Privacy clickwrap, and creates a Firebase account.
//   4. After auth: call user.register (idempotent — returns existing user
//      for sign-ins), then task.create with fields mapped from the draft.
//   5. Show post-create state. Draft is only cleared on success.
//
// Out of scope for C6: Stripe, payment intents, Hustler dispatch, dashboard,
// and any liquidity/trust/dispatch claims (no "going live", no fake supply).

export type DispatchDraft = {
  title: string;
  cleanedDescription: string;
  category: string;
  recommendedPriceCents: number;
  zip: string;
  templateSlug: string | undefined;
};

type Phase = "idle" | "auth" | "submitting" | "created";

type CreatedTask = {
  id: string;
  title: string;
};

const CREATED_TASK_STORAGE_KEY = "hustlexp.lastTaskId.v1";

export function DispatchSection({
  draft,
  onCreated,
  onFunded,
  resumeCreated,
  resumeFunding,
}: {
  draft: DispatchDraft;
  onCreated: (task: CreatedTask) => void;
  onFunded?: () => void;
  resumeCreated?: CreatedTask;
  resumeFunding?: {
    escrowId: string;
    paymentIntentId: string;
    clientSecret: string;
  };
}) {
  const { user, loading: authLoading } = useAuth();
  const [phase, setPhase] = useState<Phase>(
    resumeCreated ? "created" : "idle",
  );
  const [createdTask, setCreatedTask] = useState<CreatedTask | null>(
    resumeCreated ?? null,
  );
  const [dispatchError, setDispatchError] = useState<string | null>(null);

  const registerMutation = trpc.user.register.useMutation();
  const updateProfileMutation = trpc.user.updateProfile.useMutation();
  const createTaskMutation = trpc.task.create.useMutation();

  async function runDispatch() {
    setDispatchError(null);
    setPhase("submitting");
    try {
      const idToken = await getIdToken(true);
      const fbUser = firebaseAuth().currentUser;
      if (!idToken || !fbUser) {
        throw new Error("Sign-in lost. Please try again.");
      }

      // Best-effort idempotent registration. The backend returns the existing
      // user if they're already registered, so this is safe to call every time.
      // We intentionally pass defaultMode='poster' on first-time creation;
      // the backend ignores it for already-existing users.
      const registered = await registerMutation.mutateAsync({
        idToken,
        firebaseUid: fbUser.uid,
        email: fbUser.email ?? "",
        fullName: fbUser.displayName ?? fbUser.email?.split("@")[0] ?? "Poster",
        dateOfBirth: getStoredDOB() ?? "2000-01-01",
        defaultMode: "poster",
      });

      // If an existing account was registered as 'hustler', flip to 'poster'
      // so task.create (posterProcedure) accepts the call. updateProfile blocks
      // role switches when the user has active tasks — that error surfaces
      // verbatim and the dispatch fails cleanly without a half-created task.
      if (registered.role !== "poster") {
        await updateProfileMutation.mutateAsync({ defaultMode: "poster" });
      }

      capture("task_create_started", {
        category: draft.templateSlug,
        task_price_cents: draft.recommendedPriceCents,
        city_or_zip: draft.zip,
      });

      const task = await createTaskMutation.mutateAsync({
        title: draft.title.slice(0, 255),
        description: draft.cleanedDescription,
        price: draft.recommendedPriceCents,
        location: draft.zip,
        templateSlug: draft.templateSlug,
        requiresProof: true,
      });

      const created = { id: task.id, title: task.title ?? draft.title };
      setCreatedTask(created);
      setPhase("created");
      capture("task_create_succeeded", {
        task_id: task.id,
        task_price_cents: draft.recommendedPriceCents,
        category: draft.templateSlug,
        authenticated: true,
      });
      try {
        window.localStorage.setItem(
          CREATED_TASK_STORAGE_KEY,
          JSON.stringify({ id: created.id, createdAt: new Date().toISOString() }),
        );
      } catch {
        // localStorage may be unavailable; in-memory state still drives the UI.
      }
      onCreated(created);
    } catch (err: unknown) {
      const msg =
        (err as { message?: string } | undefined)?.message ??
        "Couldn't dispatch the task. Try again in a moment.";
      const code =
        (err as { data?: { code?: string } } | undefined)?.data?.code ?? "";
      capture("task_create_failed", { error_code: code || undefined });
      if (code === "FORBIDDEN") {
        setDispatchError(
          "Your account isn't set up as a Poster yet. Try signing out and back in.",
        );
      } else {
        setDispatchError(msg);
      }
      setPhase(user ? "idle" : "auth");
    }
  }

  if (phase === "created" && createdTask) {
    return (
      <div className="mt-6 rounded-2xl border border-brand-purple/40 bg-elevated/60 p-5 text-left">
        <p
          className="text-sm font-semibold uppercase tracking-wide text-brand-purple-glow"
          role="status"
          aria-live="polite"
        >
          Task draft created
        </p>
        <h3 className="mt-2 text-lg font-semibold text-text-primary">
          {createdTask.title}
        </h3>
        <FundingStep
          taskId={createdTask.id}
          priceCents={draft.recommendedPriceCents}
          onFunded={() => {
            onFunded?.();
          }}
          resumeFrom={resumeFunding}
        />
      </div>
    );
  }

  if (phase === "idle") {
    return (
      <div className="mt-6 border-t border-white/10 pt-5">
        <button
          type="button"
          onClick={() => {
            setDispatchError(null);
            setPhase("auth");
            capture("dispatch_clicked", { authenticated: !!user });
          }}
          disabled={authLoading}
          className="inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-6 py-3 text-base font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-50 sm:w-auto"
        >
          Dispatch task
        </button>
        <p className="mt-2 text-xs text-text-muted">
          You&apos;ll review and confirm before anything is charged.
        </p>
      </div>
    );
  }

  // phase === 'auth' OR 'submitting'
  return (
    <AuthGate
      isSignedIn={!!user}
      isSubmitting={phase === "submitting"}
      submissionError={dispatchError}
      onCancel={() => {
        setDispatchError(null);
        setPhase("idle");
      }}
      onReady={runDispatch}
    />
  );
}

// In-memory cache so the DOB stays present through a Firebase sign-up
// round-trip even though the form unmounts and remounts during phase changes.
let _dobCache: string | null = null;
function setStoredDOB(dob: string) {
  _dobCache = dob;
}
function getStoredDOB(): string | null {
  return _dobCache;
}

function AuthGate({
  isSignedIn,
  isSubmitting,
  submissionError,
  onCancel,
  onReady,
}: {
  isSignedIn: boolean;
  isSubmitting: boolean;
  submissionError: string | null;
  onCancel: () => void;
  onReady: () => void;
}) {
  const [mode, setMode] = useState<"signup" | "signin">("signup");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [dob, setDob] = useState("");
  const [agreed, setAgreed] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const termsTrackedRef = useRef(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!agreed) {
      setError("Please accept the Terms and Privacy Policy to continue.");
      return;
    }

    if (!isSignedIn) {
      if (!email || !password) {
        setError("Email and password are required.");
        return;
      }
      if (mode === "signup") {
        if (!fullName.trim()) {
          setError("Add the name you'd like on the task post.");
          return;
        }
        if (!/^\d{4}-\d{2}-\d{2}$/.test(dob)) {
          setError("Date of birth is required (YYYY-MM-DD).");
          return;
        }
      }
      capture("signup_started", { authenticated: false });
      setBusy(true);
      try {
        if (mode === "signup") {
          setStoredDOB(dob);
          await createUserWithEmailAndPassword(firebaseAuth(), email, password);
          capture("signup_completed", { authenticated: true });
        } else {
          await signInWithEmailAndPassword(firebaseAuth(), email, password);
        }
      } catch (err) {
        setError(((err as AuthError)?.message) ?? "Sign-in failed.");
        setBusy(false);
        return;
      }
      setBusy(false);
    }

    onReady();
  }

  return (
    <form
      onSubmit={onSubmit}
      className="mt-6 flex flex-col gap-3 rounded-2xl border border-brand-purple/40 bg-elevated/60 p-5 text-left"
      noValidate
    >
      <p className="text-sm font-semibold uppercase tracking-wide text-brand-purple-glow">
        Sign in to dispatch
      </p>
      <h3 className="text-lg font-semibold text-text-primary">
        Create your account to dispatch this task
      </h3>
      <p className="text-xs text-text-muted">
        Your draft stays here until your account is ready and you confirm.
      </p>

      {!isSignedIn && (
        <>
          <div className="flex gap-2 text-xs">
            <button
              type="button"
              onClick={() => setMode("signup")}
              aria-pressed={mode === "signup"}
              className={
                "rounded-full border px-3 py-1 transition " +
                (mode === "signup"
                  ? "border-brand-purple bg-brand-purple text-text-primary"
                  : "border-white/15 bg-elevated text-text-secondary hover:border-white/30")
              }
            >
              New account
            </button>
            <button
              type="button"
              onClick={() => setMode("signin")}
              aria-pressed={mode === "signin"}
              className={
                "rounded-full border px-3 py-1 transition " +
                (mode === "signin"
                  ? "border-brand-purple bg-brand-purple text-text-primary"
                  : "border-white/15 bg-elevated text-text-secondary hover:border-white/30")
              }
            >
              I have an account
            </button>
          </div>

          <label className="flex flex-col gap-1 text-xs text-text-muted">
            Email
            <input
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="rounded-lg border border-white/15 bg-elevated px-3 py-2 text-sm text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none"
              placeholder="you@example.com"
            />
          </label>
          <label className="flex flex-col gap-1 text-xs text-text-muted">
            Password
            <input
              type="password"
              autoComplete={mode === "signup" ? "new-password" : "current-password"}
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="rounded-lg border border-white/15 bg-elevated px-3 py-2 text-sm text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none"
            />
          </label>

          {mode === "signup" && (
            <>
              <label className="flex flex-col gap-1 text-xs text-text-muted">
                Your name
                <input
                  type="text"
                  autoComplete="name"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="rounded-lg border border-white/15 bg-elevated px-3 py-2 text-sm text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none"
                  placeholder="Jane Smith"
                />
              </label>
              <label className="flex flex-col gap-1 text-xs text-text-muted">
                Date of birth
                <input
                  type="date"
                  autoComplete="bday"
                  required
                  value={dob}
                  onChange={(e) => setDob(e.target.value)}
                  className="rounded-lg border border-white/15 bg-elevated px-3 py-2 text-sm text-text-primary focus:border-brand-purple focus:outline-none"
                  max={new Date(
                    Date.UTC(new Date().getUTCFullYear() - 13, 0, 1),
                  )
                    .toISOString()
                    .slice(0, 10)}
                />
                <span className="text-text-muted">
                  Required by law (COPPA). You must be at least 13.
                </span>
              </label>
            </>
          )}
        </>
      )}

      <label className="mt-1 flex items-start gap-2 text-xs text-text-secondary">
        <input
          type="checkbox"
          required
          checked={agreed}
          onChange={(e) => {
            setAgreed(e.target.checked);
            if (e.target.checked && !termsTrackedRef.current) {
              termsTrackedRef.current = true;
              capture("terms_accepted");
            }
          }}
          className="mt-0.5 h-4 w-4 rounded border-white/25 bg-elevated text-brand-purple focus:ring-brand-purple"
        />
        <span>I agree to the Terms and Privacy Policy</span>
      </label>

      {(error || submissionError) && (
        <p role="alert" className="text-sm text-error-red">
          {error ?? submissionError}
        </p>
      )}

      <div className="mt-1 flex flex-wrap gap-2">
        <button
          type="submit"
          disabled={busy || isSubmitting}
          aria-busy={busy || isSubmitting}
          className="inline-flex items-center justify-center rounded-xl bg-brand-purple px-5 py-2.5 text-sm font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-50"
        >
          {busy
            ? "Signing in…"
            : isSubmitting
            ? "Dispatching…"
            : "Dispatch task"}
        </button>
        <button
          type="button"
          onClick={onCancel}
          disabled={busy || isSubmitting}
          className="inline-flex items-center justify-center rounded-xl border border-white/15 px-4 py-2.5 text-sm font-medium text-text-secondary hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple disabled:opacity-50"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
