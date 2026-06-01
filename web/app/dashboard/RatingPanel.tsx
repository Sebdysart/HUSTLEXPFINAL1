"use client";

/**
 * Authenticated poster dashboard — rate the Hustler (Phase 1).
 *
 * Wires rating.submitRating (protected) + rating.getUserRatingSummary (read).
 *
 * Honesty invariants (do NOT violate):
 *   - Only available after the task is COMPLETED (backend also enforces this and
 *     a 7-day window + one rating per side).
 *   - Shows only the backend's public rating summary — no fabricated reviews or
 *     counts.
 */

import { useState } from "react";
import { trpc } from "@/lib/trpc";
import { capture } from "@/lib/analytics";

export function RatingPanel({
  taskId,
  taskState,
  workerId,
}: {
  taskId: string;
  taskState: string;
  workerId: string | undefined;
}) {
  const utils = trpc.useUtils();
  const submitMutation = trpc.rating.submitRating.useMutation();

  const summaryQuery = trpc.rating.getUserRatingSummary.useQuery(
    { userId: workerId ?? "" },
    { enabled: Boolean(workerId), retry: false },
  );

  const [stars, setStars] = useState(0);
  const [comment, setComment] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  // Only after completion, and only when we know who the worker is.
  if (taskState !== "COMPLETED" || !workerId) return null;

  const summary = summaryQuery.data;

  async function submit() {
    setActionError(null);
    if (stars < 1 || stars > 5) {
      setActionError("Pick a star rating from 1 to 5.");
      return;
    }
    try {
      await submitMutation.mutateAsync({
        taskId,
        stars,
        comment: comment.trim() || undefined,
      });
      capture("rating_submitted", { task_id: taskId, authenticated: true });
      setSubmitted(true);
      if (workerId) {
        await utils.rating.getUserRatingSummary.invalidate({ userId: workerId });
      }
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : "Could not submit your rating.",
      );
    }
  }

  return (
    <section
      aria-label="Rate the Hustler"
      className="mt-5 rounded-xl border border-white/10 bg-elevated/50 p-4"
    >
      <div className="flex items-center justify-between">
        <p className="text-sm font-semibold text-text-primary">
          Rate the Hustler
        </p>
        {summary && summary.total_ratings > 0 && (
          <span className="text-xs text-text-muted">
            {summary.avg_rating.toFixed(1)} ★ · {summary.total_ratings} rating
            {summary.total_ratings === 1 ? "" : "s"}
          </span>
        )}
      </div>

      {submitted ? (
        <p
          role="status"
          aria-live="polite"
          className="mt-3 rounded-lg border border-success-green/40 bg-elevated/60 p-3 text-sm text-success-green"
        >
          Thanks — your rating was submitted.
        </p>
      ) : (
        <div className="mt-3">
          <div
            role="radiogroup"
            aria-label="Star rating"
            className="flex gap-1"
          >
            {[1, 2, 3, 4, 5].map((n) => (
              <button
                key={n}
                type="button"
                role="radio"
                aria-checked={stars === n}
                aria-label={`${n} star${n === 1 ? "" : "s"}`}
                onClick={() => setStars(n)}
                className={`text-2xl leading-none transition ${
                  n <= stars ? "text-brand-purple" : "text-text-muted"
                }`}
              >
                ★
              </button>
            ))}
          </div>

          <textarea
            value={comment}
            onChange={(e) => setComment(e.target.value)}
            maxLength={500}
            rows={3}
            placeholder="Add a comment (optional)"
            className="mt-3 w-full rounded-lg border border-white/20 bg-black/40 px-3 py-2 text-sm text-text-primary"
          />

          <button
            type="button"
            disabled={submitMutation.isPending}
            aria-busy={submitMutation.isPending}
            onClick={submit}
            className="mt-3 inline-flex items-center justify-center rounded-lg bg-brand-purple px-4 py-2 text-sm font-semibold text-text-primary transition hover:bg-brand-purple-light disabled:opacity-50"
          >
            {submitMutation.isPending ? "Submitting…" : "Submit rating"}
          </button>

          {actionError && (
            <p role="alert" className="mt-3 text-sm text-error-red">
              {actionError}
            </p>
          )}
        </div>
      )}
    </section>
  );
}
