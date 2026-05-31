"use client";

import Link from "next/link";
import { signInWithEmailAndPassword, type AuthError } from "firebase/auth";
import {
  useEffect,
  useMemo,
  useRef,
  useState,
  type FormEvent,
  type ReactNode,
} from "react";
import { firebaseAuth } from "@/lib/firebase";
import { trpc } from "@/lib/trpc";
import { useAuth } from "@/providers/auth-provider";
import { capture } from "@/lib/analytics";
import { PageView } from "@/components/page-view";

// C8: Poster dashboard shell.
//
// Shows the authenticated poster's real funded/open tasks and the real
// escrow/funding state after C7 funding. A single page: a task list
// (task.listByPoster) on the left and a selected-task detail panel
// (task.getById + escrow.getByTaskId + a status timeline) on the right.
//
// Honesty invariants (do NOT violate):
//   - Every timeline step lights up ONLY when the backend proves it. A funded
//     task waiting for matching shows ONLY "Task created" + "Payment funded"
//     active; "Hustler accepted" / "Proof submitted" / "Payment released" stay
//     greyed until task.state / escrow.state proves them.
//   - No "matched", "accepted" (unless task.state proves it), "on the way",
//     "guaranteed", "protected", "insured", "background checked" copy.
//   - No fake applicants, ETAs, response times, or counts.
//   - Real data only — no fabrication anywhere.
//
// Out of scope for C8: proof review, release/refund/dispute UI, applicants UI,
// Hustler web flows, SEO, analytics.

const LAST_TASK_STORAGE_KEY = "hustlexp.lastTaskId.v1";

// Escrow states that prove funds were actually captured into escrow.
const FUNDED_ESCROW_STATES = [
  "FUNDED",
  "LOCKED_DISPUTE",
  "RELEASED",
  "REFUND_PARTIAL",
];
// Task states that prove a Hustler has accepted the task.
const ACCEPTED_TASK_STATES = [
  "ACCEPTED",
  "PROOF_SUBMITTED",
  "COMPLETED",
  "DISPUTED",
];
// Task states that prove proof has been submitted.
const PROOF_TASK_STATES = ["PROOF_SUBMITTED", "COMPLETED"];

function formatPrice(cents: number | undefined): string {
  if (typeof cents !== "number" || !Number.isFinite(cents)) return "—";
  return `$${(cents / 100).toFixed(2)}`;
}

function formatWhen(value: string | Date | undefined): string {
  if (!value) return "—";
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleString();
}

function readLastTaskId(): string | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(LAST_TASK_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { id?: string };
    return parsed?.id ?? null;
  } catch {
    return null;
  }
}

export default function DashboardPage() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <main className="mx-auto max-w-4xl p-8 text-sm text-text-muted">
        Loading…
      </main>
    );
  }

  if (!user) {
    return <SignInGate />;
  }

  return <DashboardBody />;
}

