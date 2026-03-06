import XCTest
@testable import hustleXP_final1

@MainActor
final class RatingServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: RatingService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = RatingService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - submitRating

    func testSubmitRating_callsCorrectProcedure() async throws {
        mockClient.stubJSON("rating.submitRating", json: "{}")

        try await service.submitRating(taskId: "task-1", rating: 5, review: "Great work!")

        XCTAssertTrue(mockClient.wasCalled("rating.submitRating"))
        XCTAssertEqual(mockClient.callCount("rating.submitRating"), 1)
    }

    func testSubmitRating_networkError_throws() async {
        mockClient.stubError("rating.submitRating", error: MockNetworkError.offline)

        do {
            try await service.submitRating(taskId: "task-1", rating: 5, review: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getUserRatingSummary

    func testGetUserRatingSummary_returnsSummary() async throws {
        mockClient.stubJSON("rating.getUserRatingSummary", json: TestFixtures.ratingSummaryJSON)

        let summary = try await service.getUserRatingSummary(userId: "user-1")

        XCTAssertEqual(summary.averageRating, 4.5)
        XCTAssertEqual(summary.totalRatings, 12)
        XCTAssertTrue(mockClient.wasCalled("rating.getUserRatingSummary"))
    }

    func testGetUserRatingSummary_networkError_throws() async {
        mockClient.stubError("rating.getUserRatingSummary", error: MockNetworkError.serverError)

        do {
            _ = try await service.getUserRatingSummary(userId: "user-1")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getMyRatings

    func testGetMyRatings_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.userRatingJSON)]"
        mockClient.stubJSON("rating.getMyRatings", json: listJSON)

        let ratings = try await service.getMyRatings()

        XCTAssertEqual(ratings.count, 1)
        XCTAssertEqual(ratings.first?.rating, 5)
        XCTAssertTrue(mockClient.wasCalled("rating.getMyRatings"))
    }

    // MARK: - getTaskRatings

    func testGetTaskRatings_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.userRatingJSON)]"
        mockClient.stubJSON("rating.getTaskRatings", json: listJSON)

        let ratings = try await service.getTaskRatings(taskId: "task-1")

        XCTAssertEqual(ratings.count, 1)
        XCTAssertEqual(ratings.first?.fromUserName, "Jane")
        XCTAssertTrue(mockClient.wasCalled("rating.getTaskRatings"))
    }

    // MARK: - getRatingsReceived

    func testGetRatingsReceived_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.userRatingJSON)]"
        mockClient.stubJSON("rating.getRatingsReceived", json: listJSON)

        let ratings = try await service.getRatingsReceived()

        XCTAssertEqual(ratings.count, 1)
        XCTAssertTrue(mockClient.wasCalled("rating.getRatingsReceived"))
    }

    // MARK: - Multiple Calls

    func testMultipleCalls_recordedCorrectly() async throws {
        let listJSON = "[\(TestFixtures.userRatingJSON)]"
        mockClient.stubJSON("rating.getMyRatings", json: listJSON)

        _ = try await service.getMyRatings()
        _ = try await service.getMyRatings()

        XCTAssertEqual(mockClient.callCount("rating.getMyRatings"), 2)
    }
}
