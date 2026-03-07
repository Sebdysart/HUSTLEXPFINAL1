# HustleXP Launch Readiness Design
**Date**: 2026-03-07
**Status**: Approved
**Approach**: Sequential phases (A)
**Timeline**: Quality-first, no hard deadline
**Scorecard at design time**: 100/100 (B1 + B2 fully passing)

---

## Context

The private beta scorecard reached 100/100 on 2026-03-05. All B1 (must-work) and B2 (nice-to-have) gates are passing. The product is functionally end-to-end. This design covers the four phases required to take HustleXP from "technically complete" to "ready for real users."

### Health Audit Findings (2026-03-07)

| Metric | Backend | iOS |
|--------|---------|-----|
| Tests | 1,794 passing | 169 test functions |
| Line coverage | 26% (gap) | Unknown |
| Service test coverage | 44% | 36% |
| TODO/FIXME | 0 | 0 |
| Type errors | 0 | Unknown |
| Lint errors (core) | 0 | No SwiftLint configured |
| UI tests | — | 0 screens |

**Confirmed dead code (backend):** `query-cache.ts`, `edge-cache.ts`, `connection-registry-redis.ts`
**iOS production mocks:** `MockHeatMapService.swift` + `MockLocationService.swift` in app target
**5 iOS screens > 850 lines** (complexity risk — untested)

---

## Phase 1: Backend Hardening

**Goal**: Elevate backend from functionally correct to production-grade.

### 1.1 Pagination (18 remaining list endpoints)

The existing cursor-based pagination pattern `{ cursor?, limit? } → { items, nextCursor }` used on 7 endpoints must be extended to the 18 remaining unpaginated list procedures:

**Critical (admin console risk):**
- `admin.listUsers` (`backend/src/routers/admin.ts:35`)
- `admin.listTasks` (`backend/src/routers/admin.ts:128`)
- `admin.listDisputes` (`backend/src/routers/admin.ts:173`)
- `betaDashboard.listUsers` (`backend/src/routers/betaDashboard.ts:337`)

**User-facing (memory pressure at scale):**
- `notification.getList` (`backend/src/routers/notification.ts:28`)
- `squad.listMine` (`backend/src/routers/squad.ts:158`)
- `squad.listInvites` (`backend/src/routers/squad.ts:384`)
- `squad.listTasks` (`backend/src/routers/squad.ts:478`)
- `recurringTask.listMine` (`backend/src/routers/recurringTask.ts:185`)
- `recurringTask.listOccurrences` (`backend/src/routers/recurringTask.ts:294`)
- `live.listBroadcasts` (`backend/src/routers/live.ts:92`)
- `instant.listAvailable` (`backend/src/routers/instant.ts:21`)

**Others:**
- `incidents.list` (`backend/src/routers/incidents.ts:23`)
- `expertiseSupply.listExpertise` (`backend/src/routers/expertiseSupply.ts:39`)
- `expertiseSupply.getMyWaitlist` (`backend/src/routers/expertiseSupply.ts:173`)

Standard pattern:
```typescript
.input(z.object({
  cursor: z.string().optional(),
  limit: z.number().int().min(1).max(100).default(20),
}))
.query(async ({ ctx, input }) => {
  const { cursor, limit } = input;
  // SELECT ... WHERE id > cursor ORDER BY id LIMIT limit+1
  // return { items: rows.slice(0, limit), nextCursor: rows[limit]?.id }
})
```

iOS clients updated to pass `cursor` and handle `nextCursor` for "load more."

### 1.2 Structured Observability

**Request correlation:**
- Add `x-request-id` middleware (UUID v4 generated per request)
- Propagate request ID through all child logger calls
- Include `requestId`, `userId`, `procedure`, `duration_ms` in every log line

**Error tracking (Sentry):**
- Install `@sentry/node`
- Configure with `dsn`, `environment`, `release` from env vars
- Capture unhandled errors + tRPC error responses (4xx/5xx)
- Include user context on each event

**Health + readiness endpoints:**
```
GET /health   → 200 {"status":"ok"} (liveness — just returns 200)
GET /ready    → 200 or 503 (checks DB connection + Redis ping)
```

**Performance timing:**
- Log `duration_ms` for every tRPC procedure (use middleware wrapper)
- Alert threshold: p95 > 2000ms signals a slow query or N+1

### 1.3 Production Readiness

**Graceful shutdown:**
```typescript
process.on('SIGTERM', async () => {
  await bullMQWorkers.map(w => w.close());
  await db.pool.end();
  process.exit(0);
});
```

