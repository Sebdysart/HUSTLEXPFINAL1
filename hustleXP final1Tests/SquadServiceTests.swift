import XCTest
@testable import hustleXP_final1

@MainActor
final class SquadServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: SquadService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = SquadService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - createSquad

    func testCreateSquad_callsCorrectProcedure() async throws {
        mockClient.stubJSON("squad.create", json: TestFixtures.squadJSON)

        _ = try await service.createSquad(name: "Fix-It Crew", emoji: "wrench", tagline: "We fix things")

        XCTAssertTrue(mockClient.wasCalled("squad.create"))
        XCTAssertEqual(mockClient.callCount("squad.create"), 1)
    }

    func testCreateSquad_returnsSquad() async throws {
        mockClient.stubJSON("squad.create", json: TestFixtures.squadJSON)

        let squad = try await service.createSquad(name: "Fix-It Crew", emoji: "wrench", tagline: "We fix things")

        XCTAssertEqual(squad.id, "squad-1")
        XCTAssertEqual(squad.name, "Fix-It Crew")
        XCTAssertEqual(squad.organizerId, "user-1")
    }

    // MARK: - getMySquads

    func testGetMySquads_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.squadJSON)]"
        mockClient.stubJSON("squad.listMine", json: listJSON)

        let squads = try await service.getMySquads()

        XCTAssertEqual(squads.count, 1)
        XCTAssertEqual(squads.first?.name, "Fix-It Crew")
        XCTAssertTrue(mockClient.wasCalled("squad.listMine"))
    }

    // MARK: - getSquad

    func testGetSquadById_returnsSquad() async throws {
        mockClient.stubJSON("squad.getById", json: TestFixtures.squadJSON)

        let squad = try await service.getSquad(id: "squad-1")

        XCTAssertEqual(squad.id, "squad-1")
        XCTAssertEqual(squad.squadXP, 1500)
        XCTAssertTrue(mockClient.wasCalled("squad.getById"))
    }

    // MARK: - disbandSquad

    func testDisbandSquad_callsMutation() async throws {
        mockClient.stubJSON("squad.disband", json: "{}")

        try await service.disbandSquad(id: "squad-1")

        XCTAssertTrue(mockClient.wasCalled("squad.disband"))
        XCTAssertEqual(mockClient.callCount("squad.disband"), 1)
    }

    // MARK: - inviteMember

    func testInviteMember_callsMutation() async throws {
        mockClient.stubJSON("squad.invite", json: TestFixtures.squadInviteJSON)

        let invite = try await service.inviteMember(squadId: "squad-1", userId: "user-2")

        XCTAssertEqual(invite.id, "invite-1")
        XCTAssertEqual(invite.squadName, "Fix-It Crew")
        XCTAssertTrue(mockClient.wasCalled("squad.invite"))
    }

    // MARK: - respondToInvite

    func testRespondToInvite_callsMutation() async throws {
        mockClient.stubJSON("squad.respondToInvite", json: "{}")

        try await service.respondToInvite(inviteId: "invite-1", accept: true)

        XCTAssertTrue(mockClient.wasCalled("squad.respondToInvite"))
        XCTAssertEqual(mockClient.callCount("squad.respondToInvite"), 1)
    }

    // MARK: - getPendingInvites

    func testGetPendingInvites_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.squadInviteJSON)]"
        mockClient.stubJSON("squad.listInvites", json: listJSON)

        let invites = try await service.getPendingInvites()

        XCTAssertEqual(invites.count, 1)
        XCTAssertEqual(invites.first?.inviterName, "John")
        XCTAssertTrue(mockClient.wasCalled("squad.listInvites"))
    }

    // MARK: - getSquadTasks

    func testGetSquadTasks_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.squadTaskJSON)]"
        mockClient.stubJSON("squad.listTasks", json: listJSON)

        let tasks = try await service.getSquadTasks(squadId: "squad-1")

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.requiredWorkers, 3)
        XCTAssertTrue(mockClient.wasCalled("squad.listTasks"))
    }

    // MARK: - getLeaderboard

    func testGetLeaderboard_returnsArray() async throws {
        let listJSON = "[\(TestFixtures.squadJSON)]"
        mockClient.stubJSON("squad.leaderboard", json: listJSON)

        let squads = try await service.getLeaderboard()

        XCTAssertEqual(squads.count, 1)
        XCTAssertEqual(squads.first?.squadLevel, 3)
        XCTAssertTrue(mockClient.wasCalled("squad.leaderboard"))
    }
}
