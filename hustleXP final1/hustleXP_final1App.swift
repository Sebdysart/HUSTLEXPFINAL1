//
//  hustleXP_final1App.swift
//  hustleXP final1
//
//  Created by Sebastian Dysart on 2/5/26.
//

import SwiftUI
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import StripePaymentSheet
import LocalAuthentication

// MARK: - App Delegate for Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        HXLogger.info("Firebase + Crashlytics configured successfully", category: "General")

        // Set up push notification delegates
        UNUserNotificationCenter.current().delegate = PushNotificationManager.shared
        Messaging.messaging().delegate = PushNotificationManager.shared

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Register notification categories (must be before first notification delivery)
        PushNotificationManager.registerNotificationCategories()

        // Initialize Stripe
        StripePaymentManager.shared.configure()
        HXLogger.info("Stripe configured successfully", category: "Payment")

        return true
    }

    /// Passes the APNs device token to Firebase Cloud Messaging for token mapping.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()
        HXLogger.info("[Push][APNS] APNs token received — length=\(deviceToken.count) prefix=\(String(tokenHex.prefix(20)))...", category: "Push")
        Messaging.messaging().apnsToken = deviceToken
        HXLogger.info("[Push][APNS] APNs token handed to Firebase — FCM token will follow via MessagingDelegate", category: "Push")
    }

    /// Called when a push arrives while the app is in the background (content-available:1).
    /// Dispatch pings use urgentWakeup=true so iOS wakes the app here before user taps.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let keys = userInfo.keys.map { "\($0)" }.sorted()
        HXLogger.info("[Push][BG] didReceiveRemoteNotification — keys=\(keys)", category: "Push")

        // Required when FirebaseAppDelegateProxyEnabled = NO
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Route data payload to PushNotificationManager so dispatch pings processed
        // in background fire GoModeManager.handleIncomingPing → activePing → LivePingView.
        Task { @MainActor in
            HXLogger.info("[Push][BG] Routing to PushNotificationManager.handleNotification", category: "Push")
            PushNotificationManager.shared.handleNotification(userInfo)
        }

        completionHandler(.newData)
    }

    /// Logs remote notification registration failures.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        HXLogger.error("[Push][APNS] FAILED to register for remote notifications: \(error.localizedDescription)", category: "Push")
        HXLogger.error("[Push][APNS] This means FCM cannot deliver push notifications on this device", category: "Push")
    }

}

// MARK: - Main App

