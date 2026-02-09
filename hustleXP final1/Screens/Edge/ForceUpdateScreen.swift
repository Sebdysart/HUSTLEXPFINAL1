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
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 32) {
                        Spacer(minLength: isCompact ? 20 : 40)
                        
                        // App icon with download indicator
                        ZStack {
                            RoundedRectangle(cornerRadius: isCompact ? 22 : 28)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.brandPurple, Color.brandPurpleLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: isCompact ? 90 : 120, height: isCompact ? 90 : 120)
                            
                            VStack(spacing: 4) {
                                HXText("HX", style: isCompact ? .title : .largeTitle, color: .white)
                                    .fontWeight(.black)
                            }
                            
                            // Download badge
                            Circle()
                                .fill(Color.brandBlack)
                                .frame(width: isCompact ? 32 : 40, height: isCompact ? 32 : 40)
                                .overlay(
                                    HXIcon(
                                        "arrow.down.circle.fill",
                                        size: .custom(isCompact ? 26 : 32),
                                        color: .successGreen
                                    )
                                )
                                .offset(x: isCompact ? 35 : 45, y: isCompact ? 35 : 45)
                        }
                        
                        // Content
                        VStack(spacing: isCompact ? 8 : 12) {
                            HXText("Update Required", style: isCompact ? .headline : .title2)
                            
                            HXText(
                                "A new version of HustleXP is available with important updates and new features.",
                                style: isCompact ? .subheadline : .body,
                                color: .textSecondary
                            )
                            .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        // Version info
                        VStack(spacing: isCompact ? 12 : 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HXText("Current Version", style: .caption, color: .textTertiary)
                                    HXText(currentVersion, style: isCompact ? .subheadline : .headline, color: .textSecondary)
                                }
                                
                                Spacer()
                                
                                HXIcon("arrow.right", size: .small, color: .textTertiary)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    HXText("New Version", style: .caption, color: .textTertiary)
                                    HXText(requiredVersion, style: isCompact ? .subheadline : .headline, color: .successGreen)
                                }
                            }
                        }
                        .padding(isCompact ? 16 : 20)
                        .background(Color.surfaceSecondary)
                        .cornerRadius(isCompact ? 14 : 16)
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        // What's new
                        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
                            HXText("What's New:", style: .caption, color: .textSecondary)
                            
                            UpdateFeature(icon: "bolt.fill", text: "Faster task matching", isCompact: isCompact)
                            UpdateFeature(icon: "shield.fill", text: "Enhanced security", isCompact: isCompact)
                            UpdateFeature(icon: "star.fill", text: "Improved XP system", isCompact: isCompact)
                            UpdateFeature(icon: "bubble.left.fill", text: "Better messaging", isCompact: isCompact)
                        }
                        .padding(isCompact ? 16 : 20)
                        .background(Color.surfacePrimary)
                        .cornerRadius(isCompact ? 14 : 16)
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        Spacer(minLength: isCompact ? 20 : 40)
                        
                        // Update button
                        VStack(spacing: isCompact ? 12 : 16) {
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
                                .padding(.horizontal, isCompact ? 20 : 24)
                            } else {
                                HXButton(
                                    "Update Now",
                                    variant: .primary,
                                    size: isCompact ? .medium : .large
                                ) {
                                    openAppStore()
                                }
                                .padding(.horizontal, isCompact ? 20 : 24)
                            }
                            
                            HXText(
                                "This update is required to continue using HustleXP",
                                style: .caption,
                                color: .textTertiary
                            )
                            .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, isCompact ? 20 : 32)
                    }
                }
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
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundStyle(Color.brandPurple)
                .frame(width: isCompact ? 20 : 24)
            
            HXText(text, style: isCompact ? .footnote : .subheadline, color: .textPrimary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                .foregroundStyle(Color.successGreen)
        }
    }
}

#Preview {
    ForceUpdateScreen(currentVersion: "1.0.0", requiredVersion: "2.0.0")
}
