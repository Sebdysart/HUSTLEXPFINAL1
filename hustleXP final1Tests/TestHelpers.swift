import Foundation
@testable import hustleXP_final1

/// Factory functions for creating test data.
/// Mirrors the backend's makeEscrow()/makeTask() pattern from escrow-service.test.ts.
enum TestFixtures {

    static let userJSON = """
    {
        "id": "test-user-1",
        "firebase_uid": "fb-uid-1",
        "email": "test@hustlexp.com",
        "display_name": "Test User",
        "avatar_url": null,
        "default_mode": "hustler",
        "trust_tier": 1,
        "xp": 150,
        "xp_level": 2,
        "is_banned": false,
        "stripe_customer_id": null,
        "stripe_connect_id": null,
        "payouts_enabled": false,
        "created_at": "2026-01-15T10:00:00Z",
        "updated_at": "2026-03-01T12:00:00Z"
    }
    """

    static let taskJSON = """
    {
        "id": "task-1",
        "poster_id": "poster-1",
        "worker_id": null,
        "title": "Test Task",
        "description": "A test task for unit tests",
        "price": 2500,
        "location": "San Francisco, CA",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "category": "delivery",
        "state": "open",
        "mode": "standard",
        "requires_proof": true,
        "instant_mode": false,
        "estimated_duration": "30 min",
        "required_tier": 1,
        "created_at": "2026-03-01T10:00:00Z",
        "updated_at": "2026-03-01T10:00:00Z"
    }
    """

    static let escrowJSON = """
    {
        "id": "esc-1",
        "task_id": "task-1",
        "poster_id": "poster-1",
        "worker_id": "worker-1",
        "amount_cents": 2500,
        "platform_fee_cents": 250,
        "tax_withholding_cents": 0,
        "insurance_contribution_cents": 0,
        "state": "funded",
        "stripe_payment_intent_id": "pi_test123",
        "created_at": "2026-03-01T10:00:00Z",
        "funded_at": "2026-03-01T10:01:00Z",
        "released_at": null
    }
    """

    static let paymentIntentJSON = """
    {
        "client_secret": "pi_test123_secret_abc",
        "payment_intent_id": "pi_test123",
        "amount_cents": 2500,
        "escrow_id": "esc-1"
    }
    """

    static let xpAwardJSON = """
    {
        "xpAwarded": 50,
        "newTotalXP": 200,
        "bonusXP": 10,
        "tierUp": false
    }
    """

    static let ratingSummaryJSON = """
    {
        "averageRating": 4.5,
        "totalRatings": 12,
        "ratingDistribution": {"1": 0, "2": 1, "3": 2, "4": 3, "5": 6}
    }
    """

    static let userRatingJSON = """
    {
        "id": "rating-1",
        "taskId": "task-1",
        "taskTitle": "Fix Sink",
        "fromUserId": "user-2",
        "fromUserName": "Jane",
        "rating": 5,
        "review": "Great work!",
        "createdAt": "2026-01-15T10:00:00Z"
    }
    """

    static let squadMemberJSON = """
    {
        "id": "member-1",
        "userId": "user-1",
        "userName": "TestUser",
        "userInitials": "TU",
        "role": "organizer",
        "trustTier": 4,
        "rating": 4.8,
        "completedTasks": 120,
        "joinedAt": "2026-01-01T00:00:00Z",
        "lastActiveAt": "2026-03-01T00:00:00Z",
        "isOnline": true
    }
    """

    static let squadJSON = """
    {
        "id": "squad-1",
        "name": "Fix-It Crew",
        "organizerId": "user-1",
        "organizerName": "TestUser",
        "members": [\(squadMemberJSON)],
        "status": "active",
        "maxMembers": 5,
        "createdAt": "2026-01-01T00:00:00Z",
        "lastActiveAt": "2026-03-01T00:00:00Z",
        "totalTasksCompleted": 25,
        "totalEarnings": 5000.0,
        "averageRating": 4.8,
        "squadXP": 1500,
        "squadLevel": 3,
        "emoji": "wrench",
        "tagline": "We fix things"
    }
    """

    static let squadInviteJSON = """
    {
        "id": "invite-1",
        "squadId": "squad-1",
        "squadName": "Fix-It Crew",
        "squadEmoji": "wrench",
        "inviterId": "user-1",
        "inviterName": "John",
        "inviteeId": "user-2",
        "status": "pending",
        "sentAt": "2026-03-01T00:00:00Z",
        "expiresAt": "2026-03-08T00:00:00Z"
    }
    """

    static let squadTaskJSON = """
    {
        "id": "squad-task-1",
        "taskId": "task-1",
        "squadId": "squad-1",
        "task": {
            "id": "task-1",
            "title": "Move Furniture",
            "description": "Help move furniture across town",
            "payment": 75.0,
            "location": "San Francisco, CA",
            "latitude": 37.7749,
            "longitude": -122.4194,
            "estimatedDuration": "2 hours",
            "posterId": "poster-1",
            "posterName": "Alice",
            "posterRating": 4.9,
            "state": "posted",
            "requiredTier": 1,
            "createdAt": "2026-03-01T10:00:00Z"
        },
        "requiredWorkers": 3,
        "acceptedWorkers": ["worker-1"],
        "paymentSplit": "equal",
        "perWorkerPayment": 25.0,
        "status": "recruiting",
        "createdAt": "2026-03-01T10:00:00Z"
    }
    """

    // MARK: - Messaging Service Fixtures

