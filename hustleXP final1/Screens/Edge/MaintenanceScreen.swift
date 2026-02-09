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
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated gears illustration
                ZStack {
                    Circle()
                        .fill(Color.warningYellow.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    // Rotating gear
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.warningYellow)
                        .rotationEffect(.degrees(rotationAngle))
                        .offset(x: -20, y: -10)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.warningYellow.opacity(0.7))
                        .rotationEffect(.degrees(-rotationAngle))
                        .offset(x: 15, y: 15)
                }
                .onAppear {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
                
                // Content
                VStack(spacing: 12) {
                    HXText("We're Upgrading", style: .title2)
                    
                    HXText(
                        "HustleXP is getting some improvements.\nWe'll be back shortly!",
                        style: .body,
                        color: .textSecondary
                    )
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Status card
                VStack(spacing: 16) {
                    HStack {
                        HXIcon(name: "clock.fill", size: .small, color: .warningYellow)
                        HXText("Estimated downtime", style: .subheadline, color: .textSecondary)
                        Spacer()
                        HXText(estimatedTime ?? "~15 minutes", style: .headline)
                    }
                    
                    HXDivider()
                    
                    HStack {
                        HXIcon(name: "bell.badge.fill", size: .small, color: .brandPurple)
                        HXText("We'll notify you when we're back", style: .subheadline, color: .textSecondary)
                        Spacer()
                    }
                }
                .padding(20)
                .background(Color.surfaceSecondary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                // What's happening
                VStack(alignment: .leading, spacing: 12) {
                    HXText("What we're working on:", style: .caption, color: .textSecondary)
                    
                    MaintenanceItem(icon: "bolt.fill", text: "Performance improvements")
                    MaintenanceItem(icon: "shield.fill", text: "Security updates")
                    MaintenanceItem(icon: "sparkles", text: "New features coming soon")
                }
                .padding(20)
                .background(Color.surfacePrimary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    HXText(
                        "Thanks for your patience",
                        style: .subheadline,
                        color: .textSecondary
                    )
                    
                    HStack(spacing: 4) {
                        HXIcon(name: "heart.fill", size: .small, color: .errorRed)
                        HXText("The HustleXP Team", style: .caption, color: .textTertiary)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Maintenance Item
private struct MaintenanceItem: View {
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
    MaintenanceScreen(estimatedTime: "~30 minutes")
}
