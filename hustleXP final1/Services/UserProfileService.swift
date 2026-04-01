//
//  UserProfileService.swift
//  hustleXP final1
//
//  Real tRPC service for user profile operations beyond auth
//  Maps to backend user.ts router: xpHistory, badges, verification, profile updates
//
//  Uses existing models from:
//  - Models/VerificationStatus.swift (VerificationUnlockStatus, VerificationEarningsEntry)
//

import Foundation
import Combine

// MARK: - XP History Types

/// XP ledger entry from backend
struct XPHistoryEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let amount: Int
    let reason: String
    let taskId: String?
    let taskTitle: String?
    let createdAt: Date

    /// Formatted XP amount with sign
    var formattedAmount: String {
        amount >= 0 ? "+\(amount) XP" : "\(amount) XP"
    }
}

// MARK: - Badge Types

/// User badge from backend
struct UserBadge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String?
    let tier: String?
    let earnedAt: Date
    let criteria: String?
}

// MARK: - Onboarding Types

/// Onboarding status from backend (user.getOnboardingStatus)
/// Field names match the backend response exactly.
struct OnboardingStatus: Codable {
    /// Whether the user has completed the onboarding flow.
    let onboardingComplete: Bool
    /// User's primary role: "hustler" or "poster" (backend maps worker→hustler).
    let role: String
    /// Whether the user has completed their first task (XP celebration milestone).
    let hasCompletedFirstTask: Bool
    /// ISO-8601 timestamp of when the XP first-task celebration was shown, or nil.
    let xpFirstCelebrationShownAt: String?
}

// MARK: - Role Certainty Tier

/// Backend-validated enum for role certainty after calibration.
/// Backend uses z.enum(['STRONG', 'MODERATE', 'WEAK']) — sending any other value → 400.
enum RoleCertaintyTier: String, Codable {
    case strong   = "STRONG"
    case moderate = "MODERATE"
    case weak     = "WEAK"
}

// MARK: - User Profile Service

