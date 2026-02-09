//
//  AppState.swift
//  hustleXP final1
//
//  Central app state management
//

import SwiftUI

// MARK: - User Role
enum UserRole: String, CaseIterable {
    case hustler = "hustler"
    case poster = "poster"
}

// MARK: - Trust Tier (5 tiers as per spec)
enum TrustTier: Int, CaseIterable {
    case rookie = 1
    case verified = 2
    case trusted = 3
    case elite = 4
    case master = 5
    
    var name: String {
        switch self {
        case .rookie: return "Rookie"
        case .verified: return "Verified"
        case .trusted: return "Trusted"
        case .elite: return "Elite"
        case .master: return "Master"
        }
    }
}

// MARK: - Authentication State
enum AuthState {
    case unauthenticated
    case onboarding
    case authenticated
}

// MARK: - App State
@MainActor
@Observable
final class AppState {
    // Auth
    var authState: AuthState = .unauthenticated
    var isLoggedIn: Bool = false
    
    // User
    var userRole: UserRole?
    var trustTier: TrustTier = .rookie
    var userId: String?
    var userName: String?
    
    // Onboarding
    var hasCompletedOnboarding: Bool = false
    
    // Navigation
    var selectedTab: Int = 0
    
    // MARK: - Actions
    
    func login(userId: String, role: UserRole) {
        self.userId = userId
        self.userRole = role
        self.isLoggedIn = true
        self.authState = hasCompletedOnboarding ? .authenticated : .onboarding
        print("[AppState] User logged in: \(userId), role: \(role.rawValue)")
    }
    
    func logout() {
        self.userId = nil
        self.userRole = nil
        self.isLoggedIn = false
        self.authState = .unauthenticated
        self.selectedTab = 0
        print("[AppState] User logged out")
    }
    
    func completeOnboarding() {
        self.hasCompletedOnboarding = true
        self.authState = .authenticated
        print("[AppState] Onboarding completed")
    }
    
    func setRole(_ role: UserRole) {
        self.userRole = role
        print("[AppState] Role set to: \(role.rawValue)")
    }
}
