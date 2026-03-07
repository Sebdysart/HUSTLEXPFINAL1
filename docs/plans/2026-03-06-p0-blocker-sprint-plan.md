# P0 Blocker Sprint: Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Wire the last 2 P0 blockers (G2.4 applicant management, G2.5 SSE task updates) and verify the remaining items are complete.

**Architecture:** Backend-first: add 5 tRPC procedures to `task.ts` delegating to SQL queries on the existing `task_applications` table, then wire iOS apply flow and SSE subscriptions.

**Tech Stack:** TypeScript/tRPC/Zod (backend), Swift/SwiftUI (iOS), PostgreSQL

---

## Pre-Flight: Key Discoveries

Before implementing, understand what already exists:

| Item | Status | Evidence |
|------|--------|----------|
| `task_applications` table | ✅ EXISTS | Migration `phase_application_and_dispute_resolution.sql` |
| `TaskApplicationService.ts` | ✅ EXISTS at `/src/services/` | 738 lines, full state machine, singleton export |
| iOS `TaskService.listApplicants/assignWorker/rejectApplicant` | ✅ EXISTS | Calls `task.listApplicants`, `task.assignWorker`, `task.rejectApplicant` |
| iOS `ApplicantListScreen` | ✅ EXISTS | Poster-facing accept/decline UI |
| iOS `PosterTaskDetailScreen` SSE subscription | ✅ EXISTS | `subscribeToSSE()` method on line 290 |
| iOS `ConversationScreen` photo messaging | ✅ EXISTS | PhotosPicker → R2Upload → sendPhotoMessage → AsyncImage |
| Scorecard | ✅ ALREADY 100/100 | Updated by `session-final-3-blockers` |

