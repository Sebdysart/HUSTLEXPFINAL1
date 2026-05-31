import {
  ChecklistIcon,
  ReceiptIcon,
  EscrowIcon,
  RouteIcon,
  MapDotIcon,
} from "@/components/hx-icons";

/**
 * Product preview teaser — UI credibility pass (wide premium strip).
 *
 * A static, clearly-labeled walkthrough of how a task moves through HustleXP:
 * describe → estimate → fund escrow → track. It is a *preview/example*, not a
 * live task: the mock tracking panel shows only the two backend-provable states
 * a real task would show before matching ("Task created", "Payment funded") plus
 * the honest pending line "Waiting for Hustler matching". It never claims a
 * matched/accepted/on-the-way/live state, never shows fake counts, response
 * times, or trust claims.
 *
 * Server component — no client JS. Motion is CSS-only (the `hx-*` utilities in
 * globals.css) and disabled under prefers-reduced-motion. Icons come from the
 * custom inline-SVG set in hx-icons.tsx. No new dependencies.
 *
 * COLOR LAW: entry surface → black + purple/violet + info-blue + white only.
 * Green is success-state only and never appears here.
 */

const STEPS = [
  {
    n: "01",
    Icon: ChecklistIcon,
    title: "Describe what you need",
    body: "Tell us the job in plain words — no forms to wrestle with.",
  },
  {
    n: "02",
    Icon: ReceiptIcon,
    title: "Get an estimate",
    body: "An AI-suggested price and time before you commit. The final price is yours.",
  },
  {
    n: "03",
    Icon: EscrowIcon,
    title: "Fund through escrow",
    body: "Funds stay held until proof is reviewed — nothing releases before then.",
  },
  {
    n: "04",
    Icon: RouteIcon,
    title: "Track the task",
    body: "Follow each step as it is proven on your dashboard.",
  },
] as const;

export function ProductPreview() {
  return (
    <section
      aria-labelledby="product-preview"
      className="border-t border-white/5 bg-[radial-gradient(60%_60%_at_50%_0%,rgba(91,45,255,0.10),transparent_70%)]"
    >
      <div className="mx-auto w-full max-w-[1280px] px-6 py-16 lg:px-8 lg:py-24">
        <div className="flex flex-wrap items-center gap-3">
          <h2
            id="product-preview"
            className="text-base font-semibold uppercase tracking-[0.18em] text-text-secondary"
          >
            Preview: how a task moves through HustleXP
          </h2>
          <span className="rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[0.7rem] font-semibold uppercase tracking-[0.14em] text-info">
            Example
          </span>
        </div>

        <div className="mt-10 rounded-[1.75rem] border border-white/10 bg-white/[0.02] p-6 shadow-[0_60px_140px_-60px_rgba(91,45,255,0.6)] sm:p-9 lg:p-12">
          <ol className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 lg:gap-4">
            {STEPS.map((step, i) => (
              <li
                key={step.n}
                className="hx-reveal relative flex flex-col gap-4 rounded-2xl border border-white/10 bg-elevated/40 p-5 lg:p-6"
                style={{ "--hx-i": i + 1 } as React.CSSProperties}
              >
                <div className="flex items-center justify-between">
                  <span className="inline-flex h-14 w-14 items-center justify-center rounded-2xl border border-brand-purple/40 bg-brand-purple/10 text-brand-purple-glow">
                    <step.Icon className="h-7 w-7" />
                  </span>
                  <span className="font-mono text-sm font-semibold tracking-[0.2em] text-text-muted">
                    {step.n}
                  </span>
                </div>
                <div>
                  <p className="text-lg font-semibold text-text-primary">
                    {step.title}
                  </p>
                  <p className="mt-1.5 text-sm text-text-secondary">
                    {step.body}
                  </p>
                </div>

                {/* Flow chevron between cards (desktop only, decorative). */}
                {i < STEPS.length - 1 && (
                  <svg
                    aria-hidden
                    viewBox="0 0 24 24"
                    className="absolute -right-3 top-11 hidden h-6 w-6 text-text-muted lg:block"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={1.6}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="m9 6 6 6-6 6" />
                  </svg>
                )}
              </li>
            ))}
          </ol>

          {/* Honest mock "tracking" screen — preview of the dashboard truth. */}
          <div
            className="hx-reveal mt-5 grid grid-cols-1 gap-6 rounded-2xl border border-white/10 bg-elevated/50 p-6 lg:grid-cols-[1.4fr_1fr] lg:items-center lg:p-8"
            style={{ "--hx-i": 5 } as React.CSSProperties}
          >
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <span className="text-brand-purple-glow">
                  <MapDotIcon className="h-4 w-4" />
                </span>
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                  Task tracking — example
                </p>
              </div>

              <ol className="mt-5 space-y-4">
                <TrackStep lit label="Task created" />
                <TrackStep lit label="Payment funded" />
                <TrackStep label="Waiting for Hustler matching" />
              </ol>
            </div>

            <div className="flex items-start gap-3 rounded-xl border border-info/20 bg-info/[0.06] p-4 lg:p-5">
              <span className="mt-0.5 flex-none text-info">
                <EscrowIcon className="h-5 w-5" />
              </span>
              <p className="text-sm text-text-secondary">
                Funds stay held until proof is reviewed. Nothing releases until
                you approve the work.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/**
 * One row of the mock tracking timeline. `lit` = a backend-provable state
 * (rendered in brand purple, never green on this entry surface). Unlit = an
 * honest pending state shown as a hollow, gently-floating marker.
 */
function TrackStep({ lit = false, label }: { lit?: boolean; label: string }) {
  return (
    <li className="flex items-center gap-3.5">
      {lit ? (
        <span
          aria-hidden
          className="h-3 w-3 flex-none rounded-full bg-brand-purple-glow shadow-[0_0_14px_-1px_rgba(139,92,246,0.85)]"
        />
      ) : (
        <span
          aria-hidden
          className="hx-pin h-3 w-3 flex-none rounded-full border border-text-muted"
        />
      )}
      <span
        className={
          "text-base " + (lit ? "text-text-primary" : "text-text-muted")
        }
      >
        {label}
      </span>
    </li>
  );
}
