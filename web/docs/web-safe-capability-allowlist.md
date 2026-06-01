# Web-Safe Backend Capability Allowlist

**Status:** Phase 0 safety gate. Authoritative for what the **web client** (hustlexp.app)
may call. Derived from the Backend→Web Parity Audit against
`Sebdysart/hustlexp-ai-backend` (51 routers).

**Iron rule:** the backend is the source of truth. The web app consumes it through the
typed `AppRouter` (`web/types/trpc/AppRouter.d.ts`). Do **not** reimplement backend logic
in Next.js. Nothing on this list is "exposed" until it ships behind the correct auth gate
with UI — this doc only governs *which* procedures are eligible.

Auth gates (backend `src/trpc.ts`): `publicProcedure`, `protectedProcedure`,
`posterProcedure` (`default_mode==='poster'`), `hustlerProcedure`
(`default_mode==='worker'`), `adminProcedure`.

---

## ✅ Safe for web NOW (poster lane — all REAL, already typed)

Already wired (do not regress): `task.draftEstimate` (public), `user.register` (public),
`geo.availability` (public), `task.create`, `escrow.createPaymentIntent`,
`escrow.confirmFunding`, `task.listByPoster`, `task.getById`, `escrow.getByTaskId`,
`task.getTracking` (poster, post-acceptance), `health.ping`, `user.me`.

Eligible to wire next (REAL backend, correct poster/protected gate, no new backend work):
- `task.listApplicants`, `task.assignWorker`, `task.rejectApplicant`
- `task.getProof`, `task.reviewProof`, `task.complete`, `task.cancel`
- `escrow.release`, `escrow.refund` — **money movement: require explicit confirmation UI**
- `dispute.create`, `dispute.getById`, `dispute.getByTask`, `dispute.getMine`, `jury.submitVote`
- `rating.submitRating`, `rating.getUserRatingSummary`, `rating.getTextReviews`
- `pricing.getSmartPrice`, `pricing.calculate`
- `moderation.createReport`, `moderation.getUserAppeals`
- `notification.getList/getUnreadCount/markAsRead/getPreferences/updatePreferences`
- `messaging.*` (task-scoped threads)
- `flags.getFlags` (read), `alphaTelemetry.emitEdgeStateImpression/emitEdgeStateExit`
- `gdpr.*`, `user.updateProfile`, `user.getOnboardingStatus`, `ui.*`

> Gating reminder: tracking/maps stays **dashboard-only, post-acceptance**. No live public
> tracking. Backend `GOOGLE_MAPS_API_KEY` must be set or `task.getTracking.destination` is null.

## 🕒 Safe LATER (after a backend/mobile delta — not Phase 0)

- **Hustler web lane** (new authenticated surface, `default_mode==='worker'`):
  `taskDiscovery.*`, `task.accept/start/applyForTask`, `instant.*`, `stripeConnect.*`,
  `geofence.*`. Backend is REAL; needs a whole new web surface — **paused per Phase 0**.
- **Billing surfaces:** `subscription.*`, `recurringTask.*`, `tipping.*`, `featured.*`
  (money movement; confirmation UI required).
- **Live moving-Hustler tracking + ETA:** blocked on (1) mobile GPS stream
  (`tracking.updateLocation` — `expo-location` not installed in mobile), (2) backend
  `GOOGLE_MAPS_API_KEY`, (3) a route/ETA (Distance Matrix) service that does not exist yet.

## ⛔ NEVER expose to the consumer web app

Admin / worker / internal only — belong in a **separate admin app**, never the consumer bundle:
- `admin.*` — platform ops; **`admin.escrowOverride` is an unguarded financial override**
- `fraud.*` — ML risk scoring
- `betaDashboard.*` — ops metrics + kill switch
- `disputeAI.*`, `incidents.*` — internal LLM/ops tooling
- `matchmaker.rankCandidates`, `reputation.*` (admin reads), `moderation` queue-review,
  `alphaTelemetry` admin reads, `analytics` admin aggregates

**Flagged routers / capabilities (do not surface as-is):**
| Capability | Why flagged | Action |
|---|---|---|
| `intent.*` | Developer tooling **mis-gated** as `hustlerProcedure` | Re-gate to admin/internal; never call from web |
| `capability.initiateBackgroundCheck` | **STUB** — stores a synthetic `bc_` id; no Checkr/Sterling call | Do **not** present "background-checked" as verified |
| `insurance.*` | Pool **feature-flagged OFF** (`INSURANCE_POOL_ENABLED`) for WA legal reasons | Do not surface until legal clearance |
| `biometric.*` | Camera/liveness | **Mobile-only**; not a web flow |
| `tracking.updateLocation` | GPS write path (PII) | **Mobile-only**; never a web write path |

## 🏢 Business-mode exception (web-only, preserved)

`business.submitLead` (public) is the **only** web-facing business procedure — anonymous
intake, `requires_review=true`, no auto-approval. Self-contained: shares no components,
routes, or tables with the consumer funnel. Admin review/convert
(`admin.listBusinessLeads/reviewBusinessLead/convertBusinessLead`) stays **backend/admin-only**.
E6 (business product) remains **parked**. The parity work must not touch this lane.

---

## Keeping this contract honest

- Web type currency is verified by `scripts/check-trpc-types.sh` (read-only; non-zero on drift).
- Update the vendored type via `scripts/sync-trpc-types.sh` (now guards against pulling a
  stale/shorter copy). The local backend can be the source via `HUSTLEXP_BACKEND_DIR`.
- When a procedure moves between tiers above, update this file in the same change.
