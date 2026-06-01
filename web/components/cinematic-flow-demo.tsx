import {
  ChecklistIcon,
  ReceiptIcon,
  EscrowIcon,
  RouteIcon,
  DashboardIcon,
} from "@/components/hx-icons";

/**
 * Cinematic flow demo — the homepage's "how it works" theater.
 *
 * Replaces the old static product-preview strip with a wide, in-code product
 * video: a left-hand "route theater" (animated Eastside map — drawing route
 * lines, pulsing pins, a light bead running the route, a floating example task
 * card) paired with a right-hand vertical "flow rail" of five illustrated,
 * staggered step cards (describe → estimate → fund escrow → track → dashboard).
 *
 * Server component — zero client JS. All motion is CSS-only (the `hx-*`
 * utilities in globals.css: reveal / pin / route / ping / flowline / rail-glow /
 * float) and is fully disabled under prefers-reduced-motion, resolving to a
 * static, fully-visible resting state. No new dependencies, no external media.
 *
 * HONESTY LAW: this is an *Example / Preview*, never a live task. It shows only
 * backend-provable states a real task reaches before matching ("Task created",
 * "Payment funded") plus the honest pending line "Waiting for Hustler matching"
 * / "No Hustler has accepted yet". It NEVER claims matched / accepted (except
 * that exact pending phrase) / on-the-way / live / nearby, and shows no fake
 * counts, response times, availability, or trust claims. Demo figures ($30,
 * 1 hr 15 min) are explicitly tagged "Example" and captioned as not a quote.
 *
 * COLOR LAW: entry surface → black + purple/violet + info-blue + white only.
 * Green is success-state only and never appears here.
 */
export function CinematicFlowDemo() {
  return (
    <section
      aria-labelledby="flow-demo"
      className="relative isolate overflow-hidden border-t border-white/5"
    >
      {/* Full-bleed brand wash so wide-screen side margins never read as dead. */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(75%_60%_at_50%_-5%,rgba(91,45,255,0.16),transparent_72%)]"
      />
      <div
        aria-hidden
        className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-px bg-gradient-to-r from-transparent via-brand-purple/40 to-transparent"
      />

      <div className="mx-auto w-full max-w-[1280px] px-6 py-20 lg:px-8 lg:py-28">
        <div className="flex flex-wrap items-center gap-3">
          <h2
            id="flow-demo"
            className="text-2xl font-semibold tracking-tight text-text-primary sm:text-3xl"
          >
            Preview: how HustleXP works
          </h2>
          <span className="rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[0.7rem] font-semibold uppercase tracking-[0.14em] text-info">
            Example
          </span>
        </div>
        <p className="mt-3 max-w-2xl text-base text-text-secondary lg:text-lg">
          An example task moving through HustleXP — describe it, get an estimate,
          fund escrow, and track progress on your dashboard.
        </p>

        <div className="mt-10 grid grid-cols-1 items-start gap-6 lg:mt-12 lg:grid-cols-[1.02fr_0.98fr] lg:gap-8">
          {/* Theater pins while the flow rail scrolls past — app-demo feel. */}
          <div className="lg:sticky lg:top-24">
            <RouteTheater />
          </div>
          <FlowRail />
        </div>
      </div>
    </section>
  );
}

/* ------------------------------------------------------------------ */
/* Left: the route theater — animated Eastside map + floating task card */
/* ------------------------------------------------------------------ */

