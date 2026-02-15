//
//  StripePaymentManager.swift
//  hustleXP final1
//
//  Service: Stripe Payment Manager
//  Manages Stripe PaymentSheet configuration and presentation
//  Replaces MockStripePaymentSheet with real Stripe iOS SDK integration
//

import Foundation
import UIKit
import StripePaymentSheet

@MainActor
@Observable
final class StripePaymentManager {
    static let shared = StripePaymentManager()

    private var paymentSheet: PaymentSheet?

    private init() {}

    // MARK: - Configuration

    /// Configure Stripe with publishable key (call once at app launch)
    func configure() {
        // Stripe test publishable key (safe to embed in client apps)
        StripeAPI.defaultPublishableKey = "pk_test_51SCTxI9oJYlVip5Z931pD73nICDzzkhjFrKZ1pED20fJWRgwLDrVqEhkfYuosQXrt8S56WIdnjBT9Nv5oJ4SXyvB009Ajm9uRv"
        print("✅ StripePaymentManager: Configured with publishable key")
    }

    // MARK: - Payment Sheet

    /// Prepare a payment sheet for a given client secret
    func preparePaymentSheet(clientSecret: String, merchantDisplayName: String = "HustleXP") {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = merchantDisplayName
        configuration.allowsDelayedPaymentMethods = false

        // Match the app's dark theme
        configuration.style = .alwaysDark

        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )

        print("✅ StripePaymentManager: Payment sheet prepared")
    }

    /// Present the payment sheet and return the result
    func presentPaymentSheet(from viewController: UIViewController? = nil) async -> PaymentSheetResult {
        guard let paymentSheet = paymentSheet else {
            return .failed(error: NSError(
                domain: "StripePaymentManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Payment sheet not configured. Call preparePaymentSheet first."]
            ))
        }

        // Get the top view controller
        guard let vc = viewController ?? UIApplication.shared.topViewController else {
            return .failed(error: NSError(
                domain: "StripePaymentManager",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No view controller available to present payment sheet."]
            ))
        }

        return await withCheckedContinuation { continuation in
            paymentSheet.present(from: vc) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// Resets the payment sheet (e.g., after completion or cancellation)
    func reset() {
        paymentSheet = nil
    }
}

// MARK: - UIApplication Top View Controller Helper

extension UIApplication {
    var topViewController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else {
            return nil
        }
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }
}
