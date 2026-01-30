# FRONTEND ENTRYPOINT — HUSTLEXP

**READ THIS FILE FIRST. EVERY SESSION.**

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

## STOP_CONDITION

```
When ALL success criteria pass → STOP IMMEDIATELY.

Do NOT:
- Refactor
- Polish
- Enhance
- Improve
- Add features
- Optimize
- Style beyond spec

Mark BOOTSTRAP complete and STOP.
```

---

## IF_BLOCKED

```
1. Identify the specific blocker
2. Report: "BLOCKED: [specific error/issue]"
3. REFUSE to proceed until blocker is resolved
4. Do NOT work around blockers by inventing solutions
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
```

---

## SESSION_CHECKLIST

Before starting work:
```
[ ] Read this file (FRONTEND_ENTRYPOINT.md)
[ ] Confirm CURRENT_PHASE matches your task
[ ] Confirm files you're touching are ALLOWED
[ ] Understand SUCCESS_CRITERIA
[ ] Understand STOP_CONDITION
```

After completing work:
```
[ ] All SUCCESS_CRITERIA checked
[ ] No files outside SESSION_SCOPE modified
[ ] STOP_CONDITION triggered
[ ] Session ends immediately
```

---

## AUTHORITY_REMINDER

```
This file is updated by HUSTLEXP-DOCS.
This file is NOT updated by Cursor/AI.
If this file conflicts with your assumptions → this file wins.
```

---

## NEXT_PHASE_PREVIEW (Do Not Execute)

After BOOTSTRAP passes:
- Phase: NAVIGATION
- Legal: Navigator stubs, screen stubs
- Frozen: Screen implementation details

**Do NOT preview-execute. Complete current phase first.**
