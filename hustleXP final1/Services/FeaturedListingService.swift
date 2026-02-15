//
//  FeaturedListingService.swift
//  hustleXP final1
//
//  Manages promoted/featured task listings
//

import SwiftUI
import Combine

class FeaturedListingService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?

    private let trpc = TRPCClient.shared

    // MARK: - Codable models

    private struct PromoteInput: Codable {
        let taskId: String
        let featureType: String
    }

    private struct PromoteResponse: Codable {
        let clientSecret: String
        let listingId: String?
    }

    private struct ConfirmPromotionInput: Codable {
        let listingId: String
        let stripePaymentIntentId: String
    }

    private struct ConfirmResponse: Codable {
        let success: Bool?
    }

    struct FeatureOption {
        let type: String
        let label: String
        let description: String
        let priceCents: Int
        let durationHours: Int
        let icon: String
    }

    static let options: [FeatureOption] = [
        FeatureOption(type: "promoted", label: "Promote", description: "Appear at top of feed for 24 hours", priceCents: 299, durationHours: 24, icon: "arrow.up.circle.fill"),
        FeatureOption(type: "highlighted", label: "Highlight", description: "Gold border + badge for 48 hours", priceCents: 499, durationHours: 48, icon: "star.circle.fill"),
        FeatureOption(type: "urgent_boost", label: "Urgent Boost", description: "Push notification to nearby hustlers", priceCents: 799, durationHours: 12, icon: "bolt.circle.fill"),
    ]

    /// Creates a featured listing and returns a Stripe clientSecret for payment.
    func promoteTask(taskId: String, featureType: String) async -> String? {
        await MainActor.run { isLoading = true }

        do {
            let result: PromoteResponse = try await trpc.call(
                router: "featured",
                procedure: "promoteTask",
                input: PromoteInput(taskId: taskId, featureType: featureType)
            )
            await MainActor.run { isLoading = false }
            return result.clientSecret
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return nil
        }
    }

    /// Confirms a promotion after Stripe payment succeeds.
    func confirmPromotion(listingId: String, stripePaymentIntentId: String) async -> Bool {
        await MainActor.run { isLoading = true }

        do {
            let _: ConfirmResponse = try await trpc.call(
                router: "featured",
                procedure: "confirmPromotion",
                input: ConfirmPromotionInput(
                    listingId: listingId,
                    stripePaymentIntentId: stripePaymentIntentId
                )
            )
            await MainActor.run { isLoading = false }
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
