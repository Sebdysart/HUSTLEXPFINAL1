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
    ///
    /// NOTE (2026-06-12): Debug previously pointed at
    /// `hustlexp-ai-backend-staging-production.up.railway.app`, but that
    /// Railway app no longer exists (edge returns 404 "Application not found"),
    /// which made every Debug build talk to a dead backend. Until a staging
    /// environment is recreated, Debug uses production. Re-split when staging
    /// is back.
    static var backendBaseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://hustlexp-ai-backend-production.up.railway.app")!
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

    // MARK: - Live Diagnostics (TestFlight log gateway)

    /// Beta diagnostics sink (Supabase edge function `log-ingest`).
    /// Write-only, token-gated, rate-limited endpoint — the token only allows
    /// appending log rows, never reading. Used so TestFlight failures are
    /// visible remotely in near-real-time during beta.
    // swiftlint:disable:next force_unwrapping
    static let liveDiagnosticsURL = URL(string: "https://vbnusdfqoyxrrzxshyuh.supabase.co/functions/v1/log-ingest")!

    /// Shared ingest token (append-only permission; see log-ingest function).
    static let liveDiagnosticsToken = "daafdc0a4891fe6764fe54599bdd142c3f53de4e4c43acdc"

    /// Enabled for DEBUG and TestFlight builds; OFF for App Store builds.
    static var liveDiagnosticsEnabled: Bool {
        #if DEBUG
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
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
}
