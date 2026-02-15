# HustleXP iOS

Native SwiftUI iOS client for HustleXP, a gamified local task marketplace. Connects to a tRPC backend via Firebase Auth. Supports dual roles (Hustler/Poster), real-time location, Stripe payments, and AI-powered task matching.

```
+---------------------------------------------------+
|                  hustleXP_final1App                |
|  AppDelegate (Firebase + Stripe + Crashlytics)    |
+-------------------------+-------------------------+
                          |
          +---------------+---------------+
          |               |               |
   +------v-----+  +-----v------+  +-----v------+
   |  AuthStack |  |  Onboarding|  | RootNavigator|
   |  (4 screens)|  | (7 screens)|  |             |
   +------------+  +------------+  +------+------+
                                          |
                           +--------------+--------------+
                           |              |              |
                    +------v-----+  +-----v------+  +---v--------+
                    |HustlerStack|  |PosterStack |  |SettingsStack|
                    |(19 screens)|  |(10 screens)|  |(8 screens)  |
                    +------+-----+  +-----+------+  +---+--------+
                           |              |              |
                    +------v--------------v--------------v------+
                    |              Service Layer                 |
                    |  50 services (tRPC client, auth, location, |
                    |  payments, AI, push, messaging, etc.)     |
                    +-------------------+-----------------------+
                                        |
                              +---------v----------+
                              |   tRPC Backend     |
                              | 38 routers, 261    |
                              | procedures on      |
                              | Railway             |
                              +--------------------+
```

## Requirements

- Xcode 15+
- iOS 17.0+ deployment target
- Swift 5.9+
- Active Firebase project
- Active Stripe account (test mode for development)

## Setup

1. **Clone the repository**
```bash
git clone https://github.com/Sebdysart/HUSTLEXPFINAL1.git
cd "hustleXP final1"
```

2. **Open in Xcode**
```bash
open "hustleXP final1.xcodeproj"
```

3. **Resolve Swift Packages** (automatic on first open)
   - Firebase iOS SDK v12.9
   - Google Sign-In v9.1
   - Stripe iOS v24.25

4. **Configure Firebase**
   - `GoogleService-Info.plist` is already included
   - Ensure your Firebase project has Authentication, Cloud Messaging enabled

5. **Build and Run**
   - Select target: `hustleXP final1`
   - Select simulator or device
   - Cmd+R

## Project Structure

