//
//  AppState.swift
//  hustleXP final1
//
//  Central app state management
//

import Foundation
import SwiftUI

// MARK: - User Role
// Backend may return "worker" instead of "hustler" in some endpoints
enum UserRole: String, CaseIterable, Codable {
    case hustler = "hustler"
    case poster = "poster"
    case admin = "admin"

    /// Safely decode — treat "worker" as "hustler", unknown values default to "hustler"
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "hustler", "worker": self = .hustler
        case "poster": self = .poster
        case "admin": self = .admin
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

    var nextTierName: String {
        switch self {
        case .unranked: return "Rookie"
        case .rookie: return "Verified"
        case .verified: return "Trusted"
        case .trusted: return "Elite"
        case .elite: return "Master"
        case .master: return "Master"
        }
    }

    var color: Color {
        switch self {
        case .unranked: return .textTertiary
        case .rookie: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .verified: return Color(red: 0.3, green: 0.5, blue: 1.0)
        case .trusted: return Color(red: 0.0, green: 0.85, blue: 0.6)
        case .elite: return .brandPurple
        case .master: return Color(red: 1.0, green: 0.75, blue: 0.0)
        }
    }

    /// SF Symbol icon for each tier
    var icon: String {
        switch self {
        case .unranked: return "person.crop.circle"
        case .rookie: return "shield.fill"
        case .verified: return "checkmark.seal.fill"
        case .trusted: return "star.circle.fill"
        case .elite: return "crown.fill"
        case .master: return "trophy.fill"
        }
    }

    /// Gradient colors for premium rendering
    var gradientColors: [Color] {
        switch self {
        case .unranked: return [.gray, .gray.opacity(0.5)]
        case .rookie: return [Color(red: 0.4, green: 0.8, blue: 0.4), Color(red: 0.2, green: 0.6, blue: 0.3)]
        case .verified: return [Color(red: 0.3, green: 0.5, blue: 1.0), Color(red: 0.2, green: 0.3, blue: 0.9)]
        case .trusted: return [Color(red: 0.0, green: 0.85, blue: 0.6), Color(red: 0.0, green: 0.6, blue: 0.8)]
        case .elite: return [Color(red: 0.65, green: 0.3, blue: 1.0), Color(red: 0.9, green: 0.3, blue: 0.8)]
        case .master: return [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 1.0, green: 0.5, blue: 0.0)]
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
    /// Per-user persistence so returning users skip onboarding after a cold start.
    private static let onboardingCompleteKeyPrefix = "com.hustlexp.onboardingComplete."

    private static func onboardingStorageKey(for userId: String) -> String {
        onboardingCompleteKeyPrefix + userId
    }

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
        self.hasCompletedOnboarding = UserDefaults.standard.bool(
            forKey: Self.onboardingStorageKey(for: userId)
        )
        self.authState = hasCompletedOnboarding ? .authenticated : .onboarding
        HXLogger.info("[AppState] User logged in: \(userId), role: \(role.rawValue)", category: "Navigation")
    }
    
    func logout() {
        self.userId = nil
        self.userRole = nil
        self.isLoggedIn = false
        self.hasCompletedOnboarding = false
        self.authState = .unauthenticated
        self.selectedTab = 0
        HXLogger.info("[AppState] User logged out", category: "Navigation")
    }
    
    func completeOnboarding() {
        if let userId {
            UserDefaults.standard.set(true, forKey: Self.onboardingStorageKey(for: userId))
        }
        self.hasCompletedOnboarding = true
        self.authState = .authenticated
        HXLogger.info("[AppState] Onboarding completed", category: "Navigation")
    }
    
    func setRole(_ role: UserRole) {
        self.userRole = role
        HXLogger.info("[AppState] Role set to: \(role.rawValue)", category: "Navigation")
    }
}
