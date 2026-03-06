import XCTest
@testable import hustleXP_final1

@MainActor
final class MessagingServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: MessagingService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = MessagingService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - sendMessage

    func testSendMessage_callsCorrectProcedure() async throws {
        mockClient.stubJSON("messaging.sendMessage", json: TestFixtures.messageJSON)

        _ = try await service.sendMessage(taskId: "task-1", content: "Hello!")

        XCTAssertTrue(mockClient.wasCalled("messaging.sendMessage"))
        XCTAssertEqual(mockClient.callCount("messaging.sendMessage"), 1)
    }

    // MARK: - getTaskMessages

    func testGetTaskMessages_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.messageJSON)]"
        mockClient.stubJSON("messaging.getTaskMessages", json: listJSON)

        let messages = try await service.getTaskMessages(taskId: "task-1")

        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages.first?.content, "Hello!")
        XCTAssertEqual(messages.first?.senderId, "user-2")
        XCTAssertTrue(mockClient.wasCalled("messaging.getTaskMessages"))
    }

    // MARK: - getConversations

    func testGetConversations_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.conversationSummaryJSON)]"
        mockClient.stubJSON("messaging.getConversations", json: listJSON)

        let conversations = try await service.getConversations()

        XCTAssertEqual(conversations.count, 1)
        XCTAssertEqual(conversations.first?.taskTitle, "Fix Sink")
        XCTAssertTrue(mockClient.wasCalled("messaging.getConversations"))
    }

    // MARK: - markAsRead

    func testMarkAsRead_callsMutation() async throws {
        mockClient.stubJSON("messaging.markAllAsRead", json: "{}")
        // markAsRead internally calls refreshUnreadCount -> getUnreadCount
        mockClient.stubJSON("messaging.getUnreadCount", json: "{\"count\": 0}")

        try await service.markAsRead(taskId: "task-1")

        XCTAssertTrue(mockClient.wasCalled("messaging.markAllAsRead"))
    }

    // MARK: - getUnreadCount

    func testGetUnreadCount_returnsCount() async throws {
        mockClient.stubJSON("messaging.getUnreadCount", json: """
        {"count": 5}
        """)

        let count = try await service.getUnreadCount()

        XCTAssertEqual(count, 5)
        XCTAssertTrue(mockClient.wasCalled("messaging.getUnreadCount"))
    }

    // MARK: - sendPhotoMessage

    func testSendPhotoMessage_callsMutation() async throws {
        mockClient.stubJSON("messaging.sendPhotoMessage", json: TestFixtures.messageJSON)

        _ = try await service.sendPhotoMessage(
            taskId: "task-1",
            photoUrls: ["https://example.com/photo.jpg"],
            caption: "Check this out"
        )

        XCTAssertTrue(mockClient.wasCalled("messaging.sendPhotoMessage"))
        XCTAssertEqual(mockClient.callCount("messaging.sendPhotoMessage"), 1)
    }

    // MARK: - Error Handling

    func testSendMessage_networkError_throws() async {
        mockClient.stubError("messaging.sendMessage", error: MockNetworkError.offline)

        do {
            _ = try await service.sendMessage(taskId: "task-1", content: "Hello!")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }
}