```
hustleXP final1/hustleXP final1/
├── hustleXP_final1App.swift      # App entry point + AppDelegate
├── ContentView.swift              # Root content view
├── BootstrapScreen.swift          # App bootstrap logic
├── GoogleService-Info.plist       # Firebase config
├── hustleXP_final1.entitlements   # App capabilities
│
├── Models/                        # 13 data models
│   ├── User.swift                 # HXUser (role, XP, trust tier, earnings)
│   ├── Task.swift                 # HXTask (state machine, escrow, proof)
│   ├── Message.swift              # Chat messages
│   ├── Squad.swift                # Team/squad
│   ├── LiveMode.swift             # Live broadcasting state
│   ├── RecurringTask.swift        # Recurring task config
│   ├── AIPricing.swift            # AI pricing suggestions
│   ├── BiometricProof.swift       # Biometric verification
│   ├── InsuranceClaim.swift       # Insurance claims
│   ├── TaxStatus.swift            # XP tax tracking
│   ├── VerificationStatus.swift   # Identity verification
│   ├── ProfessionalLicensing.swift # License verification
│   └── SpatialIntelligence.swift  # Location intelligence
│
├── Screens/                       # 58 screens organized by domain
│   ├── Auth/                      # Login, Signup, ForgotPassword, PhoneVerification
│   ├── Onboarding/                # Welcome, RoleSelection, SkillGrid, ProfileSetup,
│   │                              # Permissions, HowItWorks, Complete
│   ├── Hustler/                   # Home, Feed, TaskDetail, LiveRadar, HeatMap,
│   │                              # ProofSubmission, Earnings, XPBreakdown,
│   │                              # OnTheWayTracking, TaskInProgress, SquadsHub,
│   │                              # LockedQuests, LicenseUpload, TaxPayment,
│   │                              # BatchDetails, History, Profile
│   ├── Poster/                    # Home, CreateTask, AITaskCreation, ASAPCreation,
│   │                              # ActiveTasks, TaskDetail, ProofReview,
│   │                              # TaskManagement, RecurringTasks, History, Profile
│   ├── Settings/                  # Main, Account, Payment, Notification, Privacy,
│   │                              # Verification, Subscription, Help
│   ├── Shared/                    # Conversation, Dispute, FileClaim,
│   │                              # ClaimsHistory, Referral
│   ├── Edge/                      # Eligibility, ForceUpdate, Maintenance,
│   │                              # NetworkError, NoTasks
│   └── SplashScreen.swift
│
├── Services/                      # 50 service files
│   ├── Core
│   │   ├── AuthService.swift          # Firebase auth, Google/Apple sign-in
│   │   ├── TRPCClient.swift           # Type-safe tRPC HTTP client
│   │   ├── LiveDataService.swift      # Real API data (replaces mock)
│   │   ├── TaskService.swift          # Task CRUD operations
│   │   └── UserProfileService.swift   # User profile management
│   ├── Location
│   │   ├── LocationService.swift      # Core location tracking
│   │   ├── RealLocationService.swift  # Real GPS implementation
│   │   ├── GeofenceService.swift      # Geofence monitoring
│   │   └── HeatMapService.swift       # Demand heat maps
│   ├── Payments
│   │   ├── StripePaymentManager.swift # Stripe SDK integration
│   │   ├── PricingService.swift       # Dynamic pricing
│   │   ├── SubscriptionService.swift  # Plan management
│   │   ├── TaxService.swift           # XP tax + insurance
│   │   └── EscrowService.swift        # Payment escrow
│   ├── Communication
│   │   ├── PushNotificationManager.swift  # FCM token management
│   │   ├── PushNotificationService.swift  # Push registration
│   │   ├── NotificationService.swift      # In-app notifications
│   │   └── MessagingService.swift         # Direct messaging
│   ├── AI & Discovery
│   │   ├── AIOnboardingService.swift  # AI role calibration
│   │   ├── SkillService.swift         # Worker skills
│   │   └── SkillVerificationService.swift
│   ├── Features
│   │   ├── RatingService.swift        # User ratings
│   │   ├── ReferralService.swift      # Referral codes
│   │   ├── BatchQuestService.swift    # Multi-task routing
│   │   ├── DailyChallengeService.swift # Daily challenges
│   │   ├── JuryService.swift          # Community jury
│   │   ├── ModerationService.swift    # Content moderation
│   │   ├── LiveModeService.swift      # Live broadcasting
│   │   ├── ProofService.swift         # Proof submission
│   │   ├── TutorialService.swift      # Interactive tutorials
│   │   ├── FeaturedListingService.swift # Promoted tasks
│   │   ├── SquadService.swift         # Team squads
│   │   └── RecurringTaskService.swift # Recurring tasks
│   ├── Safety
│   │   ├── BiometricService.swift     # Face verification
│   │   ├── GDPRService.swift          # Data export/delete
│   │   └── PremiumInsuranceService.swift
│   ├── Analytics
│   │   ├── AnalyticsService.swift     # Event tracking
│   │   ├── AlphaTelemetryService.swift # Alpha metrics
│   │   └── UIService.swift            # UI state sync
│   └── Mock (9 files)                 # Testing/preview mocks
│
├── Components/                    # Atomic design system
│   ├── Atoms/ (8)                 # HXButton, HXText, HXInput, HXAvatar,
│   │                              # HXBadge, HXIcon, HXDivider, HXSpacer
│   └── Molecules/ (43)           # TaskCard, RadarView, HeatMapView,
│                                  # RatingStars, StatCard, PaymentSheet,
│                                  # LiveModeToggle, ProgressBar, etc.
│
├── Navigation/                    # 8 navigation files
│   ├── AppState.swift             # Global app state (@Observable)
│   ├── Router.swift               # Navigation path management
│   ├── RootNavigator.swift        # Main tab bar / role routing
│   ├── AuthStack.swift            # Auth flow navigation
│   ├── OnboardingStack.swift      # Onboarding flow
│   ├── HustlerStack.swift         # Hustler feature navigation
│   ├── PosterStack.swift          # Poster feature navigation
│   └── SettingsStack.swift        # Settings navigation
│
├── Design/                        # Design system
│   ├── ColorTokens.swift          # Color palette, semantic colors
│   └── AdaptiveLayout.swift       # Responsive layout helpers
│
├── Utilities/                     # Helpers
│   ├── HapticFeedback.swift       # Haptic engine wrapper
│   └── KeychainManager.swift      # Secure credential storage
│
└── Assets.xcassets/               # App icons, colors, launch assets
```

## Dependencies (Swift Package Manager)

