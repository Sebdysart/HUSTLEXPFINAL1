# NAVIGATION CONTRACT — HustleXP v1.0

**STATUS: LOCKED**
**Authority:** RootNavigator.tsx, BACKEND_CONTRACT.md

---

## PART A — ROUTE NAMING RULES

### A1. Global Uniqueness
- Route names MUST be unique within their containing navigator
- Route names MAY be duplicated across separate navigators ONLY IF they represent the same logical screen
- Example: "TaskDetail" exists in both HustlerStack and SharedModalStack (same screen, different context)

### A2. Naming Conventions
- Screen routes: PascalCase (e.g., "TaskDetail", "HustlerHome")
- Tab routes: PascalCase matching screen intent (e.g., "Home", "Feed", "Profile")
- Navigator routes: PascalCase ending in navigator type implied by context

### A3. Forbidden Patterns
- Numeric suffixes (TaskDetail2, TaskDetailV2)
- Abbreviations (TD, HP, TFS)
- Generic names (Screen1, Modal, Page)
- Underscores or hyphens

---

## PART B — NAVIGATOR OWNERSHIP

### B1. Stack Hierarchy

| Navigator | Type | Parent | Owns |
|-----------|------|--------|------|
| RootNavigator | Native Stack | (root) | Entry, Auth, Onboarding, Hustler, Poster, Settings, SharedModal |
| AuthStack | Native Stack | Root | Login, Signup, ForgotPassword, AuthPhoneVerification |
| OnboardingStack | Native Stack | Root | Framing, Calibration, RoleConfirmation, PreferenceLock, CapabilityIntro, LocationSetup |
| HustlerStack | Native Stack | Root | HustlerTabs, TaskDetail, TaskInProgress, TaskCompletion, HustlerEnRouteMap, XPBreakdown, InstantInterrupt |
| HustlerTabs | Bottom Tab | HustlerStack | Home, Feed, History, Profile |
| PosterTabs | Bottom Tab | Root | Home, Create, Active, Profile |
| SettingsStack | Native Stack | Root | SettingsMain, AccountSettings, NotificationSettings, PaymentSettings, PrivacySettings, Verification, Support |
| SharedModalStack | Native Stack | Root | TaskConversation, TaskDetail, ProofSubmission, Dispute, NoTasksAvailable, EligibilityMismatch, NetworkError, Maintenance, ForceUpdate |

### B2. Modal Presentation Rights
- HustlerStack MAY present modal screens above HustlerTabs
- SharedModalStack MAY present edge-case modals from any context
- PosterTabs MUST NOT present modals (navigate to SharedModalStack instead)
- AuthStack, OnboardingStack, SettingsStack MUST NOT present modals

### B3. Cross-Navigator Navigation
- Root Navigator MUST handle all cross-role transitions
- Hustler → Poster: MUST go through Root (role switch)
- Any → Settings: MUST go through Root
- Any → SharedModal: MUST go through Root

---

## PART C — NAVIGATION VERBS

### C1. When to Use Each Verb

| Verb | Use Case |
|------|----------|
| `navigate` | Default. Go to screen, allow back. |
| `push` | Add to stack even if screen exists (multiple instances). |
| `replace` | Replace current screen (no back to previous). |
| `reset` | Clear stack and set new root (auth transitions). |
| `goBack` | Return to previous screen. |

### C2. Required Patterns
- Auth → Main: MUST use `reset` (clear auth stack)
- Onboarding → Main: MUST use `reset` (clear onboarding stack)
- Task lifecycle: MUST use `navigate` (preserve back stack)
- Edge case screens: MUST use `navigate` (allow recovery)

### C3. Forbidden Patterns
- NEVER use `push` for singleton screens (TaskDetail, Profile)
- NEVER use `replace` within task lifecycle (user must be able to go back)
- NEVER use `reset` for Settings access

---

## PART D — NAVIGATION PROHIBITIONS

### D1. Hard Prohibitions
- Circular navigation: A → B → C → A MUST NOT occur
- Cross-role leaks: Hustler screens MUST NOT navigate to Poster screens directly
- Implicit deep linking: All deep links MUST go through Root validation
- Silent fallback navigation: Failed navigation MUST show error, never silently redirect

### D2. State-Based Prohibitions
Navigation MUST be disabled when:
- `state === 'loading'`: All navigation disabled except back
- `state === 'blocked'`: Only back and eligibility link allowed
- `state === 'submitting'`: All navigation disabled
- `state === 'error'`: Only back and retry allowed

---

## PART E — FUTURE-PROOFING

### E1. Adding New Screens
- New screens MUST be added to the appropriate existing navigator
- New screens MUST follow naming conventions in A2
- New screens MUST NOT create new navigation paths between roles

### E2. Deep Link Compliance
- All deep links MUST route through RootNavigator
- Deep links MUST validate user role before navigation
- Deep links to protected screens MUST check authentication first

### E3. Notification Navigation
- Notification taps MUST route through RootNavigator
- Notification navigation MUST respect state-based prohibitions
- Notifications MUST NOT bypass authentication

### E4. Modal vs Route Distinction
- Modals: Overlay content, preserve underlying screen
- Routes: Full screen replacement
- Edge cases (NetworkError, Maintenance): Routes in SharedModalStack
- Task actions (TaskDetail, TaskInProgress): Routes in HustlerStack

---

**END OF CONTRACT**
