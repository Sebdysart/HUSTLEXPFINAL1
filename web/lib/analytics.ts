/**
 * Poster funnel analytics (C10).
 *
 * A thin, privacy-enforcing wrapper over posthog-js. Three hard guarantees:
 *
 *  1. SAFE NO-OP. If NEXT_PUBLIC_POSTHOG_KEY is absent, nothing is sent. In
 *     development the event + sanitized props are echoed to the console so the
 *     funnel can be verified locally without a live PostHog project. In
 *     production an unconfigured key is silently inert.
 *
 *  2. PRIVACY ALLOW-LIST. `capture()` only ever forwards the keys in
 *     ALLOWED_KEYS. Any other property a caller passes is dropped before it
 *     reaches PostHog — raw task descriptions, names, emails, Firebase ID
 *     tokens, Stripe client secrets, payment-method data and error MESSAGES
 *     physically cannot leave the browser through this module. Failures carry
 *     an error CODE only, never a message. The `AnalyticsProps` type enforces
 *     the same allow-list at compile time; the runtime pick is defense in depth.
 *
 *  3. NEVER BLOCKS THE FUNNEL. Every call is wrapped so an analytics error can
 *     never throw into a funnel handler. init is lazy + idempotent, and
 *     autocapture / session recording / automatic pageviews are all OFF so the
 *     SDK cannot scrape DOM text or input values on its own — only the explicit
 *     events below are ever emitted.
 */

import posthog from "posthog-js";
import { env } from "@/lib/env";

/** Every funnel event C10 emits. No event outside this union can be tracked. */
export type AnalyticsEvent =
  // pre-auth
  | "landing_view"
  | "task_input_started"
  | "zip_entered"
  | "category_selected"
  | "draft_estimate_started"
  | "draft_estimate_succeeded"
  | "draft_estimate_failed"
  | "local_availability_viewed"
  | "dispatch_clicked"
  | "signup_started"
  // post-auth
  | "signup_completed"
  | "terms_accepted"
  | "task_create_started"
  | "task_create_succeeded"
  | "task_create_failed"
  | "payment_intent_created"
  | "payment_started"
  | "payment_succeeded_client"
  | "payment_funded_backend"
  | "payment_failed"
  | "dashboard_viewed"
  | "task_detail_viewed"
  // poster dashboard parity (Phase 1)
  | "proof_reviewed"
  | "task_completed"
  | "escrow_refunded"
  | "rating_submitted";

/**
 * The ONLY property keys allowed on any event. This is the privacy contract —
 * see the module header. `task_id` / `escrow_state` are only meaningful (and
 * only passed) post-auth.
 */
export interface AnalyticsProps {
  /** Route/page slug (e.g. "/redmond"). */
  source_page?: string;
  /** The 5-digit ZIP the user typed — never a street address. */
  city_or_zip?: string;
  /** Chip id or backend template slug. */
  category?: string;
  /** Integer price in cents. */
  task_price_cents?: number;
  /** Backend task id — post-auth only. */
  task_id?: string;
  /** Escrow state string (e.g. "FUNDED") — post-auth only. */
  escrow_state?: string;
  /** tRPC / Stripe error CODE only — never an error message. */
  error_code?: string;
  /** Whether the user is signed in at the time of the event. */
  authenticated?: boolean;
}

const ALLOWED_KEYS = [
  "source_page",
  "city_or_zip",
  "category",
  "task_price_cents",
  "task_id",
  "escrow_state",
  "error_code",
  "authenticated",
] as const;

const isDev = process.env.NODE_ENV !== "production";

let initAttempted = false;
let posthogReady = false;

function isConfigured(): boolean {
  return Boolean(env.posthog.key);
}

/**
 * Initialize PostHog at most once. Lazy + idempotent: callers (the provider, or
 * any capture()) can invoke it freely. With no key it marks itself attempted
 * and stays inert, so capture() falls back to the dev console.
 */
export function initAnalytics(): void {
  if (typeof window === "undefined") return;
  if (initAttempted) return;
  initAttempted = true;

  if (!isConfigured()) {
    if (isDev) {
      console.debug("[analytics] disabled (no NEXT_PUBLIC_POSTHOG_KEY)");
    }
    return;
  }

  try {
    posthog.init(env.posthog.key, {
      api_host: env.posthog.host,
      // Explicit funnel events ONLY — never let the SDK scrape the DOM.
      autocapture: false,
      capture_pageview: false,
      capture_pageleave: false,
      disable_session_recording: true,
      persistence: "localStorage+cookie",
    });
    posthogReady = true;
  } catch {
    // Never let analytics initialization break the app.
    posthogReady = false;
  }
}

/** Drop every key that isn't on the allow-list. Defense in depth behind the type. */
function pickAllowed(
  props?: AnalyticsProps,
): Record<string, string | number | boolean> {
  const out: Record<string, string | number | boolean> = {};
  if (!props) return out;
  for (const key of ALLOWED_KEYS) {
    const value = props[key];
    if (value !== undefined && value !== null) {
      out[key] = value;
    }
  }
  return out;
}

/**
 * Track a funnel event. No-ops safely when PostHog is unconfigured (dev: echoes
 * to console). Only allow-listed props are ever forwarded. Never throws.
 */
export function capture(event: AnalyticsEvent, props?: AnalyticsProps): void {
  if (typeof window === "undefined") return;
  if (!initAttempted) initAnalytics();
  const safe = pickAllowed(props);
  try {
    if (posthogReady) {
      posthog.capture(event, safe);
    } else if (isDev) {
      console.debug("[analytics]", event, safe);
    }
  } catch {
    // Analytics must never break the funnel.
  }
}

/** Tie subsequent events to a stable, opaque id (Firebase UID — never email/name). */
export function identifyUser(uid: string): void {
  if (typeof window === "undefined" || !uid) return;
  if (!initAttempted) initAnalytics();
  try {
    if (posthogReady) posthog.identify(uid);
  } catch {
    // ignore
  }
}

/** Clear identity on sign-out so the next visitor isn't conflated. */
export function resetAnalytics(): void {
  if (typeof window === "undefined") return;
  try {
    if (posthogReady) posthog.reset();
  } catch {
    // ignore
  }
}
