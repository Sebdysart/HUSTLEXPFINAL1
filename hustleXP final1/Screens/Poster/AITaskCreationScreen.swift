//
//  AITaskCreationScreen.swift
//  hustleXP final1
//
//  Conversational AI-powered task creation for Posters
//  Neon Nexus aesthetic with centered prompts and glowing inputs
//

import SwiftUI
import MapKit

struct AITaskCreationScreen: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [AIConversationMessage] = []
    @State private var userInput: String = ""
    @State private var taskDraft = AITaskDraft()
    @State private var isTyping: Bool = false
    @State private var showTaskPreview: Bool = false
    @State private var isPosting: Bool = false
    @State private var showReviewSheet: Bool = false
    @State private var postError: String?
    @State private var showPostError: Bool = false
    
    // Animation states
    @State private var showInitialPrompt: Bool = true
    @State private var promptScale: CGFloat = 0.8
    @State private var promptOpacity: Double = 0
    @State private var glowIntensity: Double = 0.3
    @State private var orbRotation: Double = 0
    
    // AIConversationService provides conversational UI (keyword extraction, offline-capable)
    // Real AI pricing/XP happens on backend via TaskService.createTask() -> ScoperAIService
    // This pattern is intentional: lightweight client-side UX + server-side AI validation
    private let aiService = AIConversationService.shared
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            VStack(spacing: 0) {
                // Minimal header
                header(isCompact: isCompact)

                if showInitialPrompt && messages.count <= 1 {
                    // Centered initial prompt view
                    initialPromptView(isCompact: isCompact)
                } else {
                    // Conversation view
                    conversationView(isCompact: isCompact)
                }

                // Post button (when ready)
                if taskDraft.isReadyToPost {
                    postButton(isCompact: isCompact)
                }

                // Glowing input bar
                neonInputBar(isCompact: isCompact)
            }
            .background(neonBackground.ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .onAppear {
            startConversation()
            startAnimations()
        }
        .sheet(isPresented: $showReviewSheet) {
            ReviewTaskSheet(draft: taskDraft, onPost: { postTask() })
        }
        .alert("Couldn't Post Task", isPresented: $showPostError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(postError ?? "An unexpected error occurred. Please try again.")
        }
    }
    
    // MARK: - Neon Background
    
    private var neonBackground: some View {
        ZStack {
            // Base black
            Color.black.ignoresSafeArea()
            
            // Animated orb gradients
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.aiPurple.opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: -100, y: -200)
                .blur(radius: 80)
                .rotationEffect(.degrees(orbRotation))
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brandPurpleGlow.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: 150, y: 300)
                .blur(radius: 60)
                .rotationEffect(.degrees(-orbRotation * 0.7))
            
            // Grid overlay for nexus feel
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 40
                    // Vertical lines
                    for x in stride(from: 0, to: geo.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    // Horizontal lines
                    for y in stride(from: 0, to: geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.aiPurple.opacity(0.03), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header
    
    private func header(isCompact: Bool) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)

                    Image(systemName: "xmark")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .accessibilityLabel("Close AI task creator")
            
            Spacer()
            
            // AI branding with glow
            HStack(spacing: isCompact ? 6 : 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    .foregroundStyle(Color.aiPurple)
                    .shadow(color: Color.aiPurple.opacity(0.8), radius: 8)
                
                Text("AI CREATOR")
                    .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .tracking(2)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Color.clear.frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
        }
        .padding(.horizontal, isCompact ? 12 : 16)
        .padding(.vertical, isCompact ? 8 : 12)
    }
    
    // MARK: - Initial Prompt View (Centered)
    
    private func initialPromptView(isCompact: Bool) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Glowing AI orb
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            Color.aiPurple.opacity(0.1 - Double(index) * 0.03),
                            lineWidth: isCompact ? 1.5 : 2
                        )
                        .frame(
                            width: CGFloat(isCompact ? 90 : 120) + CGFloat(index) * CGFloat(isCompact ? 30 : 40),
                            height: CGFloat(isCompact ? 90 : 120) + CGFloat(index) * CGFloat(isCompact ? 30 : 40)
                        )
                        .scaleEffect(1 + glowIntensity * 0.1)
                }
                
                // Core orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.aiPurple,
                                Color.brandPurple,
                                Color.brandPurple.opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: isCompact ? 35 : 50
                        )
                    )
                    .frame(width: isCompact ? 60 : 80, height: isCompact ? 60 : 80)
                    .shadow(color: Color.aiPurple.opacity(glowIntensity), radius: isCompact ? 20 : 30)
                    .shadow(color: Color.aiPurple.opacity(glowIntensity * 0.5), radius: isCompact ? 40 : 60)
                
                // Sparkle icon
                Image(systemName: "sparkles")
                    .font(.system(size: isCompact ? 22 : 28, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, isCompact ? 32 : 48)
            
            // Main prompt text - BOLD and CENTERED
            Text("What do you need done?")
                .font(.system(size: isCompact ? 24 : 30, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: Color.aiPurple.opacity(0.5), radius: 20)
                .multilineTextAlignment(.center)
                .opacity(promptOpacity)

            // Subtitle
            Text("Describe your task and I'll create it for you")
                .font(isCompact ? .footnote : .subheadline)
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .padding(.top, isCompact ? 8 : 12)
                .opacity(promptOpacity * 0.8)

            Spacer()
            Spacer()
        }
        .scaleEffect(promptScale)
        .padding(.horizontal, isCompact ? 24 : 32)
    }
    
    // MARK: - Conversation View
    
    private func conversationView(isCompact: Bool) -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: isCompact ? 16 : 20) {
                    // Messages
                    ForEach(messages) { message in
                        if message.isFromAI {
                            NeonAIMessage(
                                message: message.content,
                                isBold: message.isBold,
                                isCompact: isCompact
                            )
                        } else {
                            NeonUserMessage(message: message.content, isCompact: isCompact)
                        }
                    }
                    
                    // Typing indicator
                    if isTyping {
                        NeonTypingIndicator(isCompact: isCompact)
                            .padding(.leading, isCompact ? 16 : 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Task preview card
                    if showTaskPreview {
                        NeonTaskCardPreview(
                            title: taskDraft.title,
                            payment: taskDraft.payment,
                            location: taskDraft.locationDisplay,
                            duration: taskDraft.duration,
                            category: taskDraft.category,
                            isComplete: taskDraft.isReadyToPost,
                            templateSlug: taskDraft.templateSlug,
                            riskLevel: taskDraft.riskLevel,
                            isCompact: isCompact
                        )
                        .padding(.horizontal, isCompact ? 12 : 16)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom)
                                    .combined(with: .opacity)
                                    .combined(with: .scale(scale: 0.8, anchor: .bottom)),
                                removal: .opacity
                            )
                        )
                    }
                    
                    Color.clear.frame(height: isCompact ? 16 : 20)
                        .id("bottom")
                }
                .padding(.top, isCompact ? 16 : 24)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation(.spring(response: 0.4)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: showTaskPreview) { _, _ in
                withAnimation(.spring(response: 0.4)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Post Button
    
    private func postButton(isCompact: Bool) -> some View {
        Button {
            showReviewSheet = true
        } label: {
            HStack(spacing: isCompact ? 10 : 12) {
                if isPosting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    
                    Text("Post Task")
                        .font(isCompact ? .subheadline.weight(.bold) : .headline.weight(.bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isCompact ? 14 : 16)
            .background(
                LinearGradient(
                    colors: [Color.successGreen, Color.successGreen.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: isCompact ? 14 : 16))
            .shadow(color: Color.successGreen.opacity(0.5), radius: isCompact ? 12 : 15, y: isCompact ? 4 : 5)
        }
        .accessibilityLabel("Post task")
        .disabled(isPosting)
        .padding(.horizontal, isCompact ? 16 : 20)
        .padding(.vertical, isCompact ? 10 : 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Neon Input Bar
    
    private func neonInputBar(isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 10 : 12) {
            // Glowing text field
            HStack {
                TextField("Describe what you need...", text: $userInput, axis: .vertical)
                    .font(isCompact ? .subheadline : .body)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1...4)
                    .tint(Color.aiPurple)
            }
            .padding(.horizontal, isCompact ? 16 : 20)
            .padding(.vertical, isCompact ? 12 : 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .fill(Color.surfaceElevated)
                    
                    // Glow border
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(
                            LinearGradient(
                                colors: userInput.isEmpty 
                                    ? [Color.aiPurple.opacity(0.3), Color.brandPurple.opacity(0.2)]
                                    : [Color.aiPurple, Color.brandPurpleGlow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: userInput.isEmpty ? 1 : 2
                        )
                }
            )
            .shadow(
                color: userInput.isEmpty ? Color.clear : Color.aiPurple.opacity(0.3),
                radius: isCompact ? 12 : 15
            )
            
            // Neon send button
            Button {
                sendMessage()
            } label: {
                ZStack {
                    // Glow effect
                    if !userInput.isEmpty {
                        Circle()
                            .fill(Color.aiPurple.opacity(0.3))
                            .frame(width: isCompact ? 48 : 56, height: isCompact ? 48 : 56)
                            .blur(radius: 10)
                    }
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: userInput.isEmpty
                                    ? [Color.surfaceElevated, Color.surfaceElevated]
                                    : [Color.aiPurple, Color.brandPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCompact ? 40 : 48, height: isCompact ? 40 : 48)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                        .foregroundStyle(userInput.isEmpty ? Color.textMuted : .white)
                }
            }
            .accessibilityLabel("Send message")
            .disabled(userInput.isEmpty || isTyping)
            .scaleEffect(userInput.isEmpty ? 1.0 : 1.05)
            .animation(.spring(response: 0.3), value: userInput.isEmpty)
        }
        .padding(.horizontal, isCompact ? 12 : 16)
        .padding(.vertical, isCompact ? 12 : 16)
        .background(
            Color.black.opacity(0.8)
                .blur(radius: 20)
        )
    }
    
    // MARK: - Actions
    
    private func startConversation() {
        let initialMessage = aiService.getInitialMessage()
        messages.append(initialMessage)
    }
    
    private func startAnimations() {
        // Prompt entrance animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            promptScale = 1.0
            promptOpacity = 1.0
        }
        
        // Continuous glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
        
        // Orb rotation
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            orbRotation = 360
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        // Hide initial prompt
        withAnimation(.spring(response: 0.4)) {
            showInitialPrompt = false
        }
        
        let userMessage = AIConversationMessage(
            content: userInput,
            isFromAI: false
        )
        messages.append(userMessage)
        
        let inputText = userInput
        userInput = ""
        
        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Show typing indicator
        isTyping = true

        // Every message goes to backend AI — fully AI-powered
        Task {
            let (updatedDraft, response) = await aiService.processMessage(inputText, draft: taskDraft)
            taskDraft = updatedDraft
            isTyping = false

            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                messages.append(response)
            }

            // Show task preview after AI sets basic info
            if !showTaskPreview && taskDraft.hasBasicInfo {
                try? await Task.sleep(nanoseconds: 500_000_000)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showTaskPreview = true
                }
            }
        }
    }
    
    private func postTask() {
        isPosting = true

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        Task {
            do {
                print("🟢 [PostTask] Creating task: \(taskDraft.title), payment: \(taskDraft.payment ?? 0), location: \(taskDraft.locationDisplay)")
                let deadlineDate: Date? = {
                    guard !taskDraft.deadline.isEmpty else { return nil }
                    let fmt = ISO8601DateFormatter()
                    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    return fmt.date(from: taskDraft.deadline) ?? ISO8601DateFormatter().date(from: taskDraft.deadline)
                }()

                // Geocode location string to GPS coordinates for geofence support
                var taskLat: Double?
                var taskLng: Double?
                if !taskDraft.locationDisplay.isEmpty {
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = taskDraft.locationDisplay
                    let search = MKLocalSearch(request: request)
                    if let response = try? await search.start(),
                       let item = response.mapItems.first {
                        taskLat = item.location.coordinate.latitude
                        taskLng = item.location.coordinate.longitude
                        print("🟢 [PostTask] Geocoded: \(taskDraft.locationDisplay) → \(taskLat!), \(taskLng!)")
                    }
                }

                let task = try await TaskService.shared.createTask(
                    title: taskDraft.title,
                    description: taskDraft.description,
                    payment: taskDraft.payment ?? 25.0,
                    location: taskDraft.locationDisplay,
                    locationCity: taskDraft.locationCity,
                    locationState: taskDraft.locationState,
                    locationRadiusMiles: taskDraft.locationRadiusMiles,
                    latitude: taskLat,
                    longitude: taskLng,
                    estimatedDuration: taskDraft.duration.isEmpty ? "1 hr" : taskDraft.duration,
                    category: taskDraft.category,
                    templateSlug: taskDraft.templateSlug,
                    requiredTier: taskDraft.requiredTier,
                    deadline: deadlineDate
                )
                print("🟢 [PostTask] Task created successfully: id=\(task.id), title=\(task.title)")
                HXLogger.info("AITaskCreation: Task created - \(task.id), funding escrow...", category: "Task")

                // ── CRITICAL: Fund escrow before task goes live ──
                // Without this, hustlers could accept tasks that have no money behind them.
                do {
                    let paymentIntent = try await EscrowService.shared.createPaymentIntent(taskId: task.id)
                    HXLogger.info("AITaskCreation: Payment intent created", category: "Task")

                    let stripeManager = StripePaymentManager.shared
                    stripeManager.preparePaymentSheet(clientSecret: paymentIntent.clientSecret)
                    let payResult = await stripeManager.presentPaymentSheet()

                    switch payResult {
                    case .completed:
                        // Confirm funding so escrow goes PENDING → FUNDED
                        _ = try await EscrowService.shared.confirmFunding(
                            escrowId: paymentIntent.escrowId,
                            stripePaymentIntentId: paymentIntent.paymentIntentId
                        )
                        HXLogger.info("AITaskCreation: Escrow funded, task is now live", category: "Task")
                        await LiveDataService.shared.refreshAll()
                        isPosting = false
                        dismiss()
                        return

                    case .canceled:
                        // Payment cancelled — cancel the task so it never goes live
                        HXLogger.info("AITaskCreation: Payment cancelled, cancelling task", category: "Task")
                        _ = try? await TaskService.shared.cancelTask(taskId: task.id, reason: "Payment cancelled")
                        isPosting = false
                        postError = "Payment was cancelled. Your task was not posted. Please try again to post the task."
                        showPostError = true
                        return

                    case .failed(let payError):
                        // Payment failed — cancel the task
                        HXLogger.error("AITaskCreation: Payment failed - \(payError.localizedDescription)", category: "Task")
                        _ = try? await TaskService.shared.cancelTask(taskId: task.id, reason: "Payment failed")
                        isPosting = false
                        postError = "Payment failed: \(payError.localizedDescription). Your task was not posted. Please check your card and try again."
                        showPostError = true
                        return
                    }
                } catch {
                    // Funding setup failed — cancel the task
                    HXLogger.error("AITaskCreation: Funding failed - \(error.localizedDescription)", category: "Task")
                    _ = try? await TaskService.shared.cancelTask(taskId: task.id, reason: "Funding failed")
                    isPosting = false
                    postError = "Couldn't set up payment: \(error.localizedDescription). Your task was not posted."
                    showPostError = true
                    return
                }
            } catch {
                print("🔴 [PostTask] Task creation FAILED: \(error)")
                HXLogger.error("AITaskCreation: API failed - \(error.localizedDescription)", category: "Task")

                postError = error.localizedDescription
                showPostError = true
            }
            isPosting = false
        }
    }
}

// MARK: - Neon AI Message

struct NeonAIMessage: View {
    let message: String
    let isBold: Bool
    var isCompact: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: isCompact ? 10 : 12) {
            // AI avatar with glow
            ZStack {
                Circle()
                    .fill(Color.aiPurple.opacity(0.2))
                    .frame(width: isCompact ? 32 : 40, height: isCompact ? 32 : 40)
                    .blur(radius: 5)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPurple, Color.brandPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
                
                Image(systemName: "sparkles")
                    .font(.system(size: isCompact ? 11 : 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Message bubble
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .font(isBold ? (isCompact ? .headline.bold() : .title3.bold()) : (isCompact ? .subheadline : .body))
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                            .stroke(Color.aiPurple.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer(minLength: isCompact ? 30 : 40)
        }
        .padding(.horizontal, isCompact ? 12 : 16)
    }
}

// MARK: - Neon User Message

struct NeonUserMessage: View {
    let message: String
    var isCompact: Bool = false
    
    var body: some View {
        HStack {
            Spacer(minLength: isCompact ? 48 : 60)
            
            Text(message)
                .font(isCompact ? .subheadline : .body)
                .foregroundStyle(.white)
                .padding(isCompact ? 12 : 16)
                .background(
                    LinearGradient(
                        colors: [Color.brandPurple, Color.aiPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20))
                .shadow(color: Color.brandPurple.opacity(0.3), radius: isCompact ? 8 : 10, y: isCompact ? 4 : 5)
        }
        .padding(.horizontal, isCompact ? 12 : 16)
    }
}

// MARK: - Neon Typing Indicator

struct NeonTypingIndicator: View {
    var isCompact: Bool = false
    @State private var animatingDot = 0
    
    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPurple, Color.brandPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
                
                Image(systemName: "sparkles")
                    .font(.system(size: isCompact ? 11 : 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Dots
            HStack(spacing: isCompact ? 5 : 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.aiPurple)
                        .frame(width: isCompact ? 8 : 10, height: isCompact ? 8 : 10)
                        .scaleEffect(animatingDot == index ? 1.3 : 0.8)
                        .opacity(animatingDot == index ? 1.0 : 0.4)
                        .shadow(
                            color: animatingDot == index ? Color.aiPurple.opacity(0.8) : Color.clear,
                            radius: 5
                        )
                }
            }
            .padding(.horizontal, isCompact ? 12 : 16)
            .padding(.vertical, isCompact ? 10 : 14)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                    .fill(Color.surfaceElevated)
            )
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.spring(response: 0.3)) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}

// MARK: - Neon Task Card Preview

struct NeonTaskCardPreview: View {
    let title: String
    let payment: Double?
    let location: String
    let duration: String
    let category: TaskCategory?
    let isComplete: Bool
    var templateSlug: String = "standard_physical"
    var riskLevel: String = "LOW"
    var isCompact: Bool = false

    // Stagger entrance states
    @State private var hasAppeared = false
    @State private var blurAmount: CGFloat = 12
    @State private var showHeader = false
    @State private var showBadges = false
    @State private var showTitle = false
    @State private var showPrice = false
    @State private var showDivider = false
    @State private var showDetails = false

    // Continuous animations
    @State private var glowPulse: CGFloat = 0.3
    @State private var shimmerOffset: CGFloat = -300

    // Completion celebration
    @State private var completionBounce = false
    @State private var showConfetti = false
    @State private var confettiParticles: [TaskCardParticle] = []

    // Price counter
    @State private var displayedPrice: Double = 0
    @State private var priceTimer: Timer?

    // Field update shimmer
    @State private var fieldUpdateShimmer: CGFloat = -300
    @State private var previousLocation: String = ""
    @State private var previousDuration: String = ""

    var body: some View {
        ZStack {
            // Main card
            VStack(alignment: .leading, spacing: 0) {
                // ── Header ──
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: isCompact ? 11 : 13, weight: .bold))
                            .foregroundStyle(Color.aiPurple)
                            .rotationEffect(.degrees(hasAppeared ? 0 : -180))
                            .scaleEffect(hasAppeared ? 1.0 : 0.3)

                        Text("YOUR TASK")
                            .font(.system(size: isCompact ? 9 : 10, weight: .heavy))
                            .tracking(2)
                            .foregroundStyle(Color.aiPurple)
                    }
                    .opacity(showHeader ? 1 : 0)
                    .offset(y: showHeader ? 0 : -10)

                    Spacer()

                    // Status badge with color transition
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isComplete ? Color.successGreen : Color.warningOrange)
                            .frame(width: 8, height: 8)
                            .shadow(color: (isComplete ? Color.successGreen : Color.warningOrange).opacity(0.8), radius: 6)
                            .scaleEffect(completionBounce ? 2.0 : 1.0)

                        Text(isComplete ? "Ready" : "Building...")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isComplete ? Color.successGreen : Color.warningOrange)
                    }
                    .opacity(showHeader ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: isComplete)
                }
                .padding(.bottom, isCompact ? 12 : 16)

                // ── Category + Risk badges ──
                HStack(spacing: 8) {
                    if let category = category {
                        Text(category.displayName.uppercased())
                            .font(.system(size: isCompact ? 9 : 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(Color.brandPurple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.brandPurple.opacity(0.15)))
                    }

                    let rc: Color = riskLevel == "LOW" ? .successGreen : riskLevel == "MEDIUM" ? .warningOrange : .errorRed
                    HStack(spacing: 3) {
                        Image(systemName: "shield.fill").font(.system(size: 9))
                        Text(riskLevel).font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(rc)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(Capsule().fill(rc.opacity(0.15)))
                }
                .opacity(showBadges ? 1 : 0)
                .offset(x: showBadges ? 0 : -30)
                .padding(.bottom, isCompact ? 10 : 12)

                // ── Title ──
                Text(title.isEmpty ? "Untitled Task" : title)
                    .font(.system(size: isCompact ? 17 : 20, weight: .bold))
                    .foregroundStyle(title.isEmpty ? Color.textMuted : Color.textPrimary)
                    .lineLimit(2).minimumScaleFactor(0.8)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 15)
                    .blur(radius: showTitle ? 0 : 4)

                Spacer().frame(height: isCompact ? 12 : 16)

                // ── Payment (counting animation) ──
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.moneyGreen.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "dollarsign")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.moneyGreen)
                    }
                    .scaleEffect(showPrice ? 1.0 : 0.5)

                    if payment != nil {
                        Text("$\(String(format: "%.0f", displayedPrice))")
                            .font(.system(size: isCompact ? 22 : 28, weight: .bold))
                            .foregroundStyle(Color.moneyGreen)
                            .shadow(color: Color.moneyGreen.opacity(0.3), radius: 5)
                            .contentTransition(.numericText(countsDown: false))
                    } else {
                        Text("TBD")
                            .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                            .foregroundStyle(Color.textMuted)
                    }
                    Spacer()
                }
                .opacity(showPrice ? 1 : 0)
                .offset(y: showPrice ? 0 : 10)

                Spacer().frame(height: isCompact ? 12 : 16)

                // ── Divider (animated width) ──
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, Color.aiPurple.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 1)
                    .scaleEffect(x: showDivider ? 1 : 0, anchor: .leading)

                Spacer().frame(height: isCompact ? 12 : 16)

                // ── Details ──
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill").font(.system(size: 14)).foregroundStyle(Color.textMuted)
                        Text(location.isEmpty ? "Location TBD" : location)
                            .font(.subheadline).foregroundStyle(location.isEmpty ? Color.textMuted : Color.textSecondary)
                            .lineLimit(1).minimumScaleFactor(0.7)
                            .contentTransition(.interpolate)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill").font(.system(size: 14)).foregroundStyle(Color.textMuted)
                        Text(duration.isEmpty ? "Duration TBD" : duration)
                            .font(.subheadline).foregroundStyle(duration.isEmpty ? Color.textMuted : Color.textSecondary)
                            .contentTransition(.interpolate)
                    }
                }
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 12)
            }
            .padding(isCompact ? 16 : 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24).fill(Color.surfaceElevated)
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.aiPurple.opacity(glowPulse), Color.brandPurple.opacity(glowPulse * 0.5), Color.aiPurple.opacity(glowPulse)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: isComplete ? 2.5 : 2
                        )
                }
            )
            .shadow(color: Color.aiPurple.opacity(glowPulse * 0.5), radius: isCompact ? 15 : 20)
            // Shimmer overlay
            .overlay(
                LinearGradient(colors: [.clear, Color.white.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 150)
                    .offset(x: shimmerOffset)
                    .allowsHitTesting(false)
                    .clipped()
                    .cornerRadius(isCompact ? 20 : 24)
            )
            // Field update shimmer
            .overlay(
                LinearGradient(colors: [.clear, Color.brandPurple.opacity(0.08), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 120)
                    .offset(x: fieldUpdateShimmer)
                    .allowsHitTesting(false)
                    .clipped()
                    .cornerRadius(isCompact ? 20 : 24)
            )
            .blur(radius: blurAmount)
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0)
            .scaleEffect(completionBounce ? 1.03 : 1.0)

            // ── Confetti particles ──
            if showConfetti {
                ForEach(confettiParticles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .offset(x: p.x, y: p.y)
                        .opacity(p.opacity)
                        .scaleEffect(p.scale)
                }
            }
        }
        .onAppear { startEntranceAnimation() }
        .onChange(of: isComplete) { _, complete in
            if complete { triggerCompletionCelebration() }
        }
        .onChange(of: payment) { old, new in
            if let new, new != old ?? 0 { animatePrice(to: new) }
        }
        .onChange(of: location) { old, new in
            if new != old { triggerFieldUpdateShimmer() }
        }
        .onChange(of: duration) { old, new in
            if new != old { triggerFieldUpdateShimmer() }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // MARK: - Entrance Animation (7-stage stagger + blur reveal)
    // ══════════════════════════════════════════════════════════════════════

    private func startEntranceAnimation() {
        // Stage 1: Card fades in from blur
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            hasAppeared = true
            blurAmount = 0
        }

        // Stage 2: Header
        withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
            showHeader = true
        }

        // Stage 3: Badges slide in
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.3)) {
            showBadges = true
        }

        // Stage 4: Title deblurs + slides up
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.4)) {
            showTitle = true
        }

        // Stage 5: Price + counting animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.55)) {
            showPrice = true
        }
        if let payment { animatePrice(to: payment, delay: 0.6) }

        // Stage 6: Divider expands
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            showDivider = true
        }

        // Stage 7: Details slide up
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.8)) {
            showDetails = true
        }

        // Shimmer sweep
        withAnimation(.easeInOut(duration: 0.8).delay(0.25)) {
            shimmerOffset = 400
        }

        // Continuous glow
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            glowPulse = 0.9
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // MARK: - Price Counting Animation
    // ══════════════════════════════════════════════════════════════════════

    private func animatePrice(to target: Double, delay: Double = 0) {
        priceTimer?.invalidate()
        let startPrice = displayedPrice
        let steps = 20
        let stepDuration = 0.03
        var currentStep = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            priceTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
                currentStep += 1
                let progress = Double(currentStep) / Double(steps)
                // Ease-out curve
                let eased = 1 - pow(1 - progress, 3)
                withAnimation(.none) {
                    displayedPrice = startPrice + (target - startPrice) * eased
                }
                if currentStep >= steps {
                    timer.invalidate()
                    displayedPrice = target
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // MARK: - Field Update Shimmer
    // ══════════════════════════════════════════════════════════════════════

    private func triggerFieldUpdateShimmer() {
        fieldUpdateShimmer = -300
        withAnimation(.easeInOut(duration: 0.6)) {
            fieldUpdateShimmer = 400
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // MARK: - Completion Celebration
    // ══════════════════════════════════════════════════════════════════════

    private func triggerCompletionCelebration() {
        // Haptics
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        // Bounce
        withAnimation(.spring(response: 0.25, dampingFraction: 0.35)) {
            completionBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                completionBounce = false
            }
        }

        // Extra shimmer sweep
        shimmerOffset = -300
        withAnimation(.easeInOut(duration: 0.7).delay(0.1)) {
            shimmerOffset = 400
        }

        // Confetti burst
        spawnConfetti()
    }

    private func spawnConfetti() {
        let colors: [Color] = [.brandPurple, .pink, .moneyGreen, .infoBlue, .warningOrange, .white]
        var particles: [TaskCardParticle] = []
        for i in 0..<24 {
            let angle = Double(i) / 24.0 * .pi * 2
            let speed = Double.random(in: 60...140)
            particles.append(TaskCardParticle(
                id: i,
                x: 0, y: 0,
                targetX: cos(angle) * speed,
                targetY: sin(angle) * speed - 30,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0,
                scale: 1.0
            ))
        }
        confettiParticles = particles
        showConfetti = true

        // Animate outward
        withAnimation(.easeOut(duration: 0.6)) {
            for i in confettiParticles.indices {
                confettiParticles[i].x = confettiParticles[i].targetX
                confettiParticles[i].y = confettiParticles[i].targetY
            }
        }

        // Fade out
        withAnimation(.easeIn(duration: 0.4).delay(0.4)) {
            for i in confettiParticles.indices {
                confettiParticles[i].opacity = 0
                confettiParticles[i].scale = 0.3
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showConfetti = false
            confettiParticles = []
        }
    }
}

// MARK: - Confetti Particle

struct TaskCardParticle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var targetX: CGFloat
    var targetY: CGFloat
    var color: Color
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Preview

#Preview {
    AITaskCreationScreen()
        .environment(Router())
}