**Env validation (fail-fast):**
- On startup, verify all required vars are set: `DATABASE_URL`, `REDIS_URL`, `STRIPE_SECRET_KEY`, `FIREBASE_SERVICE_ACCOUNT`, `JWT_SECRET`, `R2_ACCOUNT_ID`, `OPENAI_API_KEY`
- Throw with clear message if any are missing

**Connection pool tuning:**
- Railway: 1 pod × pool_size connections. Neon free tier: 100 max connections.
- Set `max: 10`, `idleTimeoutMillis: 30000`, `connectionTimeoutMillis: 5000`

### 1.4 Zod Coverage Audit

Audit every tRPC procedure in `backend/src/routers/`. Flag any `publicProcedure.mutation()` or `protectedProcedure.mutation()` that lacks `.input(z.object({...}))`. Fix gaps. Estimated: <5 procedures.

### 1.5 Dead Code Removal + ESLint Config Fix

**Remove confirmed dead files:**
- `backend/src/cache/query-cache.ts` — no imports found anywhere
- `backend/src/cache/edge-cache.ts` — no imports found anywhere
- `backend/src/connection-registry-redis.ts` — no imports found anywhere

**Fix ESLint root-level config:**
- Update `.eslintrc.json` `parserOptions.project` to include test tsconfig or add `tests-vault/` to `ignorePatterns`
- Goal: `npx eslint .` at root returns 0 errors (currently 216 from scope mismatch)

**Investigate (not delete):**
- `backend/src/services/BadgeService.ts` — no static imports; verify usage pattern
- `backend/src/services/TrustService.ts` — separate from `TrustTierService.ts`; clarify roles

### 1.6 Test Coverage Improvement

Target: backend line coverage from 26% → 40%.

Zero-coverage services in compliance/financial flows (highest risk):
- `BackgroundCheckService` — background check orchestration
- `LicenseVerificationService` — license validation
- `InsuranceVerificationService` — insurance coverage verification
- `TaxReportingService` — 1099-NEC logic
- `PhotoVerificationService` — photo proof validation

Add unit tests for primary export function of each. Integration-test the key happy paths.

---

## Phase 2: iOS Polish

**Goal**: Transform from "technically working" to "feels premium."

### 2.1 Error States (49 screens)

Replace generic toast-on-failure with proper inline error UI on all data-loading screens.

**Error state component spec:**
```
┌─────────────────────────────┐
│  [Warning icon]             │
│  Couldn't load [content]    │
│  [Subtle error message]     │
│  [Try Again] button         │
└─────────────────────────────┘
```

**Priority screens (P0):**
- `HustlerTaskDetailScreen` — task load failure
- `PosterTaskDetailScreen` — task load failure
- `TaskDiscoveryScreen` — search/filter failure
- `ConversationScreen` — message load failure
- `WalletScreen` / `EarningsScreen` — payment data failure

**Error categories to handle distinctly:**
- Network offline → "No internet connection. Check your connection and try again."
- Server error (5xx) → "Something went wrong on our end. Try again in a moment."
- Auth expired → silent redirect to login
- Not found (404) → "This [task/conversation] is no longer available."

### 2.2 Empty States

Every list view shows a purposeful empty state instead of a blank screen.

| Screen | Empty State Copy | CTA |
|--------|-----------------|-----|
| Task Discovery | "No tasks near you yet" | None |
| My Tasks (Hustler) | "You haven't accepted any tasks yet" | "Explore tasks →" |
| Posted Tasks (Poster) | "You haven't posted anything yet" | "Post a task →" |
| Conversations | "No conversations yet" | None |
| Notifications | "You're all caught up! 🎉" | None |
| Wallet / Earnings | "No earnings yet — start accepting tasks" | "Find tasks →" |

Each empty state: icon/illustration + 1 line of copy + optional CTA button.

### 2.3 Loading Skeletons

Replace `ProgressView()` with shimmer skeleton screens on list-loading states.

**Skeleton component:** Reusable `SkeletonView` modifier using `.redacted(reason: .placeholder)` + shimmer animation.

**Screens requiring skeletons:**
- `TaskDiscoveryScreen` — skeleton `TaskCard` rows
- `ConversationListScreen` — skeleton message preview rows
- `HustlerTaskListScreen` / `PosterTaskListScreen` — skeleton task rows
- `WalletScreen` — skeleton balance + transaction rows
- `NotificationsScreen` — skeleton notification rows

### 2.4 Haptic Feedback Audit

Inventory and standardize across the app:

