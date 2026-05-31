"use client";

import { useState, type FormEvent } from "react";
import { trpc } from "@/lib/trpc";

/**
 * Business intake form (Roadmap E3).
 *
 * Lead-interest capture for the /business demand-sensing lane. Client-side
 * validation runs first, then a valid submit calls the public, rate-limited,
 * compliance-gated business.submitLead tRPC mutation. The lead is stored
 * backend-side as NEW + requires_review (no auto-approval). There is still NO
 * account creation, charge, analytics, localStorage, or redirect — nothing is
 * persisted in the browser and an honest, zero-promise confirmation is shown.
 *
 * HONESTY LAW (stricter for a business buyer): describe MECHANICS only. No
 * forbidden trust claims in rendered copy OR in this source file — a copy grep
 * over this file must return zero hits. Contact preference uses soft "Prefer a
 * call" wording so it never implies a guaranteed follow-up.
 *
 * COLOR LAW: entry surface → Black + Purple brand only. Green is success-state
 * only and never appears here. Blue (text-info) is the info/trust accent.
 */

// Eastside-only beta ZIPs. Mirrors the allowlist in funnel-form.tsx (kept as a
// local copy because that one is not exported and the consumer funnel is out of
// scope for E2). Honest scope — out-of-area ZIPs are told so directly.
const EASTSIDE_ZIPS = new Set([
  // Redmond
  "98052", "98053", "98073",
  // Sammamish
  "98074", "98075",
  // Bellevue
  "98004", "98005", "98006", "98007", "98008", "98009", "98015",
  // Kirkland
  "98033", "98034",
  // Issaquah
  "98027", "98029",
]);

const BUSINESS_TYPES = [
  "Event venue",
  "Office",
  "Retail shop",
  "Property manager",
  "Moving & storage operator",
  "Small service business",
  "Other",
] as const;

const RECURRING_TASK_TYPES = [
  "Event setup",
  "Moving help",
  "Pickup / dropoff",
  "Errands",
  "Furniture assembly",
  "Cleanup",
  "Inventory runs",
  "Flexible labor support",
] as const;

const FREQUENCY_OPTIONS = [
  "Daily",
  "A few times a week",
  "Weekly",
  "Monthly",
  "Occasionally",
] as const;

const URGENCY_OPTIONS = ["Low", "Normal", "High"] as const;

type BusinessType = (typeof BUSINESS_TYPES)[number];
type RecurringTaskType = (typeof RECURRING_TASK_TYPES)[number];
type FrequencyOption = (typeof FREQUENCY_OPTIONS)[number];
type UrgencyOption = (typeof URGENCY_OPTIONS)[number];

const RISK_FLAGS = [
  { id: "enteringHomes", label: "Entering homes" },
  { id: "handlingKeys", label: "Handling keys" },
  { id: "drivingDelivery", label: "Driving / delivery" },
  { id: "regulatedGoods", label: "Alcohol / regulated goods" },
  { id: "minorsSchools", label: "Minors / schools" },
  { id: "cashHandling", label: "Cash handling" },
  { id: "customerFacing", label: "Customer-facing work" },
  { id: "sensitiveLocations", label: "Sensitive locations" },
] as const;

type RiskFlagId = (typeof RISK_FLAGS)[number]["id"];

const NOTES_MAX = 1000;

type ContactPreference = "form" | "call";

type FormState = {
  businessName: string;
  contactName: string;
  email: string;
  phone: string;
  businessType: string;
  city: string;
  zip: string;
  frequency: string;
  averageBudget: string;
  urgency: string;
  notes: string;
  contactPreference: ContactPreference;
};

