"use client";

/**
 * Authenticated poster dashboard — proof review + task completion (Phase 1).
 *
 * Wires the real backend proof contract:
 *   - task.getProof   (protected) — read the latest proof for the task.
 *   - task.reviewProof (poster)    — approve / reject the SUBMITTED proof.
 *   - task.complete    (poster)    — mark the task COMPLETED once proof is ACCEPTED.
 *
 * Honesty invariants (do NOT violate):
 *   - Reviews only a proof the backend reports as SUBMITTED. No fake proof.
 *   - No verification CLAIMS ("verified", "AI-approved", "authentic"). The
 *     backend runs its own checks on approve; we never present a guarantee.
 *   - Approval only accepts the proof — completion is a separate explicit step.
 *   - Proof photos/videos are private media; we show counts + description only.
 *     Secure in-dashboard photo viewing needs a signed-read endpoint (tracked
 *     backend delta) — we never construct public URLs for private proof media.
 */

import { useState } from "react";
import { trpc } from "@/lib/trpc";
import { capture } from "@/lib/analytics";

function formatWhen(value: string | Date | undefined): string {
  if (!value) return "";
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? "" : d.toLocaleString();
}

export function ProofReviewPanel({
  taskId,
  taskState,
}: {
  taskId: string;
  taskState: string;
}) {
  const utils = trpc.useUtils();
  const proofQuery = trpc.task.getProof.useQuery({ taskId }, { retry: false });

  const reviewMutation = trpc.task.reviewProof.useMutation();
  const completeMutation = trpc.task.complete.useMutation();

  // Two-step confirm state for approve; reject reveals a reason field.
  const [confirmApprove, setConfirmApprove] = useState(false);
  const [rejecting, setRejecting] = useState(false);
  const [reason, setReason] = useState("");
  const [actionError, setActionError] = useState<string | null>(null);

  // No proof yet (getProof throws NOT_FOUND) — nothing to review.
  if (proofQuery.error || !proofQuery.data) return null;

  const proof = proofQuery.data;
  const busy = reviewMutation.isPending || completeMutation.isPending;

  async function refresh() {
    await Promise.all([
      utils.task.getProof.invalidate({ taskId }),
      utils.task.getById.invalidate({ taskId }),
      utils.escrow.getByTaskId.invalidate({ taskId }),
    ]);
  }

  async function approve() {
    setActionError(null);
    try {
      await reviewMutation.mutateAsync({ taskId, approved: true });
      capture("proof_reviewed", { task_id: taskId, authenticated: true });
      setConfirmApprove(false);
      await refresh();
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : "Could not approve the proof.",
      );
    }
  }

  async function reject() {
    setActionError(null);
    if (reason.trim().length === 0) {
      setActionError("Please give the Hustler a reason for the rejection.");
      return;
    }
    try {
      await reviewMutation.mutateAsync({
        taskId,
        approved: false,
        feedback: reason.trim(),
      });
      capture("proof_reviewed", { task_id: taskId, authenticated: true });
      setRejecting(false);
      setReason("");
      await refresh();
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : "Could not reject the proof.",
      );
    }
  }

  async function complete() {
    setActionError(null);
    try {
      await completeMutation.mutateAsync({ taskId });
      capture("task_completed", { task_id: taskId, authenticated: true });
      await refresh();
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : "Could not complete the task.",
      );
    }
  }

  const mediaSummary = `${proof.photos.length} photo${
    proof.photos.length === 1 ? "" : "s"
  } · ${proof.videos.length} video${proof.videos.length === 1 ? "" : "s"}`;

  return (
    <section
      aria-label="Proof review"
      className="mt-5 rounded-xl border border-white/10 bg-elevated/50 p-4"
    >
      <div className="flex items-center justify-between">
        <p className="text-sm font-semibold text-text-primary">Proof review</p>
        <span className="rounded-full border border-white/15 px-2 py-0.5 text-[11px] font-medium uppercase tracking-wide text-text-secondary">
          {proof.state}
        </span>
      </div>

      {/* What the Hustler submitted (description + media counts; no claims). */}
      <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
        <div className="col-span-2">
          <dt className="text-xs uppercase tracking-wide text-text-muted">
            Submitted
          </dt>
          <dd className="mt-0.5 text-text-secondary">
            {formatWhen(proof.submitted_at ?? proof.created_at) || "—"}
          </dd>
        </div>
        <div className="col-span-2">
          <dt className="text-xs uppercase tracking-wide text-text-muted">
            Description
          </dt>
          <dd className="mt-0.5 whitespace-pre-wrap text-text-secondary">
            {proof.description?.trim() || "No description provided."}
          </dd>
        </div>
        <div className="col-span-2">
          <dt className="text-xs uppercase tracking-wide text-text-muted">
            Attached media
          </dt>
          <dd className="mt-0.5 text-text-secondary">{mediaSummary}</dd>
        </div>
      </dl>

      {(proof.photos.length > 0 || proof.videos.length > 0) && (
        <p className="mt-2 text-[11px] text-text-muted">
          Photo and video viewing in the dashboard is coming soon. Review the
          description before deciding.
        </p>
      )}

      {/* SUBMITTED → approve / reject */}
      {proof.state === "SUBMITTED" && (
        <div className="mt-4">
          {!rejecting && !confirmApprove && (
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                disabled={busy}
                onClick={() => {
                  setActionError(null);
                  setConfirmApprove(true);
                }}
                className="inline-flex items-center justify-center rounded-lg bg-brand-purple px-4 py-2 text-sm font-semibold text-text-primary transition hover:bg-brand-purple-light disabled:opacity-50"
              >
                Approve proof
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => {
                  setActionError(null);
                  setRejecting(true);
                }}
                className="inline-flex items-center justify-center rounded-lg border border-white/20 px-4 py-2 text-sm font-semibold text-text-secondary transition hover:border-white/40 disabled:opacity-50"
              >
                Reject proof
              </button>
            </div>
          )}

          {confirmApprove && (
            <div className="rounded-lg border border-white/15 bg-elevated/60 p-3">
              <p className="text-sm text-text-secondary">
                Approve this proof? This accepts the Hustler&apos;s work. You can
                then mark the task complete.
              </p>
              <div className="mt-3 flex gap-2">
                <button
                  type="button"
                  disabled={busy}
                  aria-busy={busy}
                  onClick={approve}
                  className="inline-flex items-center justify-center rounded-lg bg-brand-purple px-4 py-2 text-sm font-semibold text-text-primary transition hover:bg-brand-purple-light disabled:opacity-50"
                >
                  {reviewMutation.isPending ? "Approving…" : "Confirm approve"}
                </button>
                <button
                  type="button"
                  disabled={busy}
                  onClick={() => setConfirmApprove(false)}
                  className="inline-flex items-center justify-center rounded-lg border border-white/20 px-4 py-2 text-sm font-semibold text-text-secondary transition hover:border-white/40 disabled:opacity-50"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}

          {rejecting && (
            <div className="rounded-lg border border-white/15 bg-elevated/60 p-3">
              <label
                htmlFor="proof-reject-reason"
                className="text-sm text-text-secondary"
              >
                Tell the Hustler what needs to change:
              </label>
              <textarea
                id="proof-reject-reason"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                maxLength={1000}
                rows={3}
                className="mt-2 w-full rounded-lg border border-white/20 bg-black/40 px-3 py-2 text-sm text-text-primary"
                placeholder="e.g. The photo doesn't show the finished work."
              />
              <div className="mt-3 flex gap-2">
                <button
                  type="button"
                  disabled={busy}
                  aria-busy={busy}
                  onClick={reject}
                  className="inline-flex items-center justify-center rounded-lg border border-error-red/50 px-4 py-2 text-sm font-semibold text-error-red transition hover:bg-error-red/10 disabled:opacity-50"
                >
                  {reviewMutation.isPending ? "Rejecting…" : "Confirm reject"}
                </button>
                <button
                  type="button"
                  disabled={busy}
                  onClick={() => {
                    setRejecting(false);
                    setReason("");
                  }}
                  className="inline-flex items-center justify-center rounded-lg border border-white/20 px-4 py-2 text-sm font-semibold text-text-secondary transition hover:border-white/40 disabled:opacity-50"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ACCEPTED but task not yet completed → mark complete */}
      {proof.state === "ACCEPTED" && taskState === "PROOF_SUBMITTED" && (
        <div className="mt-4 rounded-lg border border-success-green/40 bg-elevated/60 p-3">
          <p className="text-sm font-semibold text-success-green">
            Proof approved
          </p>
          <p className="mt-1 text-xs text-text-muted">
            Mark the task complete to finish it.
          </p>
          <button
            type="button"
            disabled={busy}
            aria-busy={busy}
            onClick={complete}
            className="mt-3 inline-flex items-center justify-center rounded-lg bg-brand-purple px-4 py-2 text-sm font-semibold text-text-primary transition hover:bg-brand-purple-light disabled:opacity-50"
          >
            {completeMutation.isPending ? "Completing…" : "Mark task complete"}
          </button>
        </div>
      )}

      {/* Rejected → awaiting resubmission */}
      {proof.state === "REJECTED" && (
        <div className="mt-4 rounded-lg border border-white/15 bg-elevated/60 p-3">
          <p className="text-sm text-text-secondary">
            You rejected this proof
            {proof.rejection_reason ? `: “${proof.rejection_reason}”` : "."}
          </p>
          <p className="mt-1 text-xs text-text-muted">
            The Hustler can submit new proof.
          </p>
        </div>
      )}

      {actionError && (
        <p role="alert" className="mt-3 text-sm text-error-red">
          {actionError}
        </p>
      )}
    </section>
  );
}
