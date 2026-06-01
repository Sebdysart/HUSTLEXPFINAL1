"use client";

/**
 * Authenticated poster dashboard — post-acceptance tracking map (Track B, Phase 1).
 *
 * Renders REAL data from the poster-only `task.getTracking` read:
 *   - the geocoded task destination pin (shown once the task is trackable), and
 *   - the latest known Hustler GPS point IF the worker app is streaming (Phase 2).
 *
 * Honesty invariants (do NOT violate):
 *   - Never shown on the public homepage — authenticated dashboard only.
 *   - Only renders when the backend says the task is trackable (post-acceptance).
 *   - No ETA is displayed until the backend computes one (Phase 3); when there is
 *     no live Hustler point we say "ETA appears after a Hustler accepts" — never a
 *     fabricated time, never "on the way" / "matched" copy.
 */

import { GoogleMap, MarkerF, useJsApiLoader } from "@react-google-maps/api";
import { useMemo } from "react";
import { trpc } from "@/lib/trpc";
import { env } from "@/lib/env";

type LatLng = { lat: number; lng: number };

export type TrackingView = {
  progressState: string;
  destination: LatLng | null;
  hustler: { lat: number; lng: number; accuracy: number; at: string | Date } | null;
  eta: { minutes: number } | null;
  lastUpdated: string | Date | null;
};

// Fallback map center only (Eastside beta footprint). Never labelled as a task
// location — used purely so the map has a center when nothing is geocoded yet.
const DEFAULT_CENTER: LatLng = { lat: 47.674, lng: -122.121 };

const MAP_CONTAINER = { width: "100%", height: "280px" } as const;

// Compact dark styling so the raster map fits the dashboard surface.
const DARK_MAP_STYLE: google.maps.MapTypeStyle[] = [
  { elementType: "geometry", stylers: [{ color: "#15131f" }] },
  { elementType: "labels.text.stroke", stylers: [{ color: "#15131f" }] },
  { elementType: "labels.text.fill", stylers: [{ color: "#8b8a96" }] },
  { featureType: "road", elementType: "geometry", stylers: [{ color: "#26242f" }] },
  { featureType: "water", elementType: "geometry", stylers: [{ color: "#0b0b0f" }] },
  { featureType: "poi", stylers: [{ visibility: "off" }] },
  { featureType: "transit", stylers: [{ visibility: "off" }] },
];

function formatWhen(value: string | Date | null): string {
  if (!value) return "";
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? "" : d.toLocaleTimeString();
}

/** Pure presentational map. Real data on the authenticated dashboard. */
export function TrackingMapView({ data }: { data: TrackingView }) {
  const hasKey = env.googleMapsApiKey.length > 0;
  const { isLoaded, loadError } = useJsApiLoader({
    id: "hx-google-maps",
    googleMapsApiKey: env.googleMapsApiKey,
  });

  const center = useMemo<LatLng>(() => {
    if (data.destination) return data.destination;
    if (data.hustler) return { lat: data.hustler.lat, lng: data.hustler.lng };
    return DEFAULT_CENTER;
  }, [data.destination, data.hustler]);

  return (
    <div className="mt-5 overflow-hidden rounded-xl border border-white/10 bg-elevated/50">
      <div className="flex items-center justify-between border-b border-white/10 px-4 py-2.5">
        <p className="text-sm font-semibold text-text-primary">Tracking</p>
        {data.hustler ? (
          <span className="text-xs text-text-muted">
            Hustler location
            {formatWhen(data.lastUpdated) ? ` · updated ${formatWhen(data.lastUpdated)}` : ""}
          </span>
        ) : (
          <span className="text-xs text-text-muted">Waiting for Hustler matching</span>
        )}
      </div>

      <div className="relative">
        {!hasKey || loadError ? (
          <div className="grid h-[280px] place-items-center px-6 text-center text-sm text-text-muted">
            {!hasKey
              ? "Map unavailable — Maps API key is not configured."
              : "Map unavailable — could not load Google Maps."}
          </div>
        ) : !isLoaded ? (
          <div className="grid h-[280px] place-items-center text-sm text-text-muted">
            Loading map…
          </div>
        ) : (
          <GoogleMap
            mapContainerStyle={MAP_CONTAINER}
            center={center}
            zoom={13}
            options={{
              disableDefaultUI: true,
              zoomControl: true,
              clickableIcons: false,
              styles: DARK_MAP_STYLE,
            }}
          >
            {data.destination && (
              <MarkerF position={data.destination} title="Task location" />
            )}
            {data.hustler && (
              <MarkerF
                position={{ lat: data.hustler.lat, lng: data.hustler.lng }}
                title="Hustler location"
              />
            )}
          </GoogleMap>
        )}

        {/* No live Hustler point yet → show the task location, promise no ETA. */}
        {!data.hustler && (
          <div className="pointer-events-none absolute inset-x-3 bottom-3 rounded-lg border border-info/40 bg-black/70 px-3 py-2 backdrop-blur">
            <p className="text-xs font-medium text-info">ETA appears after a Hustler accepts.</p>
            <p className="text-[11px] text-text-muted">
              The task location is shown now; the route updates once a Hustler is on the task.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

/** Dashboard wrapper: polls the poster-only tracking read; renders only when trackable. */
export function TrackingMapPanel({ taskId }: { taskId: string }) {
  const q = trpc.task.getTracking.useQuery(
    { taskId },
    { refetchInterval: 5000, retry: false },
  );

  if (!q.data || !q.data.trackable) return null;

  return (
    <TrackingMapView
      data={{
        progressState: q.data.progressState,
        destination: q.data.destination,
        hustler: q.data.hustler,
        eta: q.data.eta,
        lastUpdated: q.data.lastUpdated,
      }}
    />
  );
}
