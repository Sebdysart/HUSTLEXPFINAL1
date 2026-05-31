import { FunnelForm } from "@/components/funnel-form";
import { PageView } from "@/components/page-view";

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
 */
export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <PageView event="landing_view" />
      <header className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
        <span className="font-mono text-sm font-semibold tracking-tight text-text-primary">
          HustleXP
        </span>
      </header>

      <main className="relative flex-1">
        <section className="relative mx-auto flex w-full max-w-3xl flex-col gap-8 px-6 pb-16 pt-8 sm:pt-12 md:pt-16">
          {/* Purple atmosphere behind the hero (entry-screen composition). */}
          <div
            aria-hidden
            className="pointer-events-none absolute left-1/2 top-0 -z-10 h-72 w-72 -translate-x-1/2 rounded-full bg-brand-purple opacity-20 blur-[120px]"
          />

          <div className="space-y-4 text-center sm:text-left">
            <h1 className="text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl md:text-6xl">
              What can you get done today?
            </h1>
            <p className="text-base font-medium text-info sm:text-lg">
              You only pay when the work is approved.
            </p>
          </div>

          <FunnelForm />

          <p className="text-sm text-text-muted">
            Serving Redmond, Sammamish, Bellevue, and the rest of the Eastside.
          </p>
        </section>

        <section
          aria-labelledby="why"
          className="mx-auto w-full max-w-5xl border-t border-white/5 px-6 py-16 sm:py-20"
        >
          <h2
            id="why"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            Why HustleXP
          </h2>
          <ul className="mt-8 grid grid-cols-1 gap-x-10 gap-y-8 sm:grid-cols-2">
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
              title="Verified for higher-risk tasks"
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
      <span className="mt-1 inline-flex h-9 w-9 flex-none items-center justify-center rounded-lg bg-elevated text-info ring-1 ring-white/5">
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
