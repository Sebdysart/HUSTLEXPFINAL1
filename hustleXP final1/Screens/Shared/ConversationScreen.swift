//
//  ConversationScreen.swift
//  hustleXP final1
//
//  In-task messaging screen
//

import SwiftUI
import PhotosUI

struct ConversationScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    let conversationId: String // This is the taskId
    
    // v2.2.0: Real API service
    @StateObject private var messagingService = MessagingService.shared
    
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var apiMessages: [HXMessage] = []
    @State private var isLoading = true
    @State private var isSending = false
    @State private var showReportSheet = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCallAlert = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isOtherUserTyping = false
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
                
                // Typing indicator
                if isOtherUserTyping {
                    HStack(spacing: 4) {
                        Text("Typing")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        TypingDotsView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }

                // Message input
                MessageInputBar(
                    text: $messageText,
                    isFocused: $isInputFocused,
                    onSend: sendMessage,
                    onAttachment: { showPhotosPicker = true }
                )
                .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let newItem = newItem,
                           let data = try? await newItem.loadTransferable(type: Data.self) {
                            sendPhotoMessage(imageData: data)
                        }
                    }
                }
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
                    Button(action: viewProfile) {
                        Label("View Profile", systemImage: "person.circle")
                    }
                    Button(action: initiateCall) {
                        Label("Call", systemImage: "phone")
                    }
                    Divider()
                    Button(role: .destructive, action: { showReportSheet = true }) {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportUserSheet(taskId: conversationId, isPresented: $showReportSheet)
        }
        .alert("Call User", isPresented: $showCallAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Call via Phone") {
                // In a real app, this would use tel: URL scheme
                print("[Conversation] Initiating call for task \(conversationId)")
            }
        } message: {
            Text("In-app calling is coming soon. Would you like to call via your phone app?")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
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
        
        // v2.2.0: Load messages from real API
        Task {
            do {
                let hxMessages = try await messagingService.getTaskMessages(taskId: conversationId)
                apiMessages = hxMessages
                
                // Convert HXMessage to ChatMessage for display
                // Note: We determine isFromCurrentUser by checking if senderId matches current user
                messages = hxMessages.map { msg in
                    ChatMessage(
                        id: msg.id,
                        text: msg.content,
                        isFromCurrentUser: msg.senderName == "You", // Simplified check
                        timestamp: msg.timestamp,
                        senderName: msg.senderName
                    )
                }
                
                // Mark as read
                try? await messagingService.markAsRead(taskId: conversationId)
                
                print("✅ Conversation: Loaded \(messages.count) messages from API")
            } catch {
                print("⚠️ Conversation: API failed, using mock - \(error.localizedDescription)")
                
                // Fall back to mock messages
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
            }
            isLoading = false
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let content = messageText
        messageText = ""
        isSending = true
        
        // Optimistically add message to UI
        let optimisticMessage = ChatMessage(
            id: UUID().uuidString,
            text: content,
            isFromCurrentUser: true,
            timestamp: Date(),
            senderName: "You"
        )
        
        withAnimation(.spring(response: 0.3)) {
            messages.append(optimisticMessage)
        }
        
        // v2.2.0: Send message via real API
        Task {
            do {
                let sentMessage = try await messagingService.sendMessage(taskId: conversationId, content: content)
                
                // Update the optimistic message with real ID
                if let index = messages.firstIndex(where: { $0.id == optimisticMessage.id }) {
                    messages[index] = ChatMessage(
                        id: sentMessage.id,
                        text: sentMessage.content,
                        isFromCurrentUser: true,
                        timestamp: sentMessage.timestamp,
                        senderName: sentMessage.senderName
                    )
                }
                
                print("✅ Conversation: Message sent via API")
            } catch {
                print("⚠️ Conversation: Failed to send message - \(error.localizedDescription)")
                // Message is already displayed optimistically, just log the error
            }
            isSending = false
        }
    }
    
    // MARK: - Toolbar Actions
    
    private func viewProfile() {
        // Navigate to user profile - in a real app this would use the other user's ID
        print("[Conversation] View profile for task \(conversationId)")
        // For now, show an alert or navigate to profile
    }
    
    private func initiateCall() {
        showCallAlert = true
    }
    
    private func sendPhotoMessage(imageData: Data) {
        guard UIImage(data: imageData) != nil else { return }
        
        isSending = true
        
        Task {
            do {
                // Upload photo first
                let filename = "chat_\(conversationId)_\(Int(Date().timeIntervalSince1970)).jpg"
                
                // Get presigned URL and upload
                // For now, create a mock URL - in production this would upload to R2
                let photoUrl = "https://storage.hustlexp.com/chat/\(filename)"
                
                // Send photo message via API
                let sentMessage = try await messagingService.sendPhotoMessage(
                    taskId: conversationId,
                    photoUrls: [photoUrl],
                    caption: nil
                )
                
                // Add to local messages
                let chatMessage = ChatMessage(
                    id: sentMessage.id,
                    text: "📷 Photo",
                    isFromCurrentUser: true,
                    timestamp: sentMessage.timestamp,
                    senderName: sentMessage.senderName
                )
                
                withAnimation(.spring(response: 0.3)) {
                    messages.append(chatMessage)
                }
                
                print("✅ Conversation: Photo message sent")
            } catch {
                errorMessage = "Failed to send photo: \(error.localizedDescription)"
                showError = true
            }
            isSending = false
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    let senderName: String
    var isRead: Bool = false
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

                // Delivery status for sent messages
                if message.isFromCurrentUser {
                    HStack(spacing: 4) {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(message.isRead ? .brandPurple : .textTertiary)
                        Text(message.isRead ? "Read" : "Sent")
                            .font(.system(size: 10))
                            .foregroundColor(.textTertiary)
                    }
                }
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
    let onAttachment: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HStack(spacing: 12) {
                // Attachment button
                Button(action: onAttachment) {
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

// MARK: - Report User Sheet

struct ReportUserSheet: View {
    let taskId: String
    @Binding var isPresented: Bool
    
    @State private var selectedReason: ReportReason?
    @State private var additionalDetails: String = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    enum ReportReason: String, CaseIterable {
        case harassment = "Harassment or abuse"
        case spam = "Spam or scam"
        case inappropriate = "Inappropriate content"
        case noShow = "No show / didn't complete task"
        case fraud = "Fraudulent activity"
        case other = "Other"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                
                if showSuccess {
                    successView
                } else {
                    reportForm
                }
            }
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
    
    private var reportForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    HXText("What's the issue?", style: .headline)
                    HXText("Select the reason for your report", style: .caption, color: .textSecondary)
                }
                
                VStack(spacing: 0) {
                    ForEach(ReportReason.allCases, id: \.self) { reason in
                        Button(action: { selectedReason = reason }) {
                            HStack {
                                HXText(reason.rawValue, style: .body)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.brandPurple)
                                }
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)
                        
                        if reason != ReportReason.allCases.last {
                            HXDivider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color.surfaceElevated)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    HXText("Additional details (optional)", style: .subheadline)
                    
                    TextField("", text: $additionalDetails, prompt: Text("Describe what happened...").foregroundColor(.textTertiary), axis: .vertical)
                        .lineLimit(3...6)
                        .padding(16)
                        .background(Color.surfaceElevated)
                        .cornerRadius(12)
                        .foregroundStyle(Color.textPrimary)
                }
                
                HXButton(
                    isSubmitting ? "Submitting..." : "Submit Report",
                    variant: selectedReason != nil ? .primary : .secondary,
                    isLoading: isSubmitting
                ) {
                    submitReport()
                }
                .disabled(selectedReason == nil || isSubmitting)
            }
            .padding(24)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                HXText("Report Submitted", style: .title2)
                HXText("Thank you for helping keep HustleXP safe. We'll review your report within 24 hours.", style: .body, color: .textSecondary, alignment: .center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HXButton("Done") {
                isPresented = false
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private func submitReport() {
        guard let reason = selectedReason else { return }
        
        isSubmitting = true
        
        // Simulate API call
        Task {
            // In production, this would call a real API endpoint
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            print("[Report] Submitted report for task \(taskId): \(reason.rawValue)")
            
            isSubmitting = false
            withAnimation {
                showSuccess = true
            }
        }
    }
}

// MARK: - Typing Dots View
struct TypingDotsView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.textTertiary)
                    .frame(width: 5, height: 5)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

#Preview {
    NavigationStack {
        ConversationScreen(conversationId: "conv-123")
    }
}