/// Manages user profile operations via tRPC
/// Separate from AuthService to handle non-auth profile features
@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService(client: TRPCClient.shared)

    private let trpc: TRPCClientProtocol

    @Published var xpHistory: [XPHistoryEntry] = []
    @Published var badges: [UserBadge] = []
    @Published var verificationStatus: VerificationUnlockStatus?
    @Published var isLoading = false
    @Published var error: Error?

    init(client: TRPCClientProtocol) {
        self.trpc = client
    }

    // MARK: - Profile Updates

    /// Updates user profile fields
    func updateProfile(
        name: String? = nil,
        bio: String? = nil,
        phone: String? = nil,
        avatarURL: String? = nil
    ) async throws -> HXUser {
        isLoading = true
        defer { isLoading = false }

        struct UpdateProfileInput: Codable {
            let fullName: String?
            let bio: String?
            let phone: String?
            let avatarUrl: String?
        }

        let user: HXUser = try await trpc.call(
            router: "user",
            procedure: "updateProfile",
            input: UpdateProfileInput(fullName: name, bio: bio, phone: phone, avatarUrl: avatarURL)
        )

        // Update AuthService's current user
        AuthService.shared.currentUser = user

        HXLogger.info("UserProfileService: Updated profile", category: "General")
        return user
    }

    /// Gets a public user profile by ID
    func getUser(id: String) async throws -> HXUser {
        struct GetByIdInput: Codable {
            let userId: String
        }

        let user: HXUser = try await trpc.call(
            router: "user",
            procedure: "getById",
            type: .query,
            input: GetByIdInput(userId: id)
        )

        return user
    }

    // MARK: - XP History

    /// Gets XP history for current user
    func getXPHistory(limit: Int = 50) async throws -> [XPHistoryEntry] {
        struct HistoryInput: Codable {
            let limit: Int
        }

        let entries: [XPHistoryEntry] = try await trpc.call(
            router: "user",
            procedure: "xpHistory",
            type: .query,
            input: HistoryInput(limit: limit)
        )

        self.xpHistory = entries
        HXLogger.info("UserProfileService: Fetched \(entries.count) XP history entries", category: "General")
        return entries
    }

    // MARK: - Badges

    /// Gets badges for current user
    func getBadges() async throws -> [UserBadge] {
        struct EmptyInput: Codable {}

        let badges: [UserBadge] = try await trpc.call(
            router: "user",
            procedure: "badges",
            type: .query,
            input: EmptyInput()
        )

        self.badges = badges
        HXLogger.info("UserProfileService: Fetched \(badges.count) badges", category: "General")
        return badges
    }

    // MARK: - Verification

    /// Gets verification unlock status and progress
    /// Uses VerificationUnlockStatus from Models/VerificationStatus.swift
    func getVerificationUnlockStatus() async throws -> VerificationUnlockStatus {
        struct EmptyInput: Codable {}

        let status: VerificationUnlockStatus = try await trpc.call(
            router: "user",
            procedure: "getVerificationUnlockStatus",
            type: .query,
            input: EmptyInput()
        )

        self.verificationStatus = status
        HXLogger.info("UserProfileService: Verification \(status.unlocked ? "unlocked" : "locked") - \(Int(status.percentage))% complete", category: "General")
        return status
    }

    /// Checks if user has unlocked verification
    func checkVerificationEligibility() async throws -> Bool {
        struct EmptyInput: Codable {}

        struct EligibilityResponse: Codable {
            let isEligible: Bool
        }

        let response: EligibilityResponse = try await trpc.call(
            router: "user",
            procedure: "checkVerificationEligibility",
            type: .query,
            input: EmptyInput()
        )

        return response.isEligible
    }

    /// Gets verification earnings ledger
    /// Uses VerificationEarningsEntry from Models/VerificationStatus.swift
    func getVerificationEarningsLedger(limit: Int = 50) async throws -> [VerificationEarningsEntry] {
        struct LedgerInput: Codable {
            let limit: Int
        }

        let entries: [VerificationEarningsEntry] = try await trpc.call(
            router: "user",
            procedure: "getVerificationEarningsLedger",
            type: .query,
            input: LedgerInput(limit: limit)
        )

        HXLogger.info("UserProfileService: Fetched \(entries.count) verification earnings entries", category: "General")
        return entries
    }

    // MARK: - Onboarding

    /// Gets onboarding status
    func getOnboardingStatus() async throws -> OnboardingStatus {
        struct EmptyInput: Codable {}

        let status: OnboardingStatus = try await trpc.call(
            router: "user",
            procedure: "getOnboardingStatus",
            type: .query,
            input: EmptyInput()
        )

        return status
    }

    /// Marks onboarding as complete
    /// Backend expects: {version, roleConfidenceWorker, roleConfidencePoster, roleCertaintyTier, inconsistencyFlags?}
    func completeOnboarding(
        version: String = "1.0",
        roleConfidenceWorker: Double = 0.5,
        roleConfidencePoster: Double = 0.5,
        roleCertaintyTier: RoleCertaintyTier = .moderate,
        inconsistencyFlags: [String]? = nil
    ) async throws {
        struct CompleteOnboardingInput: Codable {
            let version: String
            let roleConfidenceWorker: Double
            let roleConfidencePoster: Double
            let roleCertaintyTier: RoleCertaintyTier
            let inconsistencyFlags: [String]?
        }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "user",
            procedure: "completeOnboarding",
            input: CompleteOnboardingInput(
                version: version,
                roleConfidenceWorker: roleConfidenceWorker,
                roleConfidencePoster: roleConfidencePoster,
                roleCertaintyTier: roleCertaintyTier,
                inconsistencyFlags: inconsistencyFlags
            )
        )

        HXLogger.info("UserProfileService: Onboarding completed", category: "General")
    }
}
