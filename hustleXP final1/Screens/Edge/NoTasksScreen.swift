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
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated illustration
                ZStack {
                    Circle()
                        .fill(Color.surfaceSecondary)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.6)
                    
                    HXIcon(
                        name: "tray.fill",
                        size: .custom(56),
                        color: .textSecondary
                    )
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                        pulseAnimation = true
                    }
                }
                
                // Content
                VStack(spacing: 12) {
                    HXText("No Tasks Available", style: .title2)
                    
                    HXText(
                        "New opportunities are posted all the time.\nCheck back soon or try adjusting your filters.",
                        style: .body,
                        color: .textSecondary
                    )
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Tips section
                VStack(alignment: .leading, spacing: 16) {
                    HXText("While you wait:", style: .caption, color: .textSecondary)
                    
                    TipRow(icon: "star.fill", text: "Complete tasks to increase your tier")
                    TipRow(icon: "bell.fill", text: "Enable notifications for new tasks")
                    TipRow(icon: "location.fill", text: "Check your location settings")
                }
                .padding(20)
                .background(Color.surfaceSecondary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Refresh button
                HXButton(
                    title: isRefreshing ? "Checking..." : "Refresh Tasks",
                    variant: .primary,
                    isLoading: isRefreshing
                ) {
                    isRefreshing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isRefreshing = false
                        onRefresh()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Tip Row
private struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.brandPurple)
                .frame(width: 24)
            
            HXText(text, style: .subheadline, color: .textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    NoTasksScreen(onRefresh: {})
}
