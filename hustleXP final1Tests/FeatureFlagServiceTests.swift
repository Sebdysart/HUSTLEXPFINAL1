import XCTest
@testable import hustleXP_final1

@MainActor
final class FeatureFlagServiceTests: XCTestCase {

    var sut: FeatureFlagService!
    var mockClient: MockTRPCClient!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        sut = FeatureFlagService(client: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - isEnabled

    func testIsEnabled_defaultsFalse() {
        // Unset flags default to false
        XCTAssertFalse(sut.isEnabled("nonexistent_flag"))
    }

    // MARK: - refreshFlags

    func testRefreshFlags_callsQueryAndUpdatesFlags() async {
        let flagsJSON = """
        [
            {"name": "dark_mode", "enabled": true},
            {"name": "beta_feature", "enabled": false}
        ]
        """
        mockClient.stubJSON("flags.getFlags", json: flagsJSON)

        await sut.refreshFlags()

        XCTAssertTrue(mockClient.wasCalled("flags.getFlags"))
        XCTAssertTrue(sut.isEnabled("dark_mode"))
        XCTAssertFalse(sut.isEnabled("beta_feature"))
    }

    func testRefreshFlags_networkError_keepsOldFlags() async {
        // First load some flags successfully
        let flagsJSON = """
        [{"name": "test_flag", "enabled": true}]
        """
        mockClient.stubJSON("flags.getFlags", json: flagsJSON)
        await sut.refreshFlags()
        XCTAssertTrue(sut.isEnabled("test_flag"))

        // Now simulate error on next refresh
        mockClient.stubError("flags.getFlags", error: MockNetworkError.serverError)
        await sut.refreshFlags()

        // Old flags should still be there (refreshFlags catches errors internally)
        XCTAssertTrue(sut.isEnabled("test_flag"))
    }
}
