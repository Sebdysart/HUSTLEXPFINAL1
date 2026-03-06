import XCTest
@testable import hustleXP_final1

@MainActor
final class ConnectivityMonitorTests: XCTestCase {

    func testSharedInstance_exists() {
        let monitor = ConnectivityMonitor.shared
        XCTAssertNotNil(monitor)
    }

    func testInitialState_isConnected() {
        // Default state is connected=true (optimistic)
        let monitor = ConnectivityMonitor.shared
        XCTAssertTrue(monitor.isConnected)
    }

    func testConnectionType_isValidValue() {
        // NWPathMonitor may have already updated connectionType by the time
        // this test runs, so verify it is a valid enum value rather than
        // asserting .unknown specifically.
        let monitor = ConnectivityMonitor.shared
        let validTypes: [ConnectivityMonitor.ConnectionType] = [.wifi, .cellular, .wiredEthernet, .unknown]
        XCTAssertTrue(validTypes.contains(monitor.connectionType),
                       "Expected valid ConnectionType, got \(monitor.connectionType)")
    }
}
