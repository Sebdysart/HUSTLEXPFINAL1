import Link from "next/link";
import { FunnelForm } from "@/components/funnel-form";
import { PageView } from "@/components/page-view";
import { HeroAurora } from "@/components/hero-aurora";
import { CinematicFlowDemo } from "@/components/cinematic-flow-demo";
import {
  EscrowIcon,
  ProofIcon,
  ChecklistIcon,
  MapDotIcon,
  ReceiptIcon,
  RouteIcon,
} from "@/components/hx-icons";

/**
 * Public Poster funnel homepage (C3) — "command center" rebuild.
 *
 * The task-creation experience IS the hero. Above the fold is a full-width,
 * viewport-filling two-column command center: a dominant headline + value on the
 * left, and a large elevated "task console" on the right that wraps the funnel
 * (the only client island, untouched behavior) and frames it with the real
 * product flow as inline status cues (estimate → escrow → proof → tracking).
 * Below it sits a wide app-screen preview of what a posted task looks like.
 *
 * Scale + light are deliberate: a 1400px shell, clamp() display type, lighter
 * charcoal panels over a purple/charcoal wash so the page reads as a premium
 * operating console — not a small artifact floating in a black void.
 *
 * COLOR LAW: entry surface → black/charcoal + purple/violet + info-blue + white
 * only. Green is success-state only and never appears here.
 *
 * HONESTY LAW: no fake liquidity, counts, response times, testimonials, logos,
 * or "background-checked"/insurance claims. Every line is a real mechanic
 * (escrow, proof-before-release, manual review). Live numbers only ever come
 * from the backend via <LocalAvailability> inside the funnel.
 */
