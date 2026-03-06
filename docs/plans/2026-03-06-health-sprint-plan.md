# Health Score Sprint Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Raise ecosystem health from 72 → 90+ by purging dead code and building iOS test infrastructure.

**Architecture:** Provider-first ordering — backend cleanup (Phase 1), then iOS cleanup + test infra (Phase 2-3), then docs (Phase 4). iOS tests use protocol injection: `TRPCClientProtocol` enables `MockTRPCClient` in the test target while keeping production code unchanged via default parameters.

**Tech Stack:** TypeScript/Vitest (backend), Swift/XCTest (iOS), Git

---

## Task 1: Fix ESLint `any` Type in recurringTask.ts

**Files:**
- Modify: `backend/src/routers/recurringTask.ts:88`

**Step 1: Add OccurrenceRow interface**

Add this interface after the existing `SeriesRow` interface (after line 55):

```typescript
interface OccurrenceRow {
  id: string;
  series_id: string;
  task_id: string | null;
  occurrence_number: number;
  scheduled_date: string;
  status: string;
  worker_id: string | null;
  worker_name: string | null;
  completed_at: string | null;
  rating: number | null;
}
```

**Step 2: Replace `any` with `OccurrenceRow`**

Change line 88 from:
```typescript
function mapOccurrenceToResponse(row: any) {
```
to:
```typescript
function mapOccurrenceToResponse(row: OccurrenceRow) {
```

**Step 3: Verify ESLint passes**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npx eslint backend/src/routers/recurringTask.ts`
Expected: No errors

**Step 4: Verify tests pass**

Run: `npx vitest run --reporter=verbose 2>&1 | tail -5`
Expected: All tests pass, 0 failures

---

## Task 2: Delete 7 Dead Backend Services

**Files:**
- Delete: `backend/src/services/BadgeEvaluationService.ts` (253 lines)
- Delete: `backend/src/services/EvidenceService.ts` (243 lines)
- Delete: `backend/src/services/StreakService.ts` (164 lines)
- Delete: `backend/src/services/AuditService.ts` (123 lines)
- Delete: `backend/src/services/BreachNotificationService.ts` (547 lines)
- Delete: `backend/src/services/CapabilityRecomputeWorker.ts` (129 lines)
- Delete: `backend/src/services/ShadowBanService.ts` (281 lines)
- Modify: `backend/src/services/index.ts:20` (remove ShadowBanService export)

**Step 1: Delete the 7 files**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
rm backend/src/services/BadgeEvaluationService.ts \
   backend/src/services/EvidenceService.ts \
   backend/src/services/StreakService.ts \
   backend/src/services/AuditService.ts \
   backend/src/services/BreachNotificationService.ts \
   backend/src/services/CapabilityRecomputeWorker.ts \
   backend/src/services/ShadowBanService.ts
```

**Step 2: Remove ShadowBanService from index.ts**

Remove line 20: `export { ShadowBanService } from './ShadowBanService';`

**Step 3: Delete legacy AlertService**

```bash
rm src/services/AlertService.ts
```

**Step 4: Verify no broken imports**

Run: `grep -rn "BadgeEvaluationService\|EvidenceService\|StreakService\|AuditService\|BreachNotificationService\|CapabilityRecomputeWorker\|ShadowBanService\|AlertService" backend/src/ src/ --include="*.ts" | grep -v "\.test\." | grep -v "node_modules"`
Expected: Zero matches (or only comments)

**Step 5: Verify tests pass**

Run: `npx vitest run 2>&1 | tail -5`
Expected: All tests pass, 0 failures

**Step 6: Commit**

