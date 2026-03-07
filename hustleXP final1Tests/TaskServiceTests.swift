import XCTest
@testable import hustleXP_final1

@MainActor
final class TaskServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: TaskService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = TaskService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - createTask

    func testCreateTask_callsCorrectProcedure() async throws {
        mockClient.stubJSON("task.create", json: TestFixtures.taskJSON)

        _ = try await service.createTask(
            title: "Test",
            description: "Desc",
            payment: 25.00,
            location: "SF",
            latitude: 37.77,
            longitude: -122.42,
            estimatedDuration: "30 min",
            category: nil
        )

        XCTAssertTrue(mockClient.wasCalled("task.create"))
        XCTAssertEqual(mockClient.callCount("task.create"), 1)
    }

    func testCreateTask_returnsDecodedTask() async throws {
        mockClient.stubJSON("task.create", json: TestFixtures.taskJSON)

        let task = try await service.createTask(
            title: "Test Task",
            description: "A test",
            payment: 25.00,
            location: "SF",
            latitude: nil,
            longitude: nil,
            estimatedDuration: "30 min",
            category: nil
        )

        XCTAssertEqual(task.id, "task-1")
        XCTAssertEqual(task.title, "Test Task")
    }

    func testCreateTask_networkError_throws() async {
        mockClient.stubError("task.create", error: MockNetworkError.offline)

        do {
            _ = try await service.createTask(
                title: "Test",
                description: "Desc",
                payment: 25.00,
                location: "SF",
                latitude: nil,
                longitude: nil,
                estimatedDuration: "30 min",
                category: nil
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getTask

    func testGetTask_returnsTask() async throws {
        mockClient.stubJSON("task.getById", json: TestFixtures.taskJSON)

        let task = try await service.getTask(id: "task-1")

        XCTAssertEqual(task.id, "task-1")
        XCTAssertTrue(mockClient.wasCalled("task.getById"))
    }

    // MARK: - acceptTask

    func testAcceptTask_callsMutation() async throws {
        let acceptedJSON = TestFixtures.modify(
            TestFixtures.taskJSON,
            key: "state",
            value: "\"ACCEPTED\""
        )
        mockClient.stubJSON("task.accept", json: acceptedJSON)

        let task = try await service.acceptTask(taskId: "task-1")

        XCTAssertTrue(mockClient.wasCalled("task.accept"))
        XCTAssertEqual(task.state, .claimed)
    }

    // MARK: - listOpenTasks

    func testListOpenTasks_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.taskJSON)]"
        mockClient.stubJSON("task.listOpen", json: listJSON)

        let tasks = try await service.listOpenTasks()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.id, "task-1")
    }

    func testListOpenTasks_emptyArray() async throws {
        mockClient.stubJSON("task.listOpen", json: "[]")

        let tasks = try await service.listOpenTasks()

        XCTAssertTrue(tasks.isEmpty)
    }

    // MARK: - State Management

    func testIsLoading_falseAfterCall() async throws {
        mockClient.stubJSON("task.getById", json: TestFixtures.taskJSON)

        XCTAssertFalse(service.isLoading)

        _ = try await service.getTask(id: "task-1")
        XCTAssertFalse(service.isLoading)
    }

    // MARK: - applyForTask

    func testApplyForTask() async throws {
        let json = """
        {"id":"app-001","task_id":"task-001","status":"pending","message":"I can help!","applied_at":"2026-03-06T00:00:00Z"}
        """
        mockClient.stubJSON("task.applyForTask", json: json)

        let result = try await service.applyForTask(taskId: "task-001", message: "I can help!")

        XCTAssertEqual(result.id, "app-001")
        XCTAssertEqual(result.status, "pending")
    }

    func testWithdrawApplication() async throws {
        let json = """
        {"success":true}
        """
        mockClient.stubJSON("task.withdrawApplication", json: json)

        try await service.withdrawApplication(taskId: "task-001")
        // No assertion needed - success means it didn't throw
    }
}
