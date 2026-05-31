/**
 * Decorative hero backdrop — UI credibility pass (full-width rebuild).
 *
 * Ambient motif for the entry-surface heroes: drifting purple/violet aurora
 * fields plus a stylized "Eastside route network" (dash-animated lines + a few
 * floating task-pin dots). Entirely decorative and aria-hidden — it carries NO
 * data, NO Hustler/liquidity claim, NO imagery. All motion is CSS-only
 * (transform / opacity / stroke-dashoffset, defined in globals.css) and is
 * disabled under prefers-reduced-motion, resolving to a fully-visible state.
 *
 * Sized to fill a full-bleed hero section (mount as the first child of a
 * `relative`/`isolate` section); it absolutely fills that section behind the
 * content (-z-10).
 *
 * COLOR LAW: purple / violet / info-blue only — green never appears on entry.
 */
export function HeroAurora({ className = "" }: { className?: string }) {
  return (
    <div
      aria-hidden
      className={
        "pointer-events-none absolute inset-0 -z-10 overflow-hidden " + className
      }
    >
      {/* Drifting aurora fields — larger and wider for a full-bleed hero. */}
      <div className="hx-aurora absolute left-[-8rem] top-[-10rem] h-[34rem] w-[34rem] rounded-full bg-brand-purple opacity-25 blur-[150px]" />
      <div
        className="hx-aurora absolute right-[-10rem] top-[-6rem] h-[30rem] w-[30rem] rounded-full bg-brand-violet opacity-[0.14] blur-[140px]"
        style={{ animationDelay: "-9s" }}
      />
      <div
        className="hx-aurora absolute bottom-[-14rem] left-1/3 h-[26rem] w-[26rem] rounded-full bg-brand-purple-light opacity-[0.1] blur-[150px]"
        style={{ animationDelay: "-4s" }}
      />

      {/* Stylized Eastside route network — anchored to the right of the hero. */}
      <svg
        viewBox="0 0 520 420"
        fill="none"
        className="absolute right-0 top-0 hidden h-full w-[58%] opacity-70 lg:block"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="hx-route-grad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#5b2dff" stopOpacity="0" />
            <stop offset="45%" stopColor="#7a4dff" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#a78bfa" stopOpacity="0.14" />
          </linearGradient>
        </defs>

        <g
          stroke="url(#hx-route-grad)"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path
            className="hx-route"
            style={{ "--hx-len": 420 } as React.CSSProperties}
            d="M40 330 L170 220 L300 262 L470 120"
          />
          <path
            className="hx-route"
            style={
              { "--hx-len": 380, animationDelay: "0.5s" } as React.CSSProperties
            }
            d="M80 90 L210 176 L320 128 L478 224"
          />
          <path
            className="hx-route"
            style={
              { "--hx-len": 240, animationDelay: "0.9s" } as React.CSSProperties
            }
            d="M170 220 L210 176"
          />
        </g>

        <g className="text-brand-purple-glow" fill="currentColor">
          <circle className="hx-pin" cx="170" cy="220" r="5" />
          <circle
            className="hx-pin"
            cx="300"
            cy="262"
            r="5"
            style={{ animationDelay: "-2s" }}
          />
          <circle
            className="hx-pin"
            cx="320"
            cy="128"
            r="4.2"
            style={{ animationDelay: "-4s" }}
          />
          <circle
            className="hx-pin"
            cx="470"
            cy="120"
            r="4"
            style={{ animationDelay: "-1s" }}
          />
          <circle
            className="hx-pin"
            cx="478"
            cy="224"
            r="3.6"
            style={{ animationDelay: "-3s" }}
          />
        </g>
      </svg>
    </div>
  );
}
