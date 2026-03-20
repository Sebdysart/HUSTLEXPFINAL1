//
//  Message.swift
//  hustleXP final1
//
//  Message model for in-task conversations
//

import Foundation

struct HXMessage: Identifiable, Codable {
    // MARK: - Backend-native fields (task_messages table, camelCase via keyDecodingStrategy)
    let id: String
    let taskId: String           // DB: task_id (was conversationId — corrected Mar 2026)
    let senderId: String         // DB: sender_id
    let receiverId: String       // DB: receiver_id
    let content: String?         // DB: content (optional — absent for AUTO/LOCATION types)
    let createdAt: Date          // DB: created_at (was timestamp — corrected Mar 2026)
    let readAt: Date?            // DB: read_at (null = unread; was isRead:Bool — corrected Mar 2026)
    let messageType: String?     // DB: message_type ('TEXT'|'AUTO'|'PHOTO'|'LOCATION')
    let photoUrls: [String]?     // DB: photo_urls
    let autoMessageTemplate: String? // DB: auto_message_template
    let updatedAt: Date          // DB: updated_at

    // MARK: - Backward-compat computed aliases (UI code uses these)
    /// Alias for taskId — task-scoped conversations are identified by taskId
    var conversationId: String { taskId }
    /// Alias for createdAt — timestamp was the old field name
    var timestamp: Date { createdAt }
    /// True when readAt is set (receiver has read the message)
    var isRead: Bool { readAt != nil }

    // MARK: - Helpers

    var formattedTime: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(createdAt) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        return formatter.string(from: createdAt)
    }

    /// Whether this message is a photo message
    var isPhoto: Bool {
        messageType == "PHOTO" || !(photoUrls ?? []).isEmpty
    }
}

struct HXConversation: Identifiable, Codable {
    let id: String
    let taskId: String
    let taskTitle: String
    let participants: [String]
    var messages: [HXMessage]
    var lastMessageAt: Date
    var unreadCount: Int
}
