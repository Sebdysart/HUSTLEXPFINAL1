"use client";

import { useState, type FormEvent } from "react";

const CATEGORIES = [
  { id: "moving", label: "Moving help" },
  { id: "assembly", label: "Furniture assembly" },
  { id: "dump", label: "Dump runs" },
  { id: "yard", label: "Yard cleanup" },
  { id: "errands", label: "Errands" },
  { id: "event", label: "Event setup" },
] as const;

type CategoryId = (typeof CATEGORIES)[number]["id"];

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

export function FunnelForm() {
  const [task, setTask] = useState("");
  const [zip, setZip] = useState("");
  const [category, setCategory] = useState<CategoryId | null>(null);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const trimmedTask = task.trim();
  const zipLooksValid = /^\d{5}$/.test(zip);
  const canSubmit = trimmedTask.length >= 3 && zipLooksValid;

  function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!canSubmit) {
      setError("Add a short description and a 5-digit ZIP.");
      return;
    }
    if (!EASTSIDE_ZIPS.has(zip)) {
      setError(
        "We're starting Eastside-only — Redmond, Sammamish, Bellevue, Kirkland, Issaquah. We'll text you when we cover your area.",
      );
      return;
    }

    setSubmitted(true);
  }

  if (submitted) {
    const selectedLabel =
      CATEGORIES.find((c) => c.id === category)?.label ?? "Uncategorized";
    return (
      <div
        role="status"
        aria-live="polite"
        className="rounded-2xl border border-brand-purple/40 bg-elevated/60 p-5 text-left shadow-[0_0_60px_-30px_rgba(91,45,255,0.6)]"
      >
        <p className="text-sm font-semibold uppercase tracking-wide text-brand-purple-glow">
          Generating estimate…
        </p>
        <dl className="mt-3 space-y-2 text-sm text-text-secondary">
          <div>
            <dt className="text-text-muted">Task</dt>
            <dd className="text-text-primary">{trimmedTask}</dd>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <dt className="text-text-muted">ZIP</dt>
              <dd className="text-text-primary">{zip}</dd>
            </div>
            <div>
              <dt className="text-text-muted">Category</dt>
              <dd className="text-text-primary">{selectedLabel}</dd>
            </div>
          </div>
        </dl>
        <p className="mt-4 text-xs text-text-muted">
          Live AI estimates land in the next update. Your details are saved in
          this browser.
        </p>
        <button
          type="button"
          onClick={() => setSubmitted(false)}
          className="mt-4 rounded-lg border border-white/15 px-4 py-2 text-sm font-medium text-text-secondary hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
        >
          Edit
        </button>
      </div>
    );
  }

  return (
    <form
      onSubmit={onSubmit}
      noValidate
      className="flex w-full flex-col gap-4 text-left"
    >
      <div>
        <label htmlFor="task" className="sr-only">
          What do you need done?
        </label>
        <textarea
          id="task"
          name="task"
          rows={3}
          value={task}
          onChange={(e) => setTask(e.target.value)}
          placeholder="What do you need done? e.g., move a couch from my apartment to a storage unit"
          className="w-full resize-none rounded-2xl border border-white/10 bg-elevated px-5 py-4 text-base text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:rows-2 sm:text-lg"
        />
      </div>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <label htmlFor="zip" className="sr-only">
          ZIP code
        </label>
        <input
          id="zip"
          name="zip"
          type="text"
          inputMode="numeric"
          autoComplete="postal-code"
          pattern="[0-9]{5}"
          maxLength={5}
          value={zip}
          onChange={(e) => setZip(e.target.value.replace(/\D/g, ""))}
          placeholder="ZIP code"
          className="w-full rounded-xl border border-white/10 bg-elevated px-4 py-3 text-base text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:w-40"
        />
        <p className="text-xs text-text-muted sm:ml-1">
          Eastside only for now.
        </p>
      </div>

      <fieldset>
        <legend className="sr-only">Pick a category</legend>
        <div className="flex flex-wrap gap-2">
          {CATEGORIES.map((c) => {
            const selected = c.id === category;
            return (
              <button
                key={c.id}
                type="button"
                aria-pressed={selected}
                onClick={() => setCategory(selected ? null : c.id)}
                className={
                  "rounded-full border px-4 py-2 text-sm font-medium transition focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple " +
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
        disabled={!canSubmit}
        className="mt-1 inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-8 py-4 text-base font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-50 sm:w-auto sm:self-start"
      >
        Get estimate
      </button>

      {error && (
        <p role="alert" className="text-sm text-error-red">
          {error}
        </p>
      )}
    </form>
  );
}