function DashboardBody() {
  const [lastTaskId, setLastTaskId] = useState<string | null>(null);
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);
  const [touchedSelection, setTouchedSelection] = useState(false);

  // Read the last created/funded task id (written by dispatch-section.tsx at
  // C6/C7) so the C7-funded task is always reachable — even for accounts that
  // aren't in poster mode and therefore can't use task.listByPoster.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    setLastTaskId(readLastTaskId());
  }, []);
  /* eslint-enable react-hooks/set-state-in-effect */

  const listQuery = trpc.task.listByPoster.useQuery(undefined, {
    retry: false,
  });

  const tasks = useMemo(
    () => listQuery.data?.tasks ?? [],
    [listQuery.data],
  );

  // Default selection: prefer the last funded task, else the first listed task.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    if (touchedSelection || selectedTaskId) return;
    if (lastTaskId) {
      setSelectedTaskId(lastTaskId);
    } else if (tasks.length > 0) {
      setSelectedTaskId(tasks[0].id);
    }
  }, [lastTaskId, tasks, selectedTaskId, touchedSelection]);
  /* eslint-enable react-hooks/set-state-in-effect */

  const hasList = tasks.length > 0;
  const showEmpty =
    !listQuery.isLoading && !hasList && !lastTaskId && !selectedTaskId;

  return (
    <main className="mx-auto max-w-5xl p-6 text-text-primary sm:p-8">
      <PageView event="dashboard_viewed" source_page="/dashboard" />
      <header className="mb-6">
        <h1 className="text-2xl font-semibold">Your tasks</h1>
        <p className="mt-1 text-sm text-text-muted">
          Track the status of tasks you&apos;ve posted and funded.
        </p>
      </header>

      <div className="grid gap-6 md:grid-cols-[minmax(0,1fr)_minmax(0,1.4fr)]">
        {/* Task list */}
        <section aria-label="Task list" className="flex flex-col gap-3">
          {listQuery.isLoading && (
            <p className="text-sm text-text-muted">Loading your tasks…</p>
          )}

          {hasList &&
            tasks.map((t) => {
              const selected = t.id === selectedTaskId;
              return (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => {
                    setTouchedSelection(true);
                    setSelectedTaskId(t.id);
                  }}
                  className={`rounded-xl border p-4 text-left transition ${
                    selected
                      ? "border-brand-purple/60 bg-elevated/70"
                      : "border-white/10 bg-elevated/40 hover:border-white/25"
                  }`}
                >
                  <p className="text-sm font-semibold text-text-primary">
                    {t.title}
                  </p>
                  <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-text-muted">
                    <span className="font-medium text-text-secondary">
                      {formatPrice(t.price)}
                    </span>
                    <StatePill state={t.state} />
                    {t.location && <span>ZIP {t.location}</span>}
                  </div>
                  <p className="mt-1 text-[11px] text-text-muted">
                    Created {formatWhen(t.created_at)}
                  </p>
                </button>
              );
            })}

          {!listQuery.isLoading && !hasList && lastTaskId && (
            <p className="text-sm text-text-muted">
              Showing your most recent task.
            </p>
          )}

          {showEmpty && (
            <div className="rounded-xl border border-white/10 bg-elevated/40 p-4">
              <p className="text-sm text-text-secondary">No tasks yet.</p>
              <Link
                href="/"
                className="mt-2 inline-block text-sm font-medium text-info underline-offset-4 hover:underline"
              >
                Post a task
              </Link>
            </div>
          )}
        </section>

        {/* Selected-task detail */}
        <section aria-label="Task detail">
          {selectedTaskId ? (
            <TaskDetail taskId={selectedTaskId} />
          ) : (
            !showEmpty && (
              <p className="text-sm text-text-muted">
                Select a task to see its status.
              </p>
            )
          )}
        </section>
      </div>
    </main>
  );
}

function TaskDetail({ taskId }: { taskId: string }) {
  const taskQuery = trpc.task.getById.useQuery({ taskId });
  const escrowQuery = trpc.escrow.getByTaskId.useQuery(
    { taskId },
    { retry: false },
  );

  // Fire once per distinct task whose detail resolves. Keyed on taskId so
  // switching tasks re-fires, but re-renders for the same task don't.
  const detailViewedRef = useRef<string | null>(null);
  useEffect(() => {
    if (!taskQuery.data) return;
    if (detailViewedRef.current === taskId) return;
    detailViewedRef.current = taskId;
    capture("task_detail_viewed", {
      task_id: taskId,
      escrow_state: escrowQuery.data?.state,
      authenticated: true,
    });
  }, [taskId, taskQuery.data, escrowQuery.data]);

  if (taskQuery.isLoading) {
    return <p className="text-sm text-text-muted">Loading task…</p>;
  }

  if (taskQuery.error || !taskQuery.data) {
    return (
      <p className="text-sm text-error-red">
        {taskQuery.error?.message ?? "Could not load this task."}
      </p>
    );
  }

  const task = taskQuery.data;
  const escrowState = escrowQuery.data?.state;
  const escrowAmount = escrowQuery.data?.amount;
  const fundedAt = escrowQuery.data?.funded_at;
  const funded = !!escrowState && FUNDED_ESCROW_STATES.includes(escrowState);
  const accepted = ACCEPTED_TASK_STATES.includes(task.state);
  const waitingForMatching =
    funded && !accepted && (task.state === "OPEN" || task.state === "MATCHING");

  return (
    <div className="rounded-2xl border border-white/10 bg-elevated/50 p-5">
      <h2 className="text-lg font-semibold text-text-primary">{task.title}</h2>

      <dl className="mt-4 grid grid-cols-2 gap-x-4 gap-y-3 text-sm">
        <Field label="Price" value={formatPrice(task.price)} />
        <Field label="Task status" value={<StatePill state={task.state} />} />
        {task.category && <Field label="Category" value={task.category} />}
        {task.location && <Field label="Location (ZIP)" value={task.location} />}
        <Field label="Created" value={formatWhen(task.created_at)} />
        <Field
          label="Payment"
          value={
            funded ? (
              <span className="font-semibold text-success-green">
                Payment funded
              </span>
            ) : (
              <span className="text-text-muted">Payment not yet funded</span>
            )
          }
        />
      </dl>

      {funded && (
        <p className="mt-3 text-xs text-text-muted">
          {formatPrice(escrowAmount)} held in escrow
          {fundedAt ? ` since ${formatWhen(fundedAt)}` : ""}.
        </p>
      )}

      {/* Status timeline — each step active only when backend state proves it. */}
      <StatusTimeline taskState={task.state} escrowState={escrowState} />

      {waitingForMatching && (
        <div className="mt-5 rounded-xl border border-info/40 bg-elevated/60 p-4">
          <p className="text-sm font-semibold text-info">
            Waiting for Hustler matching
          </p>
          <p className="mt-1 text-xs text-text-muted">No Hustler has accepted yet.</p>
          <p className="mt-1 text-xs text-text-muted">
            Funds stay in escrow until proof is reviewed.
          </p>
        </div>
      )}
    </div>
  );
}

