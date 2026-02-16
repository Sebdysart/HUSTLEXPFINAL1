//
//  AppState.swift
//  hustleXP final1
//
//  Central app state management
//

import SwiftUI

// MARK: - User Role
// Backend may return "worker" instead of "hustler" in some endpoints
enum UserRole: String, CaseIterable, Codable {
    case hustler = "hustler"
    case poster = "poster"

    /// Safely decode — treat "worker" as "hustler", unknown values default to "hustler"
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "hustler", "worker": self = .hustler
        case "poster": self = .poster
        default: self = .hustler
        }
    }
}

// MARK: - Trust Tier (5 tiers as per spec)
// Backend sends 0 for brand-new users (unranked), 1-5 for ranked tiers
enum TrustTier: Int, CaseIterable, Codable {
    case unranked = 0
    case rookie = 1
    case verified = 2
    case trusted = 3
    case elite = 4
    case master = 5

    var name: String {
        switch self {
        case .unranked: return "Rookie"  // Display as Rookie until first tier-up
        case .rookie: return "Rookie"
        case .verified: return "Verified"
        case .trusted: return "Trusted"
        case .elite: return "Elite"
        case .master: return "Master"
        }
    }

    /// Safely decode from backend — unknown values default to .unranked
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self = TrustTier(rawValue: rawValue) ?? .unranked
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
