"use client";

import { notFound } from "next/navigation";
import {
  signInWithEmailAndPassword,
  type AuthError,
} from "firebase/auth";
import { useState, type FormEvent } from "react";
import { firebaseAuth } from "@/lib/firebase";
import { trpc } from "@/lib/trpc";
import { useAuth } from "@/providers/auth-provider";

/**
 * C2 smoke page. Dev-only. Proves: tRPC client wiring, CORS, Firebase Bearer
 * header, and the auth-token-refresh link. Returns 404 in production builds.
 */
export default function DevMePage() {
  if (process.env.NODE_ENV === "production") notFound();
  return <SmokeView />;
}

function SmokeView() {
  const { user, loading, signOut } = useAuth();
  const ping = trpc.health.ping.useQuery();
  const me = trpc.user.me.useQuery(undefined, {
    enabled: !loading && !!user,
  });

  return (
    <main className="mx-auto max-w-2xl space-y-8 p-8 font-mono text-sm text-text-primary">
      <h1 className="text-xl font-semibold">/dev/me — C2 wiring smoke</h1>

      <section>
        <h2 className="mb-2 text-base font-semibold">Auth</h2>
        <pre className="rounded bg-black/40 p-3 text-xs">
          {JSON.stringify(
            { loading, uid: user?.uid ?? null, email: user?.email ?? null },
            null,
            2
          )}
        </pre>
        {user ? (
          <button
            type="button"
            onClick={() => signOut()}
            className="mt-2 rounded bg-brand-purple px-3 py-1 text-xs font-semibold text-white"
          >
            Sign out
          </button>
        ) : (
          <SignInForm />
        )}
      </section>

      <section>
        <h2 className="mb-2 text-base font-semibold">
          health.ping <span className="opacity-60">(public)</span>
        </h2>
        <pre className="rounded bg-black/40 p-3 text-xs">
          {ping.isLoading
            ? "loading…"
            : ping.error
            ? `ERROR: ${ping.error.message}`
            : JSON.stringify(ping.data, null, 2)}
        </pre>
      </section>

      <section>
        <h2 className="mb-2 text-base font-semibold">
          user.me <span className="opacity-60">(protected)</span>
        </h2>
        <pre className="rounded bg-black/40 p-3 text-xs">
          {!user
            ? "(sign in to enable)"
            : me.isLoading
            ? "loading…"
            : me.error
            ? `ERROR: ${me.error.message}`
            : JSON.stringify(me.data, null, 2)}
        </pre>
      </section>
    </main>
  );
}

function SignInForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await signInWithEmailAndPassword(firebaseAuth(), email, password);
    } catch (err) {
      setError(((err as AuthError)?.message) ?? "Sign-in failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <form onSubmit={submit} className="mt-3 flex flex-col gap-2">
      <input
        type="email"
        autoComplete="email"
        required
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="email"
        className="rounded border border-white/20 bg-black/40 px-2 py-1 text-xs"
      />
      <input
        type="password"
        autoComplete="current-password"
        required
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="password"
        className="rounded border border-white/20 bg-black/40 px-2 py-1 text-xs"
      />
      <button
        type="submit"
        disabled={busy}
        className="rounded bg-brand-purple px-3 py-1 text-xs font-semibold text-white disabled:opacity-50"
      >
        {busy ? "signing in…" : "Sign in"}
      </button>
      {error && <p className="text-xs text-error-red">{error}</p>}
    </form>
  );
}