```bash
git add -A backend/src/services/ src/services/AlertService.ts backend/src/routers/recurringTask.ts
git commit -m "refactor: delete 8 dead services (1,744 lines) + fix ESLint any type

Delete 7 dead backend services with verified zero imports:
BadgeEvaluationService, EvidenceService, StreakService, AuditService,
BreachNotificationService, CapabilityRecomputeWorker, ShadowBanService.
Delete legacy AlertService (4 lines, zero imports).
Remove ShadowBanService from services/index.ts re-export.
Add OccurrenceRow interface to fix the repo's only ESLint error.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Delete 3 Orphaned iOS Files

**Files:**
- Delete: `hustleXP final1/Components/Molecules/MockStripePaymentSheet.swift`
- Delete: `hustleXP final1/BootstrapScreen.swift`
- Delete: `hustleXP final1/Services/AlphaTelemetryService.swift`

**Step 1: Delete the files**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
rm "hustleXP final1/Components/Molecules/MockStripePaymentSheet.swift" \
   "hustleXP final1/BootstrapScreen.swift" \
   "hustleXP final1/Services/AlphaTelemetryService.swift"
```

**Step 2: Verify no broken references**

Run: `grep -rn "MockStripePaymentSheet\|BootstrapScreen\|AlphaTelemetryService" "hustleXP final1/" --include="*.swift" | grep -v "//"`
Expected: Zero matches (or only comments)

**Step 3: Verify build**

