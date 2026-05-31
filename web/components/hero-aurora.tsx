/**
 * Decorative hero backdrop — UI credibility pass.
 *
 * A purely ambient motif for the entry-surface heroes: a drifting purple/violet
 * aurora plus a stylized "Eastside route network" (dash-animated lines + a few
 * floating task-pin dots). It is entirely decorative and aria-hidden — it carries
 * NO data, NO Hustler/liquidity claim, NO imagery. All motion is CSS-only
 * (transform / opacity / stroke-dashoffset, defined in globals.css) and is
 * disabled under prefers-reduced-motion, resolving to a fully-visible resting state.
 *
 * COLOR LAW: purple / violet / info-blue only — green never appears on entry surfaces.
 *
 * Server component (no client JS). Mount it as the first child of a `relative`
 * hero section; it absolutely fills that section behind the content (-z-10).
 */
export function HeroAurora({ className = "" }: { className?: string }) {
  return (
    <div
      aria-hidden
      className={
        "pointer-events-none absolute inset-0 -z-10 overflow-hidden " + className
      }
    >
      {/* Drifting aurora blobs (decorative atmosphere). */}
      <div className="hx-aurora absolute left-1/2 top-[-7rem] h-80 w-80 -translate-x-1/2 rounded-full bg-brand-purple opacity-20 blur-[120px]" />
      <div
        className="hx-aurora absolute right-[-5rem] top-6 h-60 w-60 rounded-full bg-brand-violet opacity-10 blur-[110px]"
        style={{ animationDelay: "-9s" }}
      />

      {/* Stylized Eastside route network — decorative only. */}
      <svg
        viewBox="0 0 420 320"
        fill="none"
        className="absolute right-0 top-0 hidden h-full w-[62%] opacity-60 md:block"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="hx-route-grad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#5b2dff" stopOpacity="0.0" />
            <stop offset="45%" stopColor="#7a4dff" stopOpacity="0.55" />
            <stop offset="100%" stopColor="#a78bfa" stopOpacity="0.15" />
          </linearGradient>
        </defs>

        <g
          stroke="url(#hx-route-grad)"
          strokeWidth="1.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path
            className="hx-route"
            style={{ "--hx-len": 300 } as React.CSSProperties}
            d="M30 250 L140 168 L246 196 L388 96"
          />
          <path
            className="hx-route"
            style={{ "--hx-len": 280, animationDelay: "0.5s" } as React.CSSProperties}
            d="M62 64 L168 132 L252 96 L374 172"
          />
          <path
            className="hx-route"
            style={{ "--hx-len": 200, animationDelay: "0.9s" } as React.CSSProperties}
            d="M140 168 L168 132"
          />
        </g>

        <g className="text-brand-purple-glow" fill="currentColor">
          <circle className="hx-pin" cx="140" cy="168" r="4" />
          <circle
            className="hx-pin"
            cx="246"
            cy="196"
            r="4"
            style={{ animationDelay: "-2s" }}
          />
          <circle
            className="hx-pin"
            cx="252"
            cy="96"
            r="3.5"
            style={{ animationDelay: "-4s" }}
          />
          <circle
            className="hx-pin"
            cx="374"
            cy="172"
            r="3"
            style={{ animationDelay: "-1s" }}
          />
        </g>
      </svg>
    </div>
  );
}
