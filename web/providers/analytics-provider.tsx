"use client";

import { useEffect, useRef } from "react";
import { useAuth } from "@/providers/auth-provider";
import { initAnalytics, identifyUser, resetAnalytics } from "@/lib/analytics";

/**
 * Initializes analytics once on mount and keeps PostHog identity in sync with
 * Firebase auth (C10). Identifies by the opaque Firebase UID only — never an
 * email or name — so the pre-auth funnel (landing → estimate) stitches to the
 * post-auth funnel (signup → create → fund) for one person. Resets on sign-out.
 *
 * Must live inside <AuthProvider> (it consumes useAuth) and is a pure pass-
 * through for children — it renders no UI and never blocks rendering.
 */
export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const initedRef = useRef(false);
  const lastUidRef = useRef<string | null>(null);

  useEffect(() => {
    if (initedRef.current) return;
    initedRef.current = true;
    initAnalytics();
  }, []);

  useEffect(() => {
    const uid = user?.uid ?? null;
    if (uid && uid !== lastUidRef.current) {
      lastUidRef.current = uid;
      identifyUser(uid);
    } else if (!uid && lastUidRef.current) {
      lastUidRef.current = null;
      resetAnalytics();
    }
  }, [user]);

  return <>{children}</>;
}
