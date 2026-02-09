//
//  NoTasksScreen.swift
//  hustleXP final1
//
//  Archetype: F (System/Interrupt)
//

import SwiftUI

struct NoTasksScreen: View {
    let onRefresh: () -> Void
    
    @State private var isRefreshing = false
    @State private var pulseAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                VStack(spacing: isCompact ? 20 : 32) {
                    Spacer()
                    
                    // Animated illustration
                    ZStack {
                        Circle()
                            .fill(Color.surfaceSecondary)
                            .frame(width: isCompact ? 100 : 140, height: isCompact ? 100 : 140)
                        
                        Circle()
                            .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                            .frame(width: isCompact ? 120 : 160, height: isCompact ? 120 : 160)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.6)
                        
                        HXIcon(
                            "tray.fill",
                            size: .custom(isCompact ? 40 : 56),
                            color: .textSecondary
                        )
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                            pulseAnimation = true
                        }
                    }
                    
                    // Content
                    VStack(spacing: isCompact ? 8 : 12) {
                        HXText("No Tasks Available", style: isCompact ? .headline : .title2)
                        
                        HXText(
                            "New opportunities are posted all the time.\nCheck back soon or try adjusting your filters.",
                            style: isCompact ? .subheadline : .body,
                            color: .textSecondary
                        )
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, isCompact ? 20 : 24)
                    
                    // Tips section
                    VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
                        HXText("While you wait:", style: .caption, color: .textSecondary)
                        
                        TipRow(icon: "star.fill", text: "Complete tasks to increase your tier", isCompact: isCompact)
                        TipRow(icon: "bell.fill", text: "Enable notifications for new tasks", isCompact: isCompact)
                        TipRow(icon: "location.fill", text: "Check your location settings", isCompact: isCompact)
                    }
                    .padding(isCompact ? 16 : 20)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(isCompact ? 14 : 16)
                    .padding(.horizontal, isCompact ? 20 : 24)
                    
                    Spacer()
                    
                    // Refresh button
                    HXButton(
                        isRefreshing ? "Checking..." : "Refresh Tasks",
                        variant: .primary,
                        size: isCompact ? .medium : .large,
                        isLoading: isRefreshing
                    ) {
                        isRefreshing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isRefreshing = false
                            onRefresh()
                        }
                    }
                    .padding(.horizontal, isCompact ? 20 : 24)
                    .padding(.bottom, isCompact ? 20 : 32)
                }
            }
        }
    }
}

// MARK: - Tip Row
private struct TipRow: View {
    let icon: String
    let text: String
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundStyle(Color.brandPurple)
                .frame(width: isCompact ? 20 : 24)
            
            HXText(text, style: isCompact ? .footnote : .subheadline, color: .textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    NoTasksScreen(onRefresh: {})
}
