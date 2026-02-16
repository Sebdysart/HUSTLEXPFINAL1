//
//  ModelDecodingTests.swift
//  hustleXP final1Tests
//
//  Validates all Codable models decode safely from backend JSON,
//  including missing fields, snake_case aliases, and unknown enum values.
//

import XCTest
@testable import hustleXP_final1

final class ModelDecodingTests: XCTestCase {

    // MARK: - JSON Helpers

    /// Shared ISO-8601 date decoder matching TRPCClient
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: - HXUser

    func testHXUser_decodesWithMissingV180Fields() throws {
        // Backend that predates v1.8.0 will not send the four new fields
        let json = """
        {
            "id": "u1",
            "name": "Jane Doe",
            "email": "jane@example.com",
            "role": "hustler",
            "trustTier": 2,
            "rating": 4.8,
            "totalRatings": 12,
            "xp": 150,
            "tasksCompleted": 5,
            "tasksPosted": 0,
            "totalEarnings": 320.5,
            "totalSpent": 0,
            "isVerified": true,
            "createdAt": "2025-01-15T10:00:00Z"
        }
        """.data(using: .utf8)!

        let user = try decoder.decode(HXUser.self, from: json)

        XCTAssertEqual(user.id, "u1")
        XCTAssertEqual(user.name, "Jane Doe")
        XCTAssertEqual(user.email, "jane@example.com")
        XCTAssertEqual(user.role, .hustler)
        XCTAssertEqual(user.trustTier, .verified)
        XCTAssertEqual(user.xp, 150)
        XCTAssertTrue(user.isVerified)
        // v1.8.0 fields should default to 0
        XCTAssertEqual(user.unpaidTaxCents, 0)
        XCTAssertEqual(user.xpHeldBack, 0)
        XCTAssertEqual(user.verificationEarnedCents, 0)
        XCTAssertEqual(user.insuranceContributionsCents, 0)
    }

    func testHXUser_decodesWithAllFieldsPresent() throws {
        let json = """
        {
            "id": "u2",
            "name": "John Smith",
            "email": "john@example.com",
            "phone": "+15551234567",
            "bio": "Experienced hustler",
            "avatarURL": "https://example.com/avatar.jpg",
            "role": "poster",
            "trustTier": 4,
            "rating": 4.95,
            "totalRatings": 100,
            "xp": 850,
            "tasksCompleted": 45,
            "tasksPosted": 20,
            "totalEarnings": 5000.0,
            "totalSpent": 1200.0,
            "isVerified": true,
            "createdAt": "2024-06-01T08:30:00Z",
            "unpaidTaxCents": 1500,
            "xpHeldBack": 25,
            "verificationEarnedCents": 500,
            "insuranceContributionsCents": 200
        }
        """.data(using: .utf8)!

        let user = try decoder.decode(HXUser.self, from: json)

        XCTAssertEqual(user.id, "u2")
        XCTAssertEqual(user.phone, "+15551234567")
        XCTAssertEqual(user.bio, "Experienced hustler")
        XCTAssertNotNil(user.avatarURL)
        XCTAssertEqual(user.role, .poster)
        XCTAssertEqual(user.trustTier, .elite)
        XCTAssertEqual(user.unpaidTaxCents, 1500)
        XCTAssertEqual(user.xpHeldBack, 25)
        XCTAssertEqual(user.verificationEarnedCents, 500)
        XCTAssertEqual(user.insuranceContributionsCents, 200)
    }

    func testHXUser_initialsWithTwoNames() {
        let user = HXUser(
            id: "u3", name: "Alice Wonderland", email: "a@b.com",
            role: .hustler, trustTier: .rookie, rating: 5.0, totalRatings: 0,
            xp: 0, tasksCompleted: 0, tasksPosted: 0, totalEarnings: 0,
            totalSpent: 0, isVerified: false, createdAt: Date()
        )
        XCTAssertEqual(user.initials, "AW")
    }

    func testHXUser_initialsWithSingleName() {
        let user = HXUser(
            id: "u4", name: "Bob", email: "b@b.com",
            role: .hustler, trustTier: .rookie, rating: 5.0, totalRatings: 0,
            xp: 0, tasksCompleted: 0, tasksPosted: 0, totalEarnings: 0,
            totalSpent: 0, isVerified: false, createdAt: Date()
        )
        XCTAssertEqual(user.initials, "Bo")
    }

    // MARK: - TrustTier

    func testTrustTier_decodesValidInts() throws {
        for rawValue in 0...5 {
            let json = "\(rawValue)".data(using: .utf8)!
            let tier = try decoder.decode(TrustTier.self, from: json)
            XCTAssertEqual(tier.rawValue, rawValue, "TrustTier(\(rawValue)) should decode correctly")
        }
    }

