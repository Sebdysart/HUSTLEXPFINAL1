//
//  UIService.swift
//  hustleXP final1
//
//  Real tRPC service for UI compliance and animation tracking
//  Maps to backend ui.ts router
//
//  Provides:
//  - XP celebration status and marking
//  - Badge animation status and marking
//  - UI violation reporting
//

import Foundation
import Combine

// MARK: - UI Response Types

/// XP celebration status from backend
struct XPCelebrationStatus: Codable {
    let shouldShow: Bool
    let xpFirstCelebrationShownAt: String?
}

/// Response from marking XP celebration shown
struct XPCelebrationMarkResponse: Codable {
    let success: Bool
    let xpFirstCelebrationShownAt: String?
    let alreadyShown: Bool
}

/// Badge animation status from backend
struct BadgeAnimationStatus: Codable {
    let shouldShow: Bool
    let animationShownAt: String?
}

/// Response from marking badge animation shown
struct BadgeAnimationMarkResponse: Codable {
    let success: Bool
    let animationShownAt: String?
    let alreadyShown: Bool
}

/// UI violation type matching backend enum
enum UIViolationType: String, Codable {
    case color = "COLOR"
    case animation = "ANIMATION"
    case copy = "COPY"
    case accessibility = "ACCESSIBILITY"
    case state = "STATE"
}

/// UI violation severity
enum UIViolationSeverity: String, Codable {
    case error = "ERROR"
    case warning = "WARNING"
}

/// Response from reporting a violation
struct ViolationReportResponse: Codable {
    let success: Bool
    let loggedAt: String
}

// MARK: - UI Service

/// Manages UI compliance and animation tracking via tRPC
@MainActor
final class UIService: ObservableObject {
    static let shared = UIService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - XP Celebration

    /// Checks if first XP celebration should be shown
    func getXPCelebrationStatus() async throws -> XPCelebrationStatus {
        struct EmptyInput: Codable {}

        let status: XPCelebrationStatus = try await trpc.call(
            router: "ui",
            procedure: "getXPCelebrationStatus",
            type: .query,
            input: EmptyInput()
        )

        print("✅ UIService: XP celebration shouldShow = \(status.shouldShow)")
        return status
    }

    /// Marks first XP celebration as shown
    func markXPCelebrationShown(timestamp: String? = nil) async throws -> XPCelebrationMarkResponse {
        struct MarkInput: Codable {
            let timestamp: String?
        }

        let response: XPCelebrationMarkResponse = try await trpc.call(
            router: "ui",
            procedure: "markXPCelebrationShown",
            input: MarkInput(timestamp: timestamp)
        )

        print("✅ UIService: Marked XP celebration shown (alreadyShown: \(response.alreadyShown))")
        return response
    }

    // MARK: - Badge Animation

    /// Checks if badge animation should be shown for a specific badge
    func getBadgeAnimationStatus(badgeId: String) async throws -> BadgeAnimationStatus {
        struct BadgeInput: Codable {
            let badgeId: String
        }

        let status: BadgeAnimationStatus = try await trpc.call(
            router: "ui",
            procedure: "getBadgeAnimationStatus",
            type: .query,
            input: BadgeInput(badgeId: badgeId)
        )

        print("✅ UIService: Badge animation shouldShow = \(status.shouldShow) for badge \(badgeId)")
        return status
    }

    /// Marks badge animation as shown
    func markBadgeAnimationShown(badgeId: String, timestamp: String? = nil) async throws -> BadgeAnimationMarkResponse {
        struct MarkBadgeInput: Codable {
            let badgeId: String
            let timestamp: String?
        }

        let response: BadgeAnimationMarkResponse = try await trpc.call(
            router: "ui",
            procedure: "markBadgeAnimationShown",
            input: MarkBadgeInput(badgeId: badgeId, timestamp: timestamp)
        )

        print("✅ UIService: Marked badge animation shown for \(badgeId) (alreadyShown: \(response.alreadyShown))")
        return response
    }

    // MARK: - Violation Reporting

    /// Reports a UI_SPEC violation for monitoring and compliance
    func reportViolation(
        type: UIViolationType,
        rule: String,
        component: String,
        context: [String: String],
        severity: UIViolationSeverity = .error
    ) async throws -> ViolationReportResponse {
        struct ViolationInput: Codable {
            let type: String
            let rule: String
            let component: String
            let context: [String: String]
            let severity: String
        }

        let response: ViolationReportResponse = try await trpc.call(
            router: "ui",
            procedure: "reportViolation",
            input: ViolationInput(
                type: type.rawValue,
                rule: rule,
                component: component,
                context: context,
                severity: severity.rawValue
            )
        )

        print("✅ UIService: Reported \(severity.rawValue) violation in \(component)")
        return response
    }
}
