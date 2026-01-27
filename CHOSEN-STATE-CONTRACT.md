# CHOSEN-STATE CONTRACT

> **HustleXP should feel like a beautiful, trustworthy system that has already decided you'll succeed — and is calmly guiding you to your first result.**

This document is **immutable**. Every screen, component, and interaction must satisfy these rules.

---

## The 3 Feelings (First 5 Seconds)

### 1. CHOSEN
"I'm not starting from zero."

**Signals:**
- Activity happening in background (HSignal components)
- System already active (ambient motion)
- No empty states ever
- No "create your first..."

**Rule:** Empty = rejected. Active = chosen.

---

### 2. GUARANTEED OUTCOME
"This works. I'm next."

**Signals:**
- Language implies availability, not possibility
- Stats show activity (tasks completed, money earned)
- No "maybe", "eventually", "after setup"

**Rule:** The app implies inevitability, not hope.

---

### 3. EFFORTLESS ENTRY
"I'm already inside."

**Signals:**
- No feeling of work or configuration
- One decision at a time
- Micro-wins, gentle forward momentum

**Rule:** User should never feel "I'm setting something up."

---

## Visual Rules

### Background
- Dark void base (#0A0A0F)
- Soft animated gradients
- Slow, hypnotic motion (8-12 second cycles)
- Ambient orb always present (HAmbient)

### Color
- Purple (#7C6AEF) is SIGNAL, not decoration
- Purple appears where action happens
- Black holds everything else down
- White used sparingly for clarity

### Motion
- Slow and calming, never aggressive
- Gentle pulse = system alive
- Tap feedback: scale 0.97, 100ms

---

## Copy Rules

### Headlines
- Human, simple, slightly clever
- Outcome-oriented, not feature-oriented
- Confident but understated
- Factual, not persuasive

**Good:** "Things are happening. You're next."
**Bad:** "Turn time into money!"

### CTAs
- Feel like confirmation, not action
- Continuation, not commitment

**Good:** "Let's go", "Continue", "I'm ready"
**Bad:** "Get started", "Sign up", "Join now"

---

## Component Rules

### Every screen must:
1. Use HScreen wrapper (provides ambient, safe areas)
2. Never show empty state without activity signal
3. Have at least one micro-animation

### Every card must:
1. Use HCard with glass shine
2. Tap scale feedback (0.98)
3. Never feel static

### Every button must:
1. Use HButton
2. Primary = purple gradient + glow
3. Feel like "confirming", not "committing"

---

## Atom Checklist

Before shipping any screen, verify:

- [ ] HScreen wrapper with ambient=true
- [ ] Activity signals if showing data
- [ ] No empty states
- [ ] Copy is human, not salesy
- [ ] CTA is confirmation language
- [ ] Tap feedback on all interactive elements
- [ ] Purple only where action happens

---

## Forbidden Patterns

❌ "Get started" / "Sign up" / "Join"
❌ Empty lists without activity signals
❌ Aggressive neon colors
❌ Fast/jarring animations
❌ Salesy or hype language
❌ Feature dumps
❌ Tutorial overlays
❌ "Tell us about you" energy

---

## Approved Patterns

✅ "Let's go" / "Continue" / "I'm ready"
✅ Floating activity signals
✅ Soft purple glow on actions
✅ Slow ambient motion
✅ Confident, understated copy
✅ One decision per screen
✅ Micro-wins in onboarding

---

*Lock this. Every PR must pass this contract.*
