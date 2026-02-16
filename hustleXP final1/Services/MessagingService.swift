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

        HXLogger.info("MessagingService: Sent message in task \(taskId)", category: "General")
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
        }

        let messages: [HXMessage] = try await trpc.call(
            router: "messaging",
            procedure: "getTaskMessages",
            type: .query,
            input: GetMessagesInput(taskId: taskId)
        )

        HXLogger.info("MessagingService: Fetched \(messages.count) messages for task \(taskId)", category: "General")
        return messages
    }

    // MARK: - Conversations List

    /// Gets all conversations for current user
    func getConversations() async throws -> [APIConversationSummary] {
        struct EmptyInput: Codable {}

        let conversations: [APIConversationSummary] = try await trpc.call(
            router: "messaging",
            procedure: "getConversations",
            type: .query,
            input: EmptyInput()
        )

        // Update total unread count
        self.unreadCount = conversations.reduce(0) { $0 + $1.unreadCount }

        HXLogger.info("MessagingService: Fetched \(conversations.count) conversations", category: "General")
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

        HXLogger.info("MessagingService: Marked messages as read for task \(taskId)", category: "General")

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
            type: .query,
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
            HXLogger.error("MessagingService: Failed to refresh unread count", category: "General")
        }
    }

    // MARK: - Photo Messages

    /// Sends a photo message in a task conversation
    func sendPhotoMessage(
        taskId: String,
        photoUrls: [String],
        caption: String? = nil
    ) async throws -> HXMessage {
        isLoading = true
        defer { isLoading = false }

        struct PhotoInput: Codable {
            let taskId: String
            let photoUrls: [String]
            let caption: String?
        }

        let message: HXMessage = try await trpc.call(
            router: "messaging",
            procedure: "sendPhotoMessage",
            input: PhotoInput(taskId: taskId, photoUrls: photoUrls, caption: caption)
        )

        HXLogger.info("MessagingService: Sent photo message in task \(taskId)", category: "General")
        return message
    }

    // MARK: - Single Message Read

    /// Marks a single message as read by message ID
    func markMessageAsRead(messageId: String) async throws {
        struct MarkReadInput: Codable {
            let messageId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "messaging",
            procedure: "markAsRead",
            input: MarkReadInput(messageId: messageId)
        )

        HXLogger.info("MessagingService: Marked message \(messageId) as read", category: "General")
        await refreshUnreadCount()
    }
}

// NOTE: RatingService has been moved to its own file: RatingService.swift