export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <PageView event="landing_view" />

      {/* Premium sticky navigation — readable, not tiny. */}
      <header className="sticky top-0 z-40 border-b border-white/5 bg-background/70 backdrop-blur-xl">
        <div className="mx-auto flex h-[4.5rem] w-full max-w-[1400px] items-center justify-between px-6 lg:px-10">
          <div className="flex items-center gap-3">
            <span className="font-mono text-lg font-semibold tracking-tight text-text-primary">
              HustleXP
            </span>
            <span className="rounded-full border border-brand-purple/30 bg-brand-purple/10 px-3 py-1 text-[0.72rem] font-semibold uppercase tracking-[0.14em] text-brand-purple-glow">
              Eastside beta
            </span>
          </div>
          <nav className="flex items-center gap-2 text-[0.95rem] font-medium text-text-secondary sm:gap-7">
            <a
              href="#post"
              className="hidden rounded-lg px-2 py-1.5 transition hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:inline-flex"
            >
              Post a task
            </a>
            <Link
              href="/business"
              className="hidden rounded-lg px-2 py-1.5 transition hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:inline-flex"
            >
              For businesses
            </Link>
            <Link
              href="/dashboard"
              className="inline-flex items-center rounded-xl border border-white/15 px-4 py-2 transition hover:border-white/30 hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
            >
              Dashboard
            </Link>
          </nav>
        </div>
      </header>

      <main className="relative flex-1">
        {/* COMMAND CENTER — viewport-filling hero. */}
        <section className="relative isolate overflow-hidden">
          <HeroAurora />
          {/* Charcoal→black base + purple wash so it never reads as pure void. */}
          <div
            aria-hidden
            className="pointer-events-none absolute inset-0 -z-10 bg-[linear-gradient(180deg,#0e0e14_0%,#0a0a0f_55%,#070709_100%)]"
          />
          <div
            aria-hidden
            className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(60%_50%_at_72%_8%,rgba(91,45,255,0.22),transparent_70%)]"
          />

          <div className="mx-auto grid w-full max-w-[1400px] grid-cols-1 items-center gap-12 px-6 pb-16 pt-10 lg:grid-cols-[minmax(0,0.82fr)_minmax(0,1.18fr)] lg:gap-14 lg:px-10 lg:pb-20 lg:pt-16 lg:min-h-[calc(100svh-4.5rem)]">
            {/* LEFT — dominant headline + value + CTAs. */}
            <div className="flex flex-col gap-7 text-center lg:text-left">
              <p
                className="hx-reveal inline-flex items-center justify-center gap-2 text-xs font-semibold uppercase tracking-[0.2em] text-brand-purple-glow lg:justify-start"
                style={{ "--hx-i": 0 } as React.CSSProperties}
              >
                <span className="hx-livedot inline-block h-2 w-2 rounded-full bg-brand-purple-glow" />
                Eastside beta · Redmond · Bellevue · Sammamish · Kirkland · Issaquah
              </p>
              <h1
                className="hx-reveal text-balance font-semibold leading-[0.98] tracking-tight text-text-primary text-[clamp(2.85rem,5.4vw,5.5rem)]"
                style={{ "--hx-i": 1 } as React.CSSProperties}
              >
                Get real-world tasks handled on the Eastside.
              </h1>
              <p
                className="hx-reveal mx-auto max-w-xl text-balance text-lg font-medium text-text-secondary lg:mx-0 lg:text-2xl lg:leading-relaxed"
                style={{ "--hx-i": 2 } as React.CSSProperties}
              >
                Describe the job, get an estimate, and dispatch after you&rsquo;re
                ready.{" "}
                <span className="text-info">
                  Funds can stay held until proof is reviewed.
                </span>
              </p>

              <div
                className="hx-reveal flex flex-col items-center gap-3 sm:flex-row lg:items-start"
                style={{ "--hx-i": 3 } as React.CSSProperties}
              >
                <a
                  href="#post"
                  className="hx-shimmer inline-flex w-full items-center justify-center rounded-2xl bg-brand-purple px-8 py-4 text-lg font-semibold text-text-primary shadow-[0_18px_60px_-16px_rgba(91,45,255,0.95)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow sm:w-auto"
                >
                  Post a task
                </a>
                <Link
                  href="/business"
                  className="inline-flex w-full items-center justify-center rounded-2xl border border-white/15 px-8 py-4 text-lg font-medium text-text-secondary transition hover:border-white/30 hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:w-auto"
                >
                  For businesses
                </Link>
              </div>

              {/* Honest mechanic trust line. */}
              <ul
                className="hx-reveal mt-1 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-[0.95rem] text-text-secondary lg:justify-start"
                style={{ "--hx-i": 4 } as React.CSSProperties}
              >
                <TrustChip icon={<EscrowIcon className="h-4 w-4" />}>
                  Funds held until proof is reviewed
                </TrustChip>
                <TrustChip icon={<ProofIcon className="h-4 w-4" />}>
                  Proof before release
                </TrustChip>
                <TrustChip icon={<MapDotIcon className="h-4 w-4" />}>
                  Eastside beta
                </TrustChip>
              </ul>
            </div>

            {/* RIGHT — the task console: the product itself. */}
            <div
              id="post"
              className="hx-reveal relative scroll-mt-24"
              style={{ "--hx-i": 3 } as React.CSSProperties}
            >
              <div
                aria-hidden
                className="absolute -inset-4 -z-10 rounded-[2.5rem] bg-brand-purple/12 blur-3xl"
              />
              <div className="relative overflow-hidden rounded-[1.9rem] border border-white/12 bg-[linear-gradient(180deg,rgba(34,34,42,0.92),rgba(18,18,24,0.92))] shadow-[0_60px_140px_-50px_rgba(91,45,255,0.8)] ring-1 ring-white/5 backdrop-blur-md">
                <div
                  aria-hidden
                  className="hx-grid-texture pointer-events-none absolute inset-0 opacity-40"
                />

                {/* Console header bar. */}
                <div className="relative flex items-center justify-between border-b border-white/8 px-6 py-4 sm:px-8">
                  <div className="flex items-center gap-2.5">
                    <span className="hx-livedot h-2.5 w-2.5 rounded-full bg-brand-purple-glow shadow-[0_0_12px_-1px_rgba(139,92,246,0.9)]" />
                    <span className="text-sm font-semibold uppercase tracking-[0.16em] text-text-secondary">
                      Task console
                    </span>
                  </div>
                  <span className="rounded-full border border-info/30 bg-info/10 px-3 py-1 text-[0.72rem] font-semibold uppercase tracking-[0.14em] text-info">
                    Free estimate
                  </span>
                </div>

                {/* The funnel — the live product. */}
                <div className="relative p-6 sm:p-8">
                  <FunnelForm />
                </div>

                {/* Inline product flow — estimate → escrow → proof → tracking. */}
                <div className="relative border-t border-white/8 px-6 py-5 sm:px-8 sm:py-6">
                  <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                    <ConsoleCue
                      icon={<ReceiptIcon className="h-5 w-5" />}
                      label="Estimate"
                      sub="Price + time"
                    />
                    <ConsoleCue
                      icon={<EscrowIcon className="h-5 w-5" />}
                      label="Escrow"
                      sub="Funds held"
                    />
                    <ConsoleCue
                      icon={<ProofIcon className="h-5 w-5" />}
                      label="Proof"
                      sub="Before release"
                    />
                    <ConsoleCue
                      icon={<RouteIcon className="h-5 w-5" />}
                      label="Tracking"
                      sub="On your dashboard"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Wide app-screen preview of a posted task. */}
        <CinematicFlowDemo />

        {/* Trust band — real mechanics. */}
        <section aria-labelledby="why" className="border-t border-white/5">
          <div className="mx-auto w-full max-w-[1400px] px-6 py-16 lg:px-10 lg:py-20">
            <h2
              id="why"
              className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
            >
              Built to be trustworthy
            </h2>
            <ul className="mt-8 grid grid-cols-1 gap-x-10 gap-y-8 sm:grid-cols-2 lg:grid-cols-4">
              <TrustBullet
                icon={<EscrowIcon className="h-5 w-5" />}
                title="Secure payment"
                body="Funds are held in escrow until you approve the work."
              />
              <TrustBullet
                icon={<ProofIcon className="h-5 w-5" />}
                title="Proof before release"
                body="Hustlers submit photo or video proof before any funds release."
              />
              <TrustBullet
                icon={<ChecklistIcon className="h-5 w-5" />}
                title="Manual review for higher-risk work"
                body="Higher-risk tasks are reviewed before they can be posted."
              />
              <TrustBullet
                icon={<MapDotIcon className="h-5 w-5" />}
                title="Eastside beta"
                body="We're starting on the Eastside. Availability builds as Hustlers join."
              />
            </ul>
          </div>
        </section>
      </main>

      <footer className="border-t border-white/5">
        <div className="mx-auto w-full max-w-[1400px] px-6 py-8 lg:px-10">
          <p className="text-xs text-text-muted">
            © HustleXP · Eastside beta · No guaranteed timeline.
          </p>
        </div>
      </footer>
    </div>
  );
}

