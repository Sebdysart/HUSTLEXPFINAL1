# HustleXP iOS

HustleXP is a **gamified local task marketplace** for iOS. Workers ("Hustlers") browse nearby tasks, navigate to locations, submit GPS + photo + biometric proof of completion, and earn XP that builds toward a permanent trust tier. Employers ("Posters") post tasks, review verified workers by tier and rating, approve proof, and release payment from Stripe escrow.

**The core bet:** Your reputation compounds instead of resetting with every job. A Hustler who completes 100 tasks with a 4.9 rating and zero disputes holds an objectively verifiable credential — more trustworthy than anything in a TaskRabbit profile.

**Current status:** Private beta ready (100/100 beta gate, March 2026). iOS 17+, SwiftUI, 58 screens.

---

## What Makes It Different

### 1. Trust Tier Progression
Every task earns XP. XP builds trust tiers. Each tier unlocks real capabilities:

| Tier | Unlock Criteria | Unlocks |
|------|----------------|---------|
| Rookie | New account | Low-risk tasks, 1.0× XP |
| Verified | 5 tasks + ID verified | Medium tasks, 1.5× XP |
| Trusted | 20 tasks + 95%+ approval | High tasks, 2.0× XP, recurring tasks |
| Elite | 100 tasks + 4.8+ rating + <1% dispute | All tasks, Live Mode, Squads, 2.0× XP |
| Master | 100+ tasks + 4.95+ rating + $10k earned | All features unlocked |

### 2. Live Mode Radar
Elite+ Hustlers tap "Go Live" and enter a real-time radar screen showing ASAP task alerts pulsing within 5 miles. Each quest has a 60-second claim window with surge pricing (1.2×–2.0×) and an urgency premium. First worker to accept wins. All XP earned during a Live session gets a 1.25× multiplier.

### 3. Proof of Work Chain
Poster approves → payment releases. But before that:
- GPS coordinates validated against task geofence radius
- Photo evidence submitted and stored
- Biometric liveness check (Face ID / device auth)
- Judge AI analyzes: GPS accuracy + photo completion score + liveness → APPROVE / REVIEW / REJECT
- Human review layer for borderline cases

No ambiguous "was the work done?" disputes. Either the proof passes the chain or it doesn't.

---

## The Two User Journeys

### Hustler Journey
```
Download → Sign up → Choose Hustler → Grant location + camera → Build skill profile
  → Browse task feed (filter by category, pay, distance, tier)
  → Claim task → Navigate to location (GPS tracking + geofence)
  → Complete work → Submit proof (GPS + photo + biometric)
  → Wait for approval → Earn money + XP → Level up trust tier
  → Unlock Live Mode → See pulsing quest alerts on radar → Race to claim
  → Build squad with Elite workers → Tackle larger commercial tasks
```

### Poster Journey
```
Download → Sign up → Choose Poster → Set up profile
  → Create task: Standard (form) OR AI-assisted (one sentence) OR ASAP (live broadcast)
  → Review applicants sorted by trust tier + rating
  → Accept worker → Stripe escrow funded → Task in progress
  → Receive proof submission notification
  → Review: photos + GPS marker + Judge AI summary
  → Approve (escrow releases to worker) OR Reject (worker resubmits) OR Dispute
  → Rate worker → Task complete
```

---

## Current Status

| Area | Status |
|------|--------|
| Beta Gate | 100/100 — Launch Ready |
| Ecosystem Health | 100/100 |
| API Contract | 219 bridges, 0 mismatches |
| iOS Screens | 58 screens fully built |
| Primary Journeys | All wired to real API |
| Payments | Stripe escrow + Connect live |
| Auth | Firebase Auth + FCM live |
| AI Agents | 4 agents live (Judge, Matchmaker, Dispute, Reputation) |
| Backend | `https://hustlexp-ai-backend-staging-production.up.railway.app` |

---

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+
- Active backend deployment (see `hustlexp-ai-backend`)

---

## Setup

```bash
# Clone the repo
git clone https://github.com/Sebdysart/HUSTLEXPFINAL1.git

# Open in Xcode
open "hustleXP final1.xcodeproj"

# Configure AppConfig.swift
# Set backendBaseURL, Stripe publishable key (test mode for dev)

# Run on simulator or device
# Build target: "hustleXP final1"
```

