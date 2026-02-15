//
//  SubscriptionService.swift
//  hustleXP final1
//
//  Manages subscription plans tied to recurring task limits.
//  Plans: Free (0 recurring), Premium (5 recurring), Pro (unlimited).
//

import SwiftUI

@MainActor
@Observable
final class SubscriptionService {

    // MARK: - Singleton

    static let shared = SubscriptionService()

    // MARK: - State

    var currentPlan: SubscriptionPlan = .free
    var expiresAt: Date?
    var recurringTaskCount: Int = 0
    var recurringTaskLimit: Int = 0
    var isLoading = false
    var error: String?

    private let trpc = TRPCClient.shared

    private init() {}

    // MARK: - Plan Definition

    enum SubscriptionPlan: String, Codable, CaseIterable {
        case free
        case premium
        case pro

        var displayName: String {
            switch self {
            case .free:    return "Free"
            case .premium: return "Premium"
            case .pro:     return "Pro"
            }
        }

        var recurringTaskLimit: Int {
            switch self {
            case .free:    return 0
            case .premium: return 5
            case .pro:     return 999
            }
        }

        var monthlyPriceCents: Int {
            switch self {
            case .free:    return 0
            case .premium: return 999
            case .pro:     return 1999
            }
        }

        var yearlyPriceCents: Int {
            switch self {
            case .free:    return 0
            case .premium: return 7999
            case .pro:     return 15999
            }
        }

        var icon: String {
            switch self {
            case .free:    return "person.crop.circle"
            case .premium: return "star.circle.fill"
            case .pro:     return "bolt.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .free:    return .textSecondary
            case .premium: return .brandPurple
            case .pro:     return .aiPurple
            }
        }
    }

    // MARK: - Codable Models

    private struct EmptyInput: Codable {}

    private struct SubscriptionResponse: Codable {
        let plan: String?
        let expiresAt: String?
        let recurringTaskCount: Int?
        let recurringTaskLimit: Int?
    }

    private struct SubscribeInput: Codable {
        let plan: String
        let interval: String // "monthly" or "yearly"
    }

    private struct SubscribeResponse: Codable {
        let clientSecret: String
        let subscriptionId: String?
    }

    private struct CancelResponse: Codable {
        let success: Bool?
    }

    private struct ConfirmInput: Codable {
        let stripeSubscriptionId: String
    }

    private struct ConfirmResponse: Codable {
        let success: Bool?
    }

    // MARK: - Computed

    var canCreateRecurringTask: Bool {
        recurringTaskCount < recurringTaskLimit
    }

    var isSubscribed: Bool {
        currentPlan != .free
    }

    var slotsDisplay: String {
        if currentPlan == .pro {
            return "Using \(recurringTaskCount) recurring task slots (unlimited)"
        }
        return "Using \(recurringTaskCount) of \(recurringTaskLimit) recurring task slots"
    }

    // MARK: - API Methods

    func fetchSubscription() async {
        isLoading = true
        error = nil

        do {
            let result: SubscriptionResponse = try await trpc.call(
                router: "subscription",
                procedure: "getMySubscription",
                type: .query,
                input: EmptyInput()
            )

            if let planStr = result.plan,
               let plan = SubscriptionPlan(rawValue: planStr) {
                currentPlan = plan
            } else {
                currentPlan = .free
            }

            recurringTaskCount = result.recurringTaskCount ?? 0
            recurringTaskLimit = result.recurringTaskLimit ?? currentPlan.recurringTaskLimit

            if let expiresStr = result.expiresAt {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expiresAt = formatter.date(from: expiresStr)
            }

            isLoading = false
            print("✅ SubscriptionService: Plan=\(currentPlan.rawValue), tasks=\(recurringTaskCount)/\(recurringTaskLimit)")
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            print("⚠️ SubscriptionService: fetchSubscription failed - \(error.localizedDescription)")
        }
    }

    /// Start a subscription. Returns a Stripe clientSecret for payment confirmation.
    func subscribe(plan: String, interval: String) async -> String? {
        isLoading = true
        error = nil

        do {
            let result: SubscribeResponse = try await trpc.call(
                router: "subscription",
                procedure: "subscribe",
                input: SubscribeInput(plan: plan, interval: interval)
            )

            isLoading = false
            print("✅ SubscriptionService: Got clientSecret for \(plan) (\(interval))")
            return result.clientSecret
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            print("⚠️ SubscriptionService: subscribe failed - \(error.localizedDescription)")
            return nil
        }
    }

    /// Cancel the current subscription.
    func cancel() async -> Bool {
        isLoading = true
        error = nil

        do {
            let _: CancelResponse = try await trpc.call(
                router: "subscription",
                procedure: "cancel",
                input: EmptyInput()
            )

            currentPlan = .free
            recurringTaskLimit = 0
            expiresAt = nil
            isLoading = false
            print("✅ SubscriptionService: Subscription cancelled")
            return true
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            print("⚠️ SubscriptionService: cancel failed - \(error.localizedDescription)")
            return false
        }
    }

    /// Confirm a subscription after Stripe payment succeeds.
    func confirmSubscription(stripeSubscriptionId: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            let _: ConfirmResponse = try await trpc.call(
                router: "subscription",
                procedure: "confirmSubscription",
                input: ConfirmInput(stripeSubscriptionId: stripeSubscriptionId)
            )

            isLoading = false
            // Refresh subscription state
            await fetchSubscription()
            print("✅ SubscriptionService: Subscription confirmed")
            return true
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            print("⚠️ SubscriptionService: confirm failed - \(error.localizedDescription)")
            return false
        }
    }
}
