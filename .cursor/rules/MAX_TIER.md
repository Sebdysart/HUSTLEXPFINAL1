# Cursor MAX-TIER Execution Protocol (v10)

**Hard-law upgrade to baseline Cursor practices. This is production-grade, failure-resistant execution.**

---

## 1. Read First → **Prove First**

**Hard Rule:** Must prove existence and ownership before touching anything.

**Required Actions:**
- List exact file paths before editing
- Quote existing function signatures verbatim
- Identify file owner (domain / layer)
- If file does not exist → STOP

**Why:** Kills hallucinated imports, fake abstractions, and invented architecture.

---

## 2. Gather Context → **Declare Scope**

**Hard Rule:** Must explicitly declare what will NOT be touched.

**Required Declaration:**
- Files allowed to change
- Files explicitly forbidden
- Invariants guaranteed untouched

**Why:** Most AI damage happens outside the "intended" change.

---

## 3. Incremental Changes → **Single-Invariant Diffs**

**Hard Rule:** One diff = one invariant affected (or none).

**Rules:**
- If two invariants are touched → split into separate changes
- No refactors mixed with logic changes
- No "cleanup" in functional diffs

**Why:** Makes rollbacks trivial and bugs isolatable.

---

## 4. Verify Assumptions → **Assumption Ledger**

**Hard Rule:** Must list assumptions BEFORE writing code.

**Example Format:**
- Assumes auth context exists
- Assumes DB transaction is atomic
- Assumes async order is preserved

If any assumption is unverified → STOP and ask.

**Why:** Unspoken assumptions are the #1 source of hallucinations.

---

## 5. Follow Existing Patterns → **Pattern Enforcement**

**Hard Rule:** Must name the pattern being followed.

**Example:**
- "Matches repository pattern used in X"
- "Follows state machine pattern from Y"

If cannot name the pattern → it is guessing. STOP.

---

## 6. Ask When Uncertain → **Mandatory Escalation Triggers**

**Hard Rule:** Must escalate automatically when thresholds are crossed.

**Hard Escalation Triggers (No Discretion):**
- More than 2 plausible solutions
- Ambiguous ownership
- Missing invariant coverage
- Touching money, auth, permissions, or lifecycle

No confidence override. No "probably".

---

## 7. Use Tools → **Tool Order Enforcement**

**Enforced Sequence (No Exceptions):**
1. `list_dir` - Understand structure
2. `grep` - Find exact patterns
3. `read_file` - Read existing code
4. `codebase_search` - Semantic understanding
5. Write code (only after 1-4)

If code is written before steps 1-3 → VIOLATION.

**Why:** Prevents premature synthesis.

---

## 8. Check Side Effects → **Blast Radius Declaration**

**Hard Rule:** Must explicitly declare blast radius.

**Required:**
- Affected modules
- Runtime impact
- Failure modes introduced
- Rollback strategy

If rollback is unclear → code is REJECTED.

---

## 9. Invariant Preservation Check (CRITICAL - NEW)

**Mandatory:**
- List all invariants relevant to the change
- Explain how each invariant remains true
- Explain what would break them

No invariant analysis → no merge.

---

## 10. Pre-Merge Mental Simulation (NEW)

**Before code is accepted, must answer:**
- What happens if this runs twice?
- What happens if it fails halfway?
- What happens if inputs are malicious?
- What happens if state is stale?

This replaces "hope" with reasoning.

---

## 11. Post-Change Verification Contract (NEW)

**Must specify:**
- What test proves this works
- What signal confirms success
- What metric would reveal failure

No verification plan → change is incomplete.

---

## 12. AI Write-Access Kill Switch (NEW)

**If any of these occur:**
- Repeated crashes
- Conflicting explanations
- Spec uncertainty
- Invariant ambiguity

**Action:** Lose write access. Switch to observer mode.

This prevents thrashing.

---

## User Interaction Requirements

### User Must Always Provide:
- Objective (what changes, what must not)
- Invariants to preserve
- Files likely involved
- Success criteria

### User Must Never Accept:
- "This should work"
- "Likely"
- "Probably"
- "Temporary fix"

---

## Final Lock-In

**Done means:**
- Cannot guess
- Cannot drift
- Cannot panic-code
- Cannot corrupt architecture

**Every change must:**
1. Prove existence first
2. Declare scope and invariants
3. Follow tool order
4. List assumptions
5. Name patterns
6. Declare blast radius
7. Preserve invariants
8. Pass mental simulation
9. Have verification plan
10. Be rollback-ready

---

**This is not optional. This is the law.**
