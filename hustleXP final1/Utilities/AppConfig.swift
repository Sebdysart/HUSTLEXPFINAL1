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
        #if DEBUG
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://hustlexp-ai-backend-staging-production.up.railway.app")!
        #else
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://hustlexp-ai-backend-production.up.railway.app")!
        #endif
    }

    // MARK: - Stripe

    /// Stripe publishable key (safe to embed in client binary).
    /// Test key for debug builds, live key for release.
    static var stripePublishableKey: String {
        #if DEBUG
        // TODO: Replace with your valid Stripe test publishable key from https://dashboard.stripe.com/test/apikeys
        return "pk_live_51TQlom97UdWM2cEwuMkz0G1V0jcUxz7EKpFB8Jq8tQHHF1nYRECXgzcSHnR33PGbmmMVMoMid02BWIX3K0X8FZnq00LnzAlETg"
        #else
        // IMPORTANT: Replace with your live publishable key before App Store submission.
        // This is safe to embed — publishable keys are public by design.
        // Get it from: https://dashboard.stripe.com/apikeys
        return "pk_live_51TQlom97UdWM2cEwuMkz0G1V0jcUxz7EKpFB8Jq8tQHHF1nYRECXgzcSHnR33PGbmmMVMoMid02BWIX3K0X8FZnq00LnzAlETg"
        #endif
    }

    /// True when using Stripe test keys — used to show test mode UI hints.
    static var isStripeTestMode: Bool {
        stripePublishableKey.hasPrefix("pk_test_")
    }

    // MARK: - Test Mode Helpers

    /// Stripe-provided test card numbers for posters to use in test mode.
    /// See: https://stripe.com/docs/testing
    enum TestCard: String, CaseIterable {
        case visaSuccess     = "4242 4242 4242 4242"
        case visaDeclined    = "4000 0000 0000 0002"
        case visaInsufficientFunds = "4000 0000 0000 9995"
        case mastercard      = "5555 5555 5555 4444"
        case amex            = "3782 822463 10005"

        var label: String {
            switch self {
            case .visaSuccess: return "Visa — Success"
            case .visaDeclined: return "Visa — Declined"
            case .visaInsufficientFunds: return "Visa — Insufficient funds"
            case .mastercard: return "Mastercard — Success"
            case .amex: return "Amex — Success"
            }
        }

        /// Number stripped of spaces for copy/paste
        var rawNumber: String { rawValue.replacingOccurrences(of: " ", with: "") }
    }

    /// Test bank account values for hustler Stripe Connect onboarding.
    enum TestBank {
        static let routingNumber = "110000000"   // Stripe test routing
        static let accountNumber = "000123456789" // Successful payout
        static let ssnLast4      = "0000"        // Bypasses identity verification
        static let dateOfBirth   = "01/01/1990"  // Any past date works
    }

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
    /// Set to `true` in DEBUG as well if you need to test the gate from a simulator (mock location stays in SF).
    static var isServiceAreaLimited: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }

    /// Shown on the out-of-area screen.
    static let serviceAreaDisplayName = "San Francisco Bay Area"

    /// Center of the allowed region (WGS84).
    static let serviceAreaCenterLatitude = 37.7749
    static let serviceAreaCenterLongitude = -122.4194

    /// Radius from center in meters. 100 km covers the full Bay Area
    /// (SF, Oakland, San Jose, Cupertino) so Apple's TestFlight reviewers in
    /// Cupertino aren't blocked by the gate during Beta App Review.
    static let serviceAreaRadiusMeters: Double = 100_000
}
