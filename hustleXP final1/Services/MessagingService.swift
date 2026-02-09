//
//  MessagingService.swift
//  hustleXP final1
//
//  Real tRPC service for in-app messaging
//  Uses existing HXMessage and HXConversation models from Models/Message.swift
//

import Foundation
import Combine

/// API response for conversation list
struct APIConversationSummary: Codable, Identifiable {
    let id: String // taskId
    let taskId: String
    let taskTitle: String
    let otherUserId: String
    let otherUserName: String
    let otherUserRole: String
    let lastMessage: String?
    let lastMessageAt: Date?
    let unreadCount: Int
}

/// Manages in-app messaging via tRPC
@MainActor
final class MessagingService: ObservableObject {
    static let shared = MessagingService()

    private let trpc = TRPCClient.shared

    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Send Message

    /// Sends a message in a task conversation
    func sendMessage(
        taskId: String,
        content: String
    ) async throws -> HXMessage {
        isLoading = true
        defer { isLoading = false }

        struct SendInput: Codable {
            let taskId: String
            let messageType: String
            let content: String?
        }

        let message: HXMessage = try await trpc.call(
            router: "messaging",
            procedure: "sendMessage",
            input: SendInput(taskId: taskId, messageType: "TEXT", content: content)
        )

        print("✅ MessagingService: Sent message in task \(taskId)")
        return message
    }

    // MARK: - Get Messages

    /// Gets all messages for a task conversation
    func getTaskMessages(
        taskId: String,
        limit: Int = 100,
        before: Date? = nil
    ) async throws -> [HXMessage] {
        struct GetMessagesInput: Codable {
            let taskId: String
            let limit: Int
            let before: Date?
        }

        let messages: [HXMessage] = try await trpc.call(
            router: "messaging",
            procedure: "getTaskMessages",
            input: GetMessagesInput(taskId: taskId, limit: limit, before: before)
        )

        print("✅ MessagingService: Fetched \(messages.count) messages for task \(taskId)")
        return messages
    }

    // MARK: - Conversations List

    /// Gets all conversations for current user
    func getConversations() async throws -> [APIConversationSummary] {
        struct EmptyInput: Codable {}

        let conversations: [APIConversationSummary] = try await trpc.call(
            router: "messaging",
            procedure: "getConversations",
            input: EmptyInput()
        )

        // Update total unread count
        self.unreadCount = conversations.reduce(0) { $0 + $1.unreadCount }

        print("✅ MessagingService: Fetched \(conversations.count) conversations")
        return conversations
    }

    // MARK: - Read Status

    /// Marks messages as read
    func markAsRead(taskId: String) async throws {
        struct MarkReadInput: Codable {
            let taskId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "messaging",
            procedure: "markAllAsRead",
            input: MarkReadInput(taskId: taskId)
        )

        print("✅ MessagingService: Marked messages as read for task \(taskId)")

        // Refresh unread count
        await refreshUnreadCount()
    }

    /// Gets total unread message count
    func getUnreadCount() async throws -> Int {
        struct EmptyInput: Codable {}

        struct CountResponse: Codable {
            let count: Int
        }

        let response: CountResponse = try await trpc.call(
            router: "messaging",
            procedure: "getUnreadCount",
            input: EmptyInput()
        )

        self.unreadCount = response.count
        return response.count
    }

    /// Refreshes unread count silently
    func refreshUnreadCount() async {
        do {
            _ = try await getUnreadCount()
        } catch {
            print("⚠️ MessagingService: Failed to refresh unread count")
        }
    }
}

// MARK: - Rating Service

/// Handles post-task ratings
@MainActor
final class RatingService: ObservableObject {
    static let shared = RatingService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Submits a rating for a completed task
    func submitRating(
        taskId: String,
        rating: Int, // 1-5
        review: String?,
        tags: [String]? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        struct RatingInput: Codable {
            let taskId: String
            let stars: Int
            let comment: String?
            let tags: [String]?
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "rating",
            procedure: "submitRating",
            input: RatingInput(taskId: taskId, stars: rating, comment: review, tags: tags)
        )

        print("✅ RatingService: Submitted \(rating)-star rating for task \(taskId)")
    }

    /// Gets rating summary for a user
    func getUserRatingSummary(userId: String) async throws -> RatingSummary {
        struct GetSummaryInput: Codable {
            let userId: String
        }

        let summary: RatingSummary = try await trpc.call(
            router: "rating",
            procedure: "getUserRatingSummary",
            input: GetSummaryInput(userId: userId)
        )

        return summary
    }

    /// Gets ratings received by current user
    func getMyRatings(limit: Int = 50) async throws -> [UserRating] {
        struct GetRatingsInput: Codable {
            let limit: Int
        }

        let ratings: [UserRating] = try await trpc.call(
            router: "rating",
            procedure: "getMyRatings",
            input: GetRatingsInput(limit: limit)
        )

        print("✅ RatingService: Fetched \(ratings.count) ratings")
        return ratings
    }
}

// MARK: - Rating Types

struct RatingSummary: Codable {
    let averageRating: Double
    let totalRatings: Int
    let ratingDistribution: [String: Int] // star count as string -> number of ratings
}

struct UserRating: Codable, Identifiable {
    let id: String
    let taskId: String
    let taskTitle: String
    let fromUserId: String
    let fromUserName: String
    let rating: Int
    let review: String?
    let createdAt: Date
}
