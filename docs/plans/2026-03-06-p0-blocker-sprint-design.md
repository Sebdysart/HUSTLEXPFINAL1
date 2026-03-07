# P0 Blocker Sprint: Last Mile to Beta

**Date:** 2026-03-06
**Goal:** Resolve all remaining P0 blockers (3 of 8 — 5 already complete) + update scorecard
**Target:** Scorecard B1 → 100%, 0 P0 blockers remaining

---

## Context

The Private Beta Spec listed 8 P0 blockers. Deep investigation on 2026-03-06 revealed
**5 are already complete** (scorecard was stale):

| # | Blocker | Actual Status |
|---|---------|---------------|
| G1.4 | TaskDetailScreen | DONE — HustlerTaskDetailScreen.swift (867 lines) |
| G1.5 | R2 proof upload | DONE — ProofSubmissionViewModel → R2UploadService |
| G2.6 | Proof review UI | DONE — ProofReviewScreen + backend reviewProof |
| I3.2 | iOS R2 upload | DONE — R2UploadService.uploadPhoto() |
| I4.2 | FCM registration | DONE — PushNotificationManager.registerToken() |
| **G2.4** | **Applicant accept/reject** | **PARTIAL — backend endpoints not wired** |
| **G2.5** | **Task monitoring + SSE** | **SMALL GAP — screens not subscribed** |
| **G3.3** | **Photo messaging** | **SMALL GAP — UI needs photo picker** |

---

## Existing Infrastructure (DO NOT Rebuild)

### G2.4 — Applicant Management

**Backend (complete):**
- `task_applications` table: 10 columns, constraints, indexes, status state machine
- `TaskApplicationService`: apply, accept, reject, counter, withdraw, expire (fully tested, 763 lines)
- Migration: `phase_application_and_dispute_resolution.sql`

**iOS (complete except apply flow):**
- `TaskApplicant` model: Codable, 7 fields
- `TaskService.listApplicants/assignWorker/rejectApplicant`: tRPC calls ready
- `ApplicantListScreen`: poster-facing accept/decline UI
- `PosterTaskDetailScreen`: applicant count + navigation
- `Router.applicantList(taskId:)`: navigation case wired

**Missing:**
- Backend: 5 tRPC procedures in task router (delegating to existing service)
- iOS: `TaskService.applyForTask()` method + "Apply" button in hustler task detail
- Auto-create messaging conversation on accept

### G2.5 — SSE Task State Updates

**Complete:**
- `RealtimeSSEClient`: connect, disconnect, message parsing, reconnection
- Backend SSE server at `/realtime/stream`
- `MessagingService` subscribes to SSE for message events

**Missing:**
- Task detail screens don't subscribe to `task.stateChanged` events
- No refresh trigger when task state changes via SSE

### G3.3 — Photo Messaging

**Complete:**
- Backend: `messaging.sendPhotoMessage` endpoint (validates 1-3 photos)
- iOS: `MessagingService.sendPhotoMessage(taskId:, photoUrls:, caption:)`
- `R2UploadService.uploadPhoto()` for photo upload

**Missing:**
- Verify ConversationScreen has photo picker integration
- Verify message bubbles render photo messages

---

## Design

### Phase 1: Backend — Wire tRPC Procedures (Provider-First)

Add 5 procedures to `backend/src/routers/task.ts`:

