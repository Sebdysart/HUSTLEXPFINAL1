import XCTest
@testable import hustleXP_final1

@MainActor
final class EscrowServiceTests: XCTestCase {

    var mockClient: MockTRPCClient!
    var service: EscrowService!

    override func setUp() {
        super.setUp()
        mockClient = MockTRPCClient()
        service = EscrowService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    // MARK: - createPaymentIntent

    func testCreatePaymentIntent_returnsClientSecret() async throws {
        mockClient.stubJSON("escrow.createPaymentIntent", json: TestFixtures.paymentIntentJSON)

        let result = try await service.createPaymentIntent(taskId: "task-1")

        XCTAssertEqual(result.clientSecret, "pi_test123_secret_abc")
        XCTAssertEqual(result.escrowId, "esc-1")
        XCTAssertTrue(mockClient.wasCalled("escrow.createPaymentIntent"))
    }

    // MARK: - getEscrowByTask

    func testGetEscrowByTask_returnsEscrow() async throws {
        mockClient.stubJSON("escrow.getByTaskId", json: TestFixtures.escrowJSON)

        let escrow = try await service.getEscrowByTask(taskId: "task-1")

        XCTAssertEqual(escrow.id, "esc-1")
        XCTAssertEqual(escrow.amountCents, 2500)
        XCTAssertEqual(escrow.state, .funded)
    }

    // MARK: - releaseToWorker

    func testReleaseToWorker_transitionsState() async throws {
        let releasedJSON = TestFixtures.modify(
            TestFixtures.escrowJSON,
            key: "state",
            value: "\"released\""
        )
        mockClient.stubJSON("escrow.release", json: releasedJSON)

        let escrow = try await service.releaseToWorker(escrowId: "esc-1")

        XCTAssertEqual(escrow.state, .released)
        XCTAssertTrue(mockClient.wasCalled("escrow.release"))
    }

    // MARK: - refundToPoster

    func testRefundToPoster_transitionsState() async throws {
        let refundedJSON = TestFixtures.modify(
            TestFixtures.escrowJSON,
            key: "state",
            value: "\"refunded\""
        )
        mockClient.stubJSON("escrow.refund", json: refundedJSON)

        let escrow = try await service.refundToPoster(escrowId: "esc-1")

        XCTAssertEqual(escrow.state, .refunded)
    }

    // MARK: - awardXP

    func testAwardXP_returnsXPResult() async throws {
        mockClient.stubJSON("escrow.awardXP", json: TestFixtures.xpAwardJSON)

        let result = try await service.awardXP(
            taskId: "task-1",
            escrowId: "esc-1",
            baseXP: 50
        )

        XCTAssertEqual(result.xpAwarded, 50)
        XCTAssertEqual(result.newTotalXP, 200)
        XCTAssertEqual(result.tierUp, false)
    }

    // MARK: - Error Handling

    func testGetEscrow_networkError_throws() async {
        mockClient.stubError("escrow.getByTaskId", error: MockNetworkError.serverError)

        do {
            _ = try await service.getEscrowByTask(taskId: "task-1")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    // MARK: - getPaymentHistory

    func testGetPaymentHistory_returnsArray() async throws {
        mockClient.stubJSON("escrow.getHistory", json: "[\(TestFixtures.escrowJSON)]")

        let history = try await service.getPaymentHistory()

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.id, "esc-1")
    }
}