    func testTrustTier_fallsBackToUnrankedForUnknown() throws {
        for badValue in [99, -1, 6, 100] {
            let json = "\(badValue)".data(using: .utf8)!
            let tier = try decoder.decode(TrustTier.self, from: json)
            XCTAssertEqual(tier, .unranked, "TrustTier(\(badValue)) should fall back to .unranked")
        }
    }

    // MARK: - UserRole

    func testUserRole_decodesHustler() throws {
        let json = "\"hustler\"".data(using: .utf8)!
        let role = try decoder.decode(UserRole.self, from: json)
        XCTAssertEqual(role, .hustler)
    }

    func testUserRole_decodesPoster() throws {
        let json = "\"poster\"".data(using: .utf8)!
        let role = try decoder.decode(UserRole.self, from: json)
        XCTAssertEqual(role, .poster)
    }

    func testUserRole_workerMapsToHustler() throws {
        let json = "\"worker\"".data(using: .utf8)!
        let role = try decoder.decode(UserRole.self, from: json)
        XCTAssertEqual(role, .hustler, "\"worker\" should map to .hustler")
    }

    func testUserRole_unknownDefaultsToHustler() throws {
        let json = "\"superadmin\"".data(using: .utf8)!
        let role = try decoder.decode(UserRole.self, from: json)
        XCTAssertEqual(role, .hustler, "Unknown role should default to .hustler")
    }

    // MARK: - TaskState

    func testTaskState_decodesAllLowercaseValues() throws {
        let validStates: [(String, TaskState)] = [
            ("posted", .posted),
            ("claimed", .claimed),
            ("in_progress", .inProgress),
            ("proof_submitted", .proofSubmitted),
            ("completed", .completed),
            ("cancelled", .cancelled),
            ("disputed", .disputed),
        ]
        for (raw, expected) in validStates {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let state = try decoder.decode(TaskState.self, from: json)
            XCTAssertEqual(state, expected, "TaskState \"\(raw)\" should decode to \(expected)")
        }
    }

    func testTaskState_decodesBackendUpperCaseStates() throws {
        let backendStates: [(String, TaskState)] = [
            ("OPEN", .posted),
            ("MATCHING", .matching),
            ("ACCEPTED", .claimed),
            ("IN_PROGRESS", .inProgress),
            ("PROOF_SUBMITTED", .proofSubmitted),
            ("COMPLETED", .completed),
            ("CANCELLED", .cancelled),
            ("DISPUTED", .disputed),
            ("EXPIRED", .expired),
        ]
        for (raw, expected) in backendStates {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let state = try decoder.decode(TaskState.self, from: json)
            XCTAssertEqual(state, expected, "Backend state \"\(raw)\" should decode to \(expected)")
        }
    }

    func testTaskState_unknownFallsBackToPosted() throws {
        let json = "\"SOMETHING_NEW\"".data(using: .utf8)!
        let state = try decoder.decode(TaskState.self, from: json)
        XCTAssertEqual(state, .posted, "Unknown state should fall back to .posted")
    }

    // MARK: - HXTask (snake_case backend JSON)

