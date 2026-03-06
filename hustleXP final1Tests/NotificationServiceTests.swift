import XCTest
@testable import hustleXP_final1

@MainActor
final class NotificationServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: NotificationService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = NotificationService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - getNotifications

    func testGetList_returnsNotifications() async throws {
        let listJSON = "[\(TestFixtures.notificationJSON)]"
        mockClient.stubJSON("notification.getList", json: listJSON)

        let notifications = try await service.getNotifications()

        XCTAssertEqual(notifications.count, 1)
        XCTAssertEqual(notifications.first?.title, "Task Accepted")
        XCTAssertTrue(mockClient.wasCalled("notification.getList"))
    }

    // MARK: - getUnreadCount

    func testGetUnreadCount_returnsCount() async throws {
        mockClient.stubJSON("notification.getUnreadCount", json: """
        {"count": 5}
        """)

        let count = try await service.getUnreadCount()

        XCTAssertEqual(count, 5)
        XCTAssertTrue(mockClient.wasCalled("notification.getUnreadCount"))
    }

    // MARK: - getNotification

    func testGetById_returnsNotification() async throws {
        mockClient.stubJSON("notification.getById", json: TestFixtures.notificationJSON)

        let notification = try await service.getNotification(id: "notif-1")

        XCTAssertEqual(notification.id, "notif-1")
        XCTAssertEqual(notification.type, "taskAccepted")
        XCTAssertTrue(mockClient.wasCalled("notification.getById"))
    }

    // MARK: - markAsRead

    func testMarkAsRead_callsMutation() async throws {
        mockClient.stubJSON("notification.markAsRead", json: "{}")
        // markAsRead internally refreshes list and unread count
        mockClient.stubJSON("notification.getList", json: "[]")
        mockClient.stubJSON("notification.getUnreadCount", json: "{\"count\": 0}")

        try await service.markAsRead(notificationId: "notif-1")

        XCTAssertTrue(mockClient.wasCalled("notification.markAsRead"))
    }

    // MARK: - markAllAsRead

    func testMarkAllAsRead_callsMutation() async throws {
        mockClient.stubJSON("notification.markAllAsRead", json: "{}")
        // markAllAsRead internally refreshes the list
        mockClient.stubJSON("notification.getList", json: "[]")

        try await service.markAllAsRead()

        XCTAssertTrue(mockClient.wasCalled("notification.markAllAsRead"))
    }

    // MARK: - markAsClicked

    func testMarkAsClicked_callsMutation() async throws {
        mockClient.stubJSON("notification.markAsClicked", json: "{}")

        try await service.markAsClicked(notificationId: "notif-1")

        XCTAssertTrue(mockClient.wasCalled("notification.markAsClicked"))
    }

    // MARK: - getPreferences

    func testGetPreferences_returnsPreferences() async throws {
        mockClient.stubJSON("notification.getPreferences", json: TestFixtures.notificationPreferencesJSON)

        let prefs = try await service.getPreferences()

        XCTAssertTrue(prefs.pushEnabled)
        XCTAssertFalse(prefs.emailEnabled)
        XCTAssertTrue(prefs.taskUpdates)
        XCTAssertTrue(mockClient.wasCalled("notification.getPreferences"))
    }

    // MARK: - updatePreferences

    func testUpdatePreferences_callsMutation() async throws {
        mockClient.stubJSON("notification.updatePreferences", json: "{}")

        let prefs = NotificationPreferences(
            pushEnabled: true,
            emailEnabled: false,
            taskUpdates: true,
            paymentUpdates: true,
            messageNotifications: true,
            marketingEmails: false
        )

        try await service.updatePreferences(prefs)

        XCTAssertTrue(mockClient.wasCalled("notification.updatePreferences"))
    }
}
