"use client";

/**
 * Authenticated poster dashboard — escrow actions (Phase 1).
 *
 * Refund is fully server-side (escrow.refund creates the Stripe refund) and is
 * wired here. Self-service RELEASE is intentionally NOT exposed: escrow.release
 * requires a caller-minted stripeTransferId and a browser cannot safely create
 * a Stripe transfer — the real path is a server-side transfer (tracked backend
 * delta). We show release status read-only.
 *
 * Money-movement invariants (do NOT violate):
 *   - The backend escrow.state is the only truth — never infer success from the
 *     click. We refetch escrow after the mutation and render that state.
 *   - Refund is irreversible and reverses the Hustler's XP — two-step confirm.
 *   - Never show "released" unless escrow.state === 'RELEASED'.
 */

import { useState } from "react";
import { trpc } from "@/lib/trpc";
import { capture } from "@/lib/analytics";

function formatPrice(cents: number | undefined): string {
  if (typeof cents !== "number" || !Number.isFinite(cents)) return "—";
  return `$${(cents / 100).toFixed(2)}`;
}

export function EscrowPanel({
  taskId,
  taskState,
}: {
  taskId: string;
  taskState: string;
}) {
  const utils = trpc.useUtils();
  const escrowQuery = trpc.escrow.getByTaskId.useQuery(
    { taskId },
    { retry: false },
  );
  const refundMutation = trpc.escrow.refund.useMutation();

  const [confirmRefund, setConfirmRefund] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  if (escrowQuery.error || !escrowQuery.data) return null;

  const escrow = escrowQuery.data;
  const state = escrow.state;
  const amount = escrow.amount;

  // Refund is allowed by the backend only while FUNDED.
  const canRefund = state === "FUNDED";
  const completedAwaitingRelease = taskState === "COMPLETED" && state === "FUNDED";
  const released = state === "RELEASED";
  const refunded = state === "REFUNDED" || state === "REFUND_PARTIAL";

  // Nothing actionable or noteworthy to add beyond the timeline.
  if (!canRefund && !released && !refunded) return null;

  async function refund() {
    setActionError(null);
    try {
      await refundMutation.mutateAsync({ escrowId: escrow.id });
      capture("escrow_refunded", {
        task_id: taskId,
        escrow_state: "REFUNDED",
        authenticated: true,
      });
      setConfirmRefund(false);
      await Promise.all([
        utils.escrow.getByTaskId.invalidate({ taskId }),
        utils.task.getById.invalidate({ taskId }),
      ]);
    } catch (err) {
      setActionError(
        err instanceof Error
          ? err.message
          : "Could not process the refund. Please try again.",
      );
    }
  }

  return (
    <section
      aria-label="Payment actions"
      className="mt-5 rounded-xl border border-white/10 bg-elevated/50 p-4"
    >
      <p className="text-sm font-semibold text-text-primary">Payment</p>

      {released && (
        <p className="mt-2 text-sm text-success-green">
          {formatPrice(escrow.release_amount ?? amount)} released to the Hustler.
        </p>
      )}

      {refunded && (
        <p className="mt-2 text-sm text-text-secondary">
          {formatPrice(escrow.refund_amount ?? amount)} refunded to your original
          payment method.
        </p>
      )}

      {completedAwaitingRelease && (
        <p className="mt-2 text-sm text-text-secondary">
          Payment release is processed by HustleXP — a self-service release
          control is coming soon.
        </p>
      )}

      {canRefund && (
        <div className="mt-3">
          {!confirmRefund ? (
            <button
              type="button"
              onClick={() => {
                setActionError(null);
                setConfirmRefund(true);
              }}
              className="inline-flex items-center justify-center rounded-lg border border-error-red/50 px-4 py-2 text-sm font-semibold text-error-red transition hover:bg-error-red/10"
            >
              Refund {formatPrice(amount)}
            </button>
          ) : (
            <div className="rounded-lg border border-error-red/40 bg-elevated/60 p-3">
              <p className="text-sm text-text-secondary">
                Refund {formatPrice(amount)} to your original payment method?
                This cannot be undone, and the Hustler&apos;s XP for this task
                will be reversed.
              </p>
              <div className="mt-3 flex gap-2">
                <button
                  type="button"
                  disabled={refundMutation.isPending}
                  aria-busy={refundMutation.isPending}
                  onClick={refund}
                  className="inline-flex items-center justify-center rounded-lg border border-error-red/50 px-4 py-2 text-sm font-semibold text-error-red transition hover:bg-error-red/10 disabled:opacity-50"
                >
                  {refundMutation.isPending ? "Refunding…" : "Confirm refund"}
                </button>
                <button
                  type="button"
                  disabled={refundMutation.isPending}
                  onClick={() => setConfirmRefund(false)}
                  className="inline-flex items-center justify-center rounded-lg border border-white/20 px-4 py-2 text-sm font-semibold text-text-secondary transition hover:border-white/40 disabled:opacity-50"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
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
