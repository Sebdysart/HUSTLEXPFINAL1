/**
 * Typed access to public env vars. Logs a build/server-side warning if a
 * required var is missing, rather than producing silent undefined.
 */

function required(name: string, value: string | undefined): string {
  if (!value && typeof window === "undefined") {
    // Surfaced in build/server logs only; avoids silent misconfiguration.
    process.stdout.write(`[env] Missing required env var: ${name}\n`);
  }
  return value ?? "";
}

export const env = {
  apiUrl: required("NEXT_PUBLIC_API_URL", process.env.NEXT_PUBLIC_API_URL),
  firebase: {
    apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY ?? "",
    authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN ?? "",
    projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID ?? "",
    appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID ?? "",
  },
  stripePublishableKey: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY ?? "",
  posthog: {
    key: process.env.NEXT_PUBLIC_POSTHOG_KEY ?? "",
    host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://us.i.posthog.com",
  },
} as const;
