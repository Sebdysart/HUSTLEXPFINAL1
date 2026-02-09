//
//  Message.swift
//  hustleXP final1
//
//  Message model for in-task conversations
//

import Foundation

struct HXMessage: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: Date
    var isRead: Bool
    
    var formattedTime: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(timestamp) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        return formatter.string(from: timestamp)
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
