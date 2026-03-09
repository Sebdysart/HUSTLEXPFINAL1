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

    static let premiumBenefits = [
        "100% coverage (vs 80% basic)",
        "$10,000 max claim (vs $5,000)",
        "Priority claim processing",
        "Dedicated support line",
    ]

    static let premiumPriceCents = 999 // $9.99/month

    func loadCurrentTier() async {
        await MainActor.run { isLoading = true }
        await MainActor.run {
            self.currentTier = "basic"
            self.coveragePercent = 80.0
            self.maxClaimCents = 500000
            self.error = nil
            self.isLoading = false
        }
    }

    /// Starts a premium insurance upgrade. Returns (clientSecret, subscriptionRecordId) for payment.
    func upgradeToPremium() async -> (clientSecret: String, subscriptionRecordId: String?)? {
        await MainActor.run { isLoading = true }
        await MainActor.run {
            self.error = "Premium insurance upgrade is not available in the current backend contract."
            self.isLoading = false
        }
        return nil
    }

    /// Confirms the premium insurance upgrade after Stripe payment succeeds.
    /// Two-step pattern: server verifies Stripe subscription status before activating.
    func confirmUpgrade(subscriptionRecordId: String, stripeSubscriptionId: String) async -> Bool {
        await MainActor.run { isLoading = true }
        await MainActor.run {
            self.error = "Premium insurance upgrade confirmation is not available in the current backend contract."
            self.isLoading = false
        }
        return false
    }
}
