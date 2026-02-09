//
//  EmptyState.swift
//  hustleXP final1
//
//  Molecule: EmptyState
//  Premium empty state with animated icon and clear messaging
//

import SwiftUI

enum EmptyStateVariant {
    case standard
    case compact
    case fullScreen
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    let variant: EmptyStateVariant
    let accentColor: Color
    
    @State private var iconScale: CGFloat = 0.8
    @State private var showContent = false
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        variant: EmptyStateVariant = .standard,
        accentColor: Color = .brandPurple
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.variant = variant
        self.accentColor = accentColor
    }
    
    var body: some View {
        Group {
            switch variant {
            case .standard:
                standardView
            case .compact:
                compactView
            case .fullScreen:
                fullScreenView
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                showContent = true
            }
        }
    }
    
    // MARK: - Standard View
    
    private var standardView: some View {
        VStack(spacing: 20) {
            // Icon with glow
            iconView(size: 80, iconSize: 32)
            
            // Text content
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                HXButton(actionTitle, variant: .secondary, size: .medium, isFullWidth: false, action: action)
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    // MARK: - Compact View
    
    private var compactView: some View {
        HStack(spacing: 16) {
            iconView(size: 48, iconSize: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Full Screen View
    
    private var fullScreenView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Large icon with animated glow
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(iconScale)
                
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(accentColor)
            }
            .scaleEffect(iconScale)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            if let actionTitle = actionTitle, let action = action {
                HXButton(actionTitle, icon: "arrow.right", variant: .primary, size: .large, isFullWidth: false, action: action)
                    .padding(.top, 16)
                    .opacity(showContent ? 1 : 0)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Icon View
    
    private func iconView(size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            // Glow
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: size, height: size)
                .blur(radius: 8)
            
            // Background
            Circle()
                .fill(accentColor.opacity(0.1))
                .frame(width: size, height: size)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(accentColor.opacity(0.8))
        }
        .scaleEffect(iconScale)
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 32) {
            EmptyState(
                icon: "tray",
                title: "No Tasks Available",
                message: "Check back soon for new opportunities",
                variant: .compact
            )
            .padding(.horizontal)
            
            EmptyState(
                icon: "clock.arrow.circlepath",
                title: "No History Yet",
                message: "Your completed tasks will appear here",
                actionTitle: "Browse Tasks",
                action: {
                    print("Action tapped")
                },
                accentColor: .infoBlue
            )
            
            Spacer()
        }
        .padding()
    }
}