const INITIAL_FORM: FormState = {
  businessName: "",
  contactName: "",
  email: "",
  phone: "",
  businessType: "",
  city: "",
  zip: "",
  frequency: "",
  averageBudget: "",
  urgency: "",
  notes: "",
  contactPreference: "form",
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const inputClass =
  "w-full rounded-xl border border-white/10 bg-elevated px-4 py-3 text-base text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple";
const labelClass = "flex flex-col gap-1.5 text-sm font-medium text-text-secondary";

export function BusinessIntakeForm() {
  const [form, setForm] = useState<FormState>(INITIAL_FORM);
  const [taskTypes, setTaskTypes] = useState<Set<string>>(new Set());
  const [riskFlags, setRiskFlags] = useState<Record<RiskFlagId, boolean>>(
    () =>
      RISK_FLAGS.reduce(
        (acc, flag) => ({ ...acc, [flag.id]: false }),
        {} as Record<RiskFlagId, boolean>,
      ),
  );
  const [error, setError] = useState<string | null>(null);
  const [submitted, setSubmitted] = useState(false);

  const submitLead = trpc.business.submitLead.useMutation();
  const isLoading = submitLead.isPending;

  function update<K extends keyof FormState>(key: K, value: FormState[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  function toggleTaskType(label: string) {
    setTaskTypes((prev) => {
      const next = new Set(prev);
      if (next.has(label)) next.delete(label);
      else next.add(label);
      return next;
    });
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (isLoading) return;

    const businessName = form.businessName.trim();
    const contactName = form.contactName.trim();
    const email = form.email.trim();
    const businessType = form.businessType.trim();
    const zip = form.zip.trim();

    if (!businessName || !contactName || !email || !businessType || !zip) {
      setError(
        "Please fill in the required fields: business name, contact name, email, business type, and ZIP.",
      );
      return;
    }
    if (!EMAIL_RE.test(email)) {
      setError("Please enter a valid email address.");
      return;
    }
    if (!/^\d{5}$/.test(zip)) {
      setError("ZIP must be 5 digits.");
      return;
    }
    if (!EASTSIDE_ZIPS.has(zip)) {
      setError(
        "We're starting Eastside-only — Redmond, Sammamish, Bellevue, Kirkland, Issaquah. We'll reach out when we cover your area.",
      );
      return;
    }
    if (taskTypes.size === 0) {
      setError("Please select at least one recurring task type.");
      return;
    }

    const budgetRaw = form.averageBudget.trim();
    if (budgetRaw) {
      // Optional, but if provided must be a positive integer (whole dollars).
      if (!/^\d+$/.test(budgetRaw) || parseInt(budgetRaw, 10) <= 0) {
        setError("Average budget must be a positive whole number (dollars).");
        return;
      }
    }

    if (form.notes.length > NOTES_MAX) {
      setError(`Notes must be ${NOTES_MAX} characters or fewer.`);
      return;
    }

    // E3: submit to the public, rate-limited, compliance-gated backend.
    // No PII is persisted locally, no localStorage, no analytics, no account,
    // no redirect. avgBudget is collected in whole dollars → cents.
    const notes = form.notes.trim();
    try {
      await submitLead.mutateAsync({
        businessName,
        contactName,
        email,
        phone: form.phone.trim() || undefined,
        businessType: businessType as BusinessType,
        city: form.city.trim() || undefined,
        zip,
        recurringTaskTypes: [...taskTypes] as RecurringTaskType[],
        expectedFrequency: form.frequency
          ? (form.frequency as FrequencyOption)
          : undefined,
        avgBudgetCents: budgetRaw ? parseInt(budgetRaw, 10) * 100 : undefined,
        urgency: form.urgency ? (form.urgency as UrgencyOption) : undefined,
        notes: notes || undefined,
        riskFlags,
        contactPreference: form.contactPreference,
      });
      setSubmitted(true);
    } catch (err: unknown) {
      const code =
        (err as { data?: { code?: string } } | undefined)?.data?.code ?? "";
      if (code === "TOO_MANY_REQUESTS") {
        setError("Too many attempts. Try again shortly.");
      } else if (code === "BAD_REQUEST") {
        setError(
          "This request cannot be submitted because HustleXP only supports legal, reviewable local task demand.",
        );
      } else {
        setError("We couldn't submit this right now. Try again later.");
      }
    }
  }

  if (submitted) {
    return (
      <div
        role="status"
        aria-live="polite"
        className="rounded-2xl border border-brand-purple/40 bg-elevated/60 p-6 text-left shadow-[0_0_60px_-30px_rgba(91,45,255,0.6)]"
      >
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-brand-purple-glow">
          Interest registered
        </p>
        <p className="mt-3 text-base text-info">
          Thanks — we received your business registration interest. We&apos;ll
          review it before any access is granted. No account created and nothing
          charged.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} noValidate className="flex flex-col gap-6 text-left">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <label className={labelClass}>
          Business name *
          <input
            type="text"
            value={form.businessName}
            onChange={(e) => update("businessName", e.target.value)}
            autoComplete="organization"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Contact name *
          <input
            type="text"
            value={form.contactName}
            onChange={(e) => update("contactName", e.target.value)}
            autoComplete="name"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Email *
          <input
            type="email"
            value={form.email}
            onChange={(e) => update("email", e.target.value)}
            autoComplete="email"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Phone (optional)
          <input
            type="tel"
            value={form.phone}
            onChange={(e) => update("phone", e.target.value)}
            autoComplete="tel"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Business type *
          <select
            value={form.businessType}
            onChange={(e) => update("businessType", e.target.value)}
            className={inputClass}
          >
            <option value="">Select a type…</option>
            {BUSINESS_TYPES.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
        </label>
        <label className={labelClass}>
          City
          <input
            type="text"
            value={form.city}
            onChange={(e) => update("city", e.target.value)}
            autoComplete="address-level2"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          ZIP *
          <input
            type="text"
            inputMode="numeric"
            autoComplete="postal-code"
            pattern="[0-9]{5}"
            maxLength={5}
            value={form.zip}
            onChange={(e) => update("zip", e.target.value.replace(/\D/g, ""))}
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Average budget per task (optional)
          <input
            type="text"
            inputMode="numeric"
            value={form.averageBudget}
            onChange={(e) =>
              update("averageBudget", e.target.value.replace(/\D/g, ""))
            }
            placeholder="e.g. 80"
            className={inputClass}
          />
        </label>
        <label className={labelClass}>
          Expected frequency
          <select
            value={form.frequency}
            onChange={(e) => update("frequency", e.target.value)}
            className={inputClass}
          >
            <option value="">Select frequency…</option>
            {FREQUENCY_OPTIONS.map((opt) => (
              <option key={opt} value={opt}>
                {opt}
              </option>
            ))}
          </select>
        </label>
        <label className={labelClass}>
          Urgency
          <select
            value={form.urgency}
            onChange={(e) => update("urgency", e.target.value)}
            className={inputClass}
          >
            <option value="">Select urgency…</option>
            {URGENCY_OPTIONS.map((opt) => (
              <option key={opt} value={opt}>
                {opt}
              </option>
            ))}
          </select>
        </label>
      </div>

      <fieldset>
        <legend className="text-sm font-medium text-text-secondary">
          Recurring task types *
        </legend>
        <p className="mt-1 text-xs text-text-muted">Select at least one.</p>
        <div className="mt-3 flex flex-wrap gap-2">
          {RECURRING_TASK_TYPES.map((label) => {
            const selected = taskTypes.has(label);
            return (
              <button
                key={label}
                type="button"
                aria-pressed={selected}
                onClick={() => toggleTaskType(label)}
                className={
                  "rounded-full border px-4 py-2 text-sm font-medium transition focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple " +
                  (selected
                    ? "border-brand-purple bg-brand-purple text-text-primary"
                    : "border-white/10 bg-elevated text-text-secondary hover:border-white/30")
                }
              >
                {label}
              </button>
            );
          })}
        </div>
      </fieldset>

      <fieldset>
        <legend className="text-sm font-medium text-text-secondary">
          Does this work involve any of these?
        </legend>
        <p className="mt-1 text-xs text-text-muted">
          Higher-risk work is reviewed manually before it can be posted.
        </p>
        <div className="mt-3 grid grid-cols-1 gap-3 sm:grid-cols-2">
          {RISK_FLAGS.map((flag) => (
            <label
              key={flag.id}
              className="flex items-center gap-3 text-sm text-text-secondary"
            >
              <input
                type="checkbox"
                checked={riskFlags[flag.id]}
                onChange={(e) =>
                  setRiskFlags((prev) => ({
                    ...prev,
                    [flag.id]: e.target.checked,
                  }))
                }
                className="h-4 w-4 rounded border-white/25 bg-elevated text-brand-purple focus:ring-brand-purple"
              />
              {flag.label}
            </label>
          ))}
        </div>
      </fieldset>

      <label className={labelClass}>
        Notes
        <textarea
          rows={4}
          value={form.notes}
          onChange={(e) => update("notes", e.target.value)}
          maxLength={NOTES_MAX}
          placeholder="Anything else we should know about the work you need."
          className="w-full resize-none rounded-xl border border-white/10 bg-elevated px-4 py-3 text-base text-text-primary placeholder:text-text-muted focus:border-brand-purple focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
        />
        <span className="text-xs text-text-muted">
          {form.notes.length}/{NOTES_MAX}
        </span>
      </label>

      <fieldset>
        <legend className="text-sm font-medium text-text-secondary">
          How should we follow up?
        </legend>
        <div className="mt-3 flex flex-col gap-2 sm:flex-row sm:gap-6">
          <label className="flex items-center gap-3 text-sm text-text-secondary">
            <input
              type="radio"
              name="contactPreference"
              checked={form.contactPreference === "form"}
              onChange={() => update("contactPreference", "form")}
              className="h-4 w-4 border-white/25 bg-elevated text-brand-purple focus:ring-brand-purple"
            />
            Use this form
          </label>
          <label className="flex items-center gap-3 text-sm text-text-secondary">
            <input
              type="radio"
              name="contactPreference"
              checked={form.contactPreference === "call"}
              onChange={() => update("contactPreference", "call")}
              className="h-4 w-4 border-white/25 bg-elevated text-brand-purple focus:ring-brand-purple"
            />
            Prefer a call
          </label>
        </div>
      </fieldset>

      <button
        type="submit"
        disabled={isLoading}
        className="inline-flex w-full items-center justify-center rounded-xl bg-brand-purple px-8 py-4 text-base font-semibold text-text-primary shadow-[0_10px_40px_-15px_rgba(91,45,255,0.8)] transition hover:bg-brand-purple-light focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-purple-glow disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto sm:self-start"
      >
        {isLoading ? "Submitting…" : "Register interest"}
      </button>

      {error && (
        <p role="alert" className="text-sm text-error-red">
          {error}
        </p>
      )}

      <p className="text-xs text-text-muted">
        Registering interest creates no account and charges nothing. Every
        business is reviewed manually. No guaranteed timeline.
      </p>
    </form>
  );
}
