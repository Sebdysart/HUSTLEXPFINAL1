import XCTest
@testable import hustleXP_final1

@MainActor
final class RealtimeSSEClientTests: XCTestCase {

    func testSharedInstance_exists() {
        XCTAssertNotNil(RealtimeSSEClient.shared)
    }

    func testInitialState_isDisconnected() {
        let client = RealtimeSSEClient.shared
        // Ensure clean state by disconnecting first
        client.disconnect()
        XCTAssertFalse(client.isConnected)
    }

    func testDisconnect_clearsConnectedState() {
        let client = RealtimeSSEClient.shared
        // Connect with a dummy token (network will fail, but state is set)
        client.connect(authToken: "test-token")
        XCTAssertTrue(client.isConnected)

        // Disconnect should clear the connected state
        client.disconnect()
        XCTAssertFalse(client.isConnected)
    }
}
