# HustleXP Frontend Runtime

⚠️ **This repo optimizes for forward progress, not aesthetic iteration.**
**A session that completes its defined step MUST stop immediately.**

---

## 🚨 READ FIRST

```
FRONTEND_ENTRYPOINT.md ← What to do NOW
```

**Every session starts by reading `FRONTEND_ENTRYPOINT.md`. No exceptions.**

---

## ⚠️ EXECUTION AUTHORITY

This repository is **NOT** a standalone project.
It is a **runtime surface** governed by [HUSTLEXP-DOCS](https://github.com/Sebdysart/HUSTLEXP-DOCS).

**If conflict → HUSTLEXP-DOCS wins.**

---

## 🔒 AUTHORITY HIERARCHY

| Priority | Document |
|----------|----------|
| 1 | `FRONTEND_ENTRYPOINT.md` (this repo) |
| 2 | `HUSTLEXP-DOCS/EXECUTION_QUEUE.md` |
| 3 | `HUSTLEXP-DOCS/SCREEN_ARCHETYPES.md` |
| 4 | `HUSTLEXP-DOCS/STOP_CONDITIONS.md` |
| 5 | `.cursorrules` |

---

## 🚀 START SEQUENCE

```
1. Read FRONTEND_ENTRYPOINT.md
2. Confirm CURRENT_PHASE
3. Confirm NEXT_LEGAL_ACTION
4. Confirm SESSION_SCOPE (allowed files)
5. Execute ONLY that action
6. Check SUCCESS_CRITERIA
7. When criteria pass → STOP
```

---

## 🛑 CURRENT PHASE: BOOTSTRAP

| Criteria | Status |
|----------|--------|
| App builds in Xcode | ❌ |
| App launches without crash | ❌ |
| BootstrapScreen renders | ❌ |
| Button logs to console | ❌ |
| 30-second stability | ❌ |

### BOOTSTRAP ENFORCEMENT RULE

```
While BOOTSTRAP is failing, the ONLY legal changes are:
- Crash fixes
- Minimal wiring to render BootstrapScreen

FORBIDDEN until BOOTSTRAP passes:
- UI polish
- Copy changes
- Animations
- Aesthetic iteration
- Navigation work
- Other screens
```

**Violation = Invalid work.**

---

## 🧩 EXECUTION MODEL

```
SCREENS    ← Assembly only (no invention)
SECTIONS   ← Narrative regions
MOLECULES  ← Locked compositions
ATOMS      ← Locked primitives
```

**Screens assemble. They do NOT invent.**

---

## 🎯 ARCHETYPES

| Code | Name | Examples |
|------|------|----------|
| A | Entry/Commitment | Login, Signup |
| B | Feed/Opportunity | Task Feed |
| C | Task Lifecycle | In Progress |
| D | Calibration | Onboarding |
| E | Progress/Status | Home, Profile |
| F | System/Interrupt | Errors |

**Identify archetype BEFORE implementation.**

---

## ✨ CHOSEN-STATE

```
✅ User feels SELECTED
✅ System feels ACTIVE
✅ Success feels LIKELY

❌ "No tasks yet"
❌ "Get started"
❌ Starting from zero
```

---

## 🚫 HARD CONSTRAINTS

```
❌ Data fetching in screens
❌ Business logic (eligibility, XP, trust)
❌ Feature invention
❌ Visual invention
❌ Inline styles
❌ New dependencies without approval
❌ Navigation changes
❌ New screens not in registry
```

---

## 💻 RUN COMMANDS

```bash
npm install
cd ios && pod install && cd ..
npm start
npm run ios
```

**These commands do NOT grant permission to modify structure.**

---

## 📁 STRUCTURE

```
HUSTLEXPFINAL1/
├── FRONTEND_ENTRYPOINT.md  ← READ FIRST
├── .cursorrules            ← Enforcement
├── src/
│   ├── components/
│   │   ├── atoms/          ← Locked
│   │   └── molecules/      ← Locked
│   └── screens/            ← Assembly only
└── ios/
```

---

## 🔗 SOURCE OF TRUTH

| Concern | Location |
|---------|----------|
| What to do now | `FRONTEND_ENTRYPOINT.md` |
| Build sequence | `HUSTLEXP-DOCS/EXECUTION_QUEUE.md` |
| Components | `HUSTLEXP-DOCS/ui-puzzle/` |
| Screen specs | `HUSTLEXP-DOCS/screens-spec/` |
| Enforcement | `.cursorrules` |

---

## ❓ IF UNCLEAR

```
STOP.
Read FRONTEND_ENTRYPOINT.md.
If still unclear → ASK.
Do NOT guess.
```

---

## 📋 SESSION END CHECKLIST

```
[ ] SUCCESS_CRITERIA all pass
[ ] Only ALLOWED files modified
[ ] STOP_CONDITION triggered
[ ] Session ends NOW
```

---

**This repo is a runtime surface. HUSTLEXP-DOCS is the brain.**
