# Health Sprint 2: Tier-Priority Test Blitz + Pagination + Docs Cleanup

**Date:** 2026-03-06
**Target:** Ecosystem health 88 → 92+
**Approach:** Tier-Priority (A) — beta-critical services first

## Context

Health Sprint 1 raised the ecosystem from 72 → 88 by deleting dead code, adding TRPCClientProtocol, and writing 18 service tests. This sprint continues with the corrected recommendations from the post-sprint audit.

### Audit Corrections

| Recommendation | Audit Claim | Reality |
|---|---|---|
| Rate Limiting | "No rate limiting" | Already implemented — Upstash Redis, 6 categories, AI per-agent limits |
| Input Validation | "Missing validation" | 99%+ covered — only 7 legitimately input-free mutations |
| Pagination | "24 endpoints unbounded" | 9/16 already paginated — only 7 truly unpaginated |

### True Priorities

1. **iOS Test Coverage** — 5/56 services tested (8.9%). DI infrastructure exists but barely used.
2. **Backend Pagination** — 7 list endpoints lack LIMIT/OFFSET.
3. **Docs TODO Cleanup** — 113 items, mostly tracking artifacts.

## Part 1: iOS Test Coverage (8.9% → 37.5%)

### DI Refactoring Pattern

Same pattern proven in Sprint 1 (TaskService, EscrowService, AuthService):

```swift
// Before (untestable)
private let trpc = TRPCClient.shared

// After (mockable via existing MockTRPCClient)
private let trpc: TRPCClientProtocol
init(client: TRPCClientProtocol = TRPCClient.shared) {
    self.trpc = client
}
```

### Tier 1: Beta-Critical Services (6 services, ~40 tests)

| Service | Lines | Key Methods | DI Needed | Notes |
|---------|-------|-------------|-----------|-------|
| RatingService | 142 | submitRating, getUserRatingSummary, getMyRatings, getTaskRatings | Yes | Straightforward tRPC wrapper |
| ProofService | 261 | getUploadURL, submitProof, getProof, reviewProof | Yes | Skip raw R2 URLSession upload tests |
| SquadService | 202 | createSquad, getMySquads, inviteMember, respondToInvite, getLeaderboard | Yes | Standard CRUD |
| UserProfileService | 262 | updateProfile, getUser, getXPHistory, getBadges, getOnboardingStatus | Yes | Cross-depends on AuthService.shared (accept as-is) |
| MessagingService | 248 | sendMessage, getTaskMessages, getConversations, markAsRead | Yes | SSE dependency — test tRPC only |
| StripePaymentManager | 101 | configure, preparePaymentSheet, reset | No | Direct Stripe SDK — no tRPC |

### Tier 2: Feature Services (5 services, ~25 tests)

| Service | Lines | DI Needed | Notes |
|---------|-------|-----------|-------|
| NotificationService | ~150 | Yes | Standard tRPC wrapper |
| RecurringTaskService | ~200 | Yes | CRUD for recurring series/occurrences |
| LiveModeService | 417 | Yes | Contains nested InstantModeService. Polling needs short intervals. |
| SkillService | ~100 | Yes | Skill verification endpoints |
| SubscriptionService | ~150 | Yes | Stripe subscription management |

### Tier 3: Infrastructure (4 services, ~12 tests)

| Service | Lines | DI Needed | Notes |
|---------|-------|-----------|-------|
| ConnectivityMonitor | ~60 | No | NWPathMonitor — test state transitions |
| FeatureFlagService | ~80 | Yes | Flag fetching + caching |
| R2UploadService | ~100 | Yes | Presigned URL generation |
| RealtimeSSEClient | ~150 | No | SSE connection — test connect/disconnect lifecycle |

### Special Case Handling

- **LiveModeService (417 lines):** Two classes in one file. Both get DI injection. Polling tests use short intervals.
- **MessagingService:** Tests cover tRPC calls only. SSE subscription verified via subscribe/unsubscribe call recording.
- **UserProfileService:** `AuthService.shared.currentUser` side-effect accepted. Tests verify tRPC procedures only.
- **ProofService:** R2 upload via direct `URLSession` is not mockable without a URLSessionProtocol. Tests cover tRPC endpoints (getUploadURL, submitProof, getProof, reviewProof).