| Event | Haptic Type |
|-------|------------|
| Task apply success | `.success` notification |
| Payment received | `.success` notification |
| Task complete | `.success` notification |
| Application rejected | `.warning` notification |
| API error | `.error` notification |
| Primary CTA tap | `.medium` impact |
| Destructive action | `.heavy` impact |

Ensure no duplicate haptics fire on the same event chain. Audit with search for `UIImpactFeedbackGenerator` + `UINotificationFeedbackGenerator`.

### 2.5 Pull-to-Refresh

Add `refreshable {}` modifier to all list views missing it:
- `TaskDiscoveryScreen`
- `HustlerTaskListScreen` / `PosterTaskListScreen`
- `ConversationListScreen`
- `NotificationsScreen`
- `WalletScreen` / transaction history
- `BadgesScreen`

Refresh action must call the underlying tRPC procedure, not just re-render.

### 2.6 SwiftLint Setup

Add `.swiftlint.yml` to iOS repo root with these enabled rules:
```yaml
opt_in_rules:
  - force_cast
  - force_try
  - implicitly_unwrapped_optional
  - line_length
  - file_length
  - type_body_length

line_length: 140
file_length:
  warning: 500
  error: 1000
```

Flag the 5 screens over 850 lines as refactor candidates (not blocking, but tracked).

### 2.7 Move Production Mocks to Test Target

- Move `MockHeatMapService.swift` and `MockLocationService.swift` from `Services/` to `hustleXP final1Tests/Mocks/`
- Update any `#if DEBUG` usages accordingly
- Verify app target compiles after removal

### 2.8 Micro-Polish

- Consistent `.easeInOut` transitions on NavigationStack pushes
- Button press states: audit `.buttonStyle(.plain)` misuse causing missing press feedback
- Typography audit: verify all screens use `AppFonts` / `AppTextStyle` design system values (no raw `.font(.system(...))` calls)

---

## Phase 3: B3 Features

**Goal**: Ship deferred features that add depth and monetization to the beta.

### 3.1 Squads / Team Tasks

Backend: Squad router (`squad.*` — 9+ procedures) is complete.
iOS: `SquadsHubScreen.swift` (889 lines) is partially wired.

Work:
- Audit `SquadService.swift` — wire all procedures to real `TRPCClient` calls (replace any mocks)
- Complete `SquadsHubScreen`: create squad, invite member, view squad task list, leave squad
- Squad task creation: task posted on behalf of a squad, earnings split among members
- Add squad member management UI (accept/decline invites)

### 3.2 Subscription Plans / Premium

Backend: Stripe subscription infrastructure is built.
iOS: `SubscriptionService.swift` exists, untested.

Work:
- Define premium benefits for private beta (e.g., priority task visibility, more active task slots)
- Wire `SubscriptionService.swift` → `subscription.*` tRPC procedures
- Build paywall / upgrade sheet UI
- Add premium badge / indicator in profile and task listings
- Test subscription create, cancel, resume flow end-to-end

### 3.3 Live Mode / Broadcasts

Backend: `live.*` router exists.
iOS: `LiveDataService.swift` (487 lines) exists.

Work:
- Build `LiveBroadcastsScreen` — list of active broadcasts near user
- Wire SSE subscription for new broadcast events
- Poster "post live task" flow — creates broadcast with urgency + higher payout
- Hustler "claim live task" flow — first-come-first-served accept

### 3.4 API Versioning

Add `/v1/` prefix to all REST routes in `backend/src/server.ts`.

```typescript
// Before
app.get('/api/tasks/:taskId/state', handler)
// After
app.get('/v1/tasks/:taskId/state', handler)
```

No iOS changes needed (iOS uses tRPC, not REST). All REST routes are internal/webhook/admin. Update Railway health check URL to `/v1/health`.

### 3.5 Backend Dead Code + ESLint Final Cleanup

(Carried over from Phase 1 if not done earlier)
- Delete `query-cache.ts`, `edge-cache.ts`, `connection-registry-redis.ts`
- Resolve `BadgeService.ts` / `TrustService.ts` ownership

### 3.6 Checkr Integration (when unblocked)

Unblocked when Checkr authorizes the account. Customer-Hosted Flow chosen.

Work when keys arrive:
- Implement `BackgroundCheckService` using Checkr Customer-Hosted API
- iOS: consent capture + PII collection screen (pre-check)
- iOS: background check status UI in profile (pending/clear/consider)
- Backend: webhook for `report.completed` event
- Store signed consent record per candidate

---

## Phase 4: Launch Prep

**Goal**: Everything needed to get real humans using the app with confidence.

### 4.1 TestFlight Setup