function StatusTimeline({
  taskState,
  escrowState,
}: {
  taskState: string;
  escrowState: string | undefined;
}) {
  const funded = !!escrowState && FUNDED_ESCROW_STATES.includes(escrowState);
  const accepted = ACCEPTED_TASK_STATES.includes(taskState);
  const proofSubmitted = PROOF_TASK_STATES.includes(taskState);
  const released = escrowState === "RELEASED";

  const steps: { label: string; done: boolean }[] = [
    { label: "Task created", done: true },
    { label: "Payment funded", done: funded },
    { label: "Hustler accepted", done: accepted },
    { label: "Proof submitted", done: proofSubmitted },
    { label: "Payment released", done: released },
  ];

  return (
    <ol className="mt-5 flex flex-col gap-3" aria-label="Task status timeline">
      {steps.map((step) => (
        <li key={step.label} className="flex items-center gap-3">
          <span
            aria-hidden
            className={`flex h-5 w-5 shrink-0 items-center justify-center rounded-full border text-[11px] ${
              step.done
                ? "border-success-green bg-success-green/15 text-success-green"
                : "border-white/20 text-text-muted"
            }`}
          >
            {step.done ? "✓" : ""}
          </span>
          <span
            className={`text-sm ${
              step.done ? "text-text-primary" : "text-text-muted"
            }`}
          >
            {step.label}
          </span>
        </li>
      ))}
    </ol>
  );
}

function Field({
  label,
  value,
}: {
  label: string;
  value: ReactNode;
}) {
  return (
    <div>
      <dt className="text-xs uppercase tracking-wide text-text-muted">
        {label}
      </dt>
      <dd className="mt-0.5 text-text-secondary">{value}</dd>
    </div>
  );
}

function StatePill({ state }: { state: string }) {
  return (
    <span className="rounded-full border border-white/15 px-2 py-0.5 text-[11px] font-medium uppercase tracking-wide text-text-secondary">
      {state}
    </span>
  );
}

function SignInGate() {
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
      setError((err as AuthError)?.message ?? "Sign-in failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="mx-auto max-w-md p-8 text-text-primary">
      <h1 className="text-xl font-semibold">Sign in to view your dashboard</h1>
      <p className="mt-1 text-sm text-text-muted">
        Use the account you posted your task with.
      </p>
      <form onSubmit={submit} className="mt-5 flex flex-col gap-3">
        <input
          type="email"
          autoComplete="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          className="rounded-lg border border-white/20 bg-black/40 px-3 py-2 text-sm"
        />
        <input
          type="password"
          autoComplete="current-password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          className="rounded-lg border border-white/20 bg-black/40 px-3 py-2 text-sm"
        />
        <button
          type="submit"
          disabled={busy}
          className="inline-flex items-center justify-center rounded-lg bg-brand-purple px-4 py-2 text-sm font-semibold text-text-primary transition hover:bg-brand-purple-light disabled:opacity-50"
        >
          {busy ? "Signing in…" : "Sign in"}
        </button>
        {error && <p className="text-sm text-error-red">{error}</p>}
      </form>
    </main>
  );
}
