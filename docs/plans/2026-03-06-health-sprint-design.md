# Health Score Sprint: Dead Code Purge + iOS Test Foundation

**Date:** 2026-03-06
**Goal:** Ecosystem health 72 → 90+ / 100
**Effort:** ~3 hours
**Risk:** Low (deletions verified, tests additive)

## Context

Health audit (2026-03-06) identified two critical bottlenecks:
1. **iOS test coverage at 20/100** — only 5/202 files tested, zero service tests
2. **Backend dead code at 75/100** — 8 dead services + 5 orphaned legacy services

This sprint targets the highest-ROI actions: zero-risk deletions for immediate points
plus an iOS test infrastructure that addresses the #1 risk zone.

## Scope

### Quick Wins (~40 minutes)

**Backend:**
- Fix the single ESLint `any` error in `recurringTask.ts:88` — add `OccurrenceRow` interface
- Delete 8 dead services (1,744 lines) — all verified zero imports:
  - BadgeEvaluationService (253), EvidenceService (243), StreakService (164),
    AuditService (123), BreachNotificationService (547), CapabilityRecomputeWorker (129),
    ShadowBanService (281), AlertService (4)
- Remove ShadowBanService from `backend/src/services/index.ts`

**iOS:**
- Delete 3 orphaned files (~190 lines):
  - MockStripePaymentSheet.swift (zero code references)
  - BootstrapScreen.swift (zero navigation references)
  - AlphaTelemetryService.swift (zero references)

**Docs:**
- Commit 17 untracked files (ui-puzzle/ directory + BACKEND_CONTRACT.md)

### iOS Test Infrastructure (~2-3 hours)

**Problem:** Services use `TRPCClient.shared` singleton. Tests need a mockable boundary.

**Solution: Protocol Injection**

```
TRPCClientProtocol (new)
  ├── call<T>(procedure:input:) async throws -> T
  └── query<T>(procedure:) async throws -> T

TRPCClient: TRPCClientProtocol (add conformance)

MockTRPCClient: TRPCClientProtocol (test target only)
  ├── stubbedResponses: [String: Any]
  ├── recordedCalls: [(procedure: String, input: Any?)]
  └── Returns stubbed responses or throws stubbed errors
```

Services gain a test-only `init(client: TRPCClientProtocol)` with default
parameter `= TRPCClient.shared` so existing production code is unchanged.

**Test Files (5 new files, ~20-30 tests):**

| File | Tests | Coverage |
|------|-------|----------|
| MockTRPCClient.swift | — | Test double with stub/record |
| TestHelpers.swift | — | makeUser(), makeTask(), makeEscrow() factories |
| AuthServiceTests.swift | 6-8 | loadCurrentUser, token persistence, logout |
| TaskServiceTests.swift | 8-10 | createTask, list, state transitions, errors |
| EscrowServiceTests.swift | 6-8 | hold, release, refund, state validation |

**Pattern (XCTest, async, JSON fixtures):**

```swift
final class AuthServiceTests: XCTestCase {
    var mockClient: MockTRPCClient!
    var service: AuthService!

    override func setUp() {
        mockClient = MockTRPCClient()
        service = AuthService(client: mockClient)
    }

    func testLoadCurrentUser_success() async throws {
        mockClient.stub("user.me", response: TestHelpers.makeUserJSON())
        await service.loadCurrentUser()
        XCTAssertNotNil(service.currentUser)
    }
}
```

## Multi-Repo Coordination

### Phase Order (Provider-First)

1. **Backend** — Delete dead services, fix ESLint (no consumer impact)
2. **iOS** — Delete orphans, add test infrastructure (no backend dependency)
3. **Docs** — Commit untracked files (independent)

Phases 1-3 are fully independent and can run in parallel.

### Checkpoints

- After Phase 1: `npx vitest run` — all 1,794+ tests pass
- After Phase 2 deletion: `xcodebuild build` — BUILD SUCCEEDED
- After Phase 4 tests: `xcodebuild test` — all tests pass
- After all phases: `/health` — verify score >= 90

## Projected Score Impact

| Repo | Before | After | Delta |
|------|--------|-------|-------|
| Backend | 78 | 85 | +7 (dead code + quality) |
| iOS | 74 | 89-93 | +15-19 (test coverage jump) |
| Docs | 64 | 67 | +3 (uncommitted files) |
| **Ecosystem** | **72** | **90-94** | **+18-22** |

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| TRPCClientProtocol breaks callers | Very low | Protocol matches existing signatures; conformance is additive |
| Service init(client:) breaks production | None | Default parameter = TRPCClient.shared |
| Dead service has hidden dynamic import | Very low | Verified via grep — zero references across entire repo |
| Test target linking issues | Low | Existing test target already imports production code via @testable |

## Decision: Not In Scope

- **Pagination (P3):** Breaking API change affecting 24 endpoints + iOS consumers. Separate feature branch.
- **Docs placeholder cleanup (P4):** 298 markers need content-level decisions. Separate docs session.
- **Legacy src/ migration (P5):** 42 files with 18 active imports. Separate migration effort.
