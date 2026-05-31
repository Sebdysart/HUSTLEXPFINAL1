import { FunnelForm } from "@/components/funnel-form";
import { PageView } from "@/components/page-view";
import { HeroAurora } from "@/components/hero-aurora";

/**
 * Public Poster funnel homepage (C3).
 *
 * Server-rendered for SEO + fast LCP. The interactive form is the only
 * client island (components/funnel-form.tsx).
 *
 * COLOR LAW: entry surface → Black + Purple brand only.
 * - Green is FORBIDDEN here (success-state only).
 * - Blue (info) is the trust-line accent.
 * - Purple is the CTA / brand accent.
 *
 * HONESTY LAW: no fake liquidity, no fake completed-task counts, no fake
 * response times, no "background-checked" copy until Checkr is live, no
 * insurance / self-protection claims. Trust bullets describe mechanics
 * that ARE real (escrow, proof-before-release, TrustTierService).
 *
 * Motion: decorative CSS-only entrance/aurora (globals.css), disabled under
 * prefers-reduced-motion. No behavior, no data, no new dependencies.
 */
export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <PageView event="landing_view" />
      <header className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
        <span className="font-mono text-sm font-semibold tracking-tight text-text-primary">
          HustleXP
        </span>
        <span className="text-xs font-medium uppercase tracking-[0.18em] text-text-muted">
          Eastside beta
        </span>
      </header>

      <main className="relative flex-1">
        <section className="relative mx-auto flex w-full max-w-3xl flex-col gap-7 px-6 pb-16 pt-10 sm:pt-14 md:pt-20">
          <HeroAurora />

          <div className="space-y-4 text-center sm:text-left">
            <p
              className="hx-reveal text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow"
              style={{ "--hx-i": 0 } as React.CSSProperties}
            >
              Eastside beta · Redmond · Bellevue · Sammamish
            </p>
            <h1
              className="hx-reveal text-balance text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl md:text-6xl"
              style={{ "--hx-i": 1 } as React.CSSProperties}
            >
              Get it done today, on the Eastside.
            </h1>
            <p
              className="hx-reveal max-w-xl text-base font-medium text-info sm:text-lg"
              style={{ "--hx-i": 2 } as React.CSSProperties}
            >
              Describe a task, get a fair estimate, and dispatch a local Hustler.
              You only pay when the work is approved.
            </p>
          </div>

          {/* The funnel is the product — give it a deliberate, elevated frame. */}
          <div
            className="hx-reveal relative rounded-3xl border border-white/10 bg-white/[0.02] p-3 shadow-[0_36px_90px_-48px_rgba(91,45,255,0.6)] backdrop-blur-sm sm:p-5"
            style={{ "--hx-i": 3 } as React.CSSProperties}
          >
            <FunnelForm />
          </div>

          <p
            className="hx-reveal text-sm text-text-muted"
            style={{ "--hx-i": 4 } as React.CSSProperties}
          >
            Serving Redmond, Sammamish, Bellevue, Kirkland, and Issaquah.
          </p>
        </section>

        {/* How it works — a numbered process rail, not another card grid. */}
        <section
          aria-labelledby="how"
          className="mx-auto w-full max-w-5xl border-t border-white/5 px-6 py-16 sm:py-20"
        >
          <h2
            id="how"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            How it works
          </h2>
          <ol className="mt-8 grid grid-cols-1 gap-x-8 gap-y-8 sm:grid-cols-3">
            <Step
              n="1"
              title="Describe the task"
              body="Tell us what you need done and get an AI-suggested price and time. The final price is yours."
            />
            <Step
              n="2"
              title="Funds go into escrow"
              body="Your payment is held in escrow when you dispatch — nothing releases before the work is reviewed."
            />
            <Step
              n="3"
              title="Approve, then release"
              body="A Hustler submits photo or video proof. Funds release only after you approve it."
            />
          </ol>
        </section>

        {/* Trust mechanics — a lighter inline band, distinct from the steps above. */}
        <section
          aria-labelledby="why"
          className="mx-auto w-full max-w-5xl border-t border-white/5 px-6 py-14 sm:py-16"
        >
          <h2
            id="why"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            Built to be trustworthy
          </h2>
          <ul className="mt-8 grid grid-cols-1 gap-x-10 gap-y-6 sm:grid-cols-2">
            <TrustBullet
              icon={<LockIcon />}
              title="Secure payment"
              body="Funds are held in escrow until you approve the work."
            />
            <TrustBullet
              icon={<CameraIcon />}
              title="Proof before release"
              body="Hustlers submit photo or video proof before any funds release."
            />
            <TrustBullet
              icon={<StarIcon />}
              title="Ratings & reviews"
              body="Poster feedback appears on Hustler profiles as tasks are completed."
            />
            <TrustBullet
              icon={<ShieldCheckIcon />}
              title="Reviewed for higher-risk tasks"
              body="Hustlers complete identity and trust checks for higher-stakes work."
            />
          </ul>
        </section>
      </main>

      <footer className="mx-auto w-full max-w-6xl border-t border-white/5 px-6 py-6">
        <p className="text-xs text-text-muted">
          © HustleXP · Eastside beta · No guaranteed timeline.
        </p>
      </footer>
    </div>
  );
}

function Step({ n, title, body }: { n: string; title: string; body: string }) {
  return (
    <li className="relative flex flex-col gap-3">
      <span className="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-brand-purple/40 bg-brand-purple/10 font-mono text-base font-semibold text-brand-purple-glow">
        {n}
      </span>
      <div>
        <p className="text-base font-semibold text-text-primary">{title}</p>
        <p className="mt-1 text-sm text-text-secondary">{body}</p>
      </div>
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
    <li className="flex gap-4">
      <span className="mt-0.5 inline-flex h-9 w-9 flex-none items-center justify-center rounded-lg bg-elevated text-info ring-1 ring-white/5">
        {icon}
      </span>
      <div>
        <p className="text-base font-semibold text-text-primary">{title}</p>
        <p className="mt-1 text-sm text-text-secondary">{body}</p>
      </div>
    </li>
  );
}

function LockIcon() {
  return (
    <svg
      viewBox="0 0 20 20"
      aria-hidden
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="4" y="9" width="12" height="8" rx="2" />
      <path d="M7 9V6a3 3 0 1 1 6 0v3" />
    </svg>
  );
}

function CameraIcon() {
  return (
    <svg
      viewBox="0 0 20 20"
      aria-hidden
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M3 7h2l1.5-2h7L15 7h2a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1Z" />
      <circle cx="10" cy="12" r="3" />
    </svg>
  );
}

function StarIcon() {
  return (
    <svg
      viewBox="0 0 20 20"
      aria-hidden
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M10 3l2.36 4.78 5.28.77-3.82 3.72.9 5.25L10 15.27 5.28 17.52l.9-5.25L2.36 8.55l5.28-.77L10 3z" />
    </svg>
  );
}

function ShieldCheckIcon() {
  return (
    <svg
      viewBox="0 0 20 20"
      aria-hidden
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M10 2.5 4 5v5c0 4 2.7 6.7 6 7.5 3.3-.8 6-3.5 6-7.5V5l-6-2.5Z" />
      <path d="M7.5 10.2 9.3 12l3.4-3.4" />
    </svg>
  );
}
