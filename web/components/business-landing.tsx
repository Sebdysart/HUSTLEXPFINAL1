import Link from "next/link";
import { BusinessIntakeForm } from "@/components/business-intake-form";
import { HeroAurora } from "@/components/hero-aurora";

/**
 * Business demand-sensing landing page (Roadmap E1).
 *
 * A dedicated B2B entry surface for local Eastside businesses to register early
 * INTEREST in flexible task help. The two hero CTAs are plain anchors that
 * scroll to the #register intake form below.
 *
 * HONESTY LAW (same as the consumer side, stricter for a business buyer): no
 * insurance / "insured" claims, no "background-checked" copy, no guaranteed
 * worker / guaranteed fulfillment / SLA / response-time claims, no fabricated
 * Hustler liquidity, no fake logos/testimonials/counts. Trust copy describes
 * MECHANICS only. Business types and use cases are illustrative of what CAN be
 * posted — never presented as real activity.
 *
 * COLOR LAW: entry surface → Black + Purple brand only. Green is success-state
 * only and never appears here. Blue is the info/trust accent.
 *
 * Motion: decorative CSS-only entrance/aurora (globals.css), disabled under
 * prefers-reduced-motion. No behavior, no data, no new dependencies.
 */

const BUSINESS_TYPES = [
  "Event venues",
  "Offices",
  "Retail shops",
  "Property managers",
  "Moving & storage operators",
  "Small service businesses",
];

const USE_CASES = [
  "Event setup",
  "Moving help",
  "Pickup / dropoff",
  "Errands",
  "Furniture assembly",
  "Cleanup",
  "Inventory runs",
  "Flexible labor support",
];

export function BusinessLanding() {
  return (
    <div className="flex flex-1 flex-col">
      <header className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
        <Link
          href="/"
          className="font-mono text-sm font-semibold tracking-tight text-text-primary focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
        >
          HustleXP
        </Link>
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
              Eastside beta · For local businesses
            </p>
            <h1
              className="hx-reveal text-balance text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl md:text-6xl"
              style={{ "--hx-i": 1 } as React.CSSProperties}
            >
              Local task help for your Eastside business.
            </h1>
            <p
              className="hx-reveal max-w-xl text-base font-medium text-info sm:text-lg"
              style={{ "--hx-i": 2 } as React.CSSProperties}
            >
              Register early interest in on-demand Eastside task help. Availability
              builds as Hustlers join — no guaranteed timeline.
            </p>
          </div>

          <div
            className="hx-reveal flex flex-col gap-3 sm:flex-row sm:items-center"
            style={{ "--hx-i": 3 } as React.CSSProperties}
          >
            <a
              href="#register"
              className="hx-shimmer inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-8 py-4 text-base font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow sm:w-auto"
            >
              Register your business
            </a>
            <a
              href="#register"
              className="inline-flex w-full items-center justify-center rounded-xl border border-white/15 px-8 py-4 text-base font-medium text-text-secondary transition hover:border-white/30 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple sm:w-auto"
            >
              Request a call
            </a>
          </div>

          <p
            className="hx-reveal text-sm text-text-muted"
            style={{ "--hx-i": 4 } as React.CSSProperties}
          >
            Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.
          </p>
        </section>

        {/* Who it's for — compact chip row (distinct from the use-case list below). */}
        <section
          aria-labelledby="business-types"
          className="mx-auto w-full max-w-5xl px-6 pb-2 pt-4"
        >
          <h2
            id="business-types"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            Built for local businesses like these
          </h2>
          <ul className="mt-6 flex flex-wrap gap-2.5">
            {BUSINESS_TYPES.map((type) => (
              <li
                key={type}
                className="rounded-full border border-white/10 bg-elevated/60 px-4 py-2 text-sm text-text-secondary"
              >
                {type}
              </li>
            ))}
          </ul>
          <p className="mt-4 text-xs text-text-muted">
            Illustrative — examples of who can register interest, not a list of
            current customers.
          </p>
        </section>

        {/* What you can post — bulleted list (distinct from the chip row above). */}
        <section
          aria-labelledby="use-cases"
          className="mx-auto w-full max-w-5xl px-6 pb-2 pt-12"
        >
          <h2
            id="use-cases"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            The kinds of work you can post
          </h2>
          <ul className="mt-6 grid grid-cols-1 gap-x-8 gap-y-3 sm:grid-cols-2 lg:grid-cols-3">
            {USE_CASES.map((useCase) => (
              <li
                key={useCase}
                className="flex items-start gap-3 text-sm text-text-secondary"
              >
                <span
                  aria-hidden
                  className="mt-1.5 h-1.5 w-1.5 flex-none rounded-full bg-brand-purple-glow"
                />
                {useCase}
              </li>
            ))}
          </ul>
          <p className="mt-4 text-xs text-text-muted">
            Examples of the kinds of work you can post — not a list of completed
            tasks.
          </p>
        </section>

        <section
          aria-labelledby="trust"
          className="mx-auto w-full max-w-5xl border-t border-white/5 px-6 py-16 sm:py-20"
        >
          <h2
            id="trust"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            How payments and safety work
          </h2>
          <ul className="mt-8 grid grid-cols-1 gap-x-10 gap-y-6 sm:grid-cols-2">
            <TrustBullet
              icon={<LockIcon />}
              title="Secure payments"
              body="Funds can be held until proof is reviewed — nothing releases before then."
            />
            <TrustBullet
              icon={<CameraIcon />}
              title="Proof before release"
              body="Hustlers submit photo or video proof, reviewed before any funds release."
            />
            <TrustBullet
              icon={<ReviewIcon />}
              title="Manual review for higher-risk work"
              body="Higher-risk tasks are reviewed by our team before they go live."
            />
            <TrustBullet
              icon={<ShieldIcon />}
              title="Identity and trust checks for higher-risk tasks"
              body="Higher-risk work requires matching identity and trust checks before it can be posted."
            />
          </ul>
        </section>

        <section
          id="register"
          aria-labelledby="register-heading"
          className="mx-auto w-full max-w-3xl scroll-mt-6 border-t border-white/5 px-6 py-16 sm:py-20"
        >
          <div className="relative rounded-2xl border border-white/10 bg-elevated/60 px-6 py-8 shadow-[0_36px_90px_-50px_rgba(91,45,255,0.6)] sm:px-8">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow">
              Early access
            </p>
            <h2
              id="register-heading"
              className="mt-3 text-2xl font-semibold tracking-tight text-text-primary sm:text-3xl"
            >
              Register your interest
            </h2>
            <p className="mt-3 text-base text-info">
              We&apos;re onboarding Eastside businesses gradually. Tell us about
              your recurring work — every business is reviewed manually, and
              there&apos;s no guaranteed timeline.
            </p>
            <div className="mt-8">
              <BusinessIntakeForm />
            </div>
          </div>
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

function ReviewIcon() {
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
      <rect x="4" y="3" width="12" height="14" rx="2" />
      <path d="M7 8h6M7 11h4" />
      <path d="m12.5 14 1.4 1.4 2.6-2.8" />
    </svg>
  );
}

function ShieldIcon() {
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
      <path d="M10 2.5 4 5v4.5c0 3.5 2.4 6.6 6 8 3.6-1.4 6-4.5 6-8V5l-6-2.5Z" />
      <path d="m7.5 10 1.7 1.7 3.3-3.4" />
    </svg>
  );
}
