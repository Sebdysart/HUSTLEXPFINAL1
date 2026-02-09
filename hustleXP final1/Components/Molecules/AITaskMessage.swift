//
//  AITaskMessage.swift
//  hustleXP final1
//
//  Chat bubble components for AI task creation conversation
//

import SwiftUI

// MARK: - AI Message Bubble

/// Left-aligned chat bubble for AI messages with sparkle icon
struct AITaskMessage: View {
    let message: String
    let isBold: Bool
    var showTypingIndicator: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI avatar with sparkles
            ZStack {
                Circle()
                    .fill(Color.aiPurple.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.aiPurple)
            }
            
            // Message bubble
            VStack(alignment: .leading, spacing: 8) {
                if showTypingIndicator {
                    TypingIndicator()
                } else {
                    Text(message)
                        .font(isBold ? .title2.bold() : .body)
                        .foregroundStyle(Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(Color.surfaceElevated)
            .clipShape(AIBubbleShape())
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - User Message Bubble

/// Right-aligned chat bubble for user messages
struct UserTaskMessage: View {
    let message: String
    
    var body: some View {
        HStack {
            Spacer(minLength: 60)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.brandPurple)
                .clipShape(UserBubbleShape())
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Typing Indicator

/// Animated three-dot typing indicator
struct TypingIndicator: View {
    @State private var animatingDot = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.aiPurple)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingDot == index ? 1.2 : 0.8)
                    .opacity(animatingDot == index ? 1.0 : 0.5)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.2)) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}

// MARK: - Custom Bubble Shapes

/// AI bubble shape with rounded corners and small top-left corner
struct AIBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let smallRadius: CGFloat = 4
        
        var path = Path()
        
        // Start from top-left (small radius)
        path.move(to: CGPoint(x: smallRadius, y: 0))
        
        // Top edge to top-right
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge to bottom-right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: rect.height - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge to bottom-left
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        path.addArc(
            center: CGPoint(x: radius, y: rect.height - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge to top-left (small radius)
        path.addLine(to: CGPoint(x: 0, y: smallRadius))
        path.addArc(
            center: CGPoint(x: smallRadius, y: smallRadius),
            radius: smallRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

/// User bubble shape with rounded corners and small top-right corner
struct UserBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let smallRadius: CGFloat = 4
        
        var path = Path()
        
        // Start from top-left
        path.move(to: CGPoint(x: radius, y: 0))
        
        // Top edge to top-right (small radius)
        path.addLine(to: CGPoint(x: rect.width - smallRadius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - smallRadius, y: smallRadius),
            radius: smallRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge to bottom-right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: rect.height - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge to bottom-left
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        path.addArc(
            center: CGPoint(x: radius, y: rect.height - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge to top-left
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview("AI Message") {
    VStack(spacing: 16) {
        AITaskMessage(
            message: "What do you need done?",
            isBold: true
        )
        
        AITaskMessage(
            message: "Got it! Grocery pickup and delivery. A few quick questions:\n• How much are you looking to pay?\n• When do you need this done?",
            isBold: false
        )
        
        AITaskMessage(
            message: "",
            isBold: false,
            showTypingIndicator: true
        )
    }
    .padding(.vertical)
    .background(Color.backgroundBlack)
}

#Preview("User Message") {
    VStack(spacing: 16) {
        UserTaskMessage(
            message: "I need someone to pick up groceries from Whole Foods"
        )
        
        UserTaskMessage(
            message: "$35, today before 6pm"
        )
    }
    .padding(.vertical)
    .background(Color.backgroundBlack)
}

#Preview("Conversation") {
    ScrollView {
        VStack(spacing: 12) {
            AITaskMessage(
                message: "What do you need done?",
                isBold: true
            )
            
            UserTaskMessage(
                message: "I need someone to pick up groceries from Whole Foods and bring them to my apartment"
            )
            
            AITaskMessage(
                message: "Got it! Grocery pickup and delivery.\n\nA few quick questions to finalize:\n• How much are you looking to pay for this?\n• When do you need this done?\n• Approximately how many items/bags?",
                isBold: false
            )
            
            UserTaskMessage(
                message: "$35, today before 6pm, about 15 items"
            )
            
            AITaskMessage(
                message: "Perfect! Here's your task ready to post. Does this look good, or would you like to change anything?",
                isBold: false
            )
        }
        .padding(.vertical)
    }
    .background(Color.backgroundBlack)
}