**Environment modes** (`AppConfig.swift`):
- **Debug** — Staging backend URL, Stripe test keys, SSL pinning disabled
- **Release** — Production backend URL, live Stripe keys, SSL pinning enabled

---

## Architecture Overview

```
App Entry
  └── RootNavigator (auth state switch)
       ├── AuthStack (unauthenticated)
       ├── OnboardingStack (first launch)
       └── MainTabView (4 tabs, role-aware)
            ├── Tab 0: HustlerStack | PosterStack
            ├── Tab 1: Feed | Active Tasks
            ├── Tab 2: History
            └── Tab 3: Settings
```

Navigation is **type-safe and centralized**:
- `@Observable Router` holds `NavigationPath` for each stack
- Every destination is a typed enum (`HustlerRoute`, `PosterRoute`, `SettingsRoute`, etc.)
- No magic string navigation — compile-time safety across 58 screens

Data flow:
```
Views → ViewModels (@Observable) → Services (TRPCClient singletons) → Backend tRPC
                                                                     ← Type-safe responses
```

---

## Key Differentiating Features (In Detail)

### XP Economy
```
effective_xp = base_xp × streak_mult × trust_mult × live_mult

base_xp     = ~10% of task price ($50 task = 500 XP)
streak_mult = 1.0 + (days × 0.05), max 2.0
trust_mult  = 1.0 → 1.5 → 2.0 as tiers advance
live_mult   = 1.25× during active Live Mode
daily_cap   = 10,000 XP
```

### Squads (Elite+ Only)
- 2–8 Elite Hustlers form a named squad with an emoji and tagline
- Collective XP, shared reputation, pooled task earnings
- Squad levels 1–6 with threshold bonuses
- Organizer + Foreman + Worker role hierarchy
- Access to commercial-scale tasks (future: $500+ contracts)

### Live Mode / ASAP Tasks
- Minimum $15 base price
- `urgencyPremium` = 30% of base
- `surgeMultiplier` = 1.2×–3.0× based on demand/supply ratio
- 60-second claim window (ASAP bump: +$3 every 30s, max 3 bumps)
- Worker must be Elite tier (100+ tasks, 4.8+ rating, <1% dispute)

### Escrow Safety
iOS never handles raw payment amounts. All money flows through the backend:
1. Poster confirms task → Stripe PaymentIntent created server-side
2. iOS presents Stripe's native payment sheet (SDK handles card input)
3. Escrow record created with amount locked
4. Release only happens after proof chain passes and Poster approves
5. KYC gated: backend validates `payouts_enabled` before any transfer

---

## Project Structure

```
hustleXP final1/
├── App/
│   ├── hustleXP_final1App.swift    # App entry, SSE client init
│   └── AppConfig.swift             # Env switching, backend URL, Stripe keys
├── Core/
│   ├── Router.swift                # @Observable Router, all navigation paths
│   ├── TRPCClient.swift            # HTTP client, auth headers, offline queue
│   ├── AppState.swift              # Auth state, role, user profile
│   └── DeepLinkManager.swift       # hustlexp:// URL handling
├── Models/                         # Swift structs matching backend types
├── Services/                       # 50+ service singletons
├── Screens/
│   ├── Auth/                       # 4 screens
│   ├── Onboarding/                 # 7 screens
│   ├── Hustler/                    # 19 screens
│   ├── Poster/                     # 10 screens + 2 recurring
│   ├── Settings/                   # 8 screens
│   ├── Shared/                     # 6 screens (messaging, notifications, ratings)
│   └── Edge/                       # 5 error/edge screens
├── Components/                     # Reusable UI components
│   ├── HXButton.swift
│   ├── HXBadge.swift (trust tier + status variants)
│   ├── SkeletonView.swift
│   └── AdaptiveLayout.swift
└── Resources/                      # Colors, fonts, assets
    └── ColorTokens.swift           # brandPurple, brandBlack, tier colors
```

---

## Screens by Role (58 Total)

### Auth (4)
Login, Signup, Phone Verification, Forgot Password

### Onboarding (7)
Welcome, How It Works, Role Selection, Permissions, Profile Setup, Skill Grid, Complete