```typescript
// 1. Hustler applies for a task
applyForTask: protectedProcedure
  .input(z.object({ taskId: Schemas.uuid, message: z.string().optional() }))
  .mutation(...)  // delegates to TaskApplicationService.applyForTask()

// 2. Poster lists applicants
listApplicants: protectedProcedure
  .input(z.object({ taskId: Schemas.uuid }))
  .query(...)  // delegates to TaskApplicationService.getApplicationsForTask()

// 3. Poster accepts an applicant (auto-creates conversation)
acceptApplicant: protectedProcedure
  .input(z.object({ taskId: Schemas.uuid, workerId: Schemas.uuid }))
  .mutation(...)  // delegates to TaskApplicationService.acceptApplication()
                  // then creates/ensures messaging conversation

// 4. Poster rejects an applicant
rejectApplicant: protectedProcedure
  .input(z.object({ taskId: Schemas.uuid, workerId: Schemas.uuid, reason: z.string().optional() }))
  .mutation(...)  // delegates to TaskApplicationService.rejectApplication()

// 5. Hustler withdraws application
withdrawApplication: protectedProcedure
  .input(z.object({ taskId: Schemas.uuid }))
  .mutation(...)  // delegates to TaskApplicationService.withdrawApplication()
```

**Response mapping:** TaskApplicationService returns full application rows. Map to iOS-compatible
`TaskApplicant` shape (id, userId → hustlerId, name, rating, completedTasks, tier, appliedAt, message).

**Messaging on accept:** After `acceptApplication()`, ensure a conversation exists for the task
between poster and accepted worker. Use the messaging service's conversation creation or
send a system message ("Application accepted — you can now chat").

### Phase 2: iOS — Hustler Apply Flow

**New method in TaskService.swift:**
```swift
func applyForTask(taskId: String, message: String? = nil) async throws {
    // calls task.applyForTask
}
```

**UI changes in HustlerTaskDetailScreen.swift:**
- Add "Apply" button for tasks in `posted` state (when task requires applications)
- Show optional message text field
- After successful apply, show confirmation state
- Handle already-applied state (show "Applied" badge)

### Phase 3: iOS — SSE Task State Wiring

In both `HustlerTaskDetailScreen` and `PosterTaskDetailScreen`:
- On appear: subscribe to `RealtimeSSEClient.shared.messageReceived`
- Filter for events where `event == "task.stateChanged"` and data contains matching taskId
- On match: refresh task data from API
- On disappear: cancel subscription

### Phase 4: iOS — Photo Messaging Verification

Verify in `ConversationScreen` / messaging UI:
- Photo picker button exists (PHPickerViewController or PhotosPicker)
- Flow: select → R2UploadService.uploadPhoto(purpose: .message) → MessagingService.sendPhotoMessage()
- Message bubbles render `messageType == "PHOTO"` with AsyncImage

If missing, add the photo picker integration.

### Phase 5: Scorecard Update

Update `private-beta/scorecard.json`:
- Mark G1.4, G1.5, G2.4, G2.5, G2.6, G3.3, I3.2, I4.2 as DONE
- Recompute B1 score (expect 100%)
- Recompute overall score (expect 95+)

---

## Parallel Execution Strategy

```
Phase 1 (Backend tRPC) ─────────────┐
                                      ├──→ Phase 5 (Scorecard)
Phase 2 (Hustler Apply) ────────────┤
  [depends on Phase 1]               │
                                      │
Phase 3 (SSE wiring) ───────────────┤  [independent]
Phase 4 (Photo messaging) ──────────┘  [independent]
```

- Phase 1 must complete before Phase 2 (provider-first)
- Phases 3 + 4 are independent of everything else
- All phases must complete before Phase 5

---

## Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| TaskApplicationService field names don't match iOS model | Low | Check mapping before wiring |
| Backend doesn't emit SSE events for task state changes | Medium | Verify or add SSE emit in state transition handlers |
| Duplicate conversations on accept | Low | Use upsert/get-or-create pattern |
| ConversationScreen photo picker already exists | High | Just verify, don't rebuild |

---

## Success Criteria

- [ ] All 5 tRPC procedures pass backend tests
- [ ] Hustler can apply for a task from iOS
- [ ] Poster can see applicants, accept, and reject from iOS
- [ ] Conversation auto-created on accept
- [ ] Task detail screens refresh on SSE state changes
- [ ] Photo messaging works end-to-end
- [ ] Scorecard shows 0 P0 blockers
- [ ] iOS test suite still passes (167+ tests)
- [ ] Backend test suite still passes (1,794+ tests)