Run: `xcodebuild build -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -quiet 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -A "hustleXP final1/Components/Molecules/MockStripePaymentSheet.swift" \
           "hustleXP final1/BootstrapScreen.swift" \
           "hustleXP final1/Services/AlphaTelemetryService.swift"
git commit -m "refactor(ios): delete 3 orphaned files (MockStripePaymentSheet, BootstrapScreen, AlphaTelemetryService)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Commit Untracked Docs Files

**Files:**
- Add: `HUSTLEXP-DOCS/ui-puzzle/` (16 files)
- Add: `HUSTLEXP-DOCS/BACKEND_CONTRACT.md` (1 file)

**Step 1: Stage and commit in docs submodule**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/HUSTLEXP-DOCS
git add ui-puzzle/ BACKEND_CONTRACT.md
git commit -m "docs: add ui-puzzle component specs + backend contract

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

**Step 2: Update submodule reference in parent**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add HUSTLEXP-DOCS
git commit -m "chore(docs): update submodule after ui-puzzle commit

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Create TRPCClientProtocol

**Files:**
- Modify: `hustleXP final1/Services/TRPCClient.swift`

**Step 1: Add the protocol definition**

Add this protocol ABOVE the `TRPCClient` class declaration:

```swift
/// Protocol enabling test injection for services that call the backend.
/// Production code uses `TRPCClient.shared`; tests inject `MockTRPCClient`.
protocol TRPCClientProtocol {
    func call<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        type: ProcedureType,
        input: Input
    ) async throws -> Output
}
```

**Step 2: Add conformance to TRPCClient**

Change the class declaration from:
```swift
final class TRPCClient: ObservableObject {
```
to:
```swift
final class TRPCClient: ObservableObject, TRPCClientProtocol {
```

**Step 3: Verify build**

Run: `xcodebuild build -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -quiet 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add "hustleXP final1/Services/TRPCClient.swift"
git commit -m "feat(ios): add TRPCClientProtocol for testable service injection

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Add Test-Only Initializers to Services

**Files:**
- Modify: `hustleXP final1/Services/TaskService.swift`
- Modify: `hustleXP final1/Services/EscrowService.swift`
- Modify: `hustleXP final1/Services/AuthService.swift`

For EACH service, make two changes:

**Change 1: Type the trpc property to the protocol**

From:
```swift
private let trpc = TRPCClient.shared
```
To:
```swift
private let trpc: TRPCClientProtocol
```

**Change 2: Replace private init with injectable init**

From:
```swift
private init() {}
```
To (for TaskService and EscrowService):
```swift
init(client: TRPCClientProtocol = TRPCClient.shared) {
    self.trpc = client
}
```

For AuthService (which has additional setup):
From:
```swift
private init()
```
To:
```swift
init(client: TRPCClientProtocol = TRPCClient.shared)
```
Then inside the init body, replace `self.trpc = TRPCClient.shared` or equivalent
with `self.trpc = client`. Keep all other init logic unchanged.

**Important:** The `static let shared` property on each service calls `init()` with
no arguments, which uses the default parameter `TRPCClient.shared`. Production code
is completely unchanged.

**Step: Verify build**

Run: `xcodebuild build -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -quiet 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step: Commit**

```bash
git add "hustleXP final1/Services/TaskService.swift" \
        "hustleXP final1/Services/EscrowService.swift" \
        "hustleXP final1/Services/AuthService.swift"
git commit -m "refactor(ios): add TRPCClientProtocol injection to 3 services

Replace private init() with init(client: TRPCClientProtocol = TRPCClient.shared)
on TaskService, EscrowService, AuthService. Production behavior unchanged —
static shared still uses TRPCClient.shared via default parameter.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Create MockTRPCClient + TestHelpers

**Files:**
- Create: `hustleXP final1Tests/MockTRPCClient.swift`
- Create: `hustleXP final1Tests/TestHelpers.swift`

**Step 1: Write MockTRPCClient**

```swift
import Foundation
@testable import hustleXP_final1

/// Test double for TRPCClient that returns stubbed JSON responses.
/// Stubs are keyed by "router.procedure" (e.g., "task.create").
final class MockTRPCClient: TRPCClientProtocol {

    /// Stubbed JSON responses keyed by "router.procedure"
    private var stubs: [String: Data] = [:]

    /// Stubbed errors keyed by "router.procedure"
    private var errors: [String: Error] = [:]

    /// Every call recorded as (router, procedure) for verification
    private(set) var recordedCalls: [(router: String, procedure: String)] = []

    // MARK: - Stub API

    /// Stub a successful response with a JSON string.
    func stubJSON(_ key: String, json: String) {
        stubs[key] = json.data(using: .utf8)!
    }

    /// Stub an error for the given key.
    func stubError(_ key: String, error: Error) {
        errors[key] = error
    }

    /// Clear all stubs and recorded calls.
    func reset() {
        stubs.removeAll()
        errors.removeAll()
        recordedCalls.removeAll()
    }

    /// Returns true if a call was recorded matching the key.
    func wasCalled(_ key: String) -> Bool {
        recordedCalls.contains { "\($0.router).\($0.procedure)" == key }
    }

    /// Count of calls matching the key.
    func callCount(_ key: String) -> Int {
        recordedCalls.filter { "\($0.router).\($0.procedure)" == key }.count
    }

    // MARK: - TRPCClientProtocol

    func call<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        type: ProcedureType,
        input: Input
    ) async throws -> Output {
        let key = "\(router).\(procedure)"
        recordedCalls.append((router: router, procedure: procedure))

        if let error = errors[key] {
            throw error
        }

        guard let data = stubs[key] else {
            fatalError("MockTRPCClient: No stub for '\(key)'. Add mockClient.stubJSON(\"\(key)\", json: \"...\") in setUp().")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Output.self, from: data)
    }
}
```

**Step 2: Write TestHelpers**

```swift
import Foundation
@testable import hustleXP_final1

/// Factory functions for creating test data.
/// Mirrors the backend's makeEscrow()/makeTask() pattern from escrow-service.test.ts.
enum TestFixtures {

    static let userJSON = """
    {
        "id": "test-user-1",
        "firebase_uid": "fb-uid-1",
        "email": "test@hustlexp.com",
        "display_name": "Test User",
        "avatar_url": null,
        "default_mode": "hustler",
        "trust_tier": 1,
        "xp": 150,
        "xp_level": 2,
        "is_banned": false,
        "stripe_customer_id": null,
        "stripe_connect_id": null,
        "payouts_enabled": false,
        "created_at": "2026-01-15T10:00:00Z",
        "updated_at": "2026-03-01T12:00:00Z"
    }
    """

    static let taskJSON = """
    {
        "id": "task-1",
        "poster_id": "poster-1",
        "worker_id": null,
        "title": "Test Task",
        "description": "A test task for unit tests",
        "price": 2500,
        "location": "San Francisco, CA",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "category": "delivery",
        "state": "open",
        "mode": "standard",
        "requires_proof": true,
        "instant_mode": false,
        "estimated_duration": "30 min",
        "required_tier": 1,
        "created_at": "2026-03-01T10:00:00Z",
        "updated_at": "2026-03-01T10:00:00Z"
    }
    """

    static let escrowJSON = """
    {
        "id": "esc-1",
        "task_id": "task-1",
        "poster_id": "poster-1",
        "worker_id": "worker-1",
        "amount_cents": 2500,
        "platform_fee_cents": 250,
        "tax_withholding_cents": 0,
        "insurance_contribution_cents": 0,
        "state": "funded",
        "stripe_payment_intent_id": "pi_test123",
        "created_at": "2026-03-01T10:00:00Z",
        "funded_at": "2026-03-01T10:01:00Z",
        "released_at": null
    }
    """

    static let paymentIntentJSON = """
    {
        "client_secret": "pi_test123_secret_abc",
        "payment_intent_id": "pi_test123",
        "amount_cents": 2500,
        "escrow_id": "esc-1"
    }
    """

    static let xpAwardJSON = """
    {
        "xp_awarded": 50,
        "new_total_xp": 200,
        "bonus_xp": 10,
        "tier_up": false
    }
    """

    /// Creates a modified version of a JSON fixture by replacing a key's value.
    static func modify(_ json: String, key: String, value: String) -> String {
        // Simple key-value replacement for test fixtures
        let pattern = "\"\(key)\": [^,\\n}]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return json }
        let range = NSRange(json.startIndex..., in: json)
        return regex.stringByReplacingMatches(
            in: json, range: range,
            withTemplate: "\"\(key)\": \(value)"
        )
    }
}

/// Convenience error for testing error paths.
struct MockNetworkError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }

    static let offline = MockNetworkError(message: "The Internet connection appears to be offline.")
    static let serverError = MockNetworkError(message: "Internal Server Error")
    static let unauthorized = MockNetworkError(message: "Unauthorized")
}
```

**Step 3: Verify build**

Run: `xcodebuild build-for-testing -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -quiet 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add "hustleXP final1Tests/MockTRPCClient.swift" \
        "hustleXP final1Tests/TestHelpers.swift"
git commit -m "test(ios): add MockTRPCClient + TestFixtures for service testing

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: Write TaskService Tests

**Files:**
- Create: `hustleXP final1Tests/TaskServiceTests.swift`

**Step 1: Write the test file**

```swift
import XCTest
@testable import hustleXP_final1

@MainActor
final class TaskServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: TaskService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = TaskService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - createTask

