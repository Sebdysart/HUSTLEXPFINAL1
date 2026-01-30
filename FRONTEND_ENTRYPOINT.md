# FRONTEND ENTRYPOINT — HUSTLEXP

**READ THIS FILE FIRST. EVERY SESSION. NO EXCEPTIONS.**

---

## ⚠️ AUTHORITY NOTICE

```
FRONTEND_ENTRYPOINT.md contains ZERO original authority.
It is a MIRROR of the current state in HUSTLEXP-DOCS.
It must NEVER diverge from HUSTLEXP-DOCS.

DOCS_COMMIT_HASH: 414e1e8
DOCS_REPO: https://github.com/Sebdysart/HUSTLEXP-DOCS

If this hash differs from HUSTLEXP-DOCS HEAD → STOP AND ASK.
Do NOT proceed with stale entrypoint.
```

---

## CURRENT_PHASE

```
BOOTSTRAP
```

---

## NEXT_LEGAL_ACTION

```
Fix runtime crashes preventing BootstrapScreen render.
```

---

## SESSION_SCOPE

| Status | Files |
|--------|-------|
| **ALLOWED** | `App.tsx`, `src/screens/BootstrapScreen.tsx` |
| **FROZEN** | `src/navigation/**`, all other screens |
| **READ-ONLY** | `package.json`, `ios/`, `android/` |

---

## SUCCESS_CRITERIA (ALL REQUIRED)

```
[ ] App builds in Xcode without errors
[ ] App launches in iOS Simulator without crash
[ ] BootstrapScreen renders with "HustleXP" text
[ ] Primary button visible and logs to console on press
[ ] App survives 30 seconds idle without crash or freeze
```

---

## BOOTSTRAP VERIFICATION PROTOCOL (MANDATORY)

```
Each criterion must be MECHANICALLY VERIFIED. Mental passes are INVALID.

1. BUILD VERIFICATION
   Command: npm run ios
   Pass: Exit code 0, no red errors
   Fail: Any build error or warning treated as error

2. LAUNCH VERIFICATION
   Observation: iOS Simulator shows UI within 10 seconds
   Pass: Screen visible, no red error screen
   Fail: Crash, hang, or red screen

3. RENDER VERIFICATION
   Observation: "HustleXP" text visible on screen
   Pass: Text renders correctly
   Fail: Blank screen, missing text, or layout broken

4. INTERACTION VERIFICATION
   Action: Press primary button
   Pass: Console shows "BOOTSTRAP_OK" or equivalent log
   Fail: No log, crash on press, or unresponsive

5. STABILITY VERIFICATION
   Action: Leave app idle for 30 seconds
   Pass: No crash, no freeze, no red screen
   Fail: Any instability

ALL 5 MUST PASS. If ANY step cannot be observed → BOOTSTRAP FAILS.
```

---

## STOP_CONDITION

```
When ALL SUCCESS_CRITERIA pass → STOP IMMEDIATELY.

Do NOT:
- Refactor
- Polish
- Enhance
- Improve
- Add features
- Optimize
- Style beyond spec
- Explain what you built
- Summarize your work
- Suggest next steps

Mark BOOTSTRAP complete and STOP.
```

---

## SESSION TERMINATION CLAUSE

```
After STOP, the session MUST terminate.
Any further output is INVALID unless a new session is started.

FORBIDDEN after STOP:
- "Here's what I did..."
- "You might also want to..."
- "I noticed that..."
- "For future reference..."
- Any non-requested output

The correct response after STOP is SILENCE or "Done."
```

---

## IF_BLOCKED

```
1. Identify the specific blocker
2. Report: "BLOCKED: [specific error/issue]"
3. REFUSE to proceed until blocker is resolved
4. Do NOT work around blockers by inventing solutions
5. Do NOT describe alternative approaches
```

---

## PHASE_GATE

```
BOOTSTRAP must pass before ANY of the following are legal:
- Navigation implementation
- Screen implementation (except BootstrapScreen)
- Component creation
- Styling work
- Animation work
- Copy/text changes
- Explanations of architecture
- Documentation updates
```

---

## PROHIBITED OUTPUTS

```
❌ Describing UI instead of committing code
❌ "Verification summaries" without artifacts
❌ Screenshot-based validation claims
❌ Explanations of what was built
❌ Suggestions for improvements
❌ Alternative approaches
❌ "While I was at it, I also..."
❌ Any output after STOP condition met
```

---

## SESSION_CHECKLIST

Before starting work:
```
[ ] Verified DOCS_COMMIT_HASH matches HUSTLEXP-DOCS HEAD
[ ] Read this file completely
[ ] Confirmed CURRENT_PHASE matches your task
[ ] Confirmed files you're touching are ALLOWED
[ ] Understand SUCCESS_CRITERIA
[ ] Understand STOP_CONDITION
[ ] Understand SESSION TERMINATION CLAUSE
```

After completing work:
```
[ ] All SUCCESS_CRITERIA mechanically verified
[ ] BOOTSTRAP VERIFICATION PROTOCOL passed
[ ] No files outside SESSION_SCOPE modified
[ ] STOP_CONDITION triggered
[ ] Session terminates NOW (no further output)
```

---

## PHASE PROGRESSION

| Phase | Gate | Next Phase |
|-------|------|------------|
| BOOTSTRAP | All 5 verifications pass | NAVIGATION |
| NAVIGATION | All 38 screen stubs exist | SCREENS |
| SCREENS | All screens implemented | WIRING |
| WIRING | Mock data connected | INTEGRATION |

**Current: BOOTSTRAP**

---

## SYNC PROTOCOL

```
1. HUSTLEXP-DOCS is the SOURCE
2. This file is the COPY
3. When HUSTLEXP-DOCS updates, this file must sync
4. Sync includes updating DOCS_COMMIT_HASH
5. If hashes differ → STALE → STOP AND ASK
```

---

## CORRECT SESSION END

```
✅ "Done."
✅ [silence]
✅ "BOOTSTRAP: PASS"

❌ "I've completed the bootstrap phase. Here's what I did..."
❌ "The app now builds and runs. You might want to..."
❌ "Everything is working. For the next phase..."
```
