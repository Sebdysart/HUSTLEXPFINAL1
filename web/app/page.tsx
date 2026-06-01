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
} from "@/components/hx-icons";

/**
 * Public Poster funnel homepage (C3) — full-width premium rebuild.
 *
 * Server-rendered for SEO + fast LCP. The interactive form is the only client
 * island (components/funnel-form.tsx) and its behavior is untouched here —
 * page.tsx only owns layout, composition, and presentation.
 *
 * Layout: sticky premium nav → two-column hero (copy left, the task funnel as an
 * elevated product card right) → cinematic flow demo theater → trust band.
 * Content lives in a 1280px shell with full-bleed gradient/aurora behind it so
 * the page fills the viewport instead of stranding a narrow centered column.
 *
 * COLOR LAW: entry surface → black + purple/violet + info-blue + white only.
 * Green is success-state only and never appears here.
 *
 * HONESTY LAW: no fake liquidity, counts, response times, testimonials, logos,
 * or "background-checked"/insurance claims. Every trust line is a real mechanic
 * (escrow, proof-before-release, manual review). Live numbers only ever come
 * from the backend via <LocalAvailability> inside the funnel.
 */
export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <PageView event="landing_view" />

      {/* Premium sticky navigation. */}
      <header className="sticky top-0 z-40 border-b border-white/5 bg-background/70 backdrop-blur-xl">
        <div className="mx-auto flex h-16 w-full max-w-[1280px] items-center justify-between px-6 lg:px-8">
          <div className="flex items-center gap-3">
            <span className="font-mono text-base font-semibold tracking-tight text-text-primary">
              HustleXP
            </span>
            <span className="hidden rounded-full border border-brand-purple/30 bg-brand-purple/10 px-2.5 py-0.5 text-[0.7rem] font-semibold uppercase tracking-[0.14em] text-brand-purple-glow sm:inline">
              Eastside beta
            </span>
          </div>
          <nav className="hidden items-center gap-8 text-sm font-medium text-text-secondary md:flex">
            <a
              href="#post"
              className="transition hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
            >
              Post a task
            </a>
            <Link
              href="/business"
              className="transition hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
            >
              For businesses
            </Link>
            <Link
              href="/dashboard"
              className="inline-flex items-center rounded-lg border border-white/15 px-3.5 py-1.5 transition hover:border-white/30 hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
            >
              Dashboard
            </Link>
          </nav>
        </div>
      </header>

      <main className="relative flex-1">
        {/* HERO — full-bleed background, 1280px two-column content shell. */}
        <section className="relative isolate overflow-hidden">
          <HeroAurora />
          {/* Full-width brand wash so the page never reads as a narrow column. */}
          <div
            aria-hidden
            className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(70%_55%_at_70%_0%,rgba(91,45,255,0.20),transparent_72%)]"
          />

          <div className="mx-auto grid w-full max-w-[1280px] grid-cols-1 items-center gap-10 px-6 pb-12 pt-10 lg:grid-cols-[1.05fr_0.95fr] lg:gap-14 lg:px-8 lg:pb-16 lg:pt-16">
            {/* LEFT — dominant headline + value + CTAs. */}
            <div className="flex flex-col gap-7 text-center lg:text-left">
              <p
                className="hx-reveal text-xs font-semibold uppercase tracking-[0.2em] text-brand-purple-glow"
                style={{ "--hx-i": 0 } as React.CSSProperties}
              >
                Eastside beta · Redmond · Bellevue · Sammamish · Kirkland · Issaquah
              </p>
              <h1
                className="hx-reveal text-balance text-5xl font-semibold leading-[1.02] tracking-tight text-text-primary sm:text-6xl lg:text-7xl"
                style={{ "--hx-i": 1 } as React.CSSProperties}
              >
                Get it done today, on the Eastside.
              </h1>
              <p
                className="hx-reveal mx-auto max-w-xl text-lg font-medium text-info lg:mx-0 lg:text-xl"
                style={{ "--hx-i": 2 } as React.CSSProperties}
              >
                Describe a task, get a fair estimate, and dispatch a local
                Hustler. You only pay when the work is approved.
              </p>

              <div
                className="hx-reveal flex flex-col items-center gap-3 sm:flex-row lg:items-start"
                style={{ "--hx-i": 3 } as React.CSSProperties}
              >
                <a
                  href="#post"
                  className="hx-shimmer inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-7 py-3.5 text-base font-semibold text-text-primary shadow-[0_14px_50px_-16px_rgba(91,45,255,0.9)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow sm:w-auto"
                >
                  Post a task
                </a>
                <Link
                  href="/business"
                  className="inline-flex w-full items-center justify-center rounded-xl border border-white/15 px-7 py-3.5 text-base font-medium text-text-secondary transition hover:border-white/30 hover:text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:w-auto"
                >
                  For businesses
                </Link>
              </div>

              {/* Honest mechanic trust line. */}
              <ul
                className="hx-reveal mt-1 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm text-text-secondary lg:justify-start"
                style={{ "--hx-i": 4 } as React.CSSProperties}
              >
                <TrustChip icon={<EscrowIcon className="h-4 w-4" />}>
                  Funds held until proof is reviewed
                </TrustChip>
                <TrustChip icon={<ProofIcon className="h-4 w-4" />}>
                  Proof before release
                </TrustChip>
                <TrustChip icon={<MapDotIcon className="h-4 w-4" />}>
                  Availability builds as Hustlers join
                </TrustChip>
              </ul>
            </div>

            {/* RIGHT — the funnel, presented as the core product engine. */}
            <div
              id="post"
              className="hx-reveal relative scroll-mt-20"
              style={{ "--hx-i": 3 } as React.CSSProperties}
            >
              <div
                aria-hidden
                className="absolute -inset-3 -z-10 rounded-[2rem] bg-brand-purple/10 blur-2xl"
              />
              <div className="rounded-3xl border border-white/12 bg-elevated/50 p-6 shadow-[0_50px_120px_-50px_rgba(91,45,255,0.75)] ring-1 ring-white/5 backdrop-blur-md sm:p-8">
                <div className="mb-5 flex items-center justify-between">
                  <p className="text-sm font-semibold uppercase tracking-[0.16em] text-brand-purple-glow">
                    Post a task
                  </p>
                  <span className="rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[0.7rem] font-semibold uppercase tracking-[0.14em] text-info">
                    Free estimate
                  </span>
                </div>
                <FunnelForm />
              </div>
            </div>
          </div>
        </section>

        {/* Cinematic flow demo — wide "how it works" theater. */}
        <CinematicFlowDemo />

        {/* Trust band — real mechanics, wider rhythm. */}
        <section
          aria-labelledby="why"
          className="border-t border-white/5"
        >
          <div className="mx-auto w-full max-w-[1280px] px-6 py-16 lg:px-8 lg:py-20">
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
        <div className="mx-auto w-full max-w-[1280px] px-6 py-8 lg:px-8">
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