    func testCreateTask_callsCorrectProcedure() async throws {
        mockClient.stubJSON("task.create", json: TestFixtures.taskJSON)

        _ = try await service.createTask(
            title: "Test",
            description: "Desc",
            payment: 25.00,
            location: "SF",
            latitude: 37.77,
            longitude: -122.42,
            estimatedDuration: "30 min"
        )

        XCTAssertTrue(mockClient.wasCalled("task.create"))
        XCTAssertEqual(mockClient.callCount("task.create"), 1)
    }

    func testCreateTask_returnsDecodedTask() async throws {
        mockClient.stubJSON("task.create", json: TestFixtures.taskJSON)

        let task = try await service.createTask(
            title: "Test Task",
            description: "A test",
            payment: 25.00,
            location: "SF",
            latitude: nil,
            longitude: nil,
            estimatedDuration: "30 min"
        )

        XCTAssertEqual(task.id, "task-1")
        XCTAssertEqual(task.title, "Test Task")
    }

    func testCreateTask_networkError_throws() async {
        mockClient.stubError("task.create", error: MockNetworkError.offline)

        do {
            _ = try await service.createTask(
                title: "Test",
                description: "Desc",
                payment: 25.00,
                location: "SF",
                latitude: nil,
                longitude: nil,
                estimatedDuration: "30 min"
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getTask

    func testGetTask_returnsTask() async throws {
        mockClient.stubJSON("task.getById", json: TestFixtures.taskJSON)

        let task = try await service.getTask(id: "task-1")

        XCTAssertEqual(task.id, "task-1")
        XCTAssertTrue(mockClient.wasCalled("task.getById"))
    }

    // MARK: - acceptTask

    func testAcceptTask_callsMutation() async throws {
        let acceptedJSON = TestFixtures.modify(
            TestFixtures.taskJSON,
            key: "state",
            value: "\"accepted\""
        )
        mockClient.stubJSON("task.accept", json: acceptedJSON)

        let task = try await service.acceptTask(taskId: "task-1")

        XCTAssertTrue(mockClient.wasCalled("task.accept"))
        XCTAssertEqual(task.state.rawValue, "accepted")
    }

    // MARK: - listOpenTasks

    func testListOpenTasks_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.taskJSON)]"
        mockClient.stubJSON("task.listOpen", json: listJSON)

        let tasks = try await service.listOpenTasks()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.id, "task-1")
    }

