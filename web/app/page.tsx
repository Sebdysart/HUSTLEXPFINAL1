/**
 * Homepage shell (C1). Real task-input funnel lands in C3.
 * COLOR LAW: entry screen → Black + Purple brand. Green is FORBIDDEN here
 * (success-only). Trust messaging uses info-blue. CTA accent = brand purple.
 */
export default function Home() {
  return (
    <main className="relative flex flex-1 flex-col items-center justify-center overflow-hidden px-6 py-24 text-center">
      {/* Purple glow behind the brand mark (per entry-screen composition) */}
      <div
        aria-hidden
        className="pointer-events-none absolute -z-10 h-72 w-72 rounded-full bg-brand-purple opacity-20 blur-[100px]"
      />

      <h1 className="max-w-2xl text-4xl font-semibold tracking-tight text-text-primary sm:text-5xl">
        Get local tasks done.
      </h1>
      <p className="mt-4 max-w-md text-lg text-text-secondary">
        Post a task, get it done by a local Hustler.
      </p>
      <p className="mt-3 max-w-md text-base font-medium text-info">
        You only pay when the work is approved.
      </p>

      <p className="mt-10 text-sm text-text-muted">Coming soon to the Eastside.</p>
    </main>
  );
}
