//
//  NotificationService.swift
//  hustleXP final1
//
//  Real tRPC service for in-app notifications
//  Maps to backend notification.ts router
//

import Foundation
import Combine

// MARK: - Notification Types

/// Notification from backend
struct HXNotification: Codable, Identifiable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let body: String
    let data: [String: String]?
    let isRead: Bool
    let isClicked: Bool
    let createdAt: Date

    /// Convenience: notification category for grouping
    var category: NotificationCategory {
        NotificationCategory(rawValue: type) ?? .general
    }
}

/// Notification categories matching backend types
enum NotificationCategory: String, Codable, CaseIterable {
    case taskAccepted = "TASK_ACCEPTED"
    case taskCompleted = "TASK_COMPLETED"
    case proofSubmitted = "PROOF_SUBMITTED"
    case proofApproved = "PROOF_APPROVED"
    case proofRejected = "PROOF_REJECTED"
    case paymentReceived = "PAYMENT_RECEIVED"
    case paymentSent = "PAYMENT_SENT"
    case messageReceived = "MESSAGE_RECEIVED"
    case ratingReceived = "RATING_RECEIVED"
    case tierUp = "TIER_UP"
    case badgeEarned = "BADGE_EARNED"
    case insuranceClaim = "INSURANCE_CLAIM"
    case general = "GENERAL"

    var iconName: String {
        switch self {
        case .taskAccepted, .taskCompleted: return "checkmark.circle.fill"
        case .proofSubmitted, .proofApproved, .proofRejected: return "doc.text.fill"
        case .paymentReceived, .paymentSent: return "dollarsign.circle.fill"
        case .messageReceived: return "message.fill"
        case .ratingReceived: return "star.fill"
        case .tierUp: return "arrow.up.circle.fill"
        case .badgeEarned: return "rosette"
        case .insuranceClaim: return "shield.fill"
        case .general: return "bell.fill"
        }
    }
}

/// Notification preferences
struct NotificationPreferences: Codable {
    var pushEnabled: Bool
    var emailEnabled: Bool
    var taskUpdates: Bool
    var paymentUpdates: Bool
    var messageNotifications: Bool
    var marketingEmails: Bool

    /// Maps frontend preferences to backend updatePreferences input
    var backendInput: BackendNotificationPrefsInput {
        BackendNotificationPrefsInput(
            pushEnabled: pushEnabled,
            emailEnabled: emailEnabled,
            categoryPreferences: [
                "taskUpdates": taskUpdates,
                "paymentUpdates": paymentUpdates,
                "messageNotifications": messageNotifications,
                "marketingEmails": marketingEmails
            ]
        )
    }
}

/// Matches backend notification.updatePreferences input schema
struct BackendNotificationPrefsInput: Codable {
    let pushEnabled: Bool?
    let emailEnabled: Bool?
    let categoryPreferences: [String: Bool]?
}

// MARK: - Notification Service

/// Manages in-app notifications via tRPC
@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    private let trpc = TRPCClient.shared

    @Published var notifications: [HXNotification] = []
    @Published var unreadCount: Int = 0
    @Published var preferences: NotificationPreferences?
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Get Notifications

    /// Gets paginated notification list
    func getNotifications(limit: Int = 50, offset: Int = 0) async throws -> [HXNotification] {
        struct GetListInput: Codable {
            let limit: Int
            let offset: Int
        }

        let list: [HXNotification] = try await trpc.call(
            router: "notification",
            procedure: "getList",
            type: .query,
            input: GetListInput(limit: limit, offset: offset)
        )

        if offset == 0 {
            self.notifications = list
        } else {
            self.notifications.append(contentsOf: list)
        }

        print("✅ NotificationService: Fetched \(list.count) notifications")
        return list
    }

    /// Gets unread notification count
    func getUnreadCount() async throws -> Int {
        struct EmptyInput: Codable {}

        struct CountResponse: Codable {
            let count: Int
        }

        let response: CountResponse = try await trpc.call(
            router: "notification",
            procedure: "getUnreadCount",
            type: .query,
            input: EmptyInput()
        )

        self.unreadCount = response.count
        return response.count
    }

    /// Gets a single notification by ID
    func getNotification(id: String) async throws -> HXNotification {
        struct GetByIdInput: Codable {
            let notificationId: String
        }

        let notification: HXNotification = try await trpc.call(
            router: "notification",
            procedure: "getById",
            type: .query,
            input: GetByIdInput(notificationId: id)
        )

        return notification
    }

    // MARK: - Mark as Read

    /// Marks a single notification as read
    func markAsRead(notificationId: String) async throws {
        struct MarkReadInput: Codable {
            let notificationId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "notification",
            procedure: "markAsRead",
            input: MarkReadInput(notificationId: notificationId)
        )

        // Update local state - refresh if notification was in our list
        if notifications.contains(where: { $0.id == notificationId }) {
            _ = try? await getNotifications()
        }
        await refreshUnreadCount()

        print("✅ NotificationService: Marked notification \(notificationId) as read")
    }

    /// Marks all notifications as read
    func markAllAsRead() async throws {
        struct EmptyInput: Codable {}
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "notification",
            procedure: "markAllAsRead",
            input: EmptyInput()
        )

        self.unreadCount = 0
        // Refresh list
        _ = try? await getNotifications()

        print("✅ NotificationService: Marked all notifications as read")
    }

    /// Marks a notification as clicked (for analytics tracking)
    func markAsClicked(notificationId: String) async throws {
        struct MarkClickedInput: Codable {
            let notificationId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "notification",
            procedure: "markAsClicked",
            input: MarkClickedInput(notificationId: notificationId)
        )
    }

    // MARK: - Preferences

    /// Gets notification preferences
    func getPreferences() async throws -> NotificationPreferences {
        struct EmptyInput: Codable {}

        let prefs: NotificationPreferences = try await trpc.call(
            router: "notification",
            procedure: "getPreferences",
            type: .query,
            input: EmptyInput()
        )

        self.preferences = prefs
        return prefs
    }

    /// Updates notification preferences
    /// Maps frontend preferences to backend schema
    func updatePreferences(_ prefs: NotificationPreferences) async throws {
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "notification",
            procedure: "updatePreferences",
            input: prefs.backendInput
        )

        self.preferences = prefs
        print("✅ NotificationService: Updated notification preferences")
    }

    // MARK: - Helpers

    /// Refreshes unread count silently
    func refreshUnreadCount() async {
        do {
            _ = try await getUnreadCount()
        } catch {
            print("⚠️ NotificationService: Failed to refresh unread count")
        }
    }

    /// Refreshes notifications silently
    func refresh() async {
        do {
            _ = try await getNotifications()
            _ = try await getUnreadCount()
        } catch {
            print("⚠️ NotificationService: Failed to refresh")
        }
    }
}
