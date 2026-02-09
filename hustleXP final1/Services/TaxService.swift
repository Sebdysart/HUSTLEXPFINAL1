//
//  TaxService.swift
//  hustleXP final1
//
//  Real tRPC service for XP tax and insurance operations
//  Uses existing models from Models/TaxStatus.swift and Models/InsuranceClaim.swift
//

import Foundation
import Combine

/// Manages XP tax operations via tRPC
@MainActor
final class TaxService: ObservableObject {
    static let shared = TaxService()

    private let trpc = TRPCClient.shared

    @Published var currentStatus: TaxStatus?
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Tax Status

    /// Gets current tax status for user
    func getTaxStatus() async throws -> TaxStatus {
        isLoading = true
        defer { isLoading = false }

        struct EmptyInput: Codable {}

        let status: TaxStatus = try await trpc.call(
            router: "xpTax",
            procedure: "getTaxStatus",
            input: EmptyInput()
        )

        self.currentStatus = status
        print("✅ TaxService: Tax status - \(status.formattedUnpaidAmount) owed, \(status.xpHeldBack) XP held")
        return status
    }

    // MARK: - Tax Payment

    /// Creates payment intent for tax payment
    func createTaxPaymentIntent() async throws -> PaymentIntentResponse {
        isLoading = true
        defer { isLoading = false }

        struct EmptyInput: Codable {}

        let response: PaymentIntentResponse = try await trpc.call(
            router: "xpTax",
            procedure: "createPaymentIntent",
            input: EmptyInput()
        )

        print("✅ TaxService: Created tax payment intent")
        return response
    }

    /// Records tax payment after Stripe success
    func payTax(paymentIntentId: String) async throws -> TaxPaymentResult {
        isLoading = true
        defer { isLoading = false }

        struct PayInput: Codable {
            let paymentIntentId: String
        }

        let result: TaxPaymentResult = try await trpc.call(
            router: "xpTax",
            procedure: "payTax",
            input: PayInput(paymentIntentId: paymentIntentId)
        )

        // Update cached status
        self.currentStatus = result.newTaxStatus

        print("✅ TaxService: Paid taxes, released \(result.xpReleased) XP")
        return result
    }

    // MARK: - Tax History

    /// Gets tax ledger entries (history)
    func getTaxHistory(limit: Int = 50) async throws -> [TaxLedgerEntry] {
        struct HistoryInput: Codable {
            let limit: Int
        }

        let entries: [TaxLedgerEntry] = try await trpc.call(
            router: "xpTax",
            procedure: "getTaxHistory",
            input: HistoryInput(limit: limit)
        )

        print("✅ TaxService: Fetched \(entries.count) tax entries")
        return entries
    }
}

// MARK: - Insurance Service

/// Manages insurance pool operations via tRPC
/// Uses existing InsurancePoolStatus and InsuranceClaim models from Models/InsuranceClaim.swift
@MainActor
final class InsuranceService: ObservableObject {
    static let shared = InsuranceService()

    private let trpc = TRPCClient.shared

    @Published var poolStatus: InsurancePoolStatus?
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Pool Status

    /// Gets insurance pool status
    func getPoolStatus() async throws -> InsurancePoolStatus {
        struct EmptyInput: Codable {}

        let status: InsurancePoolStatus = try await trpc.call(
            router: "insurance",
            procedure: "getPoolStatus",
            input: EmptyInput()
        )

        self.poolStatus = status
        print("✅ InsuranceService: Pool has \(status.formattedPoolBalance)")
        return status
    }

    // MARK: - File Claim

    /// Files an insurance claim using FileClaimRequest
    func fileClaim(request: FileClaimRequest) async throws -> InsuranceClaim {
        guard request.isValid else {
            throw InsuranceError.invalidRequest(request.validationErrors.first ?? "Invalid request")
        }

        isLoading = true
        defer { isLoading = false }

        struct FileClaimInput: Codable {
            let taskId: String
            let incidentDescription: String
            let requestedAmountCents: Int
        }

        let claim: InsuranceClaim = try await trpc.call(
            router: "insurance",
            procedure: "fileClaim",
            input: FileClaimInput(
                taskId: request.taskId,
                incidentDescription: request.incidentDescription,
                requestedAmountCents: request.requestedAmountCents
            )
        )

        print("✅ InsuranceService: Filed claim for \(claim.formattedRequestedAmount)")
        return claim
    }

    // MARK: - Claims History

    /// Gets user's claims history
    func getMyClaims(limit: Int = 50) async throws -> [InsuranceClaim] {
        struct GetClaimsInput: Codable {
            let limit: Int
        }

        let claims: [InsuranceClaim] = try await trpc.call(
            router: "insurance",
            procedure: "getMyClaims",
            input: GetClaimsInput(limit: limit)
        )

        print("✅ InsuranceService: Fetched \(claims.count) claims")
        return claims
    }

    /// Gets claim by ID
    func getClaim(claimId: String) async throws -> InsuranceClaim {
        struct GetClaimInput: Codable {
            let claimId: String
        }

        let claim: InsuranceClaim = try await trpc.call(
            router: "insurance",
            procedure: "getById",
            input: GetClaimInput(claimId: claimId)
        )

        return claim
    }
}

// MARK: - Insurance Errors

enum InsuranceError: Error, LocalizedError {
    case invalidRequest(String)

    var errorDescription: String? {
        switch self {
        case .invalidRequest(let message):
            return message
        }
    }
}
