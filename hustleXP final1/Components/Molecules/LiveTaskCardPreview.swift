//
//  LiveTaskCardPreview.swift
//  hustleXP final1
//
//  Animated task card preview for AI task creation
//  Features "Max tier appeal" entrance animation with glow and shimmer effects
//

import SwiftUI

struct LiveTaskCardPreview: View {
    let title: String
    let payment: Double?
    let location: String
    let duration: String
    let category: TaskCategory?
    let isComplete: Bool
    
    @State private var hasAppeared = false
    @State private var glowRadius: CGFloat = 8
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var showUpdatePulse = false
    
    // Track previous values for update animation
    @State private var previousTitle: String = ""
    @State private var previousPayment: Double? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with completion indicator
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.aiPurple)
                    
                    Text("YOUR TASK")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Color.aiPurple)
                }
                
                Spacer()
                
                // Completion status
                HStack(spacing: 4) {
                    Circle()
                        .fill(isComplete ? Color.successGreen : Color.warningOrange)
                        .frame(width: 8, height: 8)
                    
                    Text(isComplete ? "Ready to Post" : "In Progress")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(isComplete ? Color.successGreen : Color.warningOrange)
                }
            }
            .padding(.bottom, 16)
            
            // Category tag
            if let category = category {
                Text(category.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.brandPurple.opacity(0.15))
                    )
                    .padding(.bottom, 12)
            }
            
            // Title
            HStack(alignment: .top) {
                Text(title.isEmpty ? "Untitled Task" : title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(title.isEmpty ? Color.textMuted : Color.textPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                // Title completion indicator
                CompletionCheckmark(isComplete: !title.isEmpty)
            }
            
            Spacer().frame(height: 16)
            
            // Payment
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.moneyGreen.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "dollarsign")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                }
                
                if let payment = payment {
                    Text("$\(String(format: "%.0f", payment))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                } else {
                    Text("TBD")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
                
                // Payment completion indicator
                CompletionCheckmark(isComplete: payment != nil)
            }
            
            Spacer().frame(height: 16)
            
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            Spacer().frame(height: 16)
            
            // Details row
            HStack(spacing: 0) {
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textMuted)
                    
                    Text(location.isEmpty ? "Location TBD" : location)
                        .font(.subheadline)
                        .foregroundStyle(location.isEmpty ? Color.textMuted : Color.textSecondary)
                    
                    CompletionCheckmark(isComplete: !location.isEmpty, size: 12)
                }
                
                Spacer()
                
                // Duration
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textMuted)
                    
                    Text(duration.isEmpty ? "Duration TBD" : duration)
                        .font(.subheadline)
                        .foregroundStyle(duration.isEmpty ? Color.textMuted : Color.textSecondary)
                    
                    CompletionCheckmark(isComplete: !duration.isEmpty, size: 12)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base surface
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surfaceElevated)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Shimmer effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.aiPurple.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: UnitPoint(x: shimmerOffset, y: 0),
                            endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 1)
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.aiPurple.opacity(0.3), lineWidth: 1)
            }
        )
        // Glow effect
        .shadow(
            color: Color.aiPurple.opacity(0.3),
            radius: glowRadius,
            x: 0,
            y: 0
        )
        // Update pulse
        .scaleEffect(showUpdatePulse ? 1.02 : 1.0)
        // Entrance animation
        .scaleEffect(hasAppeared ? 1.0 : 0.85)
        .opacity(hasAppeared ? 1.0 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                hasAppeared = true
            }
            
            // Start glow pulse
            startGlowAnimation()
            
            // Initial shimmer
            triggerShimmer()
            
            // Track initial values
            previousTitle = title
            previousPayment = payment
        }
        .onChange(of: title) { oldValue, newValue in
            if oldValue != newValue && !oldValue.isEmpty {
                triggerUpdatePulse()
            }
        }
        .onChange(of: payment) { oldValue, newValue in
            if oldValue != newValue {
                triggerUpdatePulse()
                triggerShimmer()
            }
        }
        .onChange(of: isComplete) { oldValue, newValue in
            if newValue && !oldValue {
                // Big shimmer when complete
                triggerShimmer()
            }
        }
    }
    
    // MARK: - Animations
    
    private func startGlowAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            glowRadius = 15
        }
    }
    
    private func triggerShimmer() {
        shimmerOffset = -0.3
        withAnimation(.easeInOut(duration: 1.0)) {
            shimmerOffset = 1.3
        }
    }
    
    private func triggerUpdatePulse() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            showUpdatePulse = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                showUpdatePulse = false
            }
        }
    }
}

// MARK: - Completion Checkmark

struct CompletionCheckmark: View {
    let isComplete: Bool
    var size: CGFloat = 16
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isComplete ? Color.successGreen.opacity(0.15) : Color.clear)
                .frame(width: size, height: size)
            
            if isComplete {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(Color.successGreen)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isComplete)
    }
}

// MARK: - Previews

#Preview("Live Preview - In Progress") {
    VStack {
        LiveTaskCardPreview(
            title: "Grocery Pickup & Delivery",
            payment: nil,
            location: "Whole Foods",
            duration: "",
            category: .shopping,
            isComplete: false
        )
    }
    .padding(20)
    .background(Color.backgroundBlack)
}

#Preview("Live Preview - Complete") {
    VStack {
        LiveTaskCardPreview(
            title: "Grocery Pickup & Delivery",
            payment: 35,
            location: "Whole Foods",
            duration: "~1 hour",
            category: .shopping,
            isComplete: true
        )
    }
    .padding(20)
    .background(Color.backgroundBlack)
}

#Preview("Live Preview - Empty") {
    VStack {
        LiveTaskCardPreview(
            title: "",
            payment: nil,
            location: "",
            duration: "",
            category: nil,
            isComplete: false
        )
    }
    .padding(20)
    .background(Color.backgroundBlack)
}
