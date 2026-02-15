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
    case howItWorks
    case roleSelection
    case permissions
    case profileSetup
    case skillSelection
    case complete

    /// Step index for progress indicator (0-based)
    var stepIndex: Int {
        switch self {
        case .welcome: return 0
        case .howItWorks: return 1
        case .roleSelection: return 2
        case .permissions: return 3
        case .profileSetup: return 4
        case .skillSelection: return 5
        case .complete: return 6
        }
    }

    /// Total steps (excluding complete screen)
    static let totalSteps = 6
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
    // v1.8.0 routes
    case taxPayment
    case fileClaim
    case claimsHistory
    // v1.9.0 Spatial Intelligence routes
    case heatMapFullscreen
    case batchDetails(batchId: String)
    // v2.0.0 LIVE Mode routes
    case liveRadar
    case onTheWayTracking(trackingId: String)
    // v2.1.0 Professional Licensing routes
    case skillSelection
    case licenseUpload(type: LicenseType)
    case lockedQuests
    // v2.4.0 Squads Mode (Gold-tier unlockable)
    case squadsHub
    case squadDetail(squadId: String)
}

enum PosterRoute: Hashable {
    case home
    case createTask
    case aiTaskCreation
    case taskDetail(taskId: String)
    case activeTasks
    case taskManagement(taskId: String)
    case proofReview(taskId: String)
    case conversation(taskId: String)
    case history
    case profile
    // v2.0.0 LIVE Mode routes
    case asapTaskCreation
    case questTracking(questId: String)
    // v2.4.0 Recurring Tasks (Silver-tier unlockable)
    case recurringTasks
    case recurringTaskDetail(seriesId: String)
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
    case referrals
    case subscription
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
