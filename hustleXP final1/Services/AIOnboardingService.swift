//
//  AIOnboardingService.swift
//  hustleXP final1
//
//  Real tRPC service for AI-powered onboarding and role calibration
//  Maps to backend ai.ts router
//

import Foundation
import Combine

// MARK: - AI Onboarding Types

struct CalibrationResult: Codable {
    let sessionId: String
    let inferredRole: String?
    let confidence: Double?
    let status: String
}

struct InferenceResult: Codable {
    let inferredRole: String?
    let confidence: Double?
    let traits: [String]?
    let suggestedMode: String?
    let status: String
}

struct RoleConfirmation: Codable {
    let userId: String
    let confirmedMode: String
    let onboardingComplete: Bool
}

// MARK: - AI Onboarding Service

/// Handles AI-driven onboarding calibration via tRPC
@MainActor
final class AIOnboardingService: ObservableObject {
    static let shared = AIOnboardingService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Submit calibration prompt for role inference
    func submitCalibration(
        calibrationPrompt: String,
        onboardingVersion: String = "1.0"
    ) async throws -> CalibrationResult {
        isLoading = true
        defer { isLoading = false }

        struct CalibrationInput: Codable {
            let calibrationPrompt: String
            let onboardingVersion: String
        }

        let result: CalibrationResult = try await trpc.call(
            router: "ai",
            procedure: "submitCalibration",
            input: CalibrationInput(
                calibrationPrompt: calibrationPrompt,
                onboardingVersion: onboardingVersion
            )
        )

        print("✅ AIOnboarding: Submitted calibration, status: \(result.status)")
        return result
    }

    /// Get the AI inference result for the current user
    func getInferenceResult() async throws -> InferenceResult {
        isLoading = true
        defer { isLoading = false }

        struct EmptyInput: Codable {}

        let result: InferenceResult = try await trpc.call(
            router: "ai",
            procedure: "getInferenceResult",
            type: .query,
            input: EmptyInput()
        )

        print("✅ AIOnboarding: Inferred role: \(result.inferredRole ?? "pending")")
        return result
    }

    /// Confirm the user's role and complete onboarding
    func confirmRole(
        confirmedMode: String,
        overrideAI: Bool = false
    ) async throws -> RoleConfirmation {
        isLoading = true
        defer { isLoading = false }

        struct ConfirmInput: Codable {
            let confirmedMode: String
            let overrideAI: Bool
        }

        let result: RoleConfirmation = try await trpc.call(
            router: "ai",
            procedure: "confirmRole",
            input: ConfirmInput(
                confirmedMode: confirmedMode,
                overrideAI: overrideAI
            )
        )

        print("✅ AIOnboarding: Role confirmed as \(result.confirmedMode)")
        return result
    }
}