**What's actually missing:**
1. Backend: 5 tRPC procedures in `task.ts` (the iOS calls them but they don't exist yet)
2. iOS: `TaskService.applyForTask()` method
3. iOS: "Apply" button in `HustlerTaskDetailScreen`
4. iOS: SSE subscription in `HustlerTaskDetailScreen`

---

## Task 1: Backend — Add `applyForTask` tRPC Procedure

**Files:**
- Modify: `/Users/sebastiandysart/Desktop/hustlexp-ai-backend/backend/src/routers/task.ts` (after line 474, before `});`)
- Test: Run existing backend test suite

**Step 1: Add the `applyForTask` mutation**

Add this procedure at the end of the taskRouter (before the closing `});`):

```typescript
  // --------------------------------------------------------------------------
  // APPLICATION MANAGEMENT
  // --------------------------------------------------------------------------

  /**
   * Hustler applies for a task
   * Creates a row in task_applications with status='pending'
   */
  applyForTask: protectedProcedure
    .input(z.object({
      taskId: Schemas.uuid,
      message: z.string().max(500).optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      // Verify task exists and is in POSTED state
      const taskResult = await db.query(
        `SELECT id, state, poster_id FROM tasks WHERE id = $1`,
        [input.taskId]
      );
      if (taskResult.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
      }
      const task = taskResult.rows[0];
      if (task.state !== 'POSTED') {
        throw new TRPCError({
          code: 'PRECONDITION_FAILED',
          message: `Task must be in POSTED state to apply, current: ${task.state}`,
        });
      }
      if (task.poster_id === ctx.user.id) {
        throw new TRPCError({ code: 'BAD_REQUEST', message: 'Cannot apply for your own task' });
      }

      // Check for existing active application
      const existing = await db.query(
        `SELECT id FROM task_applications
         WHERE task_id = $1 AND hustler_id = $2 AND status IN ('pending', 'countered')`,
        [input.taskId, ctx.user.id]
      );
      if (existing.rows.length > 0) {
        throw new TRPCError({ code: 'CONFLICT', message: 'You already have an active application for this task' });
      }

      // Insert application
      const result = await db.query(
        `INSERT INTO task_applications (id, task_id, hustler_id, message, status, counter_offer_round, created_at, updated_at)
         VALUES (gen_random_uuid(), $1, $2, $3, 'pending', 0, NOW(), NOW())
         RETURNING *`,
        [input.taskId, ctx.user.id, input.message || null]
      );

      return {
        id: result.rows[0].id,
        taskId: result.rows[0].task_id,
        status: result.rows[0].status,
        message: result.rows[0].message,
        appliedAt: result.rows[0].created_at,
      };
    }),
```

**Step 2: Run backend tests to verify no regressions**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npm test 2>&1 | tail -5`
Expected: All 1,794+ tests pass

**Step 3: Commit**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
git add backend/src/routers/task.ts
git commit -m "feat(backend): add applyForTask tRPC procedure

Wires hustler application flow to task_applications table.
Validates task state, prevents self-application, enforces
one-active-application-per-hustler invariant."
```

---

## Task 2: Backend — Add `listApplicants` tRPC Procedure

**Files:**
- Modify: `/Users/sebastiandysart/Desktop/hustlexp-ai-backend/backend/src/routers/task.ts`

**Step 1: Add the `listApplicants` query**

Add after the `applyForTask` procedure:

```typescript
  /**
   * Poster lists applicants for their task
   * Joins with users table to get profile info matching iOS TaskApplicant model
   */
  listApplicants: protectedProcedure
    .input(z.object({ taskId: Schemas.uuid }))
    .query(async ({ ctx, input }) => {
      // Verify caller is the poster
      const taskResult = await db.query(
        `SELECT poster_id FROM tasks WHERE id = $1`,
        [input.taskId]
      );
      if (taskResult.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
      }
      if (taskResult.rows[0].poster_id !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN', message: 'Only the task poster can view applicants' });
      }

      // Join applications with user profiles
      const result = await db.query(
        `SELECT
           ta.id,
           ta.hustler_id AS user_id,
           COALESCE(u.display_name, u.name, 'Unknown') AS name,
           COALESCE(u.rating, 5.0) AS rating,
           COALESCE(u.completed_tasks, 0) AS completed_tasks,
           COALESCE(u.trust_tier, 'rookie') AS tier,
           ta.created_at AS applied_at,
           ta.message
         FROM task_applications ta
         LEFT JOIN users u ON u.id = ta.hustler_id
         WHERE ta.task_id = $1 AND ta.status = 'pending'
         ORDER BY ta.created_at ASC`,
        [input.taskId]
      );

      return result.rows;
    }),
```

**Step 2: Run backend tests**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npm test 2>&1 | tail -5`
Expected: All tests pass

**Step 3: Commit**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
git add backend/src/routers/task.ts
git commit -m "feat(backend): add listApplicants tRPC procedure

Joins task_applications with users to return TaskApplicant-shaped
response matching iOS model (id, userId, name, rating, tier, etc).
Authorization: only the task poster can list applicants."
```

---

## Task 3: Backend — Add `assignWorker` and `rejectApplicant` Procedures

**Files:**
- Modify: `/Users/sebastiandysart/Desktop/hustlexp-ai-backend/backend/src/routers/task.ts`

**Step 1: Add `assignWorker` mutation (accepts an applicant)**

```typescript
  /**
   * Poster accepts an applicant — assigns them as the worker
   * Transitions task from POSTED → ACCEPTED
   * iOS calls this as task.assignWorker({ taskId, workerId })
   */
  assignWorker: protectedProcedure
    .input(z.object({
      taskId: Schemas.uuid,
      workerId: Schemas.uuid,
    }))
    .mutation(async ({ ctx, input }) => {
      // Verify caller is the poster
      const taskResult = await db.query(
        `SELECT id, state, poster_id FROM tasks WHERE id = $1`,
        [input.taskId]
      );
      if (taskResult.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
      }
      if (taskResult.rows[0].poster_id !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN', message: 'Only the task poster can assign workers' });
      }
      if (taskResult.rows[0].state !== 'POSTED') {
        throw new TRPCError({
          code: 'PRECONDITION_FAILED',
          message: `Task must be POSTED to assign a worker, current: ${taskResult.rows[0].state}`,
        });
      }

      // Verify the applicant has a pending application
      const appResult = await db.query(
        `SELECT id FROM task_applications
         WHERE task_id = $1 AND hustler_id = $2 AND status = 'pending'`,
        [input.taskId, input.workerId]
      );
      if (appResult.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'No pending application found for this worker' });
      }

      // Accept the application
      await db.query(
        `UPDATE task_applications SET status = 'accepted', updated_at = NOW()
         WHERE id = $1`,
        [appResult.rows[0].id]
      );

      // Reject all other pending applications for this task
      await db.query(
        `UPDATE task_applications SET status = 'rejected', rejection_reason = 'Another applicant was selected', updated_at = NOW()
         WHERE task_id = $1 AND status = 'pending' AND id != $2`,
        [input.taskId, appResult.rows[0].id]
      );

      // Assign worker to task and transition to ACCEPTED
      const result = await TaskService.accept({
        taskId: input.taskId,
        workerId: input.workerId,
      });

      if (!result.success) {
        throw new TRPCError({ code: 'BAD_REQUEST', message: result.error.message });
      }

      return result.data;
    }),
```

**Step 2: Add `rejectApplicant` mutation**

```typescript
  /**
   * Poster rejects a specific applicant
   * iOS calls this as task.rejectApplicant({ taskId, workerId })
   */
  rejectApplicant: protectedProcedure
    .input(z.object({
      taskId: Schemas.uuid,
      workerId: Schemas.uuid,
      reason: z.string().max(500).optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      // Verify caller is the poster
      const taskResult = await db.query(
        `SELECT poster_id FROM tasks WHERE id = $1`,
        [input.taskId]
      );
      if (taskResult.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
      }
      if (taskResult.rows[0].poster_id !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN', message: 'Only the task poster can reject applicants' });
      }

      // Find and reject the application
      const result = await db.query(
        `UPDATE task_applications
         SET status = 'rejected', rejection_reason = $3, updated_at = NOW()
         WHERE task_id = $1 AND hustler_id = $2 AND status = 'pending'
         RETURNING id`,
        [input.taskId, input.workerId, input.reason || null]
      );

      if (result.rows.length === 0) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'No pending application found for this worker' });
      }

      return { success: true };
    }),
```

**Step 3: Run backend tests**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npm test 2>&1 | tail -5`
Expected: All tests pass

**Step 4: Commit**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
git add backend/src/routers/task.ts
git commit -m "feat(backend): add assignWorker + rejectApplicant tRPC procedures

assignWorker: accepts applicant, rejects others, assigns worker via TaskService.
rejectApplicant: rejects a specific applicant with optional reason.
Both enforce poster-only authorization."
```

---

## Task 4: Backend — Add `withdrawApplication` Procedure

**Files:**
- Modify: `/Users/sebastiandysart/Desktop/hustlexp-ai-backend/backend/src/routers/task.ts`

**Step 1: Add `withdrawApplication` mutation**

```typescript
  /**
   * Hustler withdraws their own application
   */
  withdrawApplication: protectedProcedure
    .input(z.object({ taskId: Schemas.uuid }))
    .mutation(async ({ ctx, input }) => {
      const result = await db.query(
        `UPDATE task_applications
         SET status = 'withdrawn', updated_at = NOW()
         WHERE task_id = $1 AND hustler_id = $2 AND status IN ('pending', 'countered')
         RETURNING id`,
        [input.taskId, ctx.user.id]
      );

      if (result.rows.length === 0) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'No active application found to withdraw',
        });
      }

      return { success: true };
    }),
```

**Step 2: Run backend tests**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npm test 2>&1 | tail -5`
Expected: All tests pass

**Step 3: Commit**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
git add backend/src/routers/task.ts
git commit -m "feat(backend): add withdrawApplication tRPC procedure

Allows hustlers to withdraw pending/countered applications.
Uses auth context to ensure only the applicant can withdraw."
```

---

## Task 5: iOS — Add `applyForTask` Method to TaskService

**Files:**
- Modify: `/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/Services/TaskService.swift`
- Test: `/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1Tests/TaskServiceTests.swift`

**Step 1: Write the failing test**

Add to `TaskServiceTests.swift`:

```swift
func testApplyForTask() async throws {
    let json = """
    {"id":"app-001","taskId":"task-001","status":"pending","message":"I can help!","appliedAt":"2026-03-06T00:00:00Z"}
    """.data(using: .utf8)!
    mockClient.stubJSON("task.applyForTask", json: json)

    let result = try await service.applyForTask(taskId: "task-001", message: "I can help!")

    XCTAssertEqual(result.id, "app-001")
    XCTAssertEqual(result.status, "pending")
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1.xcodeproj" -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro" -only-testing:"hustleXP final1Tests/TaskServiceTests/testApplyForTask" 2>&1 | tail -10`
Expected: FAIL — `applyForTask` method does not exist

**Step 3: Add the response model and method to TaskService.swift**

Add after the `// MARK: - Applicant Management (Poster)` section (around line 262):

```swift
    // MARK: - Application (Hustler)

    /// Hustler applies for a task with optional message
    func applyForTask(taskId: String, message: String? = nil) async throws -> ApplicationResponse {
        isLoading = true
        defer { isLoading = false }

        struct ApplyInput: Codable {
            let taskId: String
            let message: String?
        }

        let response: ApplicationResponse = try await trpc.call(
            router: "task",
            procedure: "applyForTask",
            input: ApplyInput(taskId: taskId, message: message)
        )

        HXLogger.info("TaskService: Applied for task \(taskId)", category: "Task")
        return response
    }

    /// Hustler withdraws their application
    func withdrawApplication(taskId: String) async throws {
        struct WithdrawInput: Codable {
            let taskId: String
        }

        struct SuccessResponse: Codable {
            let success: Bool
        }

        let _: SuccessResponse = try await trpc.call(
            router: "task",
            procedure: "withdrawApplication",
            input: WithdrawInput(taskId: taskId)
        )

        HXLogger.info("TaskService: Withdrew application for task \(taskId)", category: "Task")
    }
```

Add the `ApplicationResponse` struct at the bottom of the file (before the closing of TaskService or in a models section):

```swift
// MARK: - Application Response

struct ApplicationResponse: Codable, Identifiable {
    let id: String
    let taskId: String
    let status: String
    let message: String?
    let appliedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case status
        case message
        case appliedAt = "applied_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        taskId = (try? container.decode(String.self, forKey: .taskId)) ?? ""
        status = (try? container.decode(String.self, forKey: .status)) ?? "pending"
        message = try? container.decode(String.self, forKey: .message)
        appliedAt = try? container.decode(Date.self, forKey: .appliedAt)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1.xcodeproj" -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro" -only-testing:"hustleXP final1Tests/TaskServiceTests/testApplyForTask" 2>&1 | tail -10`
Expected: PASS

**Step 5: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Services/TaskService.swift" "hustleXP final1Tests/TaskServiceTests.swift"
git commit -m "feat(ios): add applyForTask + withdrawApplication to TaskService

Wires hustler application flow to backend tRPC procedures.
Adds ApplicationResponse model with snake_case CodingKeys."
```

---

## Task 6: iOS — Add "Apply" Button to HustlerTaskDetailScreen

**Files:**
- Modify: `/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift`

**Step 1: Add application state variables**

Add after line 27 (`@State private var showRatingSheet = false`):

```swift
    // Application state
    @State private var hasApplied = false
    @State private var isApplying = false
    @State private var showApplySheet = false
    @State private var applicationMessage = ""
```

**Step 2: Modify `bottomActionBar` to show "Apply" for `.posted` tasks**

Replace the existing `.posted` state button logic in `bottomActionBar` (around lines 676-716).

Find this block:
```swift
                    Button(action: {
                        if task.state == .posted {
                            acceptTask(task)
                        } else {
                            router.navigateToHustler(.taskInProgress(taskId: task.id))
                        }
```

Replace with:
```swift
                    Button(action: {
                        if task.state == .posted {
                            if hasApplied {
                                // Already applied — no action
                            } else {
                                showApplySheet = true
                            }
                        } else {
                            router.navigateToHustler(.taskInProgress(taskId: task.id))
                        }
```

And update the button label (around line 692):

Find:
```swift
                            Text(task.state == .posted ? "Accept Task" : "View Progress")
```

Replace with:
```swift
                            Text(task.state == .posted ? (hasApplied ? "Applied ✓" : "Apply Now") : "View Progress")
```

And update the icon (around line 688):

Find:
```swift
                                Image(systemName: task.state == .posted ? "checkmark.circle.fill" : "arrow.right.circle.fill")
```

Replace with:
```swift
                                Image(systemName: task.state == .posted ? (hasApplied ? "checkmark.seal.fill" : "paperplane.fill") : "arrow.right.circle.fill")
```

**Step 3: Add the apply sheet and apply action**

Add a `.sheet` modifier after the existing `.alert` (around line 114):

```swift
            // Application sheet
            .sheet(isPresented: $showApplySheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Apply for Task")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Send a message to the poster explaining why you're a great fit.")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)

                        TextEditor(text: $applicationMessage)
                            .frame(minHeight: 100, maxHeight: 200)
                            .padding(8)
                            .background(Color.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1))
                            )

                        Button(action: {
                            applyForTask(task!)
                        }) {
                            HStack {
                                if isApplying {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isApplying ? "Submitting..." : "Submit Application")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.brandPurple)
                            .cornerRadius(14)
                        }
                        .disabled(isApplying)
                    }
                    .padding(24)
                    .background(Color.brandBlack)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cancel") { showApplySheet = false }
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
```

**Step 4: Add the `applyForTask` method**

Add after the existing `acceptTaskOffline` method (around line 855):

```swift
    // MARK: - Apply for Task

    private func applyForTask(_ task: HXTask) {
        isApplying = true
        Task {
            do {
                _ = try await taskService.applyForTask(
                    taskId: task.id,
                    message: applicationMessage.isEmpty ? nil : applicationMessage
                )
                hasApplied = true
                showApplySheet = false
                applicationMessage = ""

                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
            } catch {
                HXLogger.error("TaskDetail: Apply failed - \(error.localizedDescription)", category: "Task")
                acceptError = "Could not submit application. Please try again."
                showAcceptError = true
            }
            isApplying = false
        }
    }
```

**Step 5: Disable button when already applied**

In the `.disabled` modifier of the apply button (line 716), update:

Find:
```swift
                    .disabled(!isEligible || isAccepting)
```

Replace with:
```swift
                    .disabled(!isEligible || isAccepting || hasApplied || isApplying)
```

**Step 6: Build and verify**

Run: `xcodebuild build -project "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1.xcodeproj" -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro" 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift"
git commit -m "feat(ios): add Apply button to HustlerTaskDetailScreen

Replaces direct 'Accept Task' with application flow for posted tasks.
Shows apply sheet with optional message, tracks applied state,
provides haptic feedback on success."
```

---

## Task 7: iOS — Wire SSE Task State Updates in HustlerTaskDetailScreen

**Files:**
- Modify: `/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift`

**Context:** PosterTaskDetailScreen already has SSE wired (line 290). HustlerTaskDetailScreen does not.

**Step 1: Add Combine import and SSE state**

The file already imports SwiftUI. Add Combine import:

Find (line 8):
```swift
import SwiftUI
```

Replace with:
```swift
import SwiftUI
import Combine
```

Add after `@State private var applicationMessage = ""` (the new state vars from Task 6):

```swift
    // SSE subscription
    @State private var sseSubscription: AnyCancellable?
```

**Step 2: Add SSE subscription method**

Add after the `applyForTask` method:

```swift
    // MARK: - SSE Subscription

    private func subscribeToSSE() {
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                let relevantEvents = [
                    "task_updated", "task_state_changed", "proof_submitted",
                    "task_completed", "application_accepted", "application_rejected"
                ]
                guard relevantEvents.contains(message.event) else { return }

                // Check if event is for this task
                if let json = try? JSONSerialization.jsonObject(with: message.data) as? [String: Any],
                   let eventTaskId = json["taskId"] as? String ?? json["task_id"] as? String,
                   eventTaskId == taskId {
                    HXLogger.info("HustlerTaskDetail: SSE event \(message.event) for task \(taskId)", category: "Network")
                    Task {
                        await loadTaskFromAPI()
                    }
                }
            }
    }