function RouteTheater() {
  return (
    <div className="hx-reveal relative h-[24rem] overflow-hidden rounded-[1.75rem] border border-white/10 bg-elevated/40 p-6 shadow-[0_60px_140px_-60px_rgba(91,45,255,0.6)] sm:h-[28rem] lg:h-[34rem] lg:p-8">
      {/* depth: layered glows */}
      <div
        aria-hidden
        className="pointer-events-none absolute -left-16 -top-20 h-72 w-72 rounded-full bg-brand-purple/25 blur-[120px]"
      />
      <div
        aria-hidden
        className="pointer-events-none absolute -bottom-24 right-0 h-72 w-72 rounded-full bg-brand-violet/15 blur-[130px]"
      />

      <p className="relative z-10 inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.18em] text-text-muted">
        Eastside route · Example
      </p>

      {/* The map. Decorative — aria-hidden, carries no data or live claim. */}
      <svg
        aria-hidden
        viewBox="0 0 480 360"
        className="absolute inset-0 h-full w-full"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="hx-flow-grad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#5b2dff" stopOpacity="0" />
            <stop offset="45%" stopColor="#7a4dff" stopOpacity="0.7" />
            <stop offset="100%" stopColor="#a78bfa" stopOpacity="0.25" />
          </linearGradient>
          <radialGradient id="hx-bead-grad" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#a78bfa" />
            <stop offset="100%" stopColor="#5b2dff" />
          </radialGradient>
        </defs>

        {/* faint grid for logistics texture */}
        <g stroke="#ffffff" strokeOpacity="0.035" strokeWidth="1">
          {[60, 120, 180, 240, 300, 360, 420].map((x) => (
            <line key={`v${x}`} x1={x} y1="0" x2={x} y2="360" />
          ))}
          {[60, 120, 180, 240, 300].map((y) => (
            <line key={`h${y}`} x1="0" y1={y} x2="480" y2={y} />
          ))}
        </g>

        {/* secondary routes (decorative network) */}
        <g
          stroke="url(#hx-flow-grad)"
          strokeWidth="1.5"
          strokeLinecap="round"
          fill="none"
        >
          <path
            className="hx-route"
            style={{ "--hx-len": 360 } as React.CSSProperties}
            d="M70 70 L180 130 L300 96 L430 150"
          />
          <path
            className="hx-route"
            style={
              { "--hx-len": 300, animationDelay: "0.5s" } as React.CSSProperties
            }
            d="M110 300 L210 250 L300 285"
          />
        </g>

        {/* primary route: apartment → storage */}
        <path
          id="hx-primary-route"
          className="hx-route"
          style={{ "--hx-len": 470 } as React.CSSProperties}
          d="M96 286 C 170 250, 150 170, 240 160 S 360 150, 404 92"
          stroke="url(#hx-flow-grad)"
          strokeWidth="3"
          strokeLinecap="round"
          fill="none"
        />
        {/* light bead chasing along the primary route */}
        <path
          className="hx-flowline"
          style={{ "--hx-len": 470 } as React.CSSProperties}
          d="M96 286 C 170 250, 150 170, 240 160 S 360 150, 404 92"
          stroke="#c4b5fd"
          strokeWidth="3.5"
          strokeLinecap="round"
          fill="none"
        />

        {/* origin pin (apartment) */}
        <g>
          <circle className="hx-ping-ring" cx="96" cy="286" r="10" fill="#5b2dff" />
          <circle cx="96" cy="286" r="6" fill="url(#hx-bead-grad)" />
          <circle cx="96" cy="286" r="11" fill="none" stroke="#8b5cf6" strokeOpacity="0.5" strokeWidth="1.5" />
        </g>
        {/* destination pin (storage) */}
        <g>
          <circle className="hx-ping-ring" cx="404" cy="92" r="10" fill="#007aff" style={{ animationDelay: "-1.4s" }} />
          <circle cx="404" cy="92" r="6" fill="#007aff" />
          <circle cx="404" cy="92" r="11" fill="none" stroke="#3b9bff" strokeOpacity="0.55" strokeWidth="1.5" />
        </g>

        {/* floating waypoint pins */}
        <g className="text-brand-purple-glow" fill="currentColor">
          <circle className="hx-pin" cx="240" cy="160" r="4" />
          <circle className="hx-pin" cx="300" cy="96" r="3.4" style={{ animationDelay: "-2.5s" }} />
          <circle className="hx-pin" cx="180" cy="130" r="3" style={{ animationDelay: "-4s" }} />
        </g>
      </svg>

      {/* origin / destination labels (from the example task). Apartment is
          hidden on mobile where the full-width task card overlays the origin. */}
      <span className="pointer-events-none absolute bottom-[30%] left-[12%] z-10 hidden rounded-md border border-white/10 bg-background/70 px-2 py-1 text-[0.7rem] font-medium text-text-secondary backdrop-blur-sm sm:block">
        Apartment
      </span>
      <span className="pointer-events-none absolute right-[14%] top-[18%] z-10 rounded-md border border-info/25 bg-background/70 px-2 py-1 text-[0.7rem] font-medium text-info backdrop-blur-sm">
        Storage
      </span>

      {/* floating example task card overlay — bottom-right on desktop so it
          clears the bottom-left origin and top-right destination pins. */}
      <div className="hx-float absolute bottom-6 left-6 right-6 z-10 rounded-2xl border border-white/12 bg-background/80 p-4 shadow-[0_30px_80px_-40px_rgba(91,45,255,0.8)] ring-1 ring-white/5 backdrop-blur-md sm:left-auto sm:right-6 sm:w-80">
        <div className="flex items-center justify-between">
          <p className="text-[0.7rem] font-semibold uppercase tracking-[0.16em] text-brand-purple-glow">
            Example task
          </p>
          <span className="rounded-full border border-white/10 bg-elevated px-2 py-0.5 text-[0.65rem] font-medium text-text-muted">
            Preview
          </span>
        </div>
        <p className="mt-2 text-sm font-medium text-text-primary">
          Move a couch from my apartment to storage
        </p>
        <div className="mt-3 flex flex-wrap items-center gap-2 text-[0.72rem]">
          <span className="rounded-full border border-info/25 bg-info/10 px-2 py-0.5 font-medium text-info">
            ZIP 98004
          </span>
          <span className="rounded-full border border-brand-purple/30 bg-brand-purple/10 px-2 py-0.5 font-medium text-brand-purple-glow">
            Moving help
          </span>
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Right: the flow rail — five staggered, illustrated step cards       */
/* ------------------------------------------------------------------ */

function FlowRail() {
  return (
    <div className="relative">
      {/* vertical connector with a glow sweeping down it */}
      <div
        aria-hidden
        className="absolute left-[1.85rem] top-6 bottom-6 hidden w-px overflow-hidden bg-gradient-to-b from-brand-purple/10 via-brand-purple/40 to-brand-purple/10 sm:block"
      >
        <div className="hx-rail-glow absolute inset-x-0 top-0 h-16 bg-gradient-to-b from-transparent via-brand-purple-glow to-transparent" />
      </div>

      <ol className="flex flex-col gap-4">
        <FlowStep
          i={1}
          n="01"
          Icon={ChecklistIcon}
          title="Describe task"
          body="Tell us the job in plain words — no forms to wrestle with."
        >
          <p className="text-sm text-text-primary">
            Move a couch from my apartment to storage
          </p>
          <div className="mt-2.5 flex flex-wrap gap-2 text-[0.72rem]">
            <Chip tone="info">ZIP 98004</Chip>
            <Chip tone="purple">Moving help</Chip>
          </div>
        </FlowStep>

        <FlowStep
          i={2}
          n="02"
          Icon={ReceiptIcon}
          title="Get estimate"
          body="An AI-suggested price and time before you commit."
          tag="Example"
        >
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-text-muted">
            Estimated task
          </p>
          <div className="mt-2 flex flex-wrap items-end gap-x-5 gap-y-1">
            <span className="text-2xl font-semibold tracking-tight text-text-primary">
              $30
            </span>
            <span className="text-sm font-medium text-text-secondary">
              1 hr 15 min
            </span>
            <span className="rounded-full border border-info/25 bg-info/10 px-2 py-0.5 text-[0.68rem] font-medium text-info">
              Proof required
            </span>
          </div>
          <p className="mt-2.5 text-[0.72rem] text-text-muted">
            Example only — your final price is set when you post.
          </p>
        </FlowStep>

        <FlowStep
          i={3}
          n="03"
          Icon={EscrowIcon}
          title="Fund escrow"
          body="Nothing releases before the work is proven."
        >
          <div className="flex items-center gap-2.5">
            <span className="h-2 w-2 flex-none rounded-full bg-brand-purple-glow shadow-[0_0_12px_-1px_rgba(139,92,246,0.85)]" />
            <span className="text-sm font-medium text-text-primary">
              Funds held
            </span>
          </div>
          <p className="mt-1.5 text-sm text-text-secondary">
            Released after proof is reviewed.
          </p>
        </FlowStep>

        <FlowStep
          i={4}
          n="04"
          Icon={RouteIcon}
          title="Track progress"
          body="Follow each step as it is proven."
        >
          <div className="flex items-center gap-2.5">
            <span className="hx-pin h-2.5 w-2.5 flex-none rounded-full border border-text-muted" />
            <span className="text-sm font-medium text-text-secondary">
              Waiting for Hustler matching
            </span>
          </div>
          <p className="mt-1.5 text-[0.78rem] text-text-muted">
            No Hustler has accepted yet.
          </p>
        </FlowStep>

        <FlowStep
          i={5}
          n="05"
          Icon={DashboardIcon}
          title="Track progress"
          body="The same truth on your dashboard."
          tag="Dashboard"
        >
          <ol className="space-y-2.5">
            <Track lit label="Task created" />
            <Track lit label="Payment funded" />
            <Track label="Waiting for Hustler matching" />
          </ol>
        </FlowStep>
      </ol>
    </div>
  );
}

function FlowStep({
  i,
  n,
  Icon,
  title,
  body,
  tag,
  children,
}: {
  i: number;
  n: string;
  Icon: (props: React.SVGProps<SVGSVGElement>) => React.ReactElement;
  title: string;
  body: string;
  tag?: string;
  children: React.ReactNode;
}) {
  return (
    <li
      className="hx-reveal relative flex gap-4 rounded-2xl border border-white/10 bg-elevated/50 p-4 ring-1 ring-white/5 sm:p-5"
      style={{ "--hx-i": i } as React.CSSProperties}
    >
      {/* node on the rail */}
      <span className="relative z-10 inline-flex h-12 w-12 flex-none items-center justify-center rounded-2xl border border-brand-purple/40 bg-brand-purple/10 text-brand-purple-glow shadow-[0_0_30px_-12px_rgba(139,92,246,0.9)]">
        <Icon className="h-6 w-6" />
      </span>

      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between gap-3">
          <p className="text-base font-semibold text-text-primary">{title}</p>
          <div className="flex items-center gap-2">
            {tag && (
              <span className="rounded-full border border-info/30 bg-info/10 px-2 py-0.5 text-[0.62rem] font-semibold uppercase tracking-[0.12em] text-info">
                {tag}
              </span>
            )}
            <span className="font-mono text-xs font-semibold tracking-[0.18em] text-text-muted">
              {n}
            </span>
          </div>
        </div>
        <p className="mt-0.5 text-sm text-text-secondary">{body}</p>
        <div className="mt-3 rounded-xl border border-white/10 bg-background/50 p-3.5">
          {children}
        </div>
      </div>
    </li>
  );
}

function Chip({
  tone,
  children,
}: {
  tone: "info" | "purple";
  children: React.ReactNode;
}) {
  const cls =
    tone === "info"
      ? "border-info/25 bg-info/10 text-info"
      : "border-brand-purple/30 bg-brand-purple/10 text-brand-purple-glow";
  return (
    <span className={`rounded-full border px-2 py-0.5 font-medium ${cls}`}>
      {children}
    </span>
  );
}

/**
 * One dashboard timeline row. `lit` = a backend-provable state, rendered in
 * brand purple (NEVER green on this entry surface). Unlit = an honest pending
 * state shown as a hollow, gently-floating marker.
 */
function Track({ lit = false, label }: { lit?: boolean; label: string }) {
  return (
    <li className="flex items-center gap-3">
      {lit ? (
        <span
          aria-hidden
          className="h-2.5 w-2.5 flex-none rounded-full bg-brand-purple-glow shadow-[0_0_12px_-1px_rgba(139,92,246,0.85)]"
        />
      ) : (
        <span
          aria-hidden
          className="hx-pin h-2.5 w-2.5 flex-none rounded-full border border-text-muted"
        />
      )}
      <span
        className={
          "text-sm " + (lit ? "text-text-primary" : "text-text-muted")
        }
      >
        {label}
      </span>
    </li>
  );
}
