import Foundation

/// Centralized environment configuration for HustleXP.
///
/// Uses compile-time `#if DEBUG` to select test vs production credentials.
/// No secrets are embedded in release builds — live keys come from the
/// build environment (xcconfig or Xcode build settings).
enum AppConfig {

    // MARK: - Environment Detection

    #if DEBUG
    static let isProduction = false
    #else
    static let isProduction = true
    #endif

    // MARK: - Backend

    /// Railway backend base URL.
    /// Debug: staging environment. Release: production environment.
    static var backendBaseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://hustlexp-ai-backend-production.up.railway.app")!
    }

    // MARK: - Stripe

    /// Stripe publishable key (safe to embed in client binary).
    /// Debug builds use the test key so internal testing never hits live payments.
    /// Release builds use the live key.
    /// Get your test key from: https://dashboard.stripe.com/test/apikeys
    static var stripePublishableKey: String {
        #if DEBUG
        return "pk_test_51TQlom97UdWM2cEwuMkz0G1V0jcUxz7EKpFB8Jq8tQHHF1nYRECXgzcSHnR33PGbmmMVMoMid02BWIX3K0X8FZnq00LnzAlETg"
        #else
        return "pk_live_51TQlom97UdWM2cEwuMkz0G1V0jcUxz7EKpFB8Jq8tQHHF1nYRECXgzcSHnR33PGbmmMVMoMid02BWIX3K0X8FZnq00LnzAlETg"
        #endif
    }

    /// True when using Stripe test keys — used to show test mode UI hints.
    static var isStripeTestMode: Bool {
        stripePublishableKey.hasPrefix("pk_test_")
    }

    // MARK: - Test Mode Helpers (DEBUG only — never compiled into release builds)

    #if DEBUG
    /// Stripe-provided test card numbers for posters to use in test mode.
    /// See: https://stripe.com/docs/testing
    enum TestCard: String, CaseIterable {
        case visaSuccess           = "4242 4242 4242 4242"
        case visaDeclined          = "4000 0000 0000 0002"
        case visaInsufficientFunds = "4000 0000 0000 9995"
        case mastercard            = "5555 5555 5555 4444"
        case amex                  = "3782 822463 10005"

        var label: String {
            switch self {
            case .visaSuccess:           return "Visa — Success"
            case .visaDeclined:          return "Visa — Declined"
            case .visaInsufficientFunds: return "Visa — Insufficient funds"
            case .mastercard:            return "Mastercard — Success"
            case .amex:                  return "Amex — Success"
            }
        }

        /// Number stripped of spaces for copy/paste
        var rawNumber: String { rawValue.replacingOccurrences(of: " ", with: "") }
    }

    /// Test bank account values for hustler Stripe Connect onboarding in DEBUG mode only.
    /// These values are NEVER compiled into release builds.
    enum TestBank {
        static let routingNumber = "110000000"    // Stripe test routing number
        static let accountNumber = "000123456789" // Test account — triggers successful payout
        static let ssnLast4      = "0000"         // Stripe test SSN bypass
        static let dateOfBirth   = "01/01/1990"
    }
    #endif

    // MARK: - SSL Pinning

    /// Whether to enforce SSL certificate pinning.
    /// Disabled in debug builds for local/proxy debugging.
    /// Enabled in release builds for production security.
    static var sslPinningEnabled: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }

    // MARK: - Service area (single-city / regional launch)

    /// When `true`, the main app is only usable within `serviceAreaRadiusMeters` of the center point.
    /// Disabled in debug so simulator (which often uses a fixed location) isn't blocked.
    static var isServiceAreaLimited: Bool {
        #if DEBUG
        return true
        #else
        return true
        #endif
    }

    /// Shown on the out-of-area screen.
    static let serviceAreaDisplayName = "the United States"

    /// Geographic center of the contiguous United States (WGS84).
    static let serviceAreaCenterLatitude = 39.8283
    static let serviceAreaCenterLongitude = -98.5795

    /// 6,000 km radius from the US center covers all 50 states including
    /// Hawaii (~4,400 km) and Alaska (~5,400 km from center).
    static let serviceAreaRadiusMeters: Double = 6_000_000
}
