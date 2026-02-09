//
//  ForceUpdateScreen.swift
//  hustleXP final1
//
//  Archetype: F (System/Interrupt)
//

import SwiftUI

struct ForceUpdateScreen: View {
    var currentVersion: String = "1.0.0"
    var requiredVersion: String = "2.0.0"
    
    @State private var downloadProgress: Double = 0
    @State private var isDownloading = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App icon with download indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPurple, Color.brandPurpleLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 4) {
                        HXText("HX", style: .largeTitle, color: .white)
                            .fontWeight(.black)
                    }
                    
                    // Download badge
                    Circle()
                        .fill(Color.brandBlack)
                        .frame(width: 40, height: 40)
                        .overlay(
                            HXIcon(
                                name: "arrow.down.circle.fill",
                                size: .custom(32),
                                color: .successGreen
                            )
                        )
                        .offset(x: 45, y: 45)
                }
                
                // Content
                VStack(spacing: 12) {
                    HXText("Update Required", style: .title2)
                    
                    HXText(
                        "A new version of HustleXP is available with important updates and new features.",
                        style: .body,
                        color: .textSecondary
                    )
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Version info
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HXText("Current Version", style: .caption, color: .textTertiary)
                            HXText(currentVersion, style: .headline, color: .textSecondary)
                        }
                        
                        Spacer()
                        
                        HXIcon(name: "arrow.right", size: .small, color: .textTertiary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HXText("New Version", style: .caption, color: .textTertiary)
                            HXText(requiredVersion, style: .headline, color: .successGreen)
                        }
                    }
                }
                .padding(20)
                .background(Color.surfaceSecondary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                // What's new
                VStack(alignment: .leading, spacing: 12) {
                    HXText("What's New:", style: .caption, color: .textSecondary)
                    
                    UpdateFeature(icon: "bolt.fill", text: "Faster task matching")
                    UpdateFeature(icon: "shield.fill", text: "Enhanced security")
                    UpdateFeature(icon: "star.fill", text: "Improved XP system")
                    UpdateFeature(icon: "bubble.left.fill", text: "Better messaging")
                }
                .padding(20)
                .background(Color.surfacePrimary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Update button
                VStack(spacing: 16) {
                    if isDownloading {
                        VStack(spacing: 8) {
                            HXProgressBar(
                                progress: downloadProgress,
                                variant: .linear,
                                color: .brandPurple,
                                showLabel: true
                            )
                            HXText("Opening App Store...", style: .caption, color: .textSecondary)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        HXButton(
                            title: "Update Now",
                            variant: .primary
                        ) {
                            openAppStore()
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    HXText(
                        "This update is required to continue using HustleXP",
                        style: .caption,
                        color: .textTertiary
                    )
                    .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    private func openAppStore() {
        isDownloading = true
        
        // Simulate progress animation
        withAnimation(.linear(duration: 1.5)) {
            downloadProgress = 1.0
        }
        
        // Open App Store after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let url = URL(string: "itms-apps://apps.apple.com/app/idYOUR_APP_ID") {
                UIApplication.shared.open(url)
            }
            isDownloading = false
            downloadProgress = 0
        }
    }
}

// MARK: - Update Feature Row
private struct UpdateFeature: View {
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
            
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.successGreen)
        }
    }
}

#Preview {
    ForceUpdateScreen(currentVersion: "1.0.0", requiredVersion: "2.0.0")
}
