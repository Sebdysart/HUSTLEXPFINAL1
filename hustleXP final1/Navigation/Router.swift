//
//  Router.swift
//  hustleXP final1
//
//  Navigation router for managing screen transitions
//

import SwiftUI

// MARK: - Route Definitions

enum AuthRoute: Hashable {
    case login
    case signup
    case forgotPassword
    case phoneVerification
}

enum OnboardingRoute: Hashable {
    case welcome
    case roleSelection
    case permissions
    case profileSetup
    case complete
}

enum HustlerRoute: Hashable {
    case home
    case feed
    case taskDetail(taskId: String)
    case taskInProgress(taskId: String)
    case proofSubmission(taskId: String)
    case history
    case profile
    case earnings
    case xpBreakdown
}

enum PosterRoute: Hashable {
    case home
    case createTask
    case taskDetail(taskId: String)
    case activeTasks
    case taskManagement(taskId: String)
    case proofReview(taskId: String)
    case history
    case profile
}

enum SharedRoute: Hashable {
    case conversation(conversationId: String)
    case taskDetail(taskId: String)
    case proofSubmission(taskId: String)
    case dispute(taskId: String)
}

enum SettingsRoute: Hashable {
    case main
    case account
    case notifications
    case payments
    case privacy
    case verification
    case help
}

enum EdgeRoute: Hashable {
    case noTasks
    case eligibility
    case networkError
    case maintenance
    case forceUpdate
}

// MARK: - Router

@MainActor
@Observable
final class Router {
    // Navigation paths for each stack
    var authPath = NavigationPath()
    var onboardingPath = NavigationPath()
    var hustlerPath = NavigationPath()
    var posterPath = NavigationPath()
    var settingsPath = NavigationPath()
    
    // Sheet presentation
    var presentedSheet: AnyHashable?
    var isSheetPresented: Bool = false
    
    // MARK: - Auth Navigation
    
    func navigateToAuth(_ route: AuthRoute) {
        authPath.append(route)
    }
    
    func popAuth() {
        if !authPath.isEmpty {
            authPath.removeLast()
        }
    }
    
    // MARK: - Onboarding Navigation
    
    func navigateToOnboarding(_ route: OnboardingRoute) {
        onboardingPath.append(route)
    }
    
    func popOnboarding() {
        if !onboardingPath.isEmpty {
            onboardingPath.removeLast()
        }
    }
    
    // MARK: - Hustler Navigation
    
    func navigateToHustler(_ route: HustlerRoute) {
        hustlerPath.append(route)
    }
    
    func popHustler() {
        if !hustlerPath.isEmpty {
            hustlerPath.removeLast()
        }
    }
    
    // MARK: - Poster Navigation
    
    func navigateToPoster(_ route: PosterRoute) {
        posterPath.append(route)
    }
    
    func popPoster() {
        if !posterPath.isEmpty {
            posterPath.removeLast()
        }
    }
    
    // MARK: - Settings Navigation
    
    func navigateToSettings(_ route: SettingsRoute) {
        settingsPath.append(route)
    }
    
    func popSettings() {
        if !settingsPath.isEmpty {
            settingsPath.removeLast()
        }
    }
    
    // MARK: - Reset
    
    func resetAll() {
        authPath = NavigationPath()
        onboardingPath = NavigationPath()
        hustlerPath = NavigationPath()
        posterPath = NavigationPath()
        settingsPath = NavigationPath()
        presentedSheet = nil
        isSheetPresented = false
    }
}
