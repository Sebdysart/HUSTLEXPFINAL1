//
//  MaintenanceScreen.swift
//  hustleXP final1
//
//  Archetype: F (System/Interrupt)
//

import SwiftUI

struct MaintenanceScreen: View {
    var estimatedTime: String? = nil
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 32) {
                        Spacer(minLength: isCompact ? 20 : 40)
                        
                        // Animated gears illustration
                        ZStack {
                            Circle()
                                .fill(Color.warningYellow.opacity(0.15))
                                .frame(width: isCompact ? 100 : 140, height: isCompact ? 100 : 140)
                            
                            // Rotating gear
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: isCompact ? 28 : 36))
                                .foregroundStyle(Color.warningYellow)
                                .rotationEffect(.degrees(rotationAngle))
                                .offset(x: isCompact ? -15 : -20, y: isCompact ? -8 : -10)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: isCompact ? 18 : 24))
                                .foregroundStyle(Color.warningYellow.opacity(0.7))
                                .rotationEffect(.degrees(-rotationAngle))
                                .offset(x: isCompact ? 12 : 15, y: isCompact ? 12 : 15)
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                        
                        // Content
                        VStack(spacing: isCompact ? 8 : 12) {
                            HXText("We're Upgrading", style: isCompact ? .headline : .title2)
                            
                            HXText(
                                "HustleXP is getting some improvements.\nWe'll be back shortly!",
                                style: isCompact ? .subheadline : .body,
                                color: .textSecondary
                            )
                            .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        // Status card
                        VStack(spacing: isCompact ? 12 : 16) {
                            HStack {
                                HXIcon("clock.fill", size: .small, color: .warningYellow)
                                HXText("Estimated downtime", style: isCompact ? .footnote : .subheadline, color: .textSecondary)
                                Spacer()
                                HXText(estimatedTime ?? "~15 minutes", style: isCompact ? .subheadline : .headline)
                            }
                            
                            HXDivider()
                            
                            HStack {
                                HXIcon("bell.badge.fill", size: .small, color: .brandPurple)
                                HXText("We'll notify you when we're back", style: isCompact ? .footnote : .subheadline, color: .textSecondary)
                                Spacer()
                            }
                        }
                        .padding(isCompact ? 16 : 20)
                        .background(Color.surfaceSecondary)
                        .cornerRadius(isCompact ? 14 : 16)
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        // What's happening
                        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
                            HXText("What we're working on:", style: .caption, color: .textSecondary)
                            
                            MaintenanceItem(icon: "bolt.fill", text: "Performance improvements", isCompact: isCompact)
                            MaintenanceItem(icon: "shield.fill", text: "Security updates", isCompact: isCompact)
                            MaintenanceItem(icon: "sparkles", text: "New features coming soon", isCompact: isCompact)
                        }
                        .padding(isCompact ? 16 : 20)
                        .background(Color.surfacePrimary)
                        .cornerRadius(isCompact ? 14 : 16)
                        .padding(.horizontal, isCompact ? 20 : 24)
                        
                        Spacer(minLength: isCompact ? 20 : 40)
                        
                        // Footer
                        VStack(spacing: isCompact ? 6 : 8) {
                            HXText(
                                "Thanks for your patience",
                                style: isCompact ? .footnote : .subheadline,
                                color: .textSecondary
                            )
                            
                            HStack(spacing: 4) {
                                HXIcon("heart.fill", size: .small, color: .errorRed)
                                HXText("The HustleXP Team", style: .caption, color: .textTertiary)
                            }
                        }
                        .padding(.bottom, isCompact ? 24 : 48)
                    }
                }
            }
        }
    }
}

// MARK: - Maintenance Item
private struct MaintenanceItem: View {
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
    MaintenanceScreen(estimatedTime: "~30 minutes")
}
