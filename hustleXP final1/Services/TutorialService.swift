//
//  TutorialService.swift
//  hustleXP final1
//
//  Real tRPC service for onboarding tutorial quest
//  Maps to backend tutorial.ts router
//
//  Provides:
//  - getScenarios: Fetch scenario cards for onboarding quiz
//  - submitAnswers: Submit quiz answers for scoring
//  - scanEquipment: Submit equipment photo for AI analysis
//

import Foundation
import Combine

// MARK: - Tutorial Types

/// A tutorial scenario action option
enum TutorialAction: String, Codable {
    case flagRisk = "flag_risk"
    case declineTask = "decline_task"
    case requestDetails = "request_details"
    case acceptTask = "accept_task"

    /// Safe decode — unknown values default to .requestDetails
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = TutorialAction(rawValue: raw) ?? .requestDetails
    }
}

/// A single answer to a tutorial scenario
struct TutorialAnswer: Codable {
    let scenarioId: String
    let action: TutorialAction
}

/// Tutorial scenario from backend
struct TutorialScenario: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let options: [TutorialOption]?
    let correctAction: String?
    let explanation: String?
}

/// Option within a tutorial scenario
struct TutorialOption: Codable {
    let action: String
    let label: String
    let description: String?
}

/// Result from submitting tutorial answers
struct TutorialSubmitResult: Codable {
    let score: Int
    let totalQuestions: Int
    let passed: Bool
    let feedback: [TutorialFeedback]?
}

/// Per-question feedback
struct TutorialFeedback: Codable {
    let scenarioId: String
    let correct: Bool
    let explanation: String?
}

/// Result from equipment scan
struct EquipmentScanResult: Codable {
    let detected: Bool
    let items: [DetectedEquipment]?
    let confidence: Double?
    let message: String?
}

/// A detected equipment item
struct DetectedEquipment: Codable, Identifiable {
    let id: String?
    let name: String
    let category: String?
    let confidence: Double?

    // Provide default ID if missing
    var stableId: String { id ?? name }
}

// MARK: - Tutorial Service

/// Manages onboarding tutorial quest via tRPC
@MainActor
final class TutorialService: ObservableObject {
    static let shared = TutorialService()

    private let trpc = TRPCClient.shared

    @Published var scenarios: [TutorialScenario] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Get Scenarios

    /// Fetches tutorial scenario cards for onboarding quiz
    func getScenarios() async throws -> [TutorialScenario] {
        isLoading = true
        defer { isLoading = false }

        struct EmptyInput: Codable {}

        let scenarios: [TutorialScenario] = try await trpc.call(
            router: "tutorial",
            procedure: "getScenarios",
            type: .query,
            input: EmptyInput()
        )

        self.scenarios = scenarios
        print("✅ TutorialService: Fetched \(scenarios.count) scenarios")
        return scenarios
    }

    // MARK: - Submit Answers

    /// Submits quiz answers and returns score/feedback
    func submitAnswers(answers: [TutorialAnswer]) async throws -> TutorialSubmitResult {
        isLoading = true
        defer { isLoading = false }

        struct SubmitInput: Codable {
            let answers: [TutorialAnswer]
        }

        let result: TutorialSubmitResult = try await trpc.call(
            router: "tutorial",
            procedure: "submitAnswers",
            input: SubmitInput(answers: answers)
        )

        print("✅ TutorialService: Submitted answers - score \(result.score)/\(result.totalQuestions)")
        return result
    }

    // MARK: - Scan Equipment

    /// Submits equipment photo URL for AI analysis
    func scanEquipment(photoUrl: String) async throws -> EquipmentScanResult {
        isLoading = true
        defer { isLoading = false }

        struct ScanInput: Codable {
            let photoUrl: String
        }

        let result: EquipmentScanResult = try await trpc.call(
            router: "tutorial",
            procedure: "scanEquipment",
            input: ScanInput(photoUrl: photoUrl)
        )

        print("✅ TutorialService: Equipment scan - detected: \(result.detected)")
        return result
    }
}