### Test File Structure

All test files go in `hustleXP final1Tests/`:

```
hustleXP final1Tests/
├── MockTRPCClient.swift      (exists)
├── TestHelpers.swift          (exists — add new fixtures)
├── RatingServiceTests.swift   (new)
├── ProofServiceTests.swift    (new)
├── SquadServiceTests.swift    (new)
├── UserProfileServiceTests.swift (new)
├── MessagingServiceTests.swift   (new)
├── NotificationServiceTests.swift (new)
├── RecurringTaskServiceTests.swift (new)
├── LiveModeServiceTests.swift     (new)
├── SkillServiceTests.swift        (new)
├── SubscriptionServiceTests.swift (new)
├── ConnectivityMonitorTests.swift (new)
├── FeatureFlagServiceTests.swift  (new)
├── R2UploadServiceTests.swift     (new)
├── RealtimeSSEClientTests.swift   (new)
└── StripePaymentManagerTests.swift (new)
```

### Metrics Target

| Metric | Before | After |
|--------|--------|-------|
| Services with tests | 5/56 (8.9%) | 21/56 (37.5%) |
| Total iOS tests | 93 | ~170 |
| DI-injectable services | 3 | 9+ |

## Part 2: Backend Pagination (7 Endpoints)

### Endpoints to Fix

| Procedure | File:Line | Current State |
|-----------|-----------|---------------|
| expertiseSupply.listExpertise | expertiseSupply.ts:39 | No LIMIT |
| live.listBroadcasts | live.ts:92 | Geo-filtered, no LIMIT |
| recurringTask.listMine | recurringTask.ts:185 | No LIMIT |
| recurringTask.listOccurrences | recurringTask.ts:287 | Hardcoded LIMIT 50 |
| squad.listMine | squad.ts:158 | No LIMIT |
| squad.listInvites | squad.ts:377 | No LIMIT |
| squad.listTasks | squad.ts:464 | No LIMIT |

### Pattern

```typescript
// Add to input schema
.input(z.object({
  /* existing params */,
  limit: z.number().int().min(1).max(100).default(50).optional(),
  offset: z.number().int().min(0).default(0).optional(),
}))

// Add to SQL query
const limit = Math.min(input.limit ?? 50, 100);
const offset = input.offset ?? 0;
// ... LIMIT $N OFFSET $M
```

### Backward Compatibility

- `limit` and `offset` are optional with defaults → no iOS changes needed
- Existing callers continue to work as before (get first 50 results)
- `recurringTask.listOccurrences` changes from hardcoded `LIMIT 50` to configurable

## Part 3: Docs TODO Triage

### Categorization Strategy

113 TODO items across 34 files. Categorize into:

1. **Tracking items** (in EXECUTION_TODO, SLOP_AUDIT, DOCS_CHANGELOG) → Archive or convert to structured format
2. **Real debt** (in specs, reference code) → Keep or create GitHub issues
3. **Stale items** (in _archive/) → Remove

### Target

- TODO count: 113 → <20 real items
- Docs health score (TODOs): 40 → ~85

## Execution Strategy

### Parallelism

Tasks are independent and can be dispatched in parallel:

- **Stream A (iOS):** DI refactoring → Tier 1 tests → Tier 2 tests → Tier 3 tests
- **Stream B (Backend):** Pagination PR (single commit)
- **Stream C (Docs):** TODO triage and cleanup

### Verification Gates

After each tier:
1. `xcodebuild test` must pass with 0 failures
2. `npx vitest run` must pass with 0 failures (after backend changes)
3. `git push` only after verification

### Health Score Projection

| Repo | Current | Projected |
|------|---------|-----------|
| Backend | 94 | 96 |
| iOS | 85 | 90 |
| Docs | 64 | 80 |
| **Overall** | **88** | **92** |
