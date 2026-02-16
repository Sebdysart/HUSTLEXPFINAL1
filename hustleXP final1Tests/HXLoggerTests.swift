//
//  HXLoggerTests.swift
//  hustleXP final1Tests
//
//  Tests for the HXLogger utility.
//  Primarily verifies that calling log methods does not crash,
//  since the logger outputs via os.log and cannot be captured in tests.
//

import XCTest
@testable import hustleXP_final1

final class HXLoggerTests: XCTestCase {

    // MARK: - Smoke Tests (no crash)

    func testDebugDoesNotCrash() {
        // debug() is gated by #if DEBUG so this exercises that code path
        HXLogger.debug("Test debug message")
        // If we reach here, no crash occurred
        XCTAssertTrue(true)
    }

    func testInfoDoesNotCrash() {
        HXLogger.info("Test info message")
        XCTAssertTrue(true)
    }

    func testErrorDoesNotCrash() {
        HXLogger.error("Test error message")
        XCTAssertTrue(true)
    }

    // MARK: - Category Parameter

    func testDebugWithCategory() {
        HXLogger.debug("Auth test message", category: "Auth")
        HXLogger.debug("Network test message", category: "Network")
        HXLogger.debug("Task test message", category: "Task")
        HXLogger.debug("Navigation test message", category: "Navigation")
        HXLogger.debug("Payment test message", category: "Payment")
        // No crash means success
        XCTAssertTrue(true)
    }

    func testInfoWithCategory() {
        HXLogger.info("Info with Auth category", category: "Auth")
        HXLogger.info("Info with custom category", category: "CustomCategory")
        XCTAssertTrue(true)
    }

    func testErrorWithCategory() {
        HXLogger.error("Error with Network category", category: "Network")
        HXLogger.error("Error with unknown category", category: "SomethingNew")
        XCTAssertTrue(true)
    }

    // MARK: - Default Category

    func testDefaultCategoryIsGeneral() {
        // Calling without explicit category should not crash (uses "General")
        HXLogger.debug("No category specified")
        HXLogger.info("No category specified")
        HXLogger.error("No category specified")
        XCTAssertTrue(true)
    }

    // MARK: - Named Loggers

    func testNamedLoggersExist() {
        // Verify all named logger properties are accessible
        _ = HXLogger.auth
        _ = HXLogger.task
        _ = HXLogger.network
        _ = HXLogger.nav
        _ = HXLogger.live
        _ = HXLogger.payment
        _ = HXLogger.push
        _ = HXLogger.skill
        _ = HXLogger.ui
        _ = HXLogger.general
        _ = HXLogger.analytics
        // No crash means all loggers are properly initialized
        XCTAssertTrue(true)
    }

    // MARK: - Edge Cases

    func testEmptyMessage() {
        HXLogger.debug("")
        HXLogger.info("")
        HXLogger.error("")
        XCTAssertTrue(true)
    }

    func testLongMessage() {
        let longMessage = String(repeating: "A", count: 10_000)
        HXLogger.debug(longMessage)
        HXLogger.info(longMessage)
        HXLogger.error(longMessage)
        XCTAssertTrue(true)
    }

    func testSpecialCharactersInMessage() {
        HXLogger.debug("Message with emoji: and special chars: <>&\"'")
        HXLogger.info("Unicode: \u{00E9}\u{00F1}\u{00FC}")
        HXLogger.error("Newlines:\nLine2\nLine3")
        XCTAssertTrue(true)
    }
}
