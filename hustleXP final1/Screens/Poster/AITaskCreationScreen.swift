//
//  AITaskCreationScreen.swift
//  hustleXP final1
//
//  Conversational AI-powered task creation for Posters
//  Neon Nexus aesthetic with centered prompts and glowing inputs
//

import SwiftUI

struct AITaskCreationScreen: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [AIConversationMessage] = []
    @State private var userInput: String = ""
    @State private var taskDraft = AITaskDraft()
    @State private var isTyping: Bool = false
    @State private var showTaskPreview: Bool = false
    @State private var isPosting: Bool = false
    
    // Animation states
    @State private var showInitialPrompt: Bool = true
    @State private var promptScale: CGFloat = 0.8
    @State private var promptOpacity: Double = 0
    @State private var glowIntensity: Double = 0.3
    @State private var orbRotation: Double = 0
    
    private let aiService = MockAITaskService.shared
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Neon nexus background
                neonBackground
                
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
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startConversation()
            startAnimations()
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
            
            Spacer()
            
            // AI branding with glow
            HStack(spacing: isCompact ? 6 : 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    .foregroundStyle(Color.aiPurple)
                    .shadow(color: Color.aiPurple.opacity(0.8), radius: 8)
                
                Text("AI CREATOR")
                    .font(.system(size: isCompact ? 10 : 12, weight: .bold))
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
                .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: Color.aiPurple.opacity(0.5), radius: 20)
                .multilineTextAlignment(.center)
                .scaleEffect(promptScale)
                .opacity(promptOpacity)
            
            // Subtitle
            Text("Describe your task and I'll create it for you")
                .font(isCompact ? .footnote : .subheadline)
                .foregroundStyle(Color.textMuted)
                .padding(.top, isCompact ? 8 : 12)
                .opacity(promptOpacity * 0.8)
            
            Spacer()
            Spacer()
        }
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
                            location: taskDraft.location,
                            duration: taskDraft.duration,
                            category: taskDraft.category,
                            isComplete: taskDraft.isReadyToPost,
                            isCompact: isCompact
                        )
                        .padding(.horizontal, isCompact ? 12 : 16)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
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
            postTask()
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
        
        // Simulate AI thinking delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            processAIResponse(for: inputText)
        }
    }
    
    private func processAIResponse(for input: String) {
        let (updatedDraft, response) = aiService.processUserInput(input, currentDraft: taskDraft)
        
        taskDraft = updatedDraft
        isTyping = false
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            messages.append(response)
        }
        
        // Show task preview after first response
        if !showTaskPreview && taskDraft.hasBasicInfo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showTaskPreview = true
                }
            }
        }
    }
    
    private func postTask() {
        isPosting = true
        
        let newTask = taskDraft.toHXTask(
            posterId: "current-user",
            posterName: "You",
            posterRating: 4.8
        )
        
        MockDataService.shared.postTask(newTask)
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPosting = false
            dismiss()
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
    var isCompact: Bool = false
    
    @State private var hasAppeared = false
    @State private var glowPulse: CGFloat = 0.3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: isCompact ? 6 : 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                        .foregroundStyle(Color.aiPurple)
                    
                    Text("YOUR TASK")
                        .font(.system(size: isCompact ? 9 : 10, weight: .heavy))
                        .tracking(2)
                        .foregroundStyle(Color.aiPurple)
                }
                
                Spacer()
                
                // Status
                HStack(spacing: isCompact ? 5 : 6) {
                    Circle()
                        .fill(isComplete ? Color.successGreen : Color.warningOrange)
                        .frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
                        .shadow(color: isComplete ? Color.successGreen : Color.warningOrange, radius: 4)
                    
                    Text(isComplete ? "Ready" : "Building...")
                        .font(isCompact ? .system(size: 10, weight: .semibold) : .caption2.weight(.semibold))
                        .foregroundStyle(isComplete ? Color.successGreen : Color.warningOrange)
                }
            }
            .padding(.bottom, isCompact ? 12 : 16)
            
            // Category
            if let category = category {
                Text(category.displayName.uppercased())
                    .font(.system(size: isCompact ? 9 : 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, isCompact ? 8 : 10)
                    .padding(.vertical, isCompact ? 3 : 4)
                    .background(
                        Capsule()
                            .fill(Color.brandPurple.opacity(0.15))
                    )
                    .padding(.bottom, isCompact ? 10 : 12)
            }
            
            // Title
            Text(title.isEmpty ? "Untitled Task" : title)
                .font(.system(size: isCompact ? 17 : 20, weight: .bold))
                .foregroundStyle(title.isEmpty ? Color.textMuted : Color.textPrimary)
                .lineLimit(2)
            
            Spacer().frame(height: isCompact ? 12 : 16)
            
            // Payment
            HStack(spacing: isCompact ? 6 : 8) {
                ZStack {
                    Circle()
                        .fill(Color.moneyGreen.opacity(0.15))
                        .frame(width: isCompact ? 30 : 36, height: isCompact ? 30 : 36)
                    
                    Image(systemName: "dollarsign")
                        .font(.system(size: isCompact ? 13 : 16, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                }
                
                if let payment = payment {
                    Text("$\(String(format: "%.0f", payment))")
                        .font(.system(size: isCompact ? 22 : 28, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                        .shadow(color: Color.moneyGreen.opacity(0.3), radius: 5)
                } else {
                    Text("TBD")
                        .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
            }
            
            Spacer().frame(height: isCompact ? 12 : 16)
            
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.aiPurple.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            Spacer().frame(height: isCompact ? 12 : 16)
            
            // Details
            HStack(spacing: 0) {
                HStack(spacing: isCompact ? 5 : 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.textMuted)
                    
                    Text(location.isEmpty ? "Location TBD" : location)
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(location.isEmpty ? Color.textMuted : Color.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: isCompact ? 5 : 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.textMuted)
                    
                    Text(duration.isEmpty ? "Duration TBD" : duration)
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(duration.isEmpty ? Color.textMuted : Color.textSecondary)
                }
            }
        }
        .padding(isCompact ? 16 : 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                    .fill(Color.surfaceElevated)
                
                // Neon border
                RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.aiPurple.opacity(glowPulse),
                                Color.brandPurple.opacity(glowPulse * 0.5),
                                Color.aiPurple.opacity(glowPulse)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: Color.aiPurple.opacity(glowPulse * 0.5), radius: isCompact ? 15 : 20)
        .scaleEffect(hasAppeared ? 1.0 : 0.85)
        .opacity(hasAppeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                hasAppeared = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = 0.8
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AITaskCreationScreen()
        .environment(Router())
}
