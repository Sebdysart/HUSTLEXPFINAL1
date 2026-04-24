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
        Messaging.messaging().apnsToken = deviceToken
        HXLogger.info("APNs device token registered with Firebase", category: "Push")
    }

    /// When Firebase Messaging method swizzling is disabled (FirebaseAppDelegateProxyEnabled = NO),
    /// forward remote notifications to FCM manually for analytics / delivery metrics.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }

    /// Logs remote notification registration failures.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        HXLogger.error("Failed to register for remote notifications: \(error.localizedDescription)", category: "Push")
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
    
    // Splash screen state - start as true so splash shows immediately
    @State private var isInitialized = false
    @State private var showSplash = true

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
            }
            .environment(appState)
            .environment(router)
            .environment(dataService)
            .environment(serviceAreaManager)
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
                    }

                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isInitialized = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showSplash = false
                        }
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
                    // Connect SSE + earnings sync on login
                    if let token = KeychainManager.shared.get(forKey: KeychainManager.Key.authToken) {
                        RealtimeSSEClient.shared.connect(authToken: token)
                        dataService.subscribeToEarningsUpdates()
                    }

                    // Consume any pending deep link that arrived before authentication
                    if let destination = deepLinkManager.consumePendingDeepLink() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            router.navigate(to: destination, appState: appState)
                        }
                    }
                } else {
                    // Disconnect SSE + earnings sync on logout
                    RealtimeSSEClient.shared.disconnect()
                    dataService.unsubscribeFromEarningsUpdates()
                }
            }
        }
    }
}
