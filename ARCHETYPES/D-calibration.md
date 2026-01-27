# Archetype D: Calibration / Capability Screens

**Status:** 🔄 Transform after Lifecycle

## Screens
- CalibrationScreen ✅
- CapabilityAvailabilityScreen
- CapabilityBackgroundScreen
- CapabilityInsuranceScreen
- CapabilityLocationScreen
- CapabilitySkillsScreen
- CapabilityToolsScreen
- CapabilityTradesScreen
- CapabilityVehicleScreen
- PreferenceLockScreen
- WorkEligibilityScreen

## Emotional Contract
> "We're tuning the system to you."

## Visual Intent
- One decision per screen
- Binary or simple multi-select
- Progress indicator subtle
- Feels FAST, not tedious
- Cards for options, tap to select

## Allowed Atoms
- HScreen (ambient=true, scroll=false if single decision)
- HCard (selectable options)
- HText (question as headline, not label)
- HBadge (selected state indicator)
- HButton (primary: "Continue")
- HTextButton (skip if allowed)

## Forbidden
- ❌ "Tell us about yourself"
- ❌ Form field labels
- ❌ Required field indicators
- ❌ Validation errors (prevent bad states instead)
- ❌ Multiple questions per screen
- ❌ Long explanations

## Selection Pattern
- Tap card to select
- Selected = purple border + checkmark
- Multi-select: badges accumulate
- Single-select: instant highlight

## Progress Indication
- Subtle dots or bar at top
- Never "Step 3 of 12"
- Progress feels natural, not counted

## CTA Language
- "Continue" (always)
- "Skip for now" (if optional, de-emphasized)

## Copy Rules
Questions feel like curiosity, not interrogation:
- "What do you have?" not "Select your vehicles"
- "Any of these?" not "Choose your skills"
- "When are you free?" not "Set your availability"

## Defaults
- Assume reasonable defaults
- Pre-select common options
- Make it easy to proceed
