//
//  EscrowService.swift
//  hustleXP final1
//
//  Real tRPC service for escrow and payment operations
//  Integrates with Stripe via backend
//

import Foundation
import Combine

/// Escrow states matching backend
enum EscrowState: String, Codable {
    case pending = "pending"
    case funded = "funded"
    case held = "held"
    case released = "released"
    case refunded = "refunded"
    case disputed = "disputed"

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = EscrowState(rawValue: raw) ?? .pending
    }
}

/// Escrow record from backend
struct Escrow: Codable, Identifiable {
    let id: String
    let taskId: String
    let posterId: String
    let workerId: String?
    let amountCents: Int
    let platformFeeCents: Int
    let taxWithholdingCents: Int
    let insuranceContributionCents: Int
    let state: EscrowState
    let stripePaymentIntentId: String?
    let createdAt: Date
    let fundedAt: Date?
    let releasedAt: Date?

    var amount: Double {
        Double(amountCents) / 100.0
    }

    var platformFee: Double {
        Double(platformFeeCents) / 100.0
    }

    var workerPayout: Double {
        Double(amountCents - platformFeeCents - taxWithholdingCents - insuranceContributionCents) / 100.0
    }
}

/// Payment intent response for Stripe
struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let paymentIntentId: String
    let amountCents: Int
    let escrowId: String
}

/// Manages all escrow and payment operations via tRPC
@MainActor
final class EscrowService: ObservableObject {
    static let shared = EscrowService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Payment Intent (Poster pays)

    /// Creates a Stripe PaymentIntent for funding escrow
    /// Returns clientSecret for Stripe SDK
    func createPaymentIntent(taskId: String) async throws -> PaymentIntentResponse {
        isLoading = true
        defer { isLoading = false }

        struct CreateInput: Codable {
            let taskId: String
        }

        let response: PaymentIntentResponse = try await trpc.call(
            router: "escrow",
            procedure: "createPaymentIntent",
            input: CreateInput(taskId: taskId)
        )

        print("✅ EscrowService: Created payment intent for task \(taskId)")
        return response
    }

    /// Confirms escrow is funded after Stripe payment succeeds
    func confirmFunding(escrowId: String, stripePaymentIntentId: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct ConfirmInput: Codable {
            let escrowId: String
            let stripePaymentIntentId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "confirmFunding",
            input: ConfirmInput(escrowId: escrowId, stripePaymentIntentId: stripePaymentIntentId)
        )

        print("✅ EscrowService: Confirmed funding for escrow \(escrow.id)")
        return escrow
    }

    // MARK: - Escrow Queries

    /// Gets escrow details for a task
    func getEscrowByTask(taskId: String) async throws -> Escrow {
        struct GetInput: Codable {
            let taskId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "getByTaskId",
            type: .query,
            input: GetInput(taskId: taskId)
        )

        return escrow
    }

    /// Gets escrow state
    func getEscrowState(escrowId: String) async throws -> EscrowState {
        struct GetStateInput: Codable {
            let escrowId: String
        }

        struct StateResponse: Codable {
            let state: EscrowState
        }

        let response: StateResponse = try await trpc.call(
            router: "escrow",
            procedure: "getState",
            type: .query,
            input: GetStateInput(escrowId: escrowId)
        )

        return response.state
    }

    // MARK: - Payout (Worker receives)

    /// Releases escrow funds to worker after task completion
    /// Called automatically by backend when poster approves proof
    func releaseToWorker(escrowId: String, stripeTransferId: String? = nil) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct ReleaseInput: Codable {
            let escrowId: String
            let stripeTransferId: String?
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "release",
            input: ReleaseInput(escrowId: escrowId, stripeTransferId: stripeTransferId)
        )

        print("✅ EscrowService: Released escrow \(escrow.id) to worker")
        return escrow
    }

    // MARK: - Refund (Poster receives back)

    /// Refunds escrow to poster (e.g., task cancelled)
    func refundToPoster(escrowId: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct RefundInput: Codable {
            let escrowId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "refund",
            input: RefundInput(escrowId: escrowId)
        )

        print("✅ EscrowService: Refunded escrow \(escrow.id) to poster")
        return escrow
    }

    // MARK: - Transaction History

    /// Gets escrow/payment history for current user
    func getPaymentHistory(limit: Int = 50) async throws -> [Escrow] {
        struct HistoryInput: Codable {
            let limit: Int
        }

        let escrows: [Escrow] = try await trpc.call(
            router: "escrow",
            procedure: "getHistory",
            type: .query,
            input: HistoryInput(limit: limit)
        )

        print("✅ EscrowService: Fetched \(escrows.count) payment records")
        return escrows
    }

    // MARK: - Get By ID

    /// Gets escrow details by escrow ID
    /// Only poster or worker of the associated task can view
    func getById(escrowId: String) async throws -> Escrow {
        struct GetByIdInput: Codable {
            let escrowId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "getById",
            type: .query,
            input: GetByIdInput(escrowId: escrowId)
        )

        return escrow
    }

    // MARK: - Dispute Lock

    /// Locks escrow for dispute resolution
    func lockForDispute(escrowId: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct LockInput: Codable {
            let escrowId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "lockForDispute",
            input: LockInput(escrowId: escrowId)
        )

        print("✅ EscrowService: Locked escrow \(escrow.id) for dispute")
        return escrow
    }

    // MARK: - XP Award

    /// Awards XP after escrow release
    /// INV-1: Will fail if escrow is not RELEASED
    /// INV-5: Will fail if XP already awarded for this escrow
    func awardXP(taskId: String, escrowId: String, baseXP: Int) async throws -> XPAwardResult {
        isLoading = true
        defer { isLoading = false }

        struct AwardXPInput: Codable {
            let taskId: String
            let escrowId: String
            let baseXP: Int
        }

        let result: XPAwardResult = try await trpc.call(
            router: "escrow",
            procedure: "awardXP",
            input: AwardXPInput(taskId: taskId, escrowId: escrowId, baseXP: baseXP)
        )

        print("✅ EscrowService: Awarded XP for escrow \(escrowId)")
        return result
    }
}

/// XP award result from escrow
struct XPAwardResult: Codable {
    let xpAwarded: Int
    let newTotalXP: Int
    let bonusXP: Int?
    let tierUp: Bool?
}

// MARK: - Stripe Integration Helper

/// Helper for integrating with Stripe iOS SDK
struct StripeIntegration {
    /// Prepares payment sheet configuration
    /// Use the clientSecret from createPaymentIntent with Stripe's PaymentSheet
    static func configurePaymentSheet(
        clientSecret: String,
        merchantDisplayName: String = "HustleXP"
    ) -> [String: Any] {
        return [
            "paymentIntentClientSecret": clientSecret,
            "merchantDisplayName": merchantDisplayName,
            "applePay": [
                "merchantCountryCode": "US"
            ],
            "style": "alwaysDark"
        ]
    }
}
