"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { Elements, PaymentElement, useStripe, useElements } from "@stripe/react-stripe-js";
import type { Stripe, StripeElementsOptions } from "@stripe/stripe-js";
import { trpc } from "@/lib/trpc";
import { getStripe, isStripeConfigured } from "@/lib/stripe";
import { capture } from "@/lib/analytics";

// C7: Stripe Elements funding step. Mounts inside the post-create panel of
// dispatch-section.tsx once task.create has returned a task id.
//
// State machine (UI label, not literal phase strings):
//   creating-intent  → escrow.createPaymentIntent
//   collecting       → <Elements> + <PaymentElement>, awaiting submit
//   confirming       → stripe.confirmPayment(...) in flight
//   polling          → waiting for backend escrow.state === 'FUNDED'
//                      (Stripe success alone is NOT enough — backend is truth)
//   funded           → "Task funded. Next: Hustler matching."
//   error            → recoverable failure with Retry
//
// Honest invariants enforced by this component:
//   - The "Task funded" copy is gated on backend FUNDED state, never on
//     Stripe paymentIntent.status alone.
//   - localStorage["hustlexp.funding.v1"] persists enough state that a
//     refresh mid-flow lands the user back in the right phase.
//   - Single-shot createPaymentIntent guard (useRef) so React 19 strict-mode
//     double-mount doesn't double-fire the mutation.
//   - No "matched", "on the way", "going live", "background-check",
//     "protection", "guarantee", or "insured" copy anywhere.

export const FUNDING_STORAGE_KEY = "hustlexp.funding.v1";
const FUNDING_TTL_MS = 24 * 60 * 60 * 1000; // mirror draft TTL
const POLL_INTERVAL_MS = 1000;
const POLL_DEADLINE_MS = 20_000;

export type PersistedFunding = {
  taskId: string;
  escrowId: string;
  clientSecret: string;
  paymentIntentId: string;
  status: "pending" | "confirming" | "funded";
  createdAt: string;
};

export function readPersistedFunding(): PersistedFunding | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(FUNDING_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as PersistedFunding;
    if (
      !parsed?.taskId ||
      !parsed?.escrowId ||
      !parsed?.clientSecret ||
      !parsed?.paymentIntentId ||
      !parsed?.createdAt
    ) {
      window.localStorage.removeItem(FUNDING_STORAGE_KEY);
      return null;
    }
    const ageMs = Date.now() - new Date(parsed.createdAt).getTime();
    if (!Number.isFinite(ageMs) || ageMs > FUNDING_TTL_MS) {
      window.localStorage.removeItem(FUNDING_STORAGE_KEY);
      return null;
    }
    return parsed;
  } catch {
    try {
      window.localStorage.removeItem(FUNDING_STORAGE_KEY);
    } catch {
      /* ignore */
    }
    return null;
  }
}

function writePersistedFunding(p: PersistedFunding) {
  try {
    window.localStorage.setItem(FUNDING_STORAGE_KEY, JSON.stringify(p));
  } catch {
    /* localStorage may be unavailable; in-memory state still drives the UI */
  }
}

type Phase =
  | "creating-intent"
  | "collecting"
  | "confirming"
  | "polling"
  | "funded"
  | "error";

