import XCTest
@testable import hustleXP_final1

final class RecurringTaskServiceTests: XCTestCase {
    var sut: RecurringTaskService!
    var mockClient: MockTRPCClient!

    @MainActor override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        sut = RecurringTaskService(client: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - Series CRUD Tests

    @MainActor func testCreateSeries_callsCorrectProcedure() async throws {
        mockClient.stubJSON("recurringTask.create", json: TestFixtures.recurringSeriesJSON)

        let series = try await sut.createSeries(
            title: "Weekly Lawn Mow",
            description: "Mow the front lawn",
            payment: 5000,
            location: "123 Main St",
            category: nil,
            estimatedDuration: "1 hour",
            requiredTier: .rookie,
            pattern: .weekly,
            dayOfWeek: 1,
            dayOfMonth: nil,
            timeOfDay: "09:00",
            startDate: Date(),
            endDate: nil
        )

        XCTAssertEqual(series.id, "series-1")
        XCTAssertTrue(mockClient.wasCalled("recurringTask.create"))
    }

    @MainActor func testListMine_returnsArray() async throws {
        mockClient.stubJSON("recurringTask.listMine", json: "[\(TestFixtures.recurringSeriesJSON)]")

        let series = try await sut.getMySeries()

        XCTAssertEqual(series.count, 1)
        XCTAssertEqual(series.first?.title, "Weekly Lawn Mow")
        XCTAssertTrue(mockClient.wasCalled("recurringTask.listMine"))
    }

    @MainActor func testGetById_returnsSeries() async throws {
        mockClient.stubJSON("recurringTask.getById", json: TestFixtures.recurringSeriesJSON)

        let series = try await sut.getSeries(id: "series-1")

        XCTAssertEqual(series.id, "series-1")
        XCTAssertTrue(mockClient.wasCalled("recurringTask.getById"))
    }

    @MainActor func testPauseSeries_callsMutation() async throws {
        mockClient.stubJSON("recurringTask.pause", json: "{\"success\": true}")

        try await sut.pauseSeries(id: "series-1")

        XCTAssertTrue(mockClient.wasCalled("recurringTask.pause"))
    }

    @MainActor func testResumeSeries_callsMutation() async throws {
        mockClient.stubJSON("recurringTask.resume", json: "{\"success\": true}")

        try await sut.resumeSeries(id: "series-1")

        XCTAssertTrue(mockClient.wasCalled("recurringTask.resume"))
    }

    @MainActor func testCancelSeries_callsMutation() async throws {
        mockClient.stubJSON("recurringTask.cancel", json: "{\"success\": true}")

        try await sut.cancelSeries(id: "series-1")

        XCTAssertTrue(mockClient.wasCalled("recurringTask.cancel"))
    }

    // MARK: - Occurrence Tests

    @MainActor func testListOccurrences_returnsArray() async throws {
        mockClient.stubJSON("recurringTask.listOccurrences", json: "[\(TestFixtures.recurringOccurrenceJSON)]")

        let occurrences = try await sut.getOccurrences(seriesId: "series-1")

        XCTAssertEqual(occurrences.count, 1)
        XCTAssertTrue(mockClient.wasCalled("recurringTask.listOccurrences"))
    }

    @MainActor func testSkipOccurrence_callsMutation() async throws {
        mockClient.stubJSON("recurringTask.skipOccurrence", json: "{\"success\": true}")

        try await sut.skipOccurrence(occurrenceId: "occ-1")

        XCTAssertTrue(mockClient.wasCalled("recurringTask.skipOccurrence"))
    }

    // MARK: - Preferred Worker

    @MainActor func testSetPreferredWorker_callsMutation() async throws {
        mockClient.stubJSON("recurringTask.setPreferredWorker", json: "{\"success\": true}")

        try await sut.setPreferredWorker(seriesId: "series-1", workerId: "user-2")

        XCTAssertTrue(mockClient.wasCalled("recurringTask.setPreferredWorker"))
    }
}