    func testListOpenTasks_emptyArray() async throws {
        mockClient.stubJSON("task.listOpen", json: "[]")

        let tasks = try await service.listOpenTasks()

        XCTAssertTrue(tasks.isEmpty)
    }

    // MARK: - State Management

    func testIsLoading_setsDuringCall() async throws {
        mockClient.stubJSON("task.getById", json: TestFixtures.taskJSON)

        // Before call
        XCTAssertFalse(service.isLoading)

        // After call completes, isLoading should be false
        _ = try await service.getTask(id: "task-1")
        XCTAssertFalse(service.isLoading)
    }
}
```

**Step 2: Run tests**

Run: `xcodebuild test -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -only-testing:"hustleXP final1Tests/TaskServiceTests" 2>&1 | grep -E "Test Case|Tests|BUILD"`
Expected: All tests pass

**Step 3: Commit**

```bash
git add "hustleXP final1Tests/TaskServiceTests.swift"
git commit -m "test(ios): add TaskService tests (8 tests covering CRUD + error handling)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: Write EscrowService Tests

**Files:**
- Create: `hustleXP final1Tests/EscrowServiceTests.swift`

**Step 1: Write the test file**

```swift
import XCTest
@testable import hustleXP_final1

@MainActor
final class EscrowServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: EscrowService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = EscrowService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - createPaymentIntent

    func testCreatePaymentIntent_returnsClientSecret() async throws {
        mockClient.stubJSON("escrow.createPaymentIntent", json: TestFixtures.paymentIntentJSON)

        let result = try await service.createPaymentIntent(taskId: "task-1")

        XCTAssertEqual(result.clientSecret, "pi_test123_secret_abc")
        XCTAssertEqual(result.escrowId, "esc-1")
        XCTAssertTrue(mockClient.wasCalled("escrow.createPaymentIntent"))
    }

    // MARK: - getEscrowByTask

    func testGetEscrowByTask_returnsEscrow() async throws {
        mockClient.stubJSON("escrow.getByTask", json: TestFixtures.escrowJSON)

        let escrow = try await service.getEscrowByTask(taskId: "task-1")

        XCTAssertEqual(escrow.id, "esc-1")
        XCTAssertEqual(escrow.amountCents, 2500)
        XCTAssertEqual(escrow.state, .funded)
    }

    // MARK: - releaseToWorker

    func testReleaseToWorker_transitionsState() async throws {
        let releasedJSON = TestFixtures.modify(
            TestFixtures.escrowJSON,
            key: "state",
            value: "\"released\""
        )
        mockClient.stubJSON("escrow.release", json: releasedJSON)

        let escrow = try await service.releaseToWorker(escrowId: "esc-1")

        XCTAssertEqual(escrow.state, .released)
        XCTAssertTrue(mockClient.wasCalled("escrow.release"))
    }

    // MARK: - refundToPoster

    func testRefundToPoster_transitionsState() async throws {
        let refundedJSON = TestFixtures.modify(
            TestFixtures.escrowJSON,
            key: "state",
            value: "\"refunded\""
        )
        mockClient.stubJSON("escrow.refund", json: refundedJSON)

        let escrow = try await service.refundToPoster(escrowId: "esc-1")

        XCTAssertEqual(escrow.state, .refunded)
    }

    // MARK: - awardXP

    func testAwardXP_returnsXPResult() async throws {
        mockClient.stubJSON("escrow.awardXP", json: TestFixtures.xpAwardJSON)

        let result = try await service.awardXP(
            taskId: "task-1",
            escrowId: "esc-1",
            baseXP: 50
        )

        XCTAssertEqual(result.xpAwarded, 50)
        XCTAssertEqual(result.newTotalXP, 200)
        XCTAssertEqual(result.tierUp, false)
    }

    // MARK: - Error Handling

    func testGetEscrow_networkError_throws() async {
        mockClient.stubError("escrow.getByTask", error: MockNetworkError.serverError)

        do {
            _ = try await service.getEscrowByTask(taskId: "task-1")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getPaymentHistory

    func testGetPaymentHistory_returnsArray() async throws {
        mockClient.stubJSON("escrow.paymentHistory", json: "[\(TestFixtures.escrowJSON)]")

        let history = try await service.getPaymentHistory()

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.id, "esc-1")
    }
}
```

