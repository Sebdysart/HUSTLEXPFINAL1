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
    ///
    /// Reads from AppConfig to select the correct key per environment.
    /// - Debug builds: uses test publishable key (pk_test_*)
    /// - Release builds: uses live publishable key (pk_live_*) from AppConfig
    func configure() {
        let key = AppConfig.stripePublishableKey
        StripeAPI.defaultPublishableKey = key
        HXLogger.info("StripePaymentManager: Configured with \(AppConfig.isProduction ? "live" : "test") publishable key", category: "Payment")
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

        HXLogger.info("StripePaymentManager: Payment sheet prepared", category: "Payment")
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

    // MARK: - Setup Sheet (for saving cards without charging)

    /// Prepare a setup sheet for saving a payment method
    func prepareSetupSheet(clientSecret: String, merchantDisplayName: String = "HustleXP") {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = merchantDisplayName
        configuration.allowsDelayedPaymentMethods = false
        configuration.style = .alwaysDark
        // No customer config needed — SetupIntent already has customer attached

        paymentSheet = PaymentSheet(
            setupIntentClientSecret: clientSecret,
            configuration: configuration
        )

        HXLogger.info("StripePaymentManager: Setup sheet prepared for adding card", category: "Payment")
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