```

**Step 3: Wire subscription on appear/disappear**

Find the `.onAppear` block (around line 94-98):
```swift
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
```

Replace with:
```swift
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
                subscribeToSSE()
            }
            .onDisappear {
                sseSubscription?.cancel()
                sseSubscription = nil
            }
```

**Step 4: Build and verify**

Run: `xcodebuild build -project "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1.xcodeproj" -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro" 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Screens/Hustler/HustlerTaskDetailScreen.swift"
git commit -m "feat(ios): wire SSE task state updates in HustlerTaskDetailScreen

Subscribes to RealtimeSSEClient for task_updated, task_state_changed,
application_accepted/rejected events. Refreshes task from API on match.
Mirrors PosterTaskDetailScreen SSE pattern."
```

---

## Task 8: Verification — Run Full Test Suites

**Step 1: Run full iOS test suite**

Run: `xcodebuild test -project "/Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1/hustleXP final1.xcodeproj" -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16 Pro" 2>&1 | grep -E "Test Suite|Tests? (Passed|Failed|passed|failed)|TEST SUCCEEDED|TEST FAILED"`
Expected: 167+ tests, 0 failures — TEST SUCCEEDED

**Step 2: Run full backend test suite**

Run: `cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && npm test 2>&1 | tail -5`
Expected: 1,794+ tests pass

