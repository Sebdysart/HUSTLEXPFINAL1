import XCTest
@testable import hustleXP_final1

@MainActor
final class AuthServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: AuthService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = AuthService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_notAuthenticated() {
        XCTAssertNil(service.currentUser)
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertFalse(service.isLoading)
    }

    // MARK: - signOut

    func testSignOut_clearsState() {
        service.signOut()

        XCTAssertNil(service.currentUser)
        XCTAssertFalse(service.isAuthenticated)
    }

    // MARK: - Error State

    func testError_initiallyNil() {
        XCTAssertNil(service.error)
    }
}
