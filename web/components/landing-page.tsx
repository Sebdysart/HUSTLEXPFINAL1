import Link from "next/link";
import { FunnelForm, type CategoryId } from "@/components/funnel-form";
import { PageView } from "@/components/page-view";
import { HeroAurora } from "@/components/hero-aurora";

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
 *
 * Motion: decorative CSS-only entrance/aurora (globals.css), disabled under
 * prefers-reduced-motion. No behavior, no data, no new dependencies.
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
        <section className="relative mx-auto flex w-full max-w-3xl flex-col gap-7 px-6 pb-16 pt-10 sm:pt-14 md:pt-20">
          <HeroAurora />

          <div className="space-y-4 text-center sm:text-left">
            <p
              className="hx-reveal text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow"
              style={{ "--hx-i": 0 } as React.CSSProperties}
            >
              {eyebrow}
            </p>
            <h1
              className="hx-reveal text-balance text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl md:text-6xl"
              style={{ "--hx-i": 1 } as React.CSSProperties}
            >
              {headline}
            </h1>
            <p
              className="hx-reveal max-w-xl text-base font-medium text-info sm:text-lg"
              style={{ "--hx-i": 2 } as React.CSSProperties}
            >
              {subhead}
            </p>
          </div>

          {/* The funnel is the product — give it a deliberate, elevated frame. */}
          <div
            className="hx-reveal relative rounded-3xl border border-white/10 bg-white/[0.02] p-3 shadow-[0_36px_90px_-48px_rgba(91,45,255,0.6)] backdrop-blur-sm sm:p-5"
            style={{ "--hx-i": 3 } as React.CSSProperties}
          >
            <FunnelForm initialZip={initialZip} initialCategory={initialCategory} />
          </div>

          <p
            className="hx-reveal text-sm text-text-muted"
            style={{ "--hx-i": 4 } as React.CSSProperties}
          >
            Serving Redmond, Sammamish, Bellevue, Kirkland, and Issaquah.
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
          <ul className="mt-6 grid grid-cols-1 gap-x-8 gap-y-3 sm:grid-cols-2">
            {examples.map((example) => (
              <li
                key={example}
                className="flex items-start gap-3 text-sm text-text-secondary"
              >
                <span
                  aria-hidden
                  className="mt-1.5 h-1.5 w-1.5 flex-none rounded-full bg-brand-purple-glow"
                />
                {example}
              </li>
            ))}
          </ul>
          <p className="mt-5 text-xs text-text-muted">
            Examples of what you can post — not a list of completed tasks. Local
            availability appears as real tasks complete.
          </p>
        </section>

        {/* How it works — numbered process rail, consistent with the homepage. */}
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
              body="Get an AI-suggested price and time before you commit. The final price is yours."
            />
            <Step
              n="2"
              title="Funds go into escrow"
              body="Your payment is held in escrow until proof is reviewed — nothing releases before then."
            />
            <Step
              n="3"
              title="Proof, then release"
              body="Hustlers submit photo or video proof. Funds release only after you approve it."
            />
          </ol>
          <p className="mt-8 text-xs text-text-muted">
            We&apos;re starting on the Eastside. Local availability appears as real
            tasks complete.
          </p>
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
    <li className="flex flex-col gap-3">
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
