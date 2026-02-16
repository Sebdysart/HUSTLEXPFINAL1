//
//  EligibilityScreen.swift
//  hustleXP final1
//
//  Archetype: F (System/Interrupt)
//

import SwiftUI

struct EligibilityScreen: View {
    let requiredTier: TrustTier
    let currentTier: TrustTier
    let taskTitle: String
    let onDismiss: () -> Void
    let onLearnMore: () -> Void
    
    @State private var showProgress = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        HXIcon("xmark", size: .medium, color: .textSecondary)
                    }
                    .accessibilityLabel("Dismiss")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Lock illustration
                ZStack {
                    Circle()
                        .fill(Color.warningYellow.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    HXIcon(
                        "lock.fill",
                        size: .custom(48),
                        color: .warningYellow
                    )
                }
                
                // Content
                VStack(spacing: 16) {
                    HXText("Tier Required", style: .title2)
                    
                    HXText(
                        "This task requires a higher trust tier",
                        style: .body,
                        color: .textSecondary
                    )
                    
                    // Task info
                    VStack(spacing: 8) {
                        HXText(taskTitle, style: .headline)
                            .multilineTextAlignment(.center)
                        
                        HXBadge(variant: .tier(requiredTier))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                
                // Tier comparison
                VStack(spacing: 16) {
                    HStack {
                        VStack(spacing: 4) {
                            HXText("Your Tier", style: .caption, color: .textSecondary)
                            HXBadge(variant: .tier(currentTier))
                        }
                        .frame(maxWidth: .infinity)
                        
                        HXIcon("arrow.right", size: .small, color: .textTertiary)
                        
                        VStack(spacing: 4) {
                            HXText("Required", style: .caption, color: .textSecondary)
                            HXBadge(variant: .tier(requiredTier))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Progress indicator
                    VStack(spacing: 8) {
                        HXProgressBar(
                            progress: tierProgress,
                            variant: .linear,
                            color: .brandPurple,
                            showLabel: false
                        )
                        
                        HXText(
                            "\(xpToNextTier) XP to \(requiredTier.name)",
                            style: .caption,
                            color: .textSecondary
                        )
                    }
                }
                .padding(20)
                .background(Color.surfacePrimary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    HXButton(
                        "Learn How to Level Up",
                        variant: .primary,
                        action: onLearnMore
                    )
                    .accessibilityLabel("Learn how to level up your tier")

                    HXButton(
                        "Find Other Tasks",
                        variant: .ghost,
                        action: onDismiss
                    )
                    .accessibilityLabel("Find other available tasks")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private var tierProgress: Double {
        let current = Double(currentTier.rawValue)
        let required = Double(requiredTier.rawValue)
        return current / required
    }
    
    private var xpToNextTier: Int {
        // Mock calculation
        switch currentTier {
        case .unranked, .rookie: return 500
        case .verified: return 2000
        case .trusted: return 5000
        case .elite: return 10000
        case .master: return 0
        }
    }
}

#Preview {
    EligibilityScreen(
        requiredTier: .verified,
        currentTier: .rookie,
        taskTitle: "Premium Delivery Task",
        onDismiss: {},
        onLearnMore: {}
    )
}
