//
//  JuryService.swift
//  hustleXP final1
//
//  Real tRPC service for community dispute resolution via jury voting
//  Maps to backend jury.ts router
//

import Foundation
import Combine

// MARK: - Jury Types

enum JuryVote: String, Codable {
    case workerComplete = "worker_complete"
    case workerIncomplete = "worker_incomplete"
    case inconclusive = "inconclusive"

    /// Safe decode — unknown values default to .inconclusive
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = JuryVote(rawValue: raw) ?? .inconclusive
    }
}

struct VoteResult: Codable {
    let disputeId: String
    let voteRecorded: Bool
}

struct VoteTally: Codable {
    let disputeId: String
    let workerComplete: Int
    let workerIncomplete: Int
    let inconclusive: Int
    let totalVotes: Int
    let resolved: Bool
    let resolution: String?
}

// MARK: - Jury Service

/// Handles jury pool dispute resolution via tRPC
@MainActor
final class JuryService: ObservableObject {
    static let shared = JuryService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Submit a jury vote for a dispute
    func submitVote(
        disputeId: String,
        vote: JuryVote,
        confidence: Double
    ) async throws -> VoteResult {
        isLoading = true
        defer { isLoading = false }

        struct VoteInput: Codable {
            let disputeId: String
            let vote: String
            let confidence: Double
        }

        let result: VoteResult = try await trpc.call(
            router: "jury",
            procedure: "submitVote",
            input: VoteInput(
                disputeId: disputeId,
                vote: vote.rawValue,
                confidence: confidence
            )
        )

        print("✅ JuryService: Vote submitted for dispute \(disputeId)")
        return result
    }

    /// Get the vote tally for a dispute
    func getVoteTally(disputeId: String) async throws -> VoteTally {
        isLoading = true
        defer { isLoading = false }

        struct TallyInput: Codable {
            let disputeId: String
        }

        let tally: VoteTally = try await trpc.call(
            router: "jury",
            procedure: "getVoteTally",
            type: .query,
            input: TallyInput(disputeId: disputeId)
        )

        print("✅ JuryService: Tally for \(disputeId) - \(tally.totalVotes) votes")
        return tally
    }
}
