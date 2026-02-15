//
//  PremiumInsuranceService.swift
//  hustleXP final1
//
//  Manages premium insurance tier upgrades
//

import SwiftUI
import Combine

class PremiumInsuranceService: ObservableObject {
    @Published var currentTier: String = "basic" // basic or premium
    @Published var coveragePercent: Double = 80.0
    @Published var maxClaimCents: Int = 500000 // $5,000
    @Published var isLoading = false
    @Published var error: String?

    private let trpc = TRPCClient.shared

    // MARK: - Codable models

    private struct EmptyInput: Codable {}

    private struct TierResponse: Codable {
        let tier: String?
        let coveragePercent: Double?
        let maxClaimCents: Int?
    }

    private struct UpgradeResponse: Codable {
        let clientSecret: String
        let subscriptionId: String?
        let subscriptionRecordId: String?
    }

    private struct ConfirmUpgradeInput: Codable {
        let subscriptionRecordId: String
        let stripeSubscriptionId: String
    }

    private struct ConfirmUpgradeResponse: Codable {
        let success: Bool?
    }

    static let premiumBenefits = [
        "100% coverage (vs 80% basic)",
        "$10,000 max claim (vs $5,000)",
        "Priority claim processing",
        "Dedicated support line",
    ]

    static let premiumPriceCents = 999 // $9.99/month

    func loadCurrentTier() async {
        await MainActor.run { isLoading = true }

        do {
            let result: TierResponse = try await trpc.call(
                router: "insurance",
                procedure: "getCurrentTier",
                type: .query,
                input: EmptyInput()
            )

            await MainActor.run {
                self.currentTier = result.tier ?? "basic"
                self.coveragePercent = result.coveragePercent ?? 80.0
                self.maxClaimCents = result.maxClaimCents ?? 500000
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Starts a premium insurance upgrade. Returns (clientSecret, subscriptionRecordId) for payment.
    func upgradeToPremium() async -> (clientSecret: String, subscriptionRecordId: String?)? {
        await MainActor.run { isLoading = true }

        do {
            let result: UpgradeResponse = try await trpc.call(
                router: "insurance",
                procedure: "upgradeToPremium",
                input: EmptyInput()
            )

            await MainActor.run { isLoading = false }
            return (clientSecret: result.clientSecret, subscriptionRecordId: result.subscriptionRecordId)
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return nil
        }
    }

    /// Confirms the premium insurance upgrade after Stripe payment succeeds.
    /// Two-step pattern: server verifies Stripe subscription status before activating.
    func confirmUpgrade(subscriptionRecordId: String, stripeSubscriptionId: String) async -> Bool {
        await MainActor.run { isLoading = true }

        do {
            let _: ConfirmUpgradeResponse = try await trpc.call(
                router: "insurance",
                procedure: "confirmInsuranceUpgrade",
                input: ConfirmUpgradeInput(subscriptionRecordId: subscriptionRecordId, stripeSubscriptionId: stripeSubscriptionId)
            )

            await MainActor.run {
                self.currentTier = "premium"
                self.coveragePercent = 100.0
                self.maxClaimCents = 1000000
                self.isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        }
    }
}
