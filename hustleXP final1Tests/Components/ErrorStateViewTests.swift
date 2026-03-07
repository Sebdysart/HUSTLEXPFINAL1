// hustleXP final1Tests/Components/ErrorStateViewTests.swift
import XCTest
@testable import hustleXP_final1

final class AppErrorTests: XCTestCase {
    func testNetworkErrorProperties() {
        let error = AppError.network
        XCTAssertEqual(error.title, "No Internet Connection")
        XCTAssertEqual(error.message, "Check your connection and try again.")
        XCTAssertEqual(error.icon, "wifi.slash")
    }

    func testNotFoundIncludesItemName() {
        let error = AppError.notFound("Task")
        XCTAssertTrue(error.title.contains("Task"))
        XCTAssertEqual(error.message, "This task is no longer available.")
    }

    func testUnknownErrorPassesThroughMessage() {
        let error = AppError.unknown("Custom error message")
        XCTAssertEqual(error.message, "Custom error message")
    }
}
