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
            input: GetStateInput(escrowId: escrowId)
        )

        return response.state
    }

    // MARK: - Payout (Worker receives)

    /// Releases escrow funds to worker after task completion
    /// Called automatically by backend when poster approves proof
    func releaseToWorker(escrowId: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct ReleaseInput: Codable {
            let escrowId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "release",
            input: ReleaseInput(escrowId: escrowId)
        )

        print("✅ EscrowService: Released escrow \(escrow.id) to worker")
        return escrow
    }

    // MARK: - Refund (Poster receives back)

    /// Refunds escrow to poster (e.g., task cancelled)
    func refundToPoster(escrowId: String, reason: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct RefundInput: Codable {
            let escrowId: String
            let reason: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "refund",
            input: RefundInput(escrowId: escrowId, reason: reason)
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
            input: HistoryInput(limit: limit)
        )

        print("✅ EscrowService: Fetched \(escrows.count) payment records")
        return escrows
    }
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