    static let messageJSON = """
    {
        "id": "msg-1",
        "conversationId": "task-1",
        "senderId": "user-2",
        "senderName": "Jane",
        "content": "Hello!",
        "timestamp": "2026-03-01T10:00:00Z",
        "isRead": false,
        "messageType": "TEXT",
        "photoUrls": []
    }
    """

    static let conversationSummaryJSON = """
    {
        "id": "task-1",
        "taskId": "task-1",
        "taskTitle": "Fix Sink",
        "otherUserId": "user-2",
        "otherUserName": "Jane",
        "otherUserRole": "hustler",
        "lastMessage": "Hello!",
        "lastMessageAt": "2026-03-01T10:00:00Z",
        "unreadCount": 2
    }
    """

    // MARK: - User Profile Service Fixtures

    static let hxUserJSON = """
    {
        "id": "user-1",
        "name": "Test User",
        "email": "test@hustlexp.com",
        "phone": null,
        "bio": "A test bio",
        "avatarURL": null,
        "role": "hustler",
        "trustTier": 2,
        "rating": 4.5,
        "totalRatings": 10,
        "xp": 150,
        "tasksCompleted": 5,
        "tasksPosted": 3,
        "totalEarnings": 250.0,
        "totalSpent": 100.0,
        "isVerified": false,
        "createdAt": "2026-01-15T10:00:00Z"
    }
    """

    static let xpHistoryEntryJSON = """
    {
        "id": "xp-1",
        "userId": "user-1",
        "amount": 50,
        "reason": "Task completed",
        "taskId": "task-1",
        "taskTitle": "Fix Sink",
        "createdAt": "2026-01-15T10:00:00Z"
    }
    """

    static let userBadgeJSON = """
    {
        "id": "badge-1",
        "name": "First Task",
        "description": "Complete your first task",
        "iconName": "star.fill",
        "tier": "bronze",
        "earnedAt": "2026-01-15T10:00:00Z",
        "criteria": "Complete 1 task"
    }
    """

    static let onboardingStatusJSON = """
    {
        "hasCompletedOnboarding": true,
        "completedSteps": ["role_selection", "profile_setup"],
        "currentStep": null
    }
    """

    static let verificationUnlockStatusJSON = """
    {
        "earnedCents": 2000,
        "thresholdCents": 4000,
        "percentage": 50.0,
        "unlocked": false,
        "tasksCompleted": 3,
        "remainingCents": 2000
    }
    """

    static let verificationEligibilityJSON = """
    {
        "isEligible": true
    }
    """

    static let verificationEarningsEntryJSON = """
    {
        "id": "entry-1",
        "taskId": "task-1",
        "taskTitle": "Fix Sink",
        "escrowId": "esc-1",
        "netPayoutCents": 2000,
        "earnedAt": "2026-01-15T10:00:00Z"
    }
    """

    // MARK: - Notification Service Fixtures

    static let notificationJSON = """
    {
        "id": "notif-1",
        "userId": "user-1",
        "type": "taskAccepted",
        "title": "Task Accepted",
        "body": "Your task was accepted by Jane",
        "data": {"taskId": "task-1"},
        "isRead": false,
        "isClicked": false,
        "createdAt": "2026-03-01T10:00:00Z"
    }
    """

    static let notificationPreferencesJSON = """
    {
        "pushEnabled": true,
        "emailEnabled": false,
        "taskUpdates": true,
        "paymentUpdates": true,
        "messageNotifications": true,
        "marketingEmails": false
    }
    """

    // MARK: - Recurring Task Service Fixtures

    static let recurringSeriesJSON = """
    {
        "id": "series-1",
        "poster_id": "user-1",
        "template_task_id": "task-tpl-1",
        "pattern": "weekly",
        "day_of_week": 1,
        "day_of_month": null,
        "time_of_day": "09:00",
        "status": "active",
        "title": "Weekly Lawn Mow",
        "description": "Mow the front lawn",
        "payment": 5000,
        "location": "123 Main St",
        "category": "yard_work",
        "estimated_duration": "1 hour",
        "required_tier": 1,
        "occurrence_count": 10,
        "completed_count": 5,
        "preferred_worker_id": null,
        "preferred_worker_name": null,
        "next_occurrence": "2026-03-10T09:00:00Z",
        "start_date": "2026-01-01T00:00:00Z",
        "end_date": null,
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-03-01T00:00:00Z"
    }
    """

    static let recurringOccurrenceJSON = """
    {
        "id": "occ-1",
        "series_id": "series-1",
        "task_id": "task-1",
        "occurrence_number": 1,
        "scheduled_date": "2026-03-10T00:00:00Z",
        "status": "completed",
        "worker_id": "user-2",
        "worker_name": "Jane",
        "completed_at": "2026-03-10T11:00:00Z",
        "rating": 5
    }
    """

    /// Creates a modified version of a JSON fixture by replacing a key's value.
    static func modify(_ json: String, key: String, value: String) -> String {
        // Simple key-value replacement for test fixtures
        let pattern = "\"\(key)\": [^,\\n}]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return json }
        let range = NSRange(json.startIndex..., in: json)
        return regex.stringByReplacingMatches(
            in: json, range: range,
            withTemplate: "\"\(key)\": \(value)"
        )
    }
}

/// Convenience error for testing error paths.
struct MockNetworkError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }

    static let offline = MockNetworkError(message: "The Internet connection appears to be offline.")
    static let serverError = MockNetworkError(message: "Internal Server Error")
    static let unauthorized = MockNetworkError(message: "Unauthorized")
}