**Step 3: Verify scorecard is accurate**

Read: `/Users/sebastiandysart/Desktop/hustlexp-docs/private-beta/scorecard.json`
Expected: Overall score 100/100, no blockers

If the scorecard needs updating, update the `lastUpdatedAt` and `lastUpdatedBy` fields.

**Step 4: Push all repos**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend && git push origin main
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1 && git push origin main
```

---

## Parallel Execution Strategy

```
Task 1 (applyForTask) ──┐
Task 2 (listApplicants) ─┤
Task 3 (assign+reject) ──┼──→ Task 5 (iOS applyForTask) ──→ Task 6 (Apply UI)
Task 4 (withdraw) ───────┘                                        │
                                                                    ├──→ Task 8 (Verify)
Task 7 (SSE wiring) ─── [independent] ────────────────────────────┘
```

- Tasks 1-4 (backend) can be done as one batch
- Task 5 depends on Tasks 1-4 (needs backend procedures)
- Task 6 depends on Task 5 (needs `applyForTask` method)
- Task 7 is independent of everything else
- Task 8 runs after all others complete

---

## Success Criteria

- [ ] All 5 tRPC procedures exist in task.ts (applyForTask, listApplicants, assignWorker, rejectApplicant, withdrawApplication)
- [ ] `TaskService.applyForTask()` exists in iOS and has a passing test
- [ ] HustlerTaskDetailScreen shows "Apply Now" button for posted tasks
- [ ] HustlerTaskDetailScreen subscribes to SSE for task state changes
- [ ] iOS test suite passes (167+ tests, 0 failures)
- [ ] Backend test suite passes (1,794+ tests)
- [ ] Scorecard shows 100/100 with 0 P0 blockers
