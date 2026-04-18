//
//  EscrowService.swift
//  hustleXP final1
//
//  Real tRPC service for escrow and payment operations
//  Maps to backend escrow.ts router + EscrowService.ts
//
//  CORRECTED Mar 2026:
//  - EscrowState rawValues fixed to UPPERCASE (matching backend EscrowState)
//  - Escrow struct: "amount" (not "amountCents"), removed phantom fee fields
//  - XPAwardResult replaced with XPLedgerEntry (actual backend return type)
//

import Foundation
import Combine

// MARK: - Escrow State

/// Backend escrow state — must match EscrowState in types.ts (uppercase string values)
enum EscrowState: String, Codable, CaseIterable {
    case pending      = "PENDING"
    case funded       = "FUNDED"
    case lockedDispute = "LOCKED_DISPUTE"   // was "held" with rawValue "held" — CORRECTED
    case released     = "RELEASED"
    case refunded     = "REFUNDED"
    case refundPartial = "REFUND_PARTIAL"   // was "disputed" — CORRECTED

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = EscrowState(rawValue: raw) ?? .pending
    }
}

// MARK: - Escrow Model

/// Escrow DB row returned by all escrow.* procedures
/// Decoded with keyDecodingStrategy = .convertFromSnakeCase
struct Escrow: Codable, Identifiable {
    // Core fields (always present)
    let id: String
    let taskId: String                      // DB: task_id
    let amount: Int                         // DB: amount — USD cents (was "amountCents" — CORRECTED)
    let state: EscrowState

    // Partial refund tracking
    let refundAmount: Int?                  // DB: refund_amount
    let releaseAmount: Int?                 // DB: release_amount

    // Stripe references
    let stripePaymentIntentId: String?      // DB: stripe_payment_intent_id
    let stripeTransferId: String?           // DB: stripe_transfer_id
    let stripeRefundId: String?             // DB: stripe_refund_id

    // Joined from tasks table (only on escrow.getById — optional elsewhere)
    let posterId: String?                   // DB: poster_id (JOIN only — not on fund/release/refund)
    let workerId: String?                   // DB: worker_id (JOIN only)

    // Timestamps
    let fundedAt: Date?                     // DB: funded_at
    let releasedAt: Date?                   // DB: released_at
    let refundedAt: Date?                   // DB: refunded_at
    let createdAt: Date                     // DB: created_at
    let updatedAt: Date                     // DB: updated_at
}

// MARK: - Escrow UI Helpers (extension — not decoded from API)

extension Escrow {
    /// Amount in dollars (UI convenience)
    var amountDollars: Double { Double(amount) / 100.0 }

    /// Backward-compat alias (old field name was amountCents)
    var amountCents: Int { amount }
}

// MARK: - Payment Intent Response

/// Response from escrow.createPaymentIntent
struct PaymentIntentResponse: Codable {
    let escrowId: String
    let paymentIntentId: String
    let clientSecret: String
    let amountCents: Int                    // This procedure uses "amountCents" as field name
}

// MARK: - XP Ledger Entry

/// Returned by escrow.awardXP — maps to XPLedgerEntry in XPService.ts
/// Decoded with keyDecodingStrategy = .convertFromSnakeCase
struct XPLedgerEntry: Codable {
    let id: String
    let userId: String                      // DB: user_id
    let taskId: String                      // DB: task_id
    let escrowId: String                    // DB: escrow_id
    let baseXp: Int                         // DB: base_xp (was "amount" in old phantom struct)
    let streakMultiplier: Double            // DB: streak_multiplier
    let trustMultiplier: Double             // DB: trust_multiplier
    let liveModeMultiplier: Double          // DB: live_mode_multiplier (1.25× for Live tasks)
    let effectiveXp: Int                    // DB: effective_xp (baseXp × all multipliers)
    let reason: String
    let userXpBefore: Int                   // DB: user_xp_before
    let userXpAfter: Int                    // DB: user_xp_after
    let userLevelBefore: Int                // DB: user_level_before
    let userLevelAfter: Int                 // DB: user_level_after
    let userStreakAtAward: Int              // DB: user_streak_at_award
    let awardedAt: Date                     // DB: awarded_at
}

// MARK: - XPLedgerEntry UI Helpers (extension — not decoded from API)

extension XPLedgerEntry {
    /// Whether the user leveled up from this XP award
    var didLevelUp: Bool { userLevelAfter > userLevelBefore }
    /// Net XP gain
    var xpGained: Int { userXpAfter - userXpBefore }
}

// MARK: - Service

/// Manages all escrow and payment operations via tRPC
@MainActor
final class EscrowService: ObservableObject {
    static let shared = EscrowService(client: TRPCClient.shared)

    private let trpc: TRPCClientProtocol

    @Published var isLoading = false
    @Published var error: Error?

    init(client: TRPCClientProtocol) {
        self.trpc = client
    }

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

        HXLogger.info("EscrowService: Created payment intent for task \(taskId)", category: "Payment")
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

        HXLogger.info("EscrowService: Confirmed funding for escrow \(escrow.id)", category: "Payment")
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

    /// Gets escrow details by escrow ID (returns posterId/workerId via JOIN)
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

    // MARK: - Payout (Worker receives)

    /// Releases escrow funds to worker after task completion.
    /// Creates the Stripe transfer and releases escrow in one call.
    func releaseToWorker(escrowId: String) async throws -> Escrow {
        isLoading = true
        defer { isLoading = false }

        struct ReleaseInput: Codable {
            let escrowId: String
        }

        let escrow: Escrow = try await trpc.call(
            router: "escrow",
            procedure: "releaseToWorker",
            input: ReleaseInput(escrowId: escrowId)
        )

        HXLogger.info("EscrowService: Released escrow \(escrow.id) to worker", category: "Payment")
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

        HXLogger.info("EscrowService: Refunded escrow \(escrow.id) to poster", category: "Payment")
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

        HXLogger.info("EscrowService: Fetched \(escrows.count) payment records", category: "Payment")
        return escrows
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

        HXLogger.info("EscrowService: Locked escrow \(escrow.id) for dispute", category: "Payment")
        return escrow
    }

    // MARK: - XP Award

    /// Awards XP after escrow release
    /// INV-1: Will fail if escrow is not RELEASED
    /// INV-5: Will fail if XP already awarded for this escrow
    func awardXP(taskId: String, escrowId: String, baseXP: Int) async throws -> XPLedgerEntry {
        isLoading = true
        defer { isLoading = false }

        struct AwardXPInput: Codable {
            let taskId: String
            let escrowId: String
            let baseXP: Int
        }

        let entry: XPLedgerEntry = try await trpc.call(
            router: "escrow",
            procedure: "awardXP",
            input: AwardXPInput(taskId: taskId, escrowId: escrowId, baseXP: baseXP)
        )

        HXLogger.info("EscrowService: Awarded \(entry.effectiveXp) XP for escrow \(escrowId)", category: "Payment")
        return entry
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
