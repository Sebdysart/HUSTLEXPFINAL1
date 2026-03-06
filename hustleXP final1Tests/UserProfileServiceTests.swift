import XCTest
@testable import hustleXP_final1

@MainActor
final class UserProfileServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: UserProfileService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = UserProfileService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - updateProfile

    func testUpdateProfile_callsCorrectProcedure() async throws {
        mockClient.stubJSON("user.updateProfile", json: TestFixtures.hxUserJSON)

        _ = try await service.updateProfile(name: "New Name")

        XCTAssertTrue(mockClient.wasCalled("user.updateProfile"))
        XCTAssertEqual(mockClient.callCount("user.updateProfile"), 1)
    }

    // MARK: - getUser

    func testGetUser_returnsUser() async throws {
        mockClient.stubJSON("user.getById", json: TestFixtures.hxUserJSON)

        let user = try await service.getUser(id: "user-1")

        XCTAssertEqual(user.id, "user-1")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.xp, 150)
        XCTAssertTrue(mockClient.wasCalled("user.getById"))
    }

    // MARK: - getXPHistory

    func testGetXPHistory_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.xpHistoryEntryJSON)]"
        mockClient.stubJSON("user.xpHistory", json: listJSON)

        let entries = try await service.getXPHistory()

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, 50)
        XCTAssertTrue(mockClient.wasCalled("user.xpHistory"))
    }

    // MARK: - getBadges

    func testGetBadges_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.userBadgeJSON)]"
        mockClient.stubJSON("user.badges", json: listJSON)

        let badges = try await service.getBadges()

        XCTAssertEqual(badges.count, 1)
        XCTAssertEqual(badges.first?.name, "First Task")
        XCTAssertTrue(mockClient.wasCalled("user.badges"))
    }

    // MARK: - getVerificationUnlockStatus

    func testGetVerificationUnlockStatus_callsQuery() async throws {
        mockClient.stubJSON("user.getVerificationUnlockStatus", json: TestFixtures.verificationUnlockStatusJSON)

        let status = try await service.getVerificationUnlockStatus()

        XCTAssertEqual(status.earnedCents, 2000)
        XCTAssertFalse(status.unlocked)
        XCTAssertTrue(mockClient.wasCalled("user.getVerificationUnlockStatus"))
    }

    // MARK: - checkVerificationEligibility

    func testCheckVerificationEligibility_callsQuery() async throws {
        mockClient.stubJSON("user.checkVerificationEligibility", json: TestFixtures.verificationEligibilityJSON)

        let isEligible = try await service.checkVerificationEligibility()

        XCTAssertTrue(isEligible)
        XCTAssertTrue(mockClient.wasCalled("user.checkVerificationEligibility"))
    }

    // MARK: - getVerificationEarningsLedger

    func testGetVerificationEarningsLedger_callsQuery() async throws {
        let listJSON = "[\(TestFixtures.verificationEarningsEntryJSON)]"
        mockClient.stubJSON("user.getVerificationEarningsLedger", json: listJSON)

        let entries = try await service.getVerificationEarningsLedger()

        XCTAssertEqual(entries.count, 1)
        XCTAssertTrue(mockClient.wasCalled("user.getVerificationEarningsLedger"))
    }

    // MARK: - getOnboardingStatus

    func testGetOnboardingStatus_returnsStatus() async throws {
        mockClient.stubJSON("user.getOnboardingStatus", json: TestFixtures.onboardingStatusJSON)

        let status = try await service.getOnboardingStatus()

        XCTAssertTrue(status.hasCompletedOnboarding)
        XCTAssertEqual(status.completedSteps.count, 2)
        XCTAssertTrue(mockClient.wasCalled("user.getOnboardingStatus"))
    }

    // MARK: - completeOnboarding

    func testCompleteOnboarding_callsMutation() async throws {
        mockClient.stubJSON("user.completeOnboarding", json: "{}")

        try await service.completeOnboarding()

        XCTAssertTrue(mockClient.wasCalled("user.completeOnboarding"))
        XCTAssertEqual(mockClient.callCount("user.completeOnboarding"), 1)
    }
}