export function FundingStep({
  taskId,
  priceCents,
  onFunded,
  resumeFrom,
}: {
  taskId: string;
  priceCents: number;
  onFunded: () => void;
  resumeFrom?: {
    escrowId: string;
    paymentIntentId: string;
    clientSecret: string;
  };
}) {
  const [stripeInstance, setStripeInstance] = useState<Stripe | null>(null);
  const [phase, setPhase] = useState<Phase>(
    resumeFrom ? "collecting" : "creating-intent",
  );
  const [escrowId, setEscrowId] = useState<string | null>(
    resumeFrom?.escrowId ?? null,
  );
  const [clientSecret, setClientSecret] = useState<string | null>(
    resumeFrom?.clientSecret ?? null,
  );
  const [paymentIntentId, setPaymentIntentId] = useState<string | null>(
    resumeFrom?.paymentIntentId ?? null,
  );
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const createFiredRef = useRef(false);
  const fallbackFiredRef = useRef(false);

  const createIntentMutation = trpc.escrow.createPaymentIntent.useMutation();
  const confirmFundingMutation = trpc.escrow.confirmFunding.useMutation();

  // Single-shot createPaymentIntent mount. Skip if resumeFrom is provided.
  // Effect intentionally drives React state from external systems (env, mutation
  // result, persisted storage), so the set-state-in-effect rule is suppressed.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    if (resumeFrom) return;
    if (createFiredRef.current) return;
    createFiredRef.current = true;
    if (!isStripeConfigured()) {
      setErrorMessage("Payment is not configured for this environment.");
      setPhase("error");
      return;
    }
    createIntentMutation
      .mutateAsync({ taskId })
      .then((res) => {
        setEscrowId(res.escrowId);
        setClientSecret(res.clientSecret);
        setPaymentIntentId(res.paymentIntentId);
        writePersistedFunding({
          taskId,
          escrowId: res.escrowId,
          clientSecret: res.clientSecret,
          paymentIntentId: res.paymentIntentId,
          status: "pending",
          createdAt: new Date().toISOString(),
        });
        setPhase("collecting");
        capture("payment_intent_created", { task_id: taskId });
      })
      .catch((err: unknown) => {
        const code = (err as { data?: { code?: string } } | undefined)?.data
          ?.code;
        const msg =
          (err as { message?: string } | undefined)?.message ??
          "We couldn't set up the payment. Try again in a moment.";
        if (code === "PRECONDITION_FAILED") {
          // Already funded for this task — treat as success.
          setPhase("polling");
        } else {
          setErrorMessage(msg);
          setPhase("error");
        }
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [taskId, resumeFrom]);
  /* eslint-enable react-hooks/set-state-in-effect */

  // Load Stripe.js once on the client.
  useEffect(() => {
    let active = true;
    getStripe().then((s) => {
      if (active) setStripeInstance(s);
    });
    return () => {
      active = false;
    };
  }, []);

  // Handle Stripe redirect-flow return: ?payment_intent=...&payment_intent_client_secret=...
  // Captures 3DS / Apple Pay / Link / bank-redirect bounce-backs. Effect
  // syncs URL state into React state — set-state-in-effect rule suppressed.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    if (typeof window === "undefined") return;
    const params = new URLSearchParams(window.location.search);
    const piParam = params.get("payment_intent");
    const csParam = params.get("payment_intent_client_secret");
    if (!piParam || !csParam) return;
    const stored = readPersistedFunding();
    if (!stored || stored.taskId !== taskId) return;
    if (stored.paymentIntentId !== piParam) return;
    // Jump to polling — backend webhook will (or has) transitioned PENDING→FUNDED.
    writePersistedFunding({ ...stored, status: "confirming" });
    setEscrowId(stored.escrowId);
    setClientSecret(stored.clientSecret);
    setPaymentIntentId(stored.paymentIntentId);
    setPhase("polling");
    // Strip query params so a subsequent refresh is clean.
    try {
      window.history.replaceState(
        {},
        "",
        window.location.pathname + window.location.hash,
      );
    } catch {
      /* ignore */
    }
  }, [taskId]);
  /* eslint-enable react-hooks/set-state-in-effect */

  // Poll backend escrow.getByTaskId while in 'polling' phase.
  const getByTaskIdQuery = trpc.escrow.getByTaskId.useQuery(
    { taskId },
    {
      enabled: phase === "polling",
      refetchInterval: phase === "polling" ? POLL_INTERVAL_MS : false,
      refetchIntervalInBackground: false,
      retry: false,
    },
  );

  // Promote to 'funded' ONLY when the backend reports state === 'FUNDED'.
  // Effect syncs server query results into React state — set-state-in-effect
  // rule suppressed.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    if (phase !== "polling") return;
    const backendState = (getByTaskIdQuery.data as { state?: string } | undefined)
      ?.state;
    if (backendState === "FUNDED") {
      const stored = readPersistedFunding();
      if (stored) writePersistedFunding({ ...stored, status: "funded" });
      setPhase("funded");
      capture("payment_funded_backend", {
        task_id: taskId,
        escrow_state: "FUNDED",
      });
      onFunded();
    }
  }, [phase, getByTaskIdQuery.data, onFunded, taskId]);
  /* eslint-enable react-hooks/set-state-in-effect */

  // After POLL_DEADLINE_MS in polling without FUNDED, fire confirmFunding once
  // as a webhook-down fallback. Backend still independently verifies the PI
  // with Stripe before transitioning state, so a malicious client cannot fake
  // FUNDED via this fallback.
  const pollStartRef = useRef<number | null>(null);
  useEffect(() => {
    if (phase !== "polling") {
      pollStartRef.current = null;
      return;
    }
    if (pollStartRef.current === null) {
      pollStartRef.current = Date.now();
    }
    if (fallbackFiredRef.current) return;
    if (!escrowId || !paymentIntentId) return;

    const timer = window.setTimeout(() => {
      if (phase !== "polling" || fallbackFiredRef.current) return;
      fallbackFiredRef.current = true;
      confirmFundingMutation
        .mutateAsync({
          escrowId,
          stripePaymentIntentId: paymentIntentId,
        })
        .then(() => {
          // Do NOT advance phase from the mutation return — keep polling
          // until getByTaskId confirms FUNDED. The mutation's job is just
          // to nudge the backend to verify with Stripe and transition.
          void getByTaskIdQuery.refetch();
        })
        .catch((err: unknown) => {
          const code = (err as { data?: { code?: string } } | undefined)?.data
            ?.code;
          const msg =
            (err as { message?: string } | undefined)?.message ??
            "Payment received but funding is still settling. Refresh in a moment.";
          capture("payment_failed", {
            task_id: taskId,
            error_code: code || undefined,
          });
          setErrorMessage(msg);
          // Stay in 'polling' for one more refetch attempt before giving up.
          window.setTimeout(() => {
            if (phase === "polling") {
              setPhase("error");
            }
          }, POLL_INTERVAL_MS * 5);
        });
    }, POLL_DEADLINE_MS);
    return () => window.clearTimeout(timer);
  }, [
    phase,
    escrowId,
    paymentIntentId,
    confirmFundingMutation,
    getByTaskIdQuery,
    taskId,
  ]);

  const elementsOptions: StripeElementsOptions | null = useMemo(() => {
    if (!clientSecret) return null;
    return {
      clientSecret,
      appearance: {
        theme: "night",
        variables: {
          colorPrimary: "#5b2dff",
          colorBackground: "#0c0a18",
          colorText: "#f5f5fa",
        },
      },
    };
  }, [clientSecret]);

  if (phase === "creating-intent") {
    return (
      <div className="mt-4 rounded-xl border border-white/10 bg-elevated/50 p-4 text-sm text-text-secondary">
        Preparing secure payment…
      </div>
    );
  }

  if (phase === "funded") {
    return (
      <div
        role="status"
        aria-live="polite"
        className="mt-4 rounded-xl border border-success-green/40 bg-elevated/60 p-4"
      >
        <p className="text-sm font-semibold text-success-green">
          Task funded. Next: Hustler matching.
        </p>
        <p className="mt-2 text-xs text-text-muted">
          You&apos;ll get an update when a Hustler accepts. Funds stay in escrow
          until you approve the proof.
        </p>
        <Link
          href="/dashboard"
          className="mt-3 inline-flex items-center justify-center rounded-lg border border-white/15 px-4 py-2 text-sm font-medium text-text-secondary transition hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
        >
          View task dashboard
        </Link>
      </div>
    );
  }

  if (phase === "error") {
    return (
      <div className="mt-4 rounded-xl border border-error-red/40 bg-elevated/60 p-4">
        <p role="alert" className="text-sm font-semibold text-error-red">
          {errorMessage ?? "Something went wrong with payment."}
        </p>
        <button
          type="button"
          onClick={() => {
            setErrorMessage(null);
            fallbackFiredRef.current = false;
            if (clientSecret) {
              setPhase("collecting");
            } else {
              createFiredRef.current = false;
              setPhase("creating-intent");
            }
          }}
          className="mt-3 inline-flex items-center justify-center rounded-lg border border-white/15 px-4 py-2 text-sm font-medium text-text-secondary hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
        >
          Try again
        </button>
      </div>
    );
  }

  if (!stripeInstance || !elementsOptions || !clientSecret) {
    return (
      <div className="mt-4 rounded-xl border border-white/10 bg-elevated/50 p-4 text-sm text-text-secondary">
        Loading secure payment…
      </div>
    );
  }

  return (
    <div className="mt-4 rounded-xl border border-brand-purple/40 bg-elevated/60 p-5">
      <p className="text-sm font-semibold uppercase tracking-wide text-brand-purple-glow">
        Secure payment
      </p>
      <p className="mt-1 text-xs text-text-muted">
        Your card is charged only through Stripe. Funds are released after proof
        is reviewed.
      </p>
      <Elements stripe={stripeInstance} options={elementsOptions}>
        <PaymentForm
          phase={phase}
          priceCents={priceCents}
          onConfirming={() => {
            setPhase("confirming");
            const stored = readPersistedFunding();
            if (stored) writePersistedFunding({ ...stored, status: "confirming" });
            capture("payment_started", {
              task_id: taskId,
              task_price_cents: priceCents,
            });
          }}
          onPaymentReceived={() => {
            capture("payment_succeeded_client", { task_id: taskId });
            setPhase("polling");
          }}
          onError={(msg) => {
            setErrorMessage(msg);
            setPhase("error");
          }}
        />
      </Elements>
      {phase === "polling" && (
        <p className="mt-3 text-xs text-text-muted">
          Confirming payment with backend…
        </p>
      )}
    </div>
  );
}

