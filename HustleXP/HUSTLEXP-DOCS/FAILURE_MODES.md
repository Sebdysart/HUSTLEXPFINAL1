# FAILURE MODES — HustleXP v1.0

**STATUS: LOCKED**
**Authority:** Adapter invariant tests, BACKEND_CONTRACT.md

---

## PART A — Failure Type Matrix

| Failure Type | Source | Adapter Behavior | UI Result | Logged |
|--------------|--------|------------------|-----------|--------|
| Missing required field | Backend | Returns `error` + stubProps | StatusBanner danger | Yes |
| Wrong primitive type | Backend | Returns `error` + stubProps | StatusBanner danger | Yes |
| Invalid enum value | Backend | Returns `error` + stubProps | StatusBanner danger | Yes |
| Null where forbidden | Backend | Returns `error` + stubProps | StatusBanner danger | Yes |
| Empty collection | Backend | Returns `empty` + props | EmptyState component | No |
| Eligibility blocked | Backend | Returns `blocked` + props | StatusBanner warning | No |
| Optional field missing | Backend | Coerced to default via `??` | Normal UI | No |
| Array field invalid | Backend | Coerced to empty `[]` | Empty list UI | No |

---

## PART B — Specific Backend Failure Scenarios

### B1. Backend Schema Drift (New Required Field)

**Scenario:** Backend adds a new required field `task.urgency` that the client doesn't know about.

**Behavior:**
- Adapter: No guard for unknown fields → **success** (field ignored)
- UI: Renders without new field
- Risk: None until UI code tries to use `task.urgency`
- Mitigation: Adapters only validate fields they use

### B2. Partial Deploys (Old Client, New Backend)

**Scenario:** Backend deployed with new enum value before client update.

**Behavior:**
- Adapter: Guard rejects unknown enum → **error state**
- UI: StatusBanner danger "Something went wrong. Pull to retry."
- Logged: Yes, with ERROR_CODES.INVALID_RESPONSE
- Recovery: User sees error, can retry; app doesn't crash

### B3. Enum Expansion

**Scenario:** Backend returns `taskProgressState: 'PAUSED'` (new value).

**Behavior:**
- Adapter: `validStates.includes('PAUSED')` → false → **error state**
- UI: StatusBanner danger
- Logged: Yes
- Graceful: App continues functioning, user can navigate back

### B4. Removed Fields

**Scenario:** Backend removes `task.estimatedDuration` from response.

**Behavior:**
- Adapter: Optional field access with `?? 0` → **success**
- UI: Shows "0 min" fallback value
- Logged: No
- Risk: UX degradation (misleading info), not crash

### B5. Latency Masking (Stale Data)

**Scenario:** Client has cached/stale data while backend has newer state.

**Behavior:**
- Adapter: Validates response shape, not freshness → **success**
- UI: Renders stale data until refresh
- Risk: User sees outdated task status
- Mitigation: `lastUpdatedAt` field enables staleness detection

### B6. HTTP 200 with Invalid Body

**Scenario:** Backend returns `{ task: null }` instead of task object.

**Behavior:**
- Adapter: Guard catches `!data.task` → **error state**
- UI: StatusBanner danger
- Logged: Yes
- Graceful: StubProps provided, UI renders safely

---

## PART C — Recovery Patterns

### C1. User-Initiated Recovery
- All error states show "Pull to retry" UI copy
- StatusBanner provides visual feedback (danger tone)
- User can navigate back from any error state

### C2. Safe Degradation
- All error states preserve stubProps (never undefined)
- UI components receive valid props even on error
- No React render errors from missing data

### C3. Navigation Safety
- Error states allow back navigation
- Error states block forward navigation (no invalid state transitions)
- No infinite redirect loops

### C4. Logging Coverage
- All adapter errors logged with ERROR_CODES.INVALID_RESPONSE
- Logs include screen name and adapter name
- Production sink ready (Sentry/Datadog stub in place)

---

## PART D — Dry-Run Backend Swap Audit

### Scenario 1: Backend Adds Required Field

**Change:** API now requires `task.urgency: 'low' | 'medium' | 'high'`

**System trace:**
1. Backend returns `{ task: { id: '1', urgency: 'high', ... } }`
2. Adapter: No guard for `urgency` → passes validation
3. Screen: Renders task without urgency info
4. UI: Normal display, urgency not shown
5. Logs: None

**Conclusion:** Safe. Unknown fields ignored. Risk only when UI code references missing field.

---

### Scenario 2: Backend Removes Field

**Change:** `task.estimatedDuration` removed from API response

**System trace:**
1. Backend returns `{ task: { id: '1', title: '...', ... } }` (no duration)
2. Adapter: `task.estimatedDuration ?? 0` → defaults to 0
3. Screen: `metaLabel: "0 min"`
4. UI: Shows "0 min" instead of actual duration
5. Logs: None

**Conclusion:** Safe but degraded UX. App doesn't crash. User sees misleading "0 min".

---

### Scenario 3: Enum Gains New Value

**Change:** `TaskProgressState` now includes `'PAUSED'`

**System trace:**
1. Backend returns `{ state: 'PAUSED', ... }`
2. Adapter: `validStates.includes('PAUSED')` → false
3. Adapter: Returns `{ state: 'error', props: stubProps }`
4. Screen: `state === 'error'` → renders error UI
5. UI: StatusBanner danger "Something went wrong. Pull to retry."
6. Logs: `logError('adapter', ERROR_CODES.INVALID_RESPONSE, ...)`

**Conclusion:** Safe. Error handled gracefully. User sees error banner, can retry.

---

### Scenario 4: Backend Returns 200 with Invalid Body

**Change:** Backend bug returns `{ task: null }` for valid task ID

**System trace:**
1. Backend returns `{ task: null, poster: {...} }`
2. Adapter: `!data.task` → true
3. Adapter: Returns `{ state: 'error', props: stubProps }`
4. Screen: `state === 'error'` → renders error UI
5. UI: StatusBanner danger
6. Logs: `logError('adapter', ERROR_CODES.INVALID_RESPONSE, ...)`

**Conclusion:** Safe. Guard catches null. App doesn't crash.

---

## PART E — Proven Guarantees

### E1. Crash Prevention
✅ Adapters cannot crash UI
✅ Invalid backend responses degrade safely to error state
✅ StubProps always provided (never undefined)

### E2. Error Consistency
✅ Error codes map deterministically to UI
✅ ERROR_CODES.INVALID_RESPONSE → StatusBanner danger
✅ All error states logged with context

### E3. Type Safety
✅ Guards validate primitive types before use
✅ Enum values validated against known lists
✅ Null checks on required fields

### E4. Test Coverage
✅ 81 adapter invariant tests
✅ All 6 adapters covered
✅ Tests verify: valid, missing, wrong type, invalid enum, null

---

**END OF DOCUMENT**
