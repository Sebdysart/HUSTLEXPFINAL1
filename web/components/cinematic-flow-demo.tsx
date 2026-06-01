import {
  EscrowIcon,
  ReceiptIcon,
  MapDotIcon,
} from "@/components/hx-icons";

/**
 * App-screen preview — what a posted task looks like in HustleXP.
 *
 * A single large, full-width "app window" (window chrome + a two-panel body)
 * rendered at human scale: the task summary on the left, the live status rail on
 * the right. It is an *Example / Preview*, never a live task — it shows only the
 * backend-provable states a real task reaches before matching ("Task created",
 * "Payment funded") plus the honest pending line "Waiting for Hustler matching".
 * It never claims matched / on-the-way / live / nearby, and shows no fake counts,
 * response times, availability, or trust claims. Demo figures ($30 · 1 hr 15 min)
 * are explicitly tagged "Example" and captioned as not a quote.
 *
 * Server component — zero client JS. Motion is CSS-only (the `hx-*` utilities in
 * globals.css) and fully disabled under prefers-reduced-motion. No new deps.
 *
 * COLOR LAW: entry surface → charcoal + purple/violet + info-blue + white only.
 * Green is success-state only and never appears here.
 */
export function CinematicFlowDemo() {
  return (
    <section
      aria-labelledby="flow-demo"
      className="relative isolate overflow-hidden border-t border-white/5"
    >
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(70%_55%_at_50%_-8%,rgba(91,45,255,0.14),transparent_72%)]"
      />

      <div className="mx-auto w-full max-w-[1400px] px-6 py-20 lg:px-10 lg:py-24">
        <div className="flex flex-wrap items-center gap-3">
          <h2
            id="flow-demo"
            className="text-3xl font-semibold tracking-tight text-text-primary sm:text-4xl"
          >
            Preview: how HustleXP works
          </h2>
          <span className="rounded-full border border-info/30 bg-info/10 px-3 py-1 text-[0.72rem] font-semibold uppercase tracking-[0.14em] text-info">
            Example
          </span>
        </div>
        <p className="mt-3 max-w-2xl text-lg text-text-secondary">
          Describe the job and get an estimate. After you&rsquo;re ready, this is
          the task you track — funds can stay held until proof is reviewed.
        </p>

        {/* The app window — full width of the shell, rendered large. */}
        <div className="mt-10 overflow-hidden rounded-[1.75rem] border border-white/12 bg-[linear-gradient(180deg,rgba(30,30,38,0.95),rgba(16,16,22,0.95))] shadow-[0_70px_160px_-60px_rgba(91,45,255,0.6)] ring-1 ring-white/5 lg:mt-12">
          {/* Window chrome. */}
          <div className="flex items-center gap-3 border-b border-white/8 bg-white/[0.02] px-5 py-3.5 sm:px-7">
            <span className="flex items-center gap-2">
              <span className="h-3 w-3 rounded-full bg-white/15" />
              <span className="h-3 w-3 rounded-full bg-white/15" />
              <span className="h-3 w-3 rounded-full bg-white/15" />
            </span>
            <span className="ml-2 inline-flex items-center gap-2 rounded-md border border-white/10 bg-background/50 px-3 py-1 text-xs font-medium text-text-muted">
              <MapDotIcon className="h-3.5 w-3.5 text-brand-purple-glow" />
              hustlexp · your dashboard
            </span>
            <span className="ml-auto rounded-full border border-info/25 bg-info/10 px-2.5 py-0.5 text-[0.66rem] font-semibold uppercase tracking-[0.12em] text-info">
              Example
            </span>
          </div>

          {/* Body — two large panels. */}
          <div className="hx-grid-texture grid grid-cols-1 gap-px bg-white/[0.04] lg:grid-cols-[1.05fr_0.95fr]">
            {/* LEFT — the task. */}
            <div className="bg-[linear-gradient(180deg,rgba(26,26,33,0.96),rgba(16,16,22,0.96))] p-7 sm:p-9 lg:p-10">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow">
                Example task
              </p>
              <h3 className="mt-3 text-2xl font-semibold leading-snug text-text-primary sm:text-3xl">
                Move a couch from my apartment to storage
              </h3>
              <div className="mt-4 flex flex-wrap gap-2.5 text-sm">
                <span className="rounded-full border border-info/25 bg-info/10 px-3 py-1 font-medium text-info">
                  ZIP 98004
                </span>
                <span className="rounded-full border border-brand-purple/30 bg-brand-purple/10 px-3 py-1 font-medium text-brand-purple-glow">
                  Moving help
                </span>
              </div>

              {/* Estimate panel — clearly Example. */}
              <div className="mt-7 rounded-2xl border border-white/10 bg-white/[0.03] p-6">
                <div className="flex items-center justify-between">
                  <p className="inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                    <ReceiptIcon className="h-4 w-4 text-brand-purple-glow" />
                    Estimated task
                  </p>
                  <span className="rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[0.64rem] font-semibold uppercase tracking-[0.12em] text-info">
                    Example
                  </span>
                </div>
                <div className="mt-4 flex flex-wrap items-end gap-x-7 gap-y-2">
                  <span className="text-5xl font-semibold tracking-tight text-text-primary">
                    $30
                  </span>
                  <span className="pb-1.5 text-lg font-medium text-text-secondary">
                    1 hr 15 min
                  </span>
                  <span className="mb-1 rounded-full border border-info/25 bg-info/10 px-3 py-1 text-sm font-medium text-info">
                    Proof required
                  </span>
                </div>
                <p className="mt-4 text-sm text-text-muted">
                  Example only — your final price is set when you post.
                </p>
              </div>
            </div>

            {/* RIGHT — the live status rail. */}
            <div className="bg-[linear-gradient(180deg,rgba(22,22,29,0.96),rgba(14,14,19,0.96))] p-7 sm:p-9 lg:p-10">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-text-muted">
                Task status
              </p>

              <ol className="relative mt-6 space-y-7">
                {/* connector with an easing progress bead */}
                <span
                  aria-hidden
                  className="absolute left-[0.6875rem] top-2 bottom-6 w-px bg-gradient-to-b from-brand-purple-glow/60 via-brand-purple/30 to-white/10"
                >
                  <span
                    className="hx-progress absolute -left-[3px] top-0 h-2 w-2 rounded-full bg-brand-purple-glow shadow-[0_0_12px_-1px_rgba(139,92,246,0.9)]"
                    style={{ "--hx-progress-h": "7.5rem" } as React.CSSProperties}
                  />
                </span>
                <StatusRow lit label="Task created" sub="Your task is posted." />
                <StatusRow
                  lit
                  label="Payment funded"
                  sub="Held in escrow, not released."
                />
                <StatusRow
                  label="Waiting for Hustler matching"
                  sub="No Hustler has accepted yet."
                />
              </ol>

              {/* Escrow note. */}
              <div className="mt-8 flex items-start gap-3.5 rounded-2xl border border-info/20 bg-info/[0.06] p-5">
                <span className="mt-0.5 flex-none text-info">
                  <EscrowIcon className="h-6 w-6" />
                </span>
                <p className="text-[0.95rem] leading-relaxed text-text-secondary">
                  Funds can stay held until proof is reviewed. Nothing releases
                  until you approve the work.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/**
 * One status row. `lit` = a backend-provable state, rendered in brand purple
 * (NEVER green on this entry surface). Unlit = an honest pending state shown as a
 * hollow, gently-floating marker.
 */
function StatusRow({
  lit = false,
  label,
  sub,
}: {
  lit?: boolean;
  label: string;
  sub: string;
}) {
  return (
    <li className="relative flex items-start gap-4 pl-0">
      <span className="relative z-10 mt-0.5 flex-none">
        {lit ? (
          <span
            aria-hidden
            className="block h-[1.375rem] w-[1.375rem] rounded-full border-2 border-brand-purple-glow bg-brand-purple/20 shadow-[0_0_16px_-2px_rgba(139,92,246,0.9)]"
          />
        ) : (
          <span
            aria-hidden
            className="hx-pin block h-[1.375rem] w-[1.375rem] rounded-full border-2 border-dashed border-text-muted"
          />
        )}
      </span>
      <div className="min-w-0 pt-px">
        <p
          className={
            "text-lg font-semibold " +
            (lit ? "text-text-primary" : "text-text-secondary")
          }
        >
          {label}
        </p>
        <p className="mt-0.5 text-sm text-text-muted">{sub}</p>
      </div>
    </li>
  );
}
