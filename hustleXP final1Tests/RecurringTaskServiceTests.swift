import XCTest
@testable import hustleXP_final1

/// Tests for the local-only RecurringTaskService.
/// Backend support for recurring tasks is pending; the service maintains
/// series/occurrences in memory. These tests pin that local behavior.
final class RecurringTaskServiceTests: XCTestCase {
    var sut: RecurringTaskService!

    @MainActor override func setUp() {
        super.setUp()
        sut = RecurringTaskService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers

    @MainActor
    @discardableResult
    private func makeSeries(title: String = "Weekly Lawn Mow") async throws -> RecurringTaskSeries {
        try await sut.createSeries(
            title: title,
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
    }

    // MARK: - Series CRUD

    @MainActor func testCreateSeries_createsActiveLocalSeries() async throws {
        let series = try await makeSeries()

        XCTAssertTrue(series.id.hasPrefix("local-series-"))
        XCTAssertEqual(series.title, "Weekly Lawn Mow")
        XCTAssertEqual(series.status, .active)
        XCTAssertEqual(series.occurrenceCount, 1)
        XCTAssertEqual(series.completedCount, 0)
        XCTAssertNil(series.preferredWorkerId)
    }

    @MainActor func testGetMySeries_returnsCreatedSeriesNewestFirst() async throws {
        try await makeSeries(title: "First")
        try await makeSeries(title: "Second")

        let series = try await sut.getMySeries()

        XCTAssertEqual(series.count, 2)
        XCTAssertEqual(series.first?.title, "Second")
    }

    @MainActor func testGetById_returnsSeries() async throws {
        let created = try await makeSeries()

        let fetched = try await sut.getSeries(id: created.id)

        XCTAssertEqual(fetched.id, created.id)
        XCTAssertEqual(fetched.title, created.title)
    }

    @MainActor func testGetById_unknownId_throws() async {
        do {
            _ = try await sut.getSeries(id: "missing-series")
            XCTFail("Expected getSeries to throw for unknown id")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }

    @MainActor func testPauseSeries_setsPausedStatus() async throws {
        let created = try await makeSeries()

        try await sut.pauseSeries(id: created.id)

        let fetched = try await sut.getSeries(id: created.id)
        XCTAssertEqual(fetched.status, .paused)
    }

    @MainActor func testResumeSeries_setsActiveStatus() async throws {
        let created = try await makeSeries()
        try await sut.pauseSeries(id: created.id)

        try await sut.resumeSeries(id: created.id)

        let fetched = try await sut.getSeries(id: created.id)
        XCTAssertEqual(fetched.status, .active)
    }

    @MainActor func testCancelSeries_setsCancelledStatus() async throws {
        let created = try await makeSeries()

        try await sut.cancelSeries(id: created.id)

        let fetched = try await sut.getSeries(id: created.id)
        XCTAssertEqual(fetched.status, .cancelled)
    }

    @MainActor func testPauseSeries_unknownId_throws() async {
        do {
            try await sut.pauseSeries(id: "missing-series")
            XCTFail("Expected pauseSeries to throw for unknown id")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }

    // MARK: - Occurrences

    @MainActor func testGetOccurrences_returnsInitialOccurrence() async throws {
        let created = try await makeSeries()

        let occurrences = try await sut.getOccurrences(seriesId: created.id)

        XCTAssertEqual(occurrences.count, 1)
        XCTAssertEqual(occurrences.first?.seriesId, created.id)
        XCTAssertEqual(occurrences.first?.status, .scheduled)
        XCTAssertEqual(occurrences.first?.occurrenceNumber, 1)
    }

    @MainActor func testGetOccurrences_unknownSeries_returnsEmpty() async throws {
        let occurrences = try await sut.getOccurrences(seriesId: "missing-series")
        XCTAssertTrue(occurrences.isEmpty)
    }

    @MainActor func testSkipOccurrence_marksSkipped() async throws {
        let created = try await makeSeries()
        let occurrences = try await sut.getOccurrences(seriesId: created.id)
        let occurrence = try XCTUnwrap(occurrences.first)

        try await sut.skipOccurrence(occurrenceId: occurrence.id)

        let after = try await sut.getOccurrences(seriesId: created.id)
        XCTAssertEqual(after.first?.status, .skipped)
    }

    @MainActor func testSkipOccurrence_unknownId_throws() async {
        do {
            try await sut.skipOccurrence(occurrenceId: "missing-occurrence")
            XCTFail("Expected skipOccurrence to throw for unknown id")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }

    // MARK: - Preferred Worker

    @MainActor func testSetPreferredWorker_updatesSeries() async throws {
        let created = try await makeSeries()

        try await sut.setPreferredWorker(seriesId: created.id, workerId: "user-2")

        let fetched = try await sut.getSeries(id: created.id)
        XCTAssertEqual(fetched.preferredWorkerId, "user-2")
        XCTAssertNotNil(fetched.preferredWorkerName)
    }
}
