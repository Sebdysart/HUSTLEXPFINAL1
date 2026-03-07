// hustleXP final1Tests/Components/ErrorStateViewTests.swift
import XCTest
@testable import hustleXP_final1

final class AppErrorTests: XCTestCase {
    func testNetworkErrorProperties() {
        let error = AppError.network
        XCTAssertEqual(error.title, "No Internet Connection")
        XCTAssertFalse(error.message.isEmpty)
        XCTAssertFalse(error.icon.isEmpty)
    }

    func testNotFoundIncludesItemName() {
        let error = AppError.notFound("Task")
        XCTAssertTrue(error.title.contains("Task"))
    }

    func testUnknownErrorPassesThroughMessage() {
        let error = AppError.unknown("Custom error message")
        XCTAssertEqual(error.message, "Custom error message")
    }
}
