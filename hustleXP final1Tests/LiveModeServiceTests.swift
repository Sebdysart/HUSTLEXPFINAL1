import XCTest
@testable import hustleXP_final1

final class LiveModeServiceTests: XCTestCase {
    var liveSut: LiveModeService!
    var instantSut: InstantModeService!
    var mockClient: MockTRPCClient!

    @MainActor override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        liveSut = LiveModeService(client: mockClient)
        instantSut = InstantModeService(client: mockClient)
    }

    @MainActor override func tearDown() {
        liveSut.stopPolling()
        liveSut = nil
        instantSut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - LiveModeService Tests

    @MainActor func testGetStatus_callsQuery() async throws {
        mockClient.stubJSON("live.getStatus", json: TestFixtures.liveModeStatusJSON)

        let status = try await liveSut.getStatus()

        XCTAssertEqual(status.state, .active)
        XCTAssertEqual(status.totalTasks, 25)
        XCTAssertTrue(mockClient.wasCalled("live.getStatus"))
    }

    @MainActor func testListBroadcasts_returnsArray() async throws {
        mockClient.stubJSON("live.listBroadcasts", json: "[\(TestFixtures.liveBroadcastJSON)]")

        let broadcasts = try await liveSut.listBroadcasts(
            latitude: 37.7749,
            longitude: -122.4194,
            radiusMiles: 10
        )

        XCTAssertEqual(broadcasts.count, 1)
        XCTAssertEqual(broadcasts.first?.title, "Fix Sink Urgently")
        XCTAssertTrue(mockClient.wasCalled("live.listBroadcasts"))
    }

    @MainActor func testToggle_enabled_callsMutation() async throws {
        // Stub both toggle response and getStatus for the polling task that fires on active
        mockClient.stubJSON("live.toggle", json: TestFixtures.liveModeStatusJSON)
        mockClient.stubJSON("live.getStatus", json: TestFixtures.liveModeStatusJSON)

        let status = try await liveSut.toggle(enabled: true)

        XCTAssertEqual(status.state, .active)
        XCTAssertTrue(mockClient.wasCalled("live.toggle"))

        // Stop polling to prevent background task leakage
        liveSut.stopPolling()
    }

    @MainActor func testToggle_disabled_callsMutation() async throws {
        let offStatusJSON = """
        {
            "state": "OFF",
            "session_started_at": null,
            "banned_until": null,
            "total_tasks": 25,
            "completion_rate": 0.92
        }
        """
        mockClient.stubJSON("live.toggle", json: offStatusJSON)

        let status = try await liveSut.toggle(enabled: false)

        XCTAssertEqual(status.state, .off)
        XCTAssertTrue(mockClient.wasCalled("live.toggle"))
    }

    @MainActor func testStartLiveMode_createsLocalSession() {
        let session = liveSut.startLiveMode(
            workerId: "worker-1",
            location: GPSCoordinates(latitude: 37.7749, longitude: -122.4194),
            categories: [.delivery]
        )

        XCTAssertEqual(session.workerId, "worker-1")
    }

    // MARK: - InstantModeService Tests

    @MainActor func testInstantListAvailable_callsQuery() async throws {
        mockClient.stubJSON("instant.listAvailable", json: "[\(TestFixtures.instantTaskJSON)]")

        let tasks = try await instantSut.listAvailable()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Quick Delivery")
        XCTAssertTrue(mockClient.wasCalled("instant.listAvailable"))
    }

    @MainActor func testInstantAccept_callsMutation() async throws {
        mockClient.stubJSON("instant.accept", json: TestFixtures.taskJSON)

        let task = try await instantSut.accept(taskId: "task-1")

        XCTAssertEqual(task.id, "task-1")
        XCTAssertTrue(mockClient.wasCalled("instant.accept"))
    }

    @MainActor func testInstantDismiss_callsMutation() async throws {
        mockClient.stubJSON("instant.dismiss", json: "{}")

        try await instantSut.dismiss(taskId: "instant-1")

        XCTAssertTrue(mockClient.wasCalled("instant.dismiss"))
    }
}
