//
//  StripePaymentManagerTests.swift
//  hustleXP final1Tests
//
//  Smoke tests for StripePaymentManager.
//  These verify basic state management and that the Stripe SDK
//  wrapper methods run without crashing. No DI needed — the manager
//  wraps the Stripe SDK directly via the shared singleton.
//

import XCTest
@testable import hustleXP_final1

final class StripePaymentManagerTests: XCTestCase {

    // MARK: - configure

    @MainActor
    func testConfigure_doesNotCrash() {
        // configure() sets the Stripe publishable key from AppConfig.
        // Verify it runs without throwing.
        StripePaymentManager.shared.configure()
        XCTAssertTrue(true, "configure() should complete without crashing")
    }

    // MARK: - reset

    @MainActor
    func testReset_clearsPaymentSheet() {
        // reset() nils out the internal paymentSheet.
        // Verify the reset path doesn't crash.
        StripePaymentManager.shared.reset()
        XCTAssertTrue(true, "reset() should complete without crashing")
    }

    // MARK: - preparePaymentSheet

    @MainActor
    func testPreparePaymentSheet_withTestSecret_doesNotCrash() {
        // preparePaymentSheet creates a PaymentSheet.Configuration and
        // instantiates a PaymentSheet with the given client secret.
        // With a test secret it should still create the config object.
        let manager = StripePaymentManager.shared
        manager.preparePaymentSheet(
            clientSecret: "pi_test_secret",
            merchantDisplayName: "HustleXP"
        )
        // If we reach here the Stripe SDK accepted the config
        XCTAssertTrue(true, "preparePaymentSheet should complete without crashing")

        // Clean up
        manager.reset()
    }
}