**Step 2: Run tests**

Run: `xcodebuild test -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" -only-testing:"hustleXP final1Tests/EscrowServiceTests" 2>&1 | grep -E "Test Case|Tests|BUILD"`
Expected: All tests pass

**Step 3: Commit**

```bash
git add "hustleXP final1Tests/EscrowServiceTests.swift"
git commit -m "test(ios): add EscrowService tests (7 tests covering payment lifecycle)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: Write AuthService Tests

**Files:**
- Create: `hustleXP final1Tests/AuthServiceTests.swift`

AuthService is harder to test fully because signIn/signUp call Firebase Auth
directly. These tests cover the tRPC-only paths and state management.

**Step 1: Write the test file**

```swift
import XCTest
@testable import hustleXP_final1

@MainActor
final class AuthServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: AuthService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = AuthService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_notAuthenticated() {
        XCTAssertNil(service.currentUser)
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertFalse(service.isLoading)
    }

    // MARK: - signOut

    func testSignOut_clearsState() {
        // Manually set some state to verify cleanup
        service.signOut()

        XCTAssertNil(service.currentUser)
        XCTAssertFalse(service.isAuthenticated)
    }

    // MARK: - Error State

    func testError_initiallyNil() {
        XCTAssertNil(service.error)
    }
}
```

**Step 2: Run ALL tests together**

Run: `xcodebuild test -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" 2>&1 | grep -E "Test Suite|Executed|BUILD"`
Expected: All tests pass (existing 75 + new ~18 = ~93 total)

**Step 3: Commit**

```bash
git add "hustleXP final1Tests/AuthServiceTests.swift"
git commit -m "test(ios): add AuthService tests (3 tests covering state + signOut)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: Final Validation + Push

**Step 1: Run full backend test suite**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npx vitest run 2>&1 | tail -5`
Expected: All pass, 0 failures

**Step 2: Run full iOS test suite**

Run: `cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1 && xcodebuild test -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2" 2>&1 | grep -E "Executed|BUILD"`
Expected: All pass, BUILD SUCCEEDED

**Step 3: Push all repos**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && git push origin main
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1 && git push origin main
```

**Step 4: Verify health score improvement**

Run `/health` to confirm ecosystem score >= 90.

---

## Parallel Execution Map

```
Phase 1 (Backend)          Phase 2 (iOS Deletion)     Phase 3 (Docs)
┌──────────────────┐      ┌──────────────────┐       ┌──────────────────┐
│ Task 1: ESLint   │      │ Task 3: Delete   │       │ Task 4: Commit   │
│ Task 2: Delete   │      │   3 orphans      │       │   17 docs files  │
│   8 services     │      └──────────────────┘       └──────────────────┘
└──────────────────┘
         ↓ (all 3 independent — can run in parallel)

Phase 4 (iOS Tests — sequential, each depends on previous)
┌──────────────────┐
│ Task 5: Protocol │
│ Task 6: Inits    │──→ Task 7: Mock+Helpers ──→ Task 8-10: Service Tests
└──────────────────┘

Phase 5 (Validation)
┌──────────────────┐
│ Task 11: Verify  │
│   + Push         │
└──────────────────┘
```

Tasks 1-4 can be dispatched as parallel subagents.
Tasks 5-10 must be sequential (each builds on the previous).
Task 11 depends on all prior tasks.
