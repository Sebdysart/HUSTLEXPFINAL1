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
        return "pk_test_51SCTxI9oJYlVip5Z931pD73nICDzzkhjFrKZ1pED20fJWRgwLDrVqEhkfYuosQXrt8S56WIdnjBT9Nv5oJ4SXyvB009Ajm9uRv"
        #else
        // IMPORTANT: Replace with your live publishable key before App Store submission.
        // This is safe to embed — publishable keys are public by design.
        // Get it from: https://dashboard.stripe.com/apikeys
        return "pk_live_REPLACE_WITH_LIVE_PUBLISHABLE_KEY"
        #endif
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

    /// Radius from center in meters (e.g. 30_000 ≈ 30 km from downtown SF).
    static let serviceAreaRadiusMeters: Double = 30_000
}
