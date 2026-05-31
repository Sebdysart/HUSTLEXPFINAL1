"use client";

import { useEffect, useRef } from "react";
import { trpc } from "@/lib/trpc";
import { capture } from "@/lib/analytics";

const CATEGORY_LABELS: Record<string, string> = {
  standard_physical: "Physical / muscle work",
  in_home: "In-home help",
  event_appearance: "Event setup",
  errands: "Errands",
  yard: "Yard work",
  dump: "Dump runs",
  moving: "Moving help",
  assembly: "Assembly",
};

function prettyCategory(slug: string): string {
  return (
    CATEGORY_LABELS[slug] ??
    slug
      .replace(/[_-]+/g, " ")
      .replace(/\b\w/g, (c) => c.toUpperCase())
  );
}

export function LocalAvailability({
  zip,
  enabled,
}: {
  zip: string;
  enabled: boolean;
}) {
  const query = trpc.geo.availability.useQuery(
    { zip },
    {
      enabled,
      staleTime: 5 * 60 * 1000,
      refetchOnWindowFocus: false,
      retry: false,
    },
  );

  // Fire once when the availability signal first resolves for this ZIP (data or
  // honest empty-state). Ref-guarded so re-renders don't double-count.
  const viewedRef = useRef(false);
  useEffect(() => {
    if (viewedRef.current) return;
    if (!enabled || !query.data) return;
    viewedRef.current = true;
    capture("local_availability_viewed", { city_or_zip: zip });
  }, [enabled, query.data, zip]);

  if (!enabled) return null;

  if (query.isPending) {
    return (
      <section
        aria-label="Local availability signal"
        className="rounded-2xl border border-white/5 bg-elevated/40 p-4 text-sm text-text-muted"
      >
        <p className="flex items-center gap-2 text-xs uppercase tracking-wide text-text-muted">
          <span
            aria-hidden
            className="hx-pin inline-block h-1.5 w-1.5 rounded-full bg-brand-purple-glow"
          />
          Local availability signal
        </p>
        <p className="mt-1">Checking your area…</p>
      </section>
    );
  }

  if (query.isError || !query.data) {
    return (
      <section
        aria-label="Local availability signal"
        className="rounded-2xl border border-white/5 bg-elevated/40 p-4 text-sm text-text-muted"
      >
        <p className="flex items-center gap-2 text-xs uppercase tracking-wide text-text-muted">
          <span
            aria-hidden
            className="hx-pin inline-block h-1.5 w-1.5 rounded-full bg-brand-purple-glow"
          />
          Local availability signal
        </p>
        <p className="mt-1">Availability signal is temporarily unavailable.</p>
      </section>
    );
  }

  const {
    hustlerSignalAvailable,
    nearbyHustlerCount,
    tasksPostedLast7Days,
    completedLast30Days,
    averageTimeToAcceptMinutes,
    popularCategories,
    emptyState,
  } = query.data;

  if (emptyState) {
    return (
      <section
        aria-label="Local availability signal"
        className="rounded-2xl border border-white/5 bg-elevated/40 p-4 text-sm text-text-secondary"
      >
        <p className="flex items-center gap-2 text-xs uppercase tracking-wide text-text-muted">
          <span
            aria-hidden
            className="hx-pin inline-block h-1.5 w-1.5 rounded-full bg-brand-purple-glow"
          />
          Local availability signal
        </p>
        <p className="mt-2 text-text-primary">
          HustleXP is opening availability in your area.
        </p>
        <p className="mt-1 text-text-secondary">
          Post a task to help us route the right Hustlers. Real marketplace data
          appears here as tasks complete.
        </p>
      </section>
    );
  }

  const showHustlerLine =
    hustlerSignalAvailable === true && nearbyHustlerCount > 0;
  const showTimeToAccept =
    typeof averageTimeToAcceptMinutes === "number" &&
    averageTimeToAcceptMinutes > 0;
  const showCategories =
    Array.isArray(popularCategories) && popularCategories.length > 0;

  return (
    <section
      aria-label="Local availability signal"
      className="rounded-2xl border border-white/5 bg-elevated/40 p-4 text-sm text-text-secondary"
    >
      <p className="text-xs uppercase tracking-wide text-text-muted">
        Local availability signal
      </p>

      <dl className="mt-3 grid grid-cols-1 gap-3 sm:grid-cols-2">
        {tasksPostedLast7Days > 0 && (
          <div>
            <dt className="text-text-muted text-xs">Tasks posted (last 7 days)</dt>
            <dd className="text-text-primary text-base font-medium">
              {tasksPostedLast7Days}
            </dd>
          </div>
        )}
        {completedLast30Days > 0 && (
          <div>
            <dt className="text-text-muted text-xs">Tasks completed (last 30 days)</dt>
            <dd className="text-text-primary text-base font-medium">
              {completedLast30Days}
            </dd>
          </div>
        )}
        {showTimeToAccept && (
          <div>
            <dt className="text-text-muted text-xs">Average time to accept</dt>
            <dd className="text-text-primary text-base font-medium">
              {Math.round(averageTimeToAcceptMinutes!)} min
            </dd>
          </div>
        )}
        {showHustlerLine && (
          <div>
            <dt className="text-text-muted text-xs">Hustlers near you</dt>
            <dd className="text-text-primary text-base font-medium">
              {nearbyHustlerCount}
            </dd>
          </div>
        )}
      </dl>

      {showCategories && (
        <div className="mt-3">
          <p className="text-text-muted text-xs">Popular categories nearby</p>
          <ul className="mt-1 flex flex-wrap gap-2">
            {popularCategories.map((cat) => (
              <li
                key={cat}
                className="rounded-full border border-white/10 bg-elevated px-3 py-1 text-xs text-text-secondary"
              >
                {prettyCategory(cat)}
              </li>
            ))}
          </ul>
        </div>
      )}

      <p className="mt-3 text-xs text-text-muted">
        Real marketplace data appears here as tasks complete.
      </p>
    </section>
  );
}
