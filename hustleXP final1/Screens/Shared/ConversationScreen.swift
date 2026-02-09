//
//  ConversationScreen.swift
//  hustleXP final1
//
//  In-task messaging screen
//

import SwiftUI

struct ConversationScreen: View {
    let conversationId: String
    
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = true
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Task context header
                TaskContextHeader()
                
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if isLoading {
                                LoadingState(message: "Loading messages...")
                                    .frame(height: 200)
                            } else if messages.isEmpty {
                                EmptyMessagesView()
                            } else {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input
                MessageInputBar(
                    text: $messageText,
                    isFocused: $isInputFocused,
                    onSend: sendMessage
                )
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("View Profile", systemImage: "person.circle")
                    }
                    Button(action: {}) {
                        Label("Call", systemImage: "phone")
                    }
                    Divider()
                    Button(role: .destructive, action: {}) {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .onAppear {
            loadMessages()
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
    
    private func loadMessages() {
        isLoading = true
        
        // Simulate loading mock messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages = [
                ChatMessage(
                    id: "1",
                    text: "Hi! I've claimed your task and I'm on my way.",
                    isFromCurrentUser: false,
                    timestamp: Date().addingTimeInterval(-3600),
                    senderName: "Jane D."
                ),
                ChatMessage(
                    id: "2",
                    text: "Great! Let me know when you arrive.",
                    isFromCurrentUser: true,
                    timestamp: Date().addingTimeInterval(-3500),
                    senderName: "You"
                ),
                ChatMessage(
                    id: "3",
                    text: "I'm here now. The package is ready for pickup?",
                    isFromCurrentUser: false,
                    timestamp: Date().addingTimeInterval(-1800),
                    senderName: "Jane D."
                ),
                ChatMessage(
                    id: "4",
                    text: "Yes, it's at the front desk. Ask for the brown box labeled 'Smith'.",
                    isFromCurrentUser: true,
                    timestamp: Date().addingTimeInterval(-1700),
                    senderName: "You"
                )
            ]
            isLoading = false
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date(),
            senderName: "You"
        )
        
        withAnimation(.spring(response: 0.3)) {
            messages.append(newMessage)
        }
        
        messageText = ""
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    let senderName: String
}

// MARK: - Task Context Header
private struct TaskContextHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            HXAvatar(initials: "JD", size: .small)
            
            VStack(alignment: .leading, spacing: 2) {
                HXText("Jane Doe", style: .subheadline)
                HXText("Deliver Package Downtown", style: .caption, color: .textSecondary)
            }
            
            Spacer()
            
            HXBadge(variant: .status(.inProgress))
        }
        .padding(16)
        .background(Color.surfaceElevated)
    }
}

// MARK: - Empty Messages View
private struct EmptyMessagesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.textSecondary)
            }
            
            VStack(spacing: 8) {
                HXText("No messages yet", style: .headline)
                HXText(
                    "Start the conversation to coordinate the task.",
                    style: .subheadline,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Message Bubble
private struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.isFromCurrentUser ? .white : Color.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromCurrentUser
                            ? Color.brandPurple
                            : Color.surfaceElevated
                    )
                    .cornerRadius(20, corners: message.isFromCurrentUser
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                    )
                
                HXText(
                    formatTime(message.timestamp),
                    style: .caption,
                    color: .textTertiary
                )
            }
            
            if !message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Message Input Bar
private struct MessageInputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HStack(spacing: 12) {
                // Attachment button
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.textSecondary)
                }
                
                // Text input
                TextField("", text: $text, prompt: Text("Type a message...").foregroundColor(.textTertiary))
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.surfaceElevated)
                    .cornerRadius(20)
                    .focused(isFocused)
                
                // Send button
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.textTertiary
                                : Color.brandPurple
                        )
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Color.brandBlack)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        ConversationScreen(conversationId: "conv-123")
    }
}
