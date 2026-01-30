# HustleXP Frontend Runtime

⚠️ **This repo optimizes for forward progress, not aesthetic iteration.**
**A session that completes its defined step MUST stop immediately.**
**Any further output after STOP is INVALID.**

---

## 🚨 READ FIRST (MANDATORY)

```
FRONTEND_ENTRYPOINT.md ← What to do NOW
```

**Every session starts by reading `FRONTEND_ENTRYPOINT.md`. No exceptions.**
**Verify DOCS_COMMIT_HASH matches before proceeding.**

---

## ⚠️ EXECUTION AUTHORITY

This repository is **NOT** a standalone project.
It is a **runtime surface** governed by [HUSTLEXP-DOCS](https://github.com/Sebdysart/HUSTLEXP-DOCS).

```
FRONTEND_ENTRYPOINT.md contains ZERO original authority.
It is a MIRROR of HUSTLEXP-DOCS and must NEVER diverge.

If conflict → HUSTLEXP-DOCS wins.
If hash mismatch → STOP AND ASK.
```

---

## 🔒 AUTHORITY HIERARCHY

| Priority | Document |
|----------|----------|
| 1 | `FRONTEND_ENTRYPOINT.md` (verify hash first) |
| 2 | `HUSTLEXP-DOCS/EXECUTION_QUEUE.md` |
| 3 | `HUSTLEXP-DOCS/ARCHETYPE_MOLECULE_MATRIX.md` |
| 4 | `HUSTLEXP-DOCS/STOP_CONDITIONS.md` |
| 5 | `.cursorrules` |

---

## 🚀 START SEQUENCE

```
1. Read FRONTEND_ENTRYPOINT.md
2. Verify DOCS_COMMIT_HASH matches HUSTLEXP-DOCS HEAD
3. If hash mismatch → STOP (stale entrypoint)
4. Confirm CURRENT_PHASE
5. Confirm SESSION_SCOPE (allowed files)
6. Execute ONLY the NEXT_LEGAL_ACTION
7. Run BOOTSTRAP VERIFICATION PROTOCOL
8. When all criteria pass → STOP
9. Session terminates (no further output)
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

### BOOTSTRAP VERIFICATION PROTOCOL (MANDATORY)

```
Each criterion must be MECHANICALLY VERIFIED.
Mental passes are INVALID.

1. BUILD: npm run ios exits with code 0
2. LAUNCH: iOS Simulator shows UI within 10s
3. RENDER: "HustleXP" text visible
4. INTERACTION: Button press → console.log("BOOTSTRAP_OK")
5. STABILITY: No crash for 30 seconds

ALL 5 MUST PASS. If any cannot be observed → BOOTSTRAP FAILS.
```

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
- Explanations of architecture
- Documentation updates

Violation = Invalid work.
```

---

## 🧩 EXECUTION MODEL

```
SCREENS    ← Assembly only (no invention)
SECTIONS   ← Narrative regions
MOLECULES  ← Locked compositions (archetype-bound)
ATOMS      ← Locked primitives
```

**Screens assemble. They do NOT invent.**

---

## 🎯 ARCHETYPE → MOLECULE BINDING

**Each archetype has a FIXED allowed molecule set.**
**Using a molecule not in the list → INVALID.**

| Molecule | A | B | C | D | E | F |
|----------|---|---|---|---|---|---|
| TaskCard | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| FormField | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| ActionBar | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ |
| FilterBar | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |

Full matrix: `HUSTLEXP-DOCS/ARCHETYPE_MOLECULE_MATRIX.md`

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

## 🛑 SESSION TERMINATION

```
After STOP condition is met:
- Session MUST terminate immediately
- Any further output is INVALID

FORBIDDEN after STOP:
❌ "Here's what I did..."
❌ "You might also want to..."
❌ Explanations of work
❌ Suggestions for next steps

CORRECT after STOP:
✅ "Done."
✅ [silence]
✅ "BOOTSTRAP: PASS"
```

---

## 🚫 PROHIBITED OUTPUTS

```
❌ Describing UI instead of committing code
❌ "Verification summaries" without artifacts
❌ Explanations of what was built
❌ Suggestions for improvements
❌ Alternative approaches
❌ "While I was at it..."
❌ Any output after STOP
```

---

## 🚫 HARD CONSTRAINTS

```
❌ Data fetching in screens
❌ Business logic (eligibility, XP, trust)
❌ Feature invention
❌ Visual invention
❌ Inline styles
❌ Molecules not in archetype's allowed list
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
├── FRONTEND_ENTRYPOINT.md  ← READ FIRST (verify hash)
├── .cursorrules            ← Enforcement
├── src/
│   ├── components/
│   │   ├── atoms/          ← Locked
│   │   └── molecules/      ← Locked (archetype-bound)
│   └── screens/            ← Assembly only
└── ios/
```

---

## 🔗 SOURCE OF TRUTH

| Concern | Location |
|---------|----------|
| What to do now | `FRONTEND_ENTRYPOINT.md` |
| Allowed molecules | `ARCHETYPE_MOLECULE_MATRIX.md` |
| Build sequence | `EXECUTION_QUEUE.md` |
| Components | `ui-puzzle/` |
| Enforcement | `.cursorrules` |

---

## ❓ IF UNCLEAR

```
STOP.
Read FRONTEND_ENTRYPOINT.md.
If still unclear → ASK.
Do NOT guess.
Do NOT explain alternatives.
```

---

## 📋 SESSION END CHECKLIST

```
[ ] DOCS_COMMIT_HASH verified
[ ] SUCCESS_CRITERIA all pass (mechanically verified)
[ ] Only ALLOWED files modified
[ ] Only ALLOWED molecules used (per archetype)
[ ] STOP_CONDITION triggered
[ ] Session terminates NOW
[ ] No further output produced
```

---

**This repo is a runtime surface. HUSTLEXP-DOCS is the brain.**
**Session complete = Silence.**
