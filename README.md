# HustleXP Frontend Runtime

⚠️ **EXECUTION AUTHORITY NOTICE**

This repository is **NOT** a standalone React Native project.

It is a **runtime implementation surface** governed by the HustleXP Product Execution Repository (PER).

**Any work done without following the PER authority hierarchy is INVALID.**

---

## 🔒 Governing Authority (Non-Negotiable)

All frontend work in this repo is governed by:

| Document | Purpose | Priority |
|----------|---------|----------|
| **[HUSTLEXP-DOCS](https://github.com/Sebdysart/HUSTLEXP-DOCS)** | Root authority | HIGHEST |
| `EXECUTION_QUEUE.md` | What to build next | Required |
| `SCREEN_ARCHETYPES.md` | Which archetype (A-F) | Required |
| `UI_COMPONENT_HIERARCHY.md` | What components exist | Required |
| `STOP_CONDITIONS.md` | When to stop | Required |
| `AI_CHECKPOINTS.md` | Enforcement gates | Required |
| `.cursorrules` | Hard constraints | Enforced |

**If any instruction in this repository conflicts with HUSTLEXP-DOCS, HUSTLEXP-DOCS always wins.**

---

## 🚀 Canonical Start Sequence (Required)

Before making **ANY change**, you MUST:

```
1. Read HUSTLEXP-DOCS/EXECUTION_QUEUE.md
2. Find the FIRST step where Done: [ ]
3. Identify the screen's ARCHETYPE from SCREEN_ARCHETYPES.md
4. Read UI_COMPONENT_HIERARCHY.md to know what components exist
5. Read the spec file for the current step
6. Build using ONLY existing atoms/molecules
7. Verify against STOP_CONDITIONS.md
8. Mark Done: [x] and STOP
```

**Any work done without following this sequence is INVALID.**

---

## 🛑 Frontend Rules (Hard Constraints)

```
✅ UI renders PROPS ONLY
✅ Use atoms/molecules from ui-puzzle/
✅ Follow archetype patterns
✅ Stop when spec says stop

❌ NO data fetching in screens
❌ NO business logic (eligibility, XP, trust)
❌ NO feature invention
❌ NO visual invention outside ui-puzzle/
❌ NO treating screens as unique design problems
```

**If unclear: STOP AND ASK. Do not guess.**

---

## 🧩 Execution Model (Puzzle Assembly)

HustleXP UI is built as a **PUZZLE**, not as isolated screens:

```
┌─────────────────────────────────────────────────────────────┐
│  SCREENS    — Assembly ONLY (no invention allowed)          │
├─────────────────────────────────────────────────────────────┤
│  SECTIONS   — Narrative regions (header, content, actions)  │
├─────────────────────────────────────────────────────────────┤
│  MOLECULES  — Combinations of atoms (cards, forms, lists)   │
├─────────────────────────────────────────────────────────────┤
│  ATOMS      — Primitive elements (buttons, inputs, text)    │
└─────────────────────────────────────────────────────────────┘
```

**Screens may NOT introduce new visuals. They ASSEMBLE existing pieces.**

---

## 🎯 Screen Archetypes (Identify BEFORE Implementation)

| Archetype | Purpose | Examples |
|-----------|---------|----------|
| **A. Entry/Commitment** | User decides to engage | Login, Signup, Welcome |
| **B. Feed/Opportunity** | User discovers options | Task Feed, History |
| **C. Task Lifecycle** | Active work flow | In Progress, Proof |
| **D. Calibration/Capability** | User configures self | Onboarding, Settings |
| **E. Progress/Status** | User sees standing | Home, Profile, XP |
| **F. System/Interrupt** | System communicates | Errors, Maintenance |

**Screens inherit visuals, motion, and hierarchy from their archetype.**

---

## ✨ Chosen-State Requirement (Global)

All screens must make the user feel:

```
✅ ALREADY SELECTED — not being tested
✅ SYSTEM IS ACTIVE — not waiting
✅ SUCCESS IS LIKELY — not uncertain
```

**FORBIDDEN:**
- "No tasks yet" / "Get started" language
- Empty states that feel like starting from zero
- UI that makes user feel they might fail

---

## ⚠️ Current Phase: BOOTSTRAP

**Nothing proceeds until Bootstrap passes.**

| Check | Status |
|-------|--------|
| App builds in Xcode | ❌ |
| App launches without crash | ❌ |
| BootstrapScreen renders | ❌ |
| Button logs to console | ❌ |
| 30-second stability | ❌ |

See: `HUSTLEXP-DOCS/BOOTSTRAP.md`

---

## 💻 Development (Runtime Only)

This repo exists to **RUN and VALIDATE** UI assembled from HUSTLEXP-DOCS.

### Prerequisites
- Node.js 18+
- Xcode 15+ (iOS)
- CocoaPods

### Setup
```bash
npm install
cd ios && pod install && cd ..
```

### Run
```bash
npm start          # Start Metro
npm run ios        # Run on iOS Simulator
```

⚠️ **These commands do NOT grant permission to modify UI structure or invent features.**

---

## 📁 Directory Structure

```
HUSTLEXPFINAL1/
├── src/
│   ├── components/
│   │   ├── atoms/       ← Locked primitives (from ui-puzzle/)
│   │   └── molecules/   ← Locked compositions (from ui-puzzle/)
│   ├── screens/
│   │   ├── auth/        ← Auth screens (Archetype A)
│   │   ├── onboarding/  ← Onboarding screens (Archetype D)
│   │   ├── hustler/     ← Hustler screens (Archetypes B, C, E)
│   │   ├── poster/      ← Poster screens (Archetypes B, C, E)
│   │   ├── settings/    ← Settings screens (Archetype D)
│   │   ├── shared/      ← Shared screens (Archetype C)
│   │   └── edge/        ← Edge case screens (Archetype F)
│   └── navigation/      ← Navigation structure (FROZEN)
├── ios/                 ← iOS native code
├── android/             ← Android native code
└── .cursorrules         ← ENFORCEMENT (not guidance)
```

---

## 🔗 Source of Truth

| Concern | Authority |
|---------|-----------|
| Design authority | `HUSTLEXP-DOCS` |
| UI structure | `HUSTLEXP-DOCS/ui-puzzle/` |
| Screen specs | `HUSTLEXP-DOCS/screens-spec/` |
| Enforcement | `HUSTLEXP-DOCS/.cursorrules` |
| What "done" means | `HUSTLEXP-DOCS/FINISHED_STATE.md` |

**This repo is a CONSUMER, not an AUTHOR.**

---

## 🚫 Prohibited Actions

```
❌ Modifying navigation structure
❌ Adding npm dependencies without approval
❌ Creating new screens not in SCREEN_REGISTRY.md
❌ Computing eligibility, XP, or trust client-side
❌ Fetching data in screen components
❌ Using Redux/Context for data
❌ Inline styles (use design tokens only)
❌ "Improving" or "enhancing" specs
```

---

## ❓ If Unsure

**Do not guess. Do not "help" by filling gaps.**

Return to:
👉 **[HUSTLEXP-DOCS/EXECUTION_QUEUE.md](https://github.com/Sebdysart/HUSTLEXP-DOCS/blob/main/EXECUTION_QUEUE.md)**

Find the next unchecked step and execute exactly that.

---

## 👤 Contact

**Owner:** Sebastian Dysart  
**Project:** HustleXP v1.0  
**Docs Repo:** [HUSTLEXP-DOCS](https://github.com/Sebdysart/HUSTLEXP-DOCS)

---

**This repo is a runtime surface. HUSTLEXP-DOCS is the brain.**
