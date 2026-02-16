//
//  PricingService.swift
//  hustleXP final1
//
//  Real tRPC service for dynamic pricing
//  Maps to backend pricing.ts router
//

import Foundation
import Combine

// MARK: - Pricing Types

struct PriceCalculation: Codable {
    let finalPriceCents: Int
    let basePriceCents: Int
    let surgeMultiplier: Double?
    let asapPremiumCents: Int?
    let workerModifierPercent: Int?
    let breakdown: [String: Int]?
}

struct WorkerModifierResult: Codable {
    let userId: String
    let modifierPercent: Int
    let updatedAt: Date
}

// MARK: - Pricing Service

/// Handles dynamic pricing via tRPC
@MainActor
final class PricingService: ObservableObject {
    static let shared = PricingService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Calculate the dynamic price for a task
    func calculatePrice(
        basePriceCents: Int,
        mode: String = "STANDARD",
        category: String? = nil,
        locationLat: Double? = nil,
        locationLng: Double? = nil,
        isASAP: Bool? = nil
    ) async throws -> PriceCalculation {
        isLoading = true
        defer { isLoading = false }

        struct CalculateInput: Codable {
            let basePriceCents: Int
            let mode: String
            let category: String?
            let locationLat: Double?
            let locationLng: Double?
            let isASAP: Bool?
        }

        let result: PriceCalculation = try await trpc.call(
            router: "pricing",
            procedure: "calculate",
            type: .query,
            input: CalculateInput(
                basePriceCents: basePriceCents,
                mode: mode,
                category: category,
                locationLat: locationLat,
                locationLng: locationLng,
                isASAP: isASAP
            )
        )

        HXLogger.info("PricingService: Calculated price \(result.finalPriceCents) cents", category: "Payment")
        return result
    }

    /// Update the current worker's price modifier (IC Compliance)
    func updateMyModifier(modifierPercent: Int) async throws -> WorkerModifierResult {
        isLoading = true
        defer { isLoading = false }

        struct ModifierInput: Codable {
            let modifierPercent: Int
        }

        let result: WorkerModifierResult = try await trpc.call(
            router: "pricing",
            procedure: "updateMyModifier",
            input: ModifierInput(modifierPercent: modifierPercent)
        )

        HXLogger.info("PricingService: Updated modifier to \(modifierPercent)%", category: "Payment")
        return result
    }
}
