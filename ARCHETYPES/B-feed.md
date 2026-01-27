# Archetype B: Feed / Opportunity Screens

**Status:** 🔄 Transform next

## Screens
- HustlerHomeScreen ✅
- TaskFeedScreen ✅
- PosterHomeScreen
- NoTasksAvailableScreen

## Emotional Contract
> "Things are happening. You're next."

## Visual Intent
- Activity signals floating (HSignalStream)
- Cards with content, never empty
- Pull-to-refresh implies freshness
- Subtle motion everywhere
- Information density balanced with breathing room

## Allowed Atoms
- HScreen (ambient=true, scroll=true)
- HCard (for task/opportunity cards)
- HMoney (prominent, glowing)
- HText (all variants)
- HBadge (status, filters)
- HSignal, HSignalStream (activity proof)
- HActivityIndicator
- HTrustBadge
- HSearchInput (for filtering)
- HButton (primary for main CTA)

## Forbidden
- ❌ Empty list states (use activity signals instead)
- ❌ "No results found"
- ❌ Static screens
- ❌ Overwhelming data density

## Empty State Rule
NEVER show "No tasks available"

Instead show:
- Activity signals: "Tasks dropping in your area"
- "Pull down to refresh"
- Implied momentum, not absence

## CTA Language
- "Let's go"
- "Browse what's out there"
- "Find more"

## Copy Rules
- Time-aware greetings ("Morning, {name}")
- Short labels ("Find" not "Find Tasks")
- Imply activity ("Around you" not "Nearby Tasks")
- Stats prove life (tasks completed, money earned)