### Hustler (19)
Home, Feed, Task Detail, Task In Progress, Proof Submission, Profile, Earnings, XP Breakdown, History, Tax Payment, File Claim, Claims History, Heat Map Fullscreen, Batch Details, Live Radar, On The Way Tracking, Squads Hub, Squad Detail, Locked Quests

### Poster (10 + 2 recurring)
Home, Create Task, AI Task Creation, ASAP Task Creation, Active Tasks, Task Management, Applicant List, Proof Review, History, Profile, Recurring Tasks List, Recurring Task Detail

### Settings (8)
Main, Account, Notifications, Payments, Privacy, Verification, Subscription, Help

### Shared (6)
Messages Inbox, Conversation, Notification Center, Rate Task, Dispute, Referral

### Edge / Error (5)
Eligibility, No Tasks, Network Error, Maintenance, Force Update

### Splash (1)

---

## Service Layer (50+ Services)

All services are `@MainActor` singletons injecting `TRPCClient.shared`.

| Category | Services |
|----------|---------|
| Core | TRPCClient, AuthService, TaskService, UserProfileService |
| Location | RealLocationService (CLLocationManager), GeofenceService, HeatMapService |
| Payments | StripePaymentManager, EscrowService, SubscriptionService |
| Communication | PushNotificationManager, MessagingService, RealtimeSSEClient |
| Features | LiveModeService, SquadService, RecurringTaskService, RatingService |
| Safety | BiometricService, LicenseVerificationService, GDPRService |
| Utility | R2UploadService, AnalyticsService, OfflineCacheService, DeepLinkManager |

---

## Dependencies

| Package | Purpose |
|---------|---------|
| Firebase iOS SDK | Auth (FirebaseAuth), Push (FirebaseMessaging) |
| Stripe iOS SDK | Native payment sheet, card input |
| GoogleSignIn | Google OAuth |

All other functionality (tRPC, SSE, R2 upload) is implemented natively in Swift — no additional SDKs required.

---

## Backend Connection

All API calls go through `TRPCClient.shared`:
- Base URL: `AppConfig.backendBaseURL`
- Auth: Firebase JWT in `Authorization: Bearer` header
- Encoding: JSON with `keyDecodingStrategy = .convertFromSnakeCase`
- Offline queue: Failed requests queued in `OfflineCacheService`, retried on reconnect
- Real-time: `RealtimeSSEClient` maintains persistent connection to `/realtime/stream`

---

## Known Gaps (Being Fixed)

| Gap | Severity | Status |
|-----|----------|--------|
| Dispute submission is a UI stub (`asyncAfter` delay, no API call) | CRITICAL | Fix in progress |
| AWS Rekognition liveness — `createLivenessSession` / `getLivenessResult` never called, Amplify SDK not installed | CRITICAL | Planned |
| Biometric validation result shown is from local mock, not API response | HIGH | Fix in progress |
| Squad task list / leaderboard return hardcoded empty arrays | HIGH | Fix in progress |
| Jury voting — `JuryService` exists but no screen built | HIGH | Planned |
| Daily challenges — `DailyChallengeService` exists but no screen built | MEDIUM | Planned |
| Featured listing — no Poster screen calls `FeaturedListingService` | MEDIUM | Planned |
| Batch quest `buildRoute` never called, secondary tasks not claimed | MEDIUM | Fix in progress |

---

## Roadmap

**Private Beta (immediate):**
- Fix critical gaps above
- AWS Rekognition step-up biometric auth at task location
- Jury voting screen

**Next 90 days:**
- Android client research
- Daily challenges screen surfaced on Hustler Home
- Featured listing Poster UI

**2-year north star:**
HustleXP becomes a credentialing layer. Master Hustlers hold verifiable work history exportable to other platforms. Squads bid on commercial contracts. Trusted+ workers access earned wage advance. The XP economy extends into insurance discounts and financial products.

---

## Build Notes

**Dark mode only** — `brandBlack (#0F0F1F)` background, `brandPurple (#7C3AED)` accent. Light mode not supported.

**AdaptiveLayout** — Responsive padding based on screen height (`UIScreen.main.bounds.height`). All spacing uses 4pt grid multiples.

**Trust tier colors** — Each tier has a distinct color defined in `ColorTokens.swift`. Never hardcode tier colors — always reference the token.

---

## License

Proprietary — All rights reserved.
