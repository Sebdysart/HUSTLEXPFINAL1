//
//  hustleXP_final1App.swift
//  hustleXP final1
//
//  Created by Sebastian Dysart on 2/5/26.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import StripePaymentSheet

// Note: FirebaseCrashlytics removed - add FirebaseCrashlytics to SPM if crash reporting needed

// MARK: - App Delegate for Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")

        // Set up push notification delegates
        UNUserNotificationCenter.current().delegate = PushNotificationManager.shared
        Messaging.messaging().delegate = PushNotificationManager.shared

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Initialize Stripe
        StripePaymentManager.shared.configure()
        print("✅ Stripe configured successfully")

        return true
    }

    /// Passes the APNs device token to Firebase Cloud Messaging for token mapping.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs device token registered with Firebase")
    }

    /// Logs remote notification registration failures.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
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
            .adaptiveLayout()  // Inject AdaptiveLayout for consistent responsive sizing
            .onAppear {
                // Bridge AuthService to AppState for coordinated auth state
                authService.appState = appState
                
                // Quick initialization - auth state is already checked synchronously
                // by AuthService on init, so we just need a minimal delay for UI to settle
                Task {
                    // Minimal delay - just enough for the splash to render one frame
                    try? await Task.sleep(for: .milliseconds(100))
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isInitialized = true
                        }
                        // Remove splash after fade completes
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
                // Consume any pending deep link that arrived before authentication
                if isAuthenticated,
                   let destination = deepLinkManager.consumePendingDeepLink() {
                    // Small delay to let the main navigation mount first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        router.navigate(to: destination, appState: appState)
                    }
                }
            }
        }
    }
}
