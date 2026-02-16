//
//  XPProgressionTests.swift
//  hustleXP final1Tests
//
//  Tests the XP/Trust tier progression math from the HXUser extension.
//  Verifies xpToNextTier values, xpProgress boundaries, and tier ladder.
//

import XCTest
@testable import hustleXP_final1

final class XPProgressionTests: XCTestCase {

    // MARK: - Helpers

    /// Create a test user at a given tier and XP level
    private func makeUser(tier: TrustTier, xp: Int) -> HXUser {
        HXUser(
            id: "test", name: "Test User", email: "test@test.com",
            role: .hustler, trustTier: tier, rating: 5.0, totalRatings: 0,
            xp: xp, tasksCompleted: 0, tasksPosted: 0, totalEarnings: 0,
            totalSpent: 0, isVerified: false, createdAt: Date()
        )
    }

    // MARK: - xpToNextTier

    func testXpToNextTier_unranked() {
        let user = makeUser(tier: .unranked, xp: 0)
        XCTAssertEqual(user.xpToNextTier, 100)
    }

    func testXpToNextTier_rookie() {
        let user = makeUser(tier: .rookie, xp: 50)
        XCTAssertEqual(user.xpToNextTier, 100)
    }

    func testXpToNextTier_verified() {
        let user = makeUser(tier: .verified, xp: 150)
        XCTAssertEqual(user.xpToNextTier, 300)
    }

    func testXpToNextTier_trusted() {
        let user = makeUser(tier: .trusted, xp: 400)
        XCTAssertEqual(user.xpToNextTier, 600)
    }

    func testXpToNextTier_elite() {
        let user = makeUser(tier: .elite, xp: 700)
        XCTAssertEqual(user.xpToNextTier, 1000)
    }

    func testXpToNextTier_master() {
        let user = makeUser(tier: .master, xp: 2000)
        XCTAssertEqual(user.xpToNextTier, 0, "Master tier has no next tier")
    }

    // MARK: - xpProgress

    func testXpProgress_masterReturns1() {
        let user = makeUser(tier: .master, xp: 5000)
        XCTAssertEqual(user.xpProgress, 1.0, accuracy: 0.001,
                        "Master tier should always return 1.0 progress")
    }

    func testXpProgress_unrankedAtZero() {
        // unranked: tierStartXP=0, xpToNextTier=100
        // progressXP = 0 - 0 = 0, tierXP = 100 - 0 = 100
        // progress = 0/100 = 0.0
        let user = makeUser(tier: .unranked, xp: 0)
        XCTAssertEqual(user.xpProgress, 0.0, accuracy: 0.001)
    }

    func testXpProgress_unrankedAt50Percent() {
        // unranked: tierStartXP=0, xpToNextTier=100
        // progressXP = 50, tierXP = 100, progress = 0.5
        let user = makeUser(tier: .unranked, xp: 50)
        XCTAssertEqual(user.xpProgress, 0.5, accuracy: 0.001)
    }

    func testXpProgress_unrankedAt100Percent() {
        // unranked: tierStartXP=0, xpToNextTier=100
        // progressXP = 100, tierXP = 100, progress = 1.0
        let user = makeUser(tier: .unranked, xp: 100)
        XCTAssertEqual(user.xpProgress, 1.0, accuracy: 0.001)
    }

    func testXpProgress_verifiedAtStart() {
        // verified: tierStartXP=100, xpToNextTier=300
        // progressXP = 100 - 100 = 0, tierXP = 300 - 100 = 200
        // progress = 0/200 = 0.0
        let user = makeUser(tier: .verified, xp: 100)
        XCTAssertEqual(user.xpProgress, 0.0, accuracy: 0.001)
    }

    func testXpProgress_verifiedAtMidpoint() {
        // verified: tierStartXP=100, xpToNextTier=300
        // progressXP = 200 - 100 = 100, tierXP = 300 - 100 = 200
        // progress = 100/200 = 0.5
        let user = makeUser(tier: .verified, xp: 200)
        XCTAssertEqual(user.xpProgress, 0.5, accuracy: 0.001)
    }

    func testXpProgress_trustedAt50Percent() {
        // trusted: tierStartXP=300, xpToNextTier=600
        // progressXP = 450 - 300 = 150, tierXP = 600 - 300 = 300
        // progress = 150/300 = 0.5
        let user = makeUser(tier: .trusted, xp: 450)
        XCTAssertEqual(user.xpProgress, 0.5, accuracy: 0.001)
    }

    func testXpProgress_eliteAt50Percent() {
        // elite: tierStartXP=600, xpToNextTier=1000
        // progressXP = 800 - 600 = 200, tierXP = 1000 - 600 = 400
        // progress = 200/400 = 0.5
        let user = makeUser(tier: .elite, xp: 800)
        XCTAssertEqual(user.xpProgress, 0.5, accuracy: 0.001)
    }

    // MARK: - Tier Progression Ladder

    func testTierProgression_fullLadder() {
        // Verify the tier ladder: unranked(0) -> rookie(1) -> verified(2) -> trusted(3) -> elite(4) -> master(5)
        let tiers: [TrustTier] = [.unranked, .rookie, .verified, .trusted, .elite, .master]
        let expectedRawValues = [0, 1, 2, 3, 4, 5]

        for (tier, expected) in zip(tiers, expectedRawValues) {
            XCTAssertEqual(tier.rawValue, expected, "\(tier) should have rawValue \(expected)")
        }
    }

    func testTierNames() {
        // unranked displays as "Rookie" (until first tier-up)
        XCTAssertEqual(TrustTier.unranked.name, "Rookie")
        XCTAssertEqual(TrustTier.rookie.name, "Rookie")
        XCTAssertEqual(TrustTier.verified.name, "Verified")
        XCTAssertEqual(TrustTier.trusted.name, "Trusted")
        XCTAssertEqual(TrustTier.elite.name, "Elite")
        XCTAssertEqual(TrustTier.master.name, "Master")
    }

    // MARK: - HXTask convenience properties

    func testTask_isAvailable() {
        let postedTask = HXTask(
            id: "t1", title: "Test", description: "", payment: 10,
            location: "Here", posterId: "p1", posterName: "P",
            state: .posted
        )
        XCTAssertTrue(postedTask.isAvailable)
        XCTAssertFalse(postedTask.isActive)

        let matchingTask = HXTask(
            id: "t2", title: "Test", description: "", payment: 10,
            location: "Here", posterId: "p1", posterName: "P",
            state: .matching
        )
        XCTAssertTrue(matchingTask.isAvailable)
    }

    func testTask_isActive() {
        let activeStates: [TaskState] = [.claimed, .inProgress, .proofSubmitted]
        for state in activeStates {
            let task = HXTask(
                id: "t", title: "Test", description: "", payment: 10,
                location: "Here", posterId: "p", posterName: "P",
                state: state
            )
            XCTAssertTrue(task.isActive, "\(state) should be active")
            XCTAssertFalse(task.isAvailable, "\(state) should not be available")
        }
    }

    func testTask_formattedPayment() {
        let task = HXTask(
            id: "t", title: "Test", description: "", payment: 42.0,
            location: "Here", posterId: "p", posterName: "P",
            state: .posted
        )
        XCTAssertEqual(task.formattedPayment, "$42")
    }
}