function PaymentForm({
  phase,
  priceCents,
  onConfirming,
  onPaymentReceived,
  onError,
}: {
  phase: Phase;
  priceCents: number;
  onConfirming: () => void;
  onPaymentReceived: () => void;
  onError: (msg: string) => void;
}) {
  const stripe = useStripe();
  const elements = useElements();
  const disabled =
    !stripe ||
    !elements ||
    phase === "confirming" ||
    phase === "polling" ||
    phase === "funded";

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!stripe || !elements) return;
    onConfirming();
    const { error, paymentIntent } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: window.location.href,
      },
      redirect: "if_required",
    });
    if (error) {
      capture("payment_failed", { error_code: error.code });
      onError(error.message ?? "Payment could not be confirmed. Please try a different card.");
      return;
    }
    // Stripe returned without redirect. Status will be succeeded or processing.
    // Either way, hand off to backend polling — we never trust Stripe success
    // alone as proof of funded.
    if (paymentIntent && (paymentIntent.status === "succeeded" || paymentIntent.status === "processing")) {
      onPaymentReceived();
      return;
    }
    capture("payment_failed", {
      error_code: paymentIntent?.status ?? "unknown",
    });
    onError(`Payment is in state ${paymentIntent?.status ?? "unknown"}; please try again.`);
  }

  return (
    <form onSubmit={onSubmit} className="mt-4 flex flex-col gap-4">
      <PaymentElement options={{ layout: "tabs" }} />
      <button
        type="submit"
        disabled={disabled}
        aria-busy={phase === "confirming"}
        className="inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-6 py-3 text-base font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-50"
      >
        {phase === "confirming"
          ? "Charging…"
          : `Pay $${(priceCents / 100).toFixed(2)} to fund this task`}
      </button>
    </form>
  );
}