    func testHXTask_decodesFromSnakeCaseBackendJSON() throws {
        let json = """
        {
            "id": "task-1",
            "title": "Move couch",
            "description": "Help me move a couch downstairs",
            "price": 5000,
            "location": "123 Main St",
            "poster_id": "poster-abc",
            "poster_name": "Alice",
            "poster_rating": 4.5,
            "worker_id": "worker-xyz",
            "worker_name": "Bob",
            "state": "ACCEPTED",
            "required_tier": 1,
            "created_at": "2025-02-10T09:14:05Z",
            "estimated_duration": "1 hour",
            "has_active_claim": true
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(HXTask.self, from: json)

        XCTAssertEqual(task.id, "task-1")
        XCTAssertEqual(task.title, "Move couch")
        // price 5000 cents = $50.00
        XCTAssertEqual(task.payment, 50.0, accuracy: 0.01)
        XCTAssertEqual(task.posterId, "poster-abc")
        XCTAssertEqual(task.posterName, "Alice")
        XCTAssertEqual(task.posterRating, 4.5, accuracy: 0.01)
        XCTAssertEqual(task.hustlerId, "worker-xyz")
        XCTAssertEqual(task.hustlerName, "Bob")
        XCTAssertEqual(task.state, .claimed) // ACCEPTED -> .claimed
        XCTAssertEqual(task.requiredTier, .rookie)
        XCTAssertEqual(task.estimatedDuration, "1 hour")
        XCTAssertTrue(task.hasActiveClaim)
    }

    // MARK: - HXTask (camelCase frontend JSON)

    func testHXTask_decodesFromCamelCaseJSON() throws {
        let json = """
        {
            "id": "task-2",
            "title": "Dog walking",
            "description": "Walk my golden retriever",
            "payment": 25.0,
            "location": "Central Park",
            "latitude": 40.785091,
            "longitude": -73.968285,
            "estimatedDuration": "45 min",
            "posterId": "poster-def",
            "posterName": "Carol",
            "posterRating": 5.0,
            "state": "posted",
            "requiredTier": 0,
            "createdAt": "2025-03-01T12:00:00Z",
            "aiSuggestedPrice": true,
            "category": "pet_care",
            "paymentMethod": "escrow",
            "hasActiveClaim": false
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(HXTask.self, from: json)

        XCTAssertEqual(task.id, "task-2")
        XCTAssertEqual(task.payment, 25.0, accuracy: 0.01)
        XCTAssertEqual(task.latitude ?? 0, 40.785091, accuracy: 0.0001)
        XCTAssertEqual(task.longitude ?? 0, -73.968285, accuracy: 0.0001)
        XCTAssertEqual(task.posterId, "poster-def")
        XCTAssertEqual(task.state, .posted)
        XCTAssertEqual(task.requiredTier, .unranked)
        XCTAssertTrue(task.aiSuggestedPrice)
        XCTAssertEqual(task.category, .petCare)
        XCTAssertEqual(task.paymentMethod, .escrow)
        XCTAssertFalse(task.hasActiveClaim)
    }

    func testHXTask_missingOptionalFieldsDecodeGracefully() throws {
        // Minimal JSON with only id and some required-ish fields
        let json = """
        {
            "id": "task-3"
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(HXTask.self, from: json)

        XCTAssertEqual(task.id, "task-3")
        XCTAssertEqual(task.title, "Untitled Task")
        XCTAssertEqual(task.description, "")
        XCTAssertEqual(task.payment, 0)
        XCTAssertEqual(task.location, "Unknown")
        XCTAssertNil(task.latitude)
        XCTAssertNil(task.longitude)
        XCTAssertEqual(task.estimatedDuration, "~30 min")
        XCTAssertEqual(task.posterId, "")
        XCTAssertEqual(task.posterName, "Unknown")
        XCTAssertEqual(task.posterRating, 5.0, accuracy: 0.01)
        XCTAssertNil(task.hustlerId)
        XCTAssertNil(task.hustlerName)
        XCTAssertEqual(task.state, .posted)
        XCTAssertEqual(task.requiredTier, .rookie)
        XCTAssertFalse(task.aiSuggestedPrice)
        XCTAssertNil(task.paymentMethod)
        XCTAssertNil(task.category)
        XCTAssertFalse(task.hasActiveClaim)
    }

    // MARK: - TaskCategory safe fallback

    func testTaskCategory_unknownFallsBackToOther() throws {
        let json = "\"drone_delivery\"".data(using: .utf8)!
        let category = try decoder.decode(TaskCategory.self, from: json)
        XCTAssertEqual(category, .other, "Unknown TaskCategory should fall back to .other")
    }

    func testTaskCategory_decodesValidValues() throws {
        let valid: [(String, TaskCategory)] = [
            ("delivery", .delivery), ("moving", .moving), ("cleaning", .cleaning),
            ("yard_work", .yardWork), ("assembly", .assembly), ("pet_care", .petCare),
            ("shopping", .shopping), ("tech", .tech), ("other", .other),
        ]
        for (raw, expected) in valid {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let cat = try decoder.decode(TaskCategory.self, from: json)
            XCTAssertEqual(cat, expected)
        }
    }

    // MARK: - PricingConfidence safe fallback

    func testPricingConfidence_unknownFallsBackToMedium() throws {
        let json = "\"ultra_high\"".data(using: .utf8)!
        let confidence = try decoder.decode(PricingConfidence.self, from: json)
        XCTAssertEqual(confidence, .medium, "Unknown PricingConfidence should fall back to .medium")
    }

    func testPricingConfidence_decodesValidValues() throws {
        for raw in ["high", "medium", "low"] {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let conf = try decoder.decode(PricingConfidence.self, from: json)
            XCTAssertEqual(conf.rawValue, raw)
        }
    }

    // MARK: - PaymentMethod safe fallback

    func testPaymentMethod_unknownFallsBackToEscrow() throws {
        let json = "\"crypto\"".data(using: .utf8)!
        let method = try decoder.decode(PaymentMethod.self, from: json)
        XCTAssertEqual(method, .escrow, "Unknown PaymentMethod should fall back to .escrow")
    }

    func testPaymentMethod_decodesValidValues() throws {
        let valid: [(String, PaymentMethod)] = [
            ("offline_cash", .offlineCash), ("offline_venmo", .offlineVenmo),
            ("offline_cashapp", .offlineCashApp), ("escrow", .escrow),
        ]
        for (raw, expected) in valid {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let method = try decoder.decode(PaymentMethod.self, from: json)
            XCTAssertEqual(method, expected)
        }
    }

    // MARK: - FactorImpact safe fallback

    func testFactorImpact_unknownFallsBackToNeutral() throws {
        let json = "\"very_positive\"".data(using: .utf8)!
        let impact = try decoder.decode(FactorImpact.self, from: json)
        XCTAssertEqual(impact, .neutral, "Unknown FactorImpact should fall back to .neutral")
    }
}