| Package | Version | Purpose |
|---------|---------|---------|
| Firebase iOS SDK | v12.9.0 | Auth, Cloud Messaging, Crashlytics |
| Google Sign-In | v9.1.0 | Social authentication |
| Stripe iOS | v24.25.0 | Payment sheet, card input |

## Architecture

### Data Flow

```
Screen (@Environment LiveDataService)
    |
    +--> LiveDataService.shared (singleton, @Observable)
    |       |
    |       +--> AuthService.shared (Firebase JWT)
    |       +--> TaskService.shared (task CRUD)
    |       +--> TRPCClient (HTTP calls to backend)
    |               |
    |               +--> Authorization: Bearer <firebase_jwt>
    |               +--> POST /trpc/<router>.<procedure>
    |
    +--> AppState (UI state, selected role, userId)
    +--> Router (navigation path stack)
```

### Key Patterns

- **@Observable + @Environment** injection for all services
- **LiveDataService.shared** singleton replaces all mock data
- **`refreshAll()`** parallel data fetch on screen appear via `.task {}`
- **Dual role** system: users select Hustler or Poster at onboarding
- **State machine** tasks: draft -> open -> accepted -> in_progress -> proof_submitted -> completed
- **Escrow** payments: funded -> locked -> released/refunded

### Auth Flow

```
App Launch
    |
    v
SplashScreen (100ms)
    |
    v
AuthService.shared.isAuthenticated?
    |
    +-- No  --> AuthStack (Login/Signup)
    |               |
    |               v
    |           Firebase Auth (Email, Google, Apple)
    |               |
    |               v
    |           user.register tRPC call
    |               |
    |               v
    |           OnboardingStack (role selection, skills, profile)
    |
    +-- Yes --> RootNavigator (HustlerStack or PosterStack)
```

## Screens by Role

### Hustler (Task Worker) - 19 screens
| Screen | Purpose |
|--------|---------|
| HustlerHomeScreen | Dashboard: nearby tasks, XP, earnings |
| HustlerFeedScreen | Browse and filter available tasks |
| HustlerTaskDetailScreen | View task details, accept tasks |
| LiveRadarScreen | Real-time map of live-mode tasks |
| HeatMapFullscreenScreen | Demand heat map overlay |
| ProofSubmissionScreen | Submit photo proof of completion |
| OnTheWayTrackingScreen | Navigation to task location |
| TaskInProgressScreen | Active task management |
| EarningsScreen | Earnings breakdown and history |
| XPBreakdownScreen | XP progression and tier info |
| TaxPaymentScreen | XP tax payment via Stripe |
| LicenseUploadScreen | Professional license upload |
| LockedQuestsScreen | Tasks requiring skill verification |
| SquadsHubScreen | Team squad management |
| BatchDetailsScreen | Multi-task batch route details |
| HustlerHistoryScreen | Completed task history |
| HustlerProfileScreen | Profile and stats |

### Poster (Task Creator) - 10 screens
| Screen | Purpose |
|--------|---------|
| PosterHomeScreen | Dashboard: posted tasks, spending |
| CreateTaskScreen | Standard task creation form |
| AITaskCreationScreen | AI-assisted task creation |
| ASAPTaskCreationScreen | Urgent task posting |
| PosterTaskDetailScreen | View posted task status |
| ProofReviewScreen | Review worker proof submissions |
| PosterActiveTasksScreen | Manage active posted tasks |
| TaskManagementScreen | Full task management panel |
| RecurringTasksScreen | Set up recurring tasks |
| PosterHistoryScreen | Completed task history |

## Backend Connection

The app connects to a Hono + tRPC v11 backend:

- **Production**: `https://hustlexp-ai-backend-staging-production.up.railway.app`
- **tRPC endpoint**: `/trpc/<router>.<procedure>`
- **Auth**: Firebase JWT in `Authorization: Bearer` header
- **Backend repo**: `https://github.com/Sebdysart/hustlexp-ai-backend.git`

The `TRPCClient.swift` handles all HTTP communication with type-safe Codable request/response models.

## Build Notes

- Bundle ID: `taskme.hustleXP-final1`
- The project uses Xcode's file system synchronized groups (no manual file references needed)
- Privacy policy URL: `https://hustlexp-ai-backend-staging-production.up.railway.app/privacy-policy`
- All mock services remain in codebase for SwiftUI previews but are not injected at runtime

## Git

```
Repository: https://github.com/Sebdysart/HUSTLEXPFINAL1.git
Branch: main
```

## License

Proprietary - All rights reserved.
