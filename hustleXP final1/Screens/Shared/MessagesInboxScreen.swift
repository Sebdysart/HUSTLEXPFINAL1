//
//  MessagesInboxScreen.swift
//  hustleXP final1
//
//  v2.5.0: Conversations inbox — lists all active task conversations
//  Wired to backend messaging.getConversations via MessagingService
//

import SwiftUI

struct MessagesInboxScreen: View {
    @Environment(Router.self) private var router
    @StateObject private var messagingService = MessagingService.shared

    @State private var conversations: [APIConversationSummary] = []
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            if isLoading {
                LoadingState(message: "Loading conversations...")
            } else if conversations.isEmpty {
                emptyState
            } else {
                conversationList
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if messagingService.unreadCount > 0 {
                    Button(action: markAllRead) {
                        Text("Read All")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.brandPurple)
                    }
                }
            }
        }
        .task {
            await loadConversations()
        }
        .refreshable {
            await loadConversations()
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "bubble.left.and.bubble.right",
            title: "No Conversations Yet",
            message: "When you accept or post a task, you'll be able to message the other party here."
        )
    }

    private var conversationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(conversations) { conv in
                    Button {
                        router.navigateToHustler(.conversation(taskId: conv.taskId))
                    } label: {
                        ConversationRow(conversation: conv)
                    }
                    .buttonStyle(.plain)

                    HXDivider()
                        .padding(.leading, 72)
                }
            }
        }
    }

    private func loadConversations() async {
        isLoading = conversations.isEmpty
        do {
            conversations = try await messagingService.getConversations()
            error = nil
        } catch {
            self.error = error
            HXLogger.error("MessagesInbox: Failed to load - \(error.localizedDescription)", category: "General")
        }
        isLoading = false
    }

    private func markAllRead() {
        Task {
            for conv in conversations where conv.unreadCount > 0 {
                try? await messagingService.markAsRead(taskId: conv.taskId)
            }
            await loadConversations()
        }
    }
}

// MARK: - Conversation Row

private struct ConversationRow: View {
    let conversation: APIConversationSummary

    private var initials: String {
        let parts = conversation.otherUserName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    private var timeString: String {
        guard let date = conversation.lastMessageAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar with unread indicator
            ZStack(alignment: .topTrailing) {
                HXAvatar(initials: initials, size: .medium)

                if conversation.unreadCount > 0 {
                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.brandBlack, lineWidth: 2)
                        )
                        .offset(x: 2, y: -2)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HXText(
                        conversation.otherUserName,
                        style: conversation.unreadCount > 0 ? .headline : .subheadline
                    )

                    Spacer()

                    HXText(timeString, style: .caption, color: .textTertiary)
                }

                HXText(
                    conversation.taskTitle,
                    style: .caption,
                    color: .brandPurple
                )
                .lineLimit(1)

                if let lastMessage = conversation.lastMessage {
                    HXText(
                        lastMessage,
                        style: .caption,
                        color: conversation.unreadCount > 0 ? .textPrimary : .textSecondary
                    )
                    .lineLimit(1)
                }
            }

            // Unread badge
            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.brandPurple)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        MessagesInboxScreen()
    }
    .environment(Router())
}
