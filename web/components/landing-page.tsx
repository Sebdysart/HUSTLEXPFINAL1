import Link from "next/link";
import { FunnelForm, type CategoryId } from "@/components/funnel-form";
import { PageView } from "@/components/page-view";

/**
 * Reusable local/category landing page template (C9).
 *
 * Every landing page (/redmond, /moving-help, …) is just this template with
 * page-specific copy. It does NOT invent a new flow: it embeds the exact same
 * proven <FunnelForm> the homepage uses, optionally prefilling the ZIP (local
 * pages) or category (category pages). The funnel's "Get estimate" button is
 * the CTA that routes the visitor into the existing draftEstimate → dispatch →
 * fund flow.
 *
 * HONESTY LAW (same as the homepage): no fake liquidity, no fake completed-task
 * counts, no fake response times, no fake Hustler counts, no "background-checked"
 * copy, no insurance/protection claims, no fake testimonials. The task examples
 * are illustrative of what CAN be posted — they are never presented as real
 * completed tasks or real local activity. Live marketplace numbers only ever
 * come from the backend via <LocalAvailability> inside the funnel.
 *
 * COLOR LAW: entry surface → Black + Purple brand only. Green is success-state
 * only and never appears here. Blue is the info/trust accent.
 */
export function LandingPage({
  eyebrow,
  headline,
  subhead,
  examplesHeading,
  examples,
  initialZip,
  initialCategory,
}: {
  /** Short context line above the H1, e.g. "Redmond · Eastside beta". */
  eyebrow: string;
  /** Page H1 — local or category specific. */
  headline: string;
  /** Sub-headline under the H1 (the escrow promise, info-blue). */
  subhead: string;
  /** Heading for the concrete-examples block. */
  examplesHeading: string;
  /** Concrete, illustrative task examples — what you CAN post, not real history. */
  examples: string[];
  /** ZIP prefill for local pages. */
  initialZip?: string;
  /** Category prefill for category pages. */
  initialCategory?: CategoryId;
}) {
  return (
    <div className="flex flex-1 flex-col">
      <PageView event="landing_view" />
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
        <section className="relative mx-auto flex w-full max-w-3xl flex-col gap-8 px-6 pb-16 pt-8 sm:pt-12 md:pt-16">
          {/* Purple atmosphere behind the hero (entry-screen composition). */}
          <div
            aria-hidden
            className="pointer-events-none absolute left-1/2 top-0 -z-10 h-72 w-72 -translate-x-1/2 rounded-full bg-brand-purple opacity-20 blur-[120px]"
          />

          <div className="space-y-4 text-center sm:text-left">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow">
              {eyebrow}
            </p>
            <h1 className="text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl md:text-6xl">
              {headline}
            </h1>
            <p className="text-base font-medium text-info sm:text-lg">{subhead}</p>
          </div>

          <FunnelForm initialZip={initialZip} initialCategory={initialCategory} />

          <p className="text-sm text-text-muted">
            Serving Redmond, Sammamish, Bellevue, and nearby Eastside areas.
          </p>
        </section>

        <section
          aria-labelledby="examples"
          className="mx-auto w-full max-w-3xl px-6 pb-4"
        >
          <h2
            id="examples"
            className="text-sm font-semibold uppercase tracking-[0.18em] text-text-muted"
          >
            {examplesHeading}
          </h2>
          <ul className="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2">
            {examples.map((example) => (
              <li
                key={example}
                className="rounded-xl border border-white/10 bg-elevated/60 px-4 py-3 text-sm text-text-secondary"
              >
                {example}
              </li>
            ))}
          </ul>
          <p className="mt-4 text-xs text-text-muted">
            Examples of what you can post — not a list of completed tasks. Local
            availability appears as real tasks complete.
          </p>
        </section>

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
          <ul className="mt-8 grid grid-cols-1 gap-x-10 gap-y-8 sm:grid-cols-2">
            <TrustBullet
              icon={<EstimateIcon />}
              title="Post a task and get an estimate"
              body="Describe the job and get an AI-suggested price and time before you commit. The final price is yours."
            />
            <TrustBullet
              icon={<LockIcon />}
              title="Funds stay in escrow"
              body="Your payment is held in escrow until proof is reviewed — nothing releases before then."
            />
            <TrustBullet
              icon={<CameraIcon />}
              title="Proof before release"
              body="Hustlers submit photo or video proof before any funds release."
            />
            <TrustBullet
              icon={<MapPinIcon />}
              title="Eastside beta"
              body="We're starting on the Eastside. Local availability appears as real tasks complete."
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

function EstimateIcon() {
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
      <path d="M7 7h6M7 10h6M7 13h3" />
    </svg>
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

function MapPinIcon() {
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
      <path d="M10 17.5c3-3.2 5-6 5-8.5a5 5 0 0 0-10 0c0 2.5 2 5.3 5 8.5Z" />
      <circle cx="10" cy="9" r="1.8" />
    </svg>
  );
}