@main
struct hustleXP_final1App: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // App-wide state
    @StateObject private var authService = AuthService.shared
    @State private var appState = AppState()
    @State private var router = Router()
    @State private var dataService = LiveDataService.shared
    @State private var deepLinkManager = DeepLinkManager.shared
    @State private var serviceAreaManager = ServiceAreaManager.shared
    @State private var goModeManager = GoModeManager.shared
    
    // Splash screen state - start as true so splash shows immediately
    @State private var isInitialized = false
    @State private var showSplash = true
    // Ping presentation state — bridged from goModeManager.activePing via onChange
    // so SwiftUI's @Observable tracking works correctly (Binding closures are not tracked).
    @State private var livePingItem: IncomingPing? = nil

    // Biometric lock — set true when app backgrounds, cleared after successful Face ID
    @State private var biometricLocked = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content - always in view hierarchy for faster transition
                Group {
                    if authService.isAuthenticated {
                        // User is logged in - show main app
                        RootNavigator()
                            .environmentObject(authService)
                    } else {
                        // User is not logged in - show auth flow
                        AuthStack()
                            .environmentObject(authService)
                    }
                }
                .opacity(isInitialized ? 1 : 0)
                
                // Splash overlay - shows immediately, fades out when ready
                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                        .zIndex(1)
                }

                // Biometric lock overlay
                if biometricLocked && authService.isAuthenticated && isInitialized {
                    BiometricLockView(onUnlock: evaluateBiometric)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .environment(appState)
            .environment(router)
            .environment(dataService)
            .environment(serviceAreaManager)
            .environment(goModeManager)
            // LivePingView: only for hustlers — posters must never see dispatch pings.
            // onChange bridges @Observable changes into @State so SwiftUI's fullScreenCover
            // receives proper state updates (Binding(get:set:) closures are NOT observation-tracked).
            .onChange(of: goModeManager.activePing) { _, newPing in
                guard appState.userRole == .hustler else {
                    if newPing != nil {
                        HXLogger.info("[GoMode][8] Suppressing LivePingView — user is not a hustler (role=\(String(describing: appState.userRole)))", category: "Dispatch")
                    }
                    return
                }
                if let ping = newPing {
                    HXLogger.info("[GoMode][8] Bridging activePing → livePingItem for taskId=\(ping.taskId)", category: "Dispatch")
                } else {
                    HXLogger.info("[GoMode][8] activePing cleared — dismissing LivePingView", category: "Dispatch")
                }
                livePingItem = newPing
            }
            .onChange(of: livePingItem) { _, newItem in
                // Sync dismissal back to GoModeManager (e.g. system swipe-dismiss)
                if newItem == nil && goModeManager.activePing != nil {
                    goModeManager.activePing = nil
                }
            }
            .fullScreenCover(item: $livePingItem) { ping in
                LivePingView(
                    ping: ping,
                    onAccept: {
                        HXLogger.info("[GoMode][9] User tapped Accept on ping \(ping.taskId)", category: "Dispatch")
                        Task {
                            if await goModeManager.acceptPing(ping) != nil {
                                router.navigateToHustler(.taskDetail(taskId: ping.taskId))
                            }
                        }
                    },
                    onDecline: {
                        HXLogger.info("[GoMode][9] User tapped Pass on ping \(ping.taskId)", category: "Dispatch")
                        goModeManager.declinePing(ping)
                    }
                )
                .environment(goModeManager)
            }
            .adaptiveLayout()  // Inject AdaptiveLayout for consistent responsive sizing
            .errorToast()      // Global error toast overlay
            .onAppear {
                // Bridge AuthService to AppState for coordinated auth state
                authService.appState = appState

                // If AuthService already loaded the user during init (before appState was set),
                // sync the state now so RootNavigator routes correctly.
                if let user = authService.currentUser {
                    appState.login(userId: user.id, role: user.role, onboardingComplete: user.onboardingComplete)
                }

                Task {
                    // Wait for AuthService to finish loading if it has a saved session.
                    // This prevents briefly showing the wrong screen.
                    let hasToken = KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) != nil
                    if hasToken && !authService.isAuthenticated {
                        // Wait up to 5 seconds for auth to resolve
                        for _ in 0..<50 {
                            try? await Task.sleep(for: .milliseconds(100))
                            if authService.isAuthenticated { break }
                        }
                        // Sync after async load completes
                        if let user = authService.currentUser {
                            appState.login(userId: user.id, role: user.role, onboardingComplete: user.onboardingComplete)
                        }
                    }

                    // Connect SSE + earnings sync for authenticated users
                    if authService.isAuthenticated,
                       let token = KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) {
                        RealtimeSSEClient.shared.connect(authToken: token)
                        dataService.subscribeToEarningsUpdates()
                        NotificationService.shared.subscribeToSSE()
                        // Restore Go Mode state after app launch
                        await goModeManager.loadStatus()
                    }

                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isInitialized = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showSplash = false
                        }
                    }

                    // Request notification permission on every launch — shows dialog on first
                    // install, silently succeeds afterwards. Must be called before FCM can
                    // show banners on devices that skipped the onboarding permissions screen.
                    let granted = await PushNotificationManager.shared.requestAuthorization()
                    if granted {
                        PushNotificationManager.shared.registerForRemoteNotifications()
                    }

                    // Log full push notification diagnostic on every launch
                    await PushNotificationManager.shared.logDiagnostics()

                    // Require biometric unlock on fresh launch if already authenticated
                    if authService.isAuthenticated {
                        await MainActor.run { biometricLocked = true }
                        evaluateBiometric()
                    }
                }
            }
            .onOpenURL { url in
                // 1. Try deep link handling first (hustlexp:// or https://hustlexp.app/)
                if deepLinkManager.handleURL(url) {
                    // Deep link recognised — route to destination if authenticated
                    if authService.isAuthenticated,
                       let destination = deepLinkManager.consumePendingDeepLink() {
                        router.navigate(to: destination, appState: appState)
                    }
                    // If not authenticated the pending link stays in
                    // deepLinkManager.pendingDeepLink and can be consumed
                    // after the user logs in.
                    return
                }

                // 2. Fall through to Google Sign-In URL callback
                GIDSignIn.sharedInstance.handle(url)
            }
            .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    // Connect SSE + subscribe to real-time channels on login
                    if let token = KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) {
                        RealtimeSSEClient.shared.connect(authToken: token)
                        dataService.subscribeToEarningsUpdates()
                        NotificationService.shared.subscribeToSSE()
                    }

                    // Restore Go Mode state after login
                    Task { await goModeManager.loadStatus() }

                    // Consume any pending deep link that arrived before authentication
                    if let destination = deepLinkManager.consumePendingDeepLink() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            router.navigate(to: destination, appState: appState)
                        }
                    }
                } else {
                    // Disconnect SSE + unsubscribe on logout
                    RealtimeSSEClient.shared.disconnect()
                    dataService.unsubscribeFromEarningsUpdates()
                    NotificationService.shared.unsubscribeFromSSE()
                    goModeManager.stopLocationUpdates()
                    biometricLocked = false
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background && authService.isAuthenticated {
                    biometricLocked = true
                } else if phase == .active {
                    UNUserNotificationCenter.current().setBadgeCount(0)
                    if biometricLocked { evaluateBiometric() }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .pushNotificationDeepLink)) { notification in
                guard isInitialized, authService.isAuthenticated,
                      let userInfo = notification.userInfo,
                      let type = userInfo["type"] as? String else { return }
                let taskId = userInfo["taskId"] as? String
                let role = appState.userRole
                switch type {
                case "task_assigned":
                    guard let taskId else { return }
                    role == .poster
                        ? router.navigateToPoster(.taskDetail(taskId: taskId))
                        : router.navigateToHustler(.taskDetail(taskId: taskId))
                case "proof_submitted":
                    if let taskId, role == .poster {
                        router.navigateToPoster(.proofReview(taskId: taskId))
                    }
                case "proof_rejected":
                    if let taskId, role == .hustler {
                        router.navigateToHustler(.proofSubmission(taskId: taskId))
                    }
                case "proof_approved":
                    if let taskId, role == .hustler {
                        router.navigateToHustler(.taskDetail(taskId: taskId))
                    }
                case "escrow_released", "payment_confirmed":
                    if role == .hustler {
                        router.navigateToHustler(.earnings)
                    } else if let taskId {
                        router.navigateToPoster(.taskDetail(taskId: taskId))
                    }
                case "payment_failed", "transfer_failed":
                    if role == .hustler {
                        router.navigateToHustler(.earnings)
                    } else if let taskId {
                        router.navigateToPoster(.taskManagement(taskId: taskId))
                    }
                case "payout_failed":
                    if role == .hustler { router.navigateToHustler(.earnings) }
                case "dispute_update":
                    if let taskId {
                        role == .poster
                            ? router.navigateToPoster(.dispute(taskId: taskId))
                            : router.navigateToHustler(.dispute(taskId: taskId))
                    }
                case "tier_up", "badge_earned", "xp_earned":
                    if role == .hustler { router.navigateToHustler(.xpBreakdown) }
                case "message_received":
                    if let taskId {
                        role == .poster
                            ? router.navigateToPoster(.conversation(taskId: taskId))
                            : router.navigateToHustler(.conversation(taskId: taskId))
                    }
                case "task_cancelled", "task_expired":
                    if let taskId {
                        role == .poster
                            ? router.navigateToPoster(.taskDetail(taskId: taskId))
                            : router.navigateToHustler(.taskDetail(taskId: taskId))
                    }
                default:
                    break
                }
            }
        }
    }

    private func evaluateBiometric() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            biometricLocked = false
            return
        }
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock HustleXP"
        ) { success, _ in
            if success {
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        biometricLocked = false
                    }
                }
            }
        }
    }
}

// MARK: - Biometric Lock Screen

private struct BiometricLockView: View {
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "faceid")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.brandPurple)

                VStack(spacing: 8) {
                    Text("HustleXP")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Authenticate to continue")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }

                Button(action: onUnlock) {
                    Text("Unlock with Face ID")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brandPurple))
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
        }
        .onAppear { onUnlock() }
    }
}