function TrustChip({
  icon,
  children,
}: {
  icon: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <li className="flex items-center gap-2">
      <span className="text-info">{icon}</span>
      <span>{children}</span>
    </li>
  );
}

/** One inline product-flow cue inside the task console. */
function ConsoleCue({
  icon,
  label,
  sub,
}: {
  icon: React.ReactNode;
  label: string;
  sub: string;
}) {
  return (
    <div className="flex items-center gap-3 rounded-xl border border-white/10 bg-white/[0.03] px-3 py-2.5 transition hover:border-brand-purple/30 hover:bg-white/[0.05]">
      <span className="inline-flex h-9 w-9 flex-none items-center justify-center rounded-lg border border-brand-purple/30 bg-brand-purple/10 text-brand-purple-glow">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-sm font-semibold text-text-primary">{label}</p>
        <p className="truncate text-xs text-text-muted">{sub}</p>
      </div>
    </div>
  );
}

function TrustBullet({
  icon,
  title,
  body,
}: {
  icon: React.ReactNode;
  title: string;
  body: string;
}) {
  return (
    <li className="flex flex-col gap-3">
      <span className="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-elevated text-info ring-1 ring-white/10">
        {icon}
      </span>
      <div>
        <p className="text-base font-semibold text-text-primary">{title}</p>
        <p className="mt-1 text-sm text-text-secondary">{body}</p>
      </div>
    </li>
  );
}
