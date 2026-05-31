"use client";

import { useEffect, useRef } from "react";
import { capture, type AnalyticsEvent } from "@/lib/analytics";
import { useAuth } from "@/providers/auth-provider";

/**
 * Fires a single view event on mount (C10). Ref-guarded so Next dev Strict Mode
 * double-mounts and refreshes don't double-count. Safe to drop into a server-
 * rendered page — it renders nothing and only acts on the client.
 *
 * `source_page` defaults to the current pathname, so the same component on the
 * homepage and on every C9 landing route reports its own route without per-page
 * wiring.
 */
export function PageView({
  event,
  source_page,
}: {
  event: AnalyticsEvent;
  source_page?: string;
}) {
  const { user } = useAuth();
  const firedRef = useRef(false);

  useEffect(() => {
    if (firedRef.current) return;
    firedRef.current = true;
    capture(event, {
      source_page:
        source_page ??
        (typeof window !== "undefined" ? window.location.pathname : undefined),
      authenticated: !!user,
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return null;
}