- Create internal TestFlight group (team + stakeholders)
- Create external TestFlight group (invite-only beta — 25 initial testers)
- Configure Xcode Cloud or Fastlane to auto-push to TestFlight on `main` merge
- Write internal testing script (walkthrough of J1–J6 journeys)

### 4.2 App Store Connect Metadata

- App name: "HustleXP — Gig Marketplace"
- Subtitle: "Earn money helping neighbors" (or test "Post tasks, get help fast")
- Description: focus on earn loop for Hustlers (broader appeal)
- Keywords: gig, earn money, task, local help, side hustle, marketplace, jobs, freelance, neighborhood, delivery
- Screenshots: 6.7", 6.5", 5.5" required. Capture: onboarding, discovery, task detail, messaging, payment, profile
- Privacy Policy URL: required before Apple review
- Age rating: 17+ (due to financial transactions)

### 4.3 Privacy Policy + Terms of Service

**Privacy Policy must cover:**
- What data is collected (name, email, location, payment info)
- Firebase Auth (Google) — data processing
- Stripe — payment processing, Connect accounts
- Cloudflare R2 — photo/document storage
- FCM — push notification delivery
- Data retention and deletion
- User rights (CCPA/GDPR where applicable)

**Terms of Service must cover:**
- User roles (Poster vs Hustler) and responsibilities
- Task posting rules and content policy
- Payment terms (escrow, release conditions, fees)
- Dispute resolution process
- Account suspension/termination policy
- Limitation of liability

**Hosting:** Vercel or Notion public page. URL needed for App Store + iOS onboarding footer links.

### 4.4 Beta Tester Onboarding

- TestFlight invitation email template (personal, warm tone — not automated-sounding)
- "Getting Started" guide (2-page PDF or Notion page):
  - What HustleXP is
  - How to post your first task (Poster flow)
  - How to earn money (Hustler flow)
  - How payments work
  - How to report issues
- Beta feedback channel: Discord server with `#bug-reports`, `#feedback`, `#general`
- Known limitations doc (Checkr not live yet, squads limited, etc.)

### 4.5 Production Infrastructure Review

- [ ] Railway: health check URL set, restart policy configured, env vars confirmed production
- [ ] Neon: connection limit matches `pool.max × pod_count` (verify headroom)
- [ ] Stripe: webhook signing secret is production (`whsec_live_...`), not test key
- [ ] Firebase: service account is production project (verify project ID)
- [ ] R2: CORS policy allows production iOS app bundle ID (or wildcard for beta)
- [ ] Upstash Redis: plan supports expected concurrent connections
- [ ] FCM: production APNs certificate configured (not dev certificate)
- [ ] Sentry: `environment=production`, release tag set to version number

### 4.6 Monitoring + Alerting

- Uptime monitoring: BetterUptime or Uptime Robot free tier
  - Alert on `GET /health` failing 3x in 5 minutes
  - Alert to email + SMS
- Sentry: set alert on >10 errors/hour for any single issue
- Railway logs: set log drain to Papertrail or Logtail (free tier) for searchable logs
- Define incident response: who gets paged, how to rollback (Railway one-click redeploy)

---

## Effort Estimates

| Phase | Backend Work | iOS Work | Total Est. |
|-------|-------------|----------|-----------|
| 1: Backend Hardening | 3–5 days | 0.5 days (pagination iOS client) | ~1–1.5 weeks |
| 2: iOS Polish | 0 days | 4–6 days | ~1–1.5 weeks |
| 3: B3 Features | 2–3 days | 4–6 days | ~1.5–2 weeks |
| 4: Launch Prep | 0.5 days infra | 0.5 days (privacy links) | ~4–5 days (mostly writing/config) |
| **Total** | | | **~5–7 weeks** |

---

## Definition of Done

A phase is complete when:
1. All tasks in the phase have passing tests
2. No new TypeScript/Swift compilation errors
3. Backend: `npm test` passes all 1,794+ assertions
4. iOS: all 169+ test functions pass
5. Changes committed + pushed to `main`
6. Scorecard updated (where applicable)

---

## Implementation Notes

- All backend list procedures use the existing cursor pagination pattern — no new pattern to introduce
- iOS pagination: `TaskService` already handles `cursor`/`nextCursor` on some calls — extend that pattern
- Sentry DSN: create new project on sentry.io before Phase 1 begins
- Privacy Policy + ToS: can be drafted in parallel with Phase 1 (no code dependency)
- Checkr: completely unblocked by external — do not block Phase 3 on it; it slots in whenever keys arrive
