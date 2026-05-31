/**
 * Stripe.js loader singleton.
 *
 * `loadStripe` returns the same instance per public-key value, but we cache the
 * resolved promise here so React strict-mode double-mounts and component
 * remounts don't re-invoke the Stripe.js loader. Browser-only — never resolve
 * on the server.
 */

import { loadStripe, type Stripe } from "@stripe/stripe-js";
import { env } from "@/lib/env";

let stripePromise: Promise<Stripe | null> | null = null;

export function getStripe(): Promise<Stripe | null> {
  if (typeof window === "undefined") {
    return Promise.resolve(null);
  }
  if (!env.stripePublishableKey) {
    return Promise.resolve(null);
  }
  if (!stripePromise) {
    stripePromise = loadStripe(env.stripePublishableKey);
  }
  return stripePromise;
}

export function isStripeConfigured(): boolean {
  return Boolean(env.stripePublishableKey);
}
