//
//  ConversationScreen.swift
//  hustleXP final1
//
//  In-task messaging screen
//

import SwiftUI
import PhotosUI
import Combine

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
    @State private var photoUploadTask: Task<Void, Never>?
    @State private var showReportSheet = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCallAlert = false
    @State private var pendingMessage: String?
    @State private var showOffPlatformWarning = false
    @State private var sseSubscription: AnyCancellable?
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isOtherUserTyping = false
    @State private var otherUserName: String = ""
    @State private var taskTitle: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Task context header
                    TaskContextHeader(
                        otherUserName: otherUserName,
                        taskTitle: taskTitle
                    )
                    
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
                                        MessageBubble(message: message, maxWidth: geometry.size.width * 0.75)
                                            .id(message.id)
                                    }
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 8) // Extra padding before input bar
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

                    // Message input with safe area handling
                    MessageInputBar(
                        text: $messageText,
                        isFocused: $isInputFocused,
                        onSend: sendMessage,
                        onAttachment: { showPhotosPicker = true },
                        bottomSafeArea: geometry.safeAreaInsets.bottom
                    )
                    .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let newItem = newItem,
                               let data = try? await newItem.loadTransferable(type: Data.self) {
                                sendPhotoMessage(imageData: data)
                                selectedPhotoItem = nil
                            }
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
        .onDisappear {
            photoUploadTask?.cancel()
        }
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
                .accessibilityLabel("Conversation options")
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportUserSheet(taskId: conversationId, isPresented: $showReportSheet)
        }
        .alert("Call User", isPresented: $showCallAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Call via Phone") {
                // In a real app, this would use tel: URL scheme
                HXLogger.debug("[Conversation] Initiating call for task \(conversationId)", category: "General")
            }
        } message: {
            Text("In-app calling is coming soon. Would you like to call via your phone app?")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .alert("Keep Payment in HustleXP", isPresented: $showOffPlatformWarning) {
            Button("Cancel", role: .cancel) { pendingMessage = nil }
            Button("Send Anyway", role: .destructive) {
                if let msg = pendingMessage {
                    actuallySendMessage(msg)
                }
            }
        } message: {
            Text("Looks like you're trying to arrange payment outside the app. If you do, you LOSE:\n\n• Refund protection if something goes wrong\n• Insurance coverage for damage or theft\n• Dispute resolution\n• Verified completion history\n\nKeep payment in HustleXP to stay protected.")
        }
        .onAppear {
            loadMessages()
            subscribeToIncomingMessages()
        }
        .onDisappear {
            sseSubscription?.cancel()
            sseSubscription = nil
        }
        .onTapGesture {
            isInputFocused = false
        }
    }

    /// Listens for SSE `message.new` events scoped to this conversation.
    /// When a new message arrives from the other party, append it to the chat.
    private func subscribeToIncomingMessages() {
        let currentUserId = appState.userId ?? ""
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .filter { $0.event == "message.new" }
            .receive(on: DispatchQueue.main)
            .sink { event in
                // Decode the SSE payload
                struct NewMessagePayload: Codable {
                    let messageId: String
                    let taskId: String
                    let senderId: String
                    let recipientId: String
                    let content: String?
                    let createdAt: String
                }
                guard let payload = try? JSONDecoder().decode(NewMessagePayload.self, from: event.data),
                      payload.taskId == conversationId else { return }

                // Skip if it's our own message (already added optimistically)
                if payload.senderId == currentUserId { return }

                // Skip if we already have this message (dedupe)
                if messages.contains(where: { $0.id == payload.messageId }) { return }

                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let timestamp = formatter.date(from: payload.createdAt)
                    ?? ISO8601DateFormatter().date(from: payload.createdAt)
                    ?? Date()

                let chatMessage = ChatMessage(
                    id: payload.messageId,
                    text: payload.content ?? "",
                    isFromCurrentUser: false,
                    timestamp: timestamp,
                    senderName: otherUserName,
                    isRead: false
                )

                withAnimation(.spring(response: 0.3)) {
                    messages.append(chatMessage)
                }

                // Auto-mark as read since we're viewing the conversation
                Task { try? await messagingService.markAsRead(taskId: conversationId) }

                HXLogger.info("Conversation: Received message via SSE", category: "General")
            }
    }
    
    private func loadMessages() {
        isLoading = true
        let currentUserId = appState.userId ?? ""
        HXLogger.info("Conversation: loadMessages — userId=\(currentUserId.prefix(8)), conversationId(taskId)=\(conversationId)", category: "General")

        Task {
            // Load conversation metadata for header
            do {
                let conversations = try await messagingService.getConversations()
                HXLogger.info("Conversation: User has \(conversations.count) conversations total", category: "General")
                if let conv = conversations.first(where: { $0.taskId == conversationId }) {
                    otherUserName = conv.otherUserName
                    taskTitle = conv.taskTitle
                    HXLogger.info("Conversation: Found matching conversation — other=\(otherUserName), task=\(taskTitle)", category: "General")
                } else {
                    let inboxIds = conversations.map { String($0.taskId.prefix(8)) }.joined(separator: ", ")
                    HXLogger.error("Conversation: NO matching conversation in inbox for taskId \(conversationId). Inbox returns: \(inboxIds)", category: "General")
                }
            } catch {
                HXLogger.error("Conversation: Failed to load metadata - \(error.localizedDescription)", category: "General")
            }

            // Load messages from real API
            do {
                let hxMessages = try await messagingService.getTaskMessages(taskId: conversationId)
                HXLogger.info("Conversation: API returned \(hxMessages.count) messages for taskId \(conversationId)", category: "General")
                apiMessages = hxMessages

                // Convert HXMessage to ChatMessage — use senderId for accurate ownership
                messages = hxMessages.map { msg in
                    ChatMessage(
                        id: msg.id,
                        text: msg.content ?? "",
                        isFromCurrentUser: msg.senderId == currentUserId,
                        timestamp: msg.timestamp,
                        senderName: msg.senderId == currentUserId ? "You" : otherUserName,
                        isRead: msg.isRead,
                        photoUrls: msg.photoUrls ?? []
                    )
                }

                // Mark as read
                try? await messagingService.markAsRead(taskId: conversationId)

                HXLogger.info("Conversation: Loaded \(messages.count) messages from API", category: "General")
            } catch {
                HXLogger.error("Conversation: Failed to load messages - \(error.localizedDescription)", category: "General")
                // Don't show mock conversations — leave empty so the user sees the real state
                // (and can start a fresh conversation by sending a message).
                messages = []
                ErrorToastManager.shared.show("Couldn't load messages: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    /// Detects off-platform payment keywords (Venmo, Cash App, etc.) and phone numbers.
    /// These attempts to bypass the platform put both parties at risk.
    private func detectsOffPlatformAttempt(_ text: String) -> Bool {
        let lower = text.lowercased()
        let keywords = [
            "venmo", "cash app", "cashapp", "zelle", "paypal", "apple pay",
            "google pay", "pay me cash", "pay in cash", "pay outside", "off the app",
            "off platform", "off-platform", "skip the app", "without the app", "instead of the app",
        ]
        if keywords.contains(where: { lower.contains($0) }) {
            return true
        }
        // Detect phone numbers (e.g. 555-555-5555 or 5555555555)
        let phonePattern = #"(\+?1?[\s.-]?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}"#
        if text.range(of: phonePattern, options: .regularExpression) != nil {
            return true
        }
        return false
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let content = messageText

        // Off-platform payment detection — warn before sending
        if detectsOffPlatformAttempt(content) {
            pendingMessage = content
            showOffPlatformWarning = true
            return
        }

        actuallySendMessage(content)
    }

    private func actuallySendMessage(_ content: String) {
        messageText = ""
        pendingMessage = nil
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
                        text: sentMessage.content ?? "",
                        isFromCurrentUser: true,
                        timestamp: sentMessage.timestamp,
                        senderName: "You"
                    )
                }
                
                HXLogger.info("Conversation: Message sent via API", category: "General")
            } catch {
                HXLogger.error("Conversation: Failed to send message - \(error.localizedDescription)", category: "General")
                // Message is already displayed optimistically, just log the error
            }
            isSending = false
        }
    }
    
    // MARK: - Toolbar Actions
    
    private func viewProfile() {
        // Navigate to user profile - in a real app this would use the other user's ID
        HXLogger.debug("[Conversation] View profile for task \(conversationId)", category: "General")
        // For now, show an alert or navigate to profile
    }
    
    private func initiateCall() {
        showCallAlert = true
    }
    
    private func sendPhotoMessage(imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }

        isSending = true

        photoUploadTask = Task {
            do {
                // Step 1: Upload photo to R2 via the general-purpose upload service
                let publicUrl = try await R2UploadService.shared.uploadPhoto(
                    image,
                    purpose: .message,
                    taskId: conversationId
                )

                // Step 2: Send photo message via tRPC (stores real R2 URL in DB)
                let sentMessage = try await messagingService.sendPhotoMessage(
                    taskId: conversationId,
                    photoUrls: [publicUrl],
                    caption: nil
                )

                // Step 3: Append to local message list with photo URL
                let chatMessage = ChatMessage(
                    id: sentMessage.id,
                    text: sentMessage.content ?? "",
                    isFromCurrentUser: true,
                    timestamp: sentMessage.timestamp,
                    senderName: "You",
                    photoUrls: [publicUrl]
                )

                withAnimation(.spring(response: 0.3)) {
                    messages.append(chatMessage)
                }

                HXLogger.info("Conversation: Photo message sent to R2 (\(publicUrl))", category: "General")
            } catch {
                if !(error is CancellationError) {
                    errorMessage = "Failed to send photo: \(error.localizedDescription)"
                    showError = true
                }
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
    var photoUrls: [String] = []

    /// Whether this message contains photos
    var isPhoto: Bool { !photoUrls.isEmpty }
}

// MARK: - Task Context Header
private struct TaskContextHeader: View {
    let otherUserName: String
    let taskTitle: String

    private var initials: String {
        let parts = otherUserName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    var body: some View {
        HStack(spacing: 12) {
            HXAvatar(initials: initials.isEmpty ? "?" : initials, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                HXText(otherUserName.isEmpty ? "Loading..." : otherUserName, style: .subheadline)
                HXText(taskTitle.isEmpty ? "Task conversation" : taskTitle, style: .caption, color: .textSecondary)
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
    var maxWidth: CGFloat = 280 // Default max width, overridden by parent

    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 40)
            }

            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if message.isPhoto {
                    // Photo message: render each photo with AsyncImage
                    VStack(spacing: 4) {
                        ForEach(message.photoUrls, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: maxWidth, maxHeight: 240)
                                            .clipped()
                                    case .failure:
                                        photoPlaceholder(systemName: "photo.fill", label: "Failed to load")
                                    case .empty:
                                        photoPlaceholder(systemName: "arrow.down.circle", label: "Loading...")
                                            .overlay(ProgressView().tint(.white))
                                    @unknown default:
                                        photoPlaceholder(systemName: "photo", label: "Photo")
                                    }
                                }
                                .cornerRadius(16, corners: message.isFromCurrentUser
                                    ? [.topLeft, .topRight, .bottomLeft]
                                    : [.topLeft, .topRight, .bottomRight]
                                )
                            }
                        }

                        // Optional caption below photos
                        if !message.text.isEmpty && message.text != "Photo" {
                            Text(message.text)
                                .font(.body)
                                .foregroundStyle(message.isFromCurrentUser ? .white : Color.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                    }
                    .frame(maxWidth: maxWidth, alignment: message.isFromCurrentUser ? .trailing : .leading)
                } else {
                    // Text message: existing rendering
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
                        .frame(maxWidth: maxWidth, alignment: message.isFromCurrentUser ? .trailing : .leading)
                }

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
                Spacer(minLength: 40)
            }
        }
    }

    /// Placeholder view shown while photo is loading or on error
    private func photoPlaceholder(systemName: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 32))
                .foregroundColor(.textTertiary)
            Text(label)
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .frame(width: maxWidth * 0.8, height: 160)
        .background(Color.surfaceElevated)
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
    var bottomSafeArea: CGFloat = 0
    
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
                .accessibilityLabel("Attach photo")
                
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
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, max(12, bottomSafeArea))
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
            
            HXLogger.debug("[Report] Submitted report for task \(taskId): \(reason.rawValue)", category: "General")
            
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
