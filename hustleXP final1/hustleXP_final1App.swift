//
//  hustleXP_final1App.swift
//  hustleXP final1
//
//  Created by Sebastian Dysart on 2/5/26.
//

import SwiftUI
import FirebaseCore

// MARK: - App Delegate for Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        return true
    }

    // Handle Google Sign-In URL callback
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // GoogleSignIn SDK will handle the URL when added
        // GIDSignIn.sharedInstance.handle(url)
        return false
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
    @State private var dataService = MockDataService.shared

    var body: some Scene {
        WindowGroup {
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
            .environment(appState)
            .environment(router)
            .environment(dataService)
            .adaptiveLayout()  // Inject AdaptiveLayout for consistent responsive sizing
        }
    }
}
