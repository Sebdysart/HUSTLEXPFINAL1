//
//  XPBreakdownScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct XPBreakdownScreen: View {
    @Environment(LiveDataService.self) private var dataService
    
    private var user: HXUser {
        dataService.currentUser
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // XP hero
                    xpHero
                    
                    // Tier progress
                    tierProgress
                    
                    // XP sources guide
                    xpSourcesGuide
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("XP Breakdown")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - XP Hero
    
    private var xpHero: some View {
        VStack(spacing: 12) {
            HXText("Total XP", style: .subheadline, color: .textSecondary)
            
            Text("\(user.xp)")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Color.brandPurple)
            
            HXBadge(variant: .tier(user.trustTier))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [Color.brandPurple.opacity(0.1), Color.brandPurple.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Tier Progress
    
    private var tierProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Trust Tier Progress", style: .headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Current tier info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HXText("Current Tier", style: .caption, color: .textSecondary)
                        HXText(user.trustTier.name, style: .headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HXText("Next Tier", style: .caption, color: .textSecondary)
                        HXText(nextTierName, style: .headline, color: .brandPurple)
                    }
                }
                
                // Progress bar
                HXProgressBar(
                    progress: user.xpProgress,
                    variant: .linear,
                    color: .brandPurple,
                    showLabel: true,
                    label: "\(user.xp) / \(user.xpToNextTier) XP"
                )
                
                // Tier benefits preview
                if user.trustTier != .master {
                    HStack(spacing: 8) {
                        HXIcon("sparkles", size: .small, color: .brandPurple)
                        HXText("Unlock \(nextTierName) perks at \(user.xpToNextTier) XP", style: .caption, color: .textSecondary)
                    }
                }
            }
            .padding()
            .background(Color.surfaceElevated)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - XP Sources Guide
    
    private var xpSourcesGuide: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("How to Earn XP", style: .headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                XPSourceRow(
                    icon: "checkmark.circle.fill",
                    source: "Complete tasks",
                    xp: "+10-50",
                    description: "Based on task complexity"
                )
                XPSourceRow(
                    icon: "star.fill",
                    source: "5-star ratings",
                    xp: "+5",
                    description: "When poster rates you 5 stars"
                )
                XPSourceRow(
                    icon: "bolt.fill",
                    source: "Quick completion",
                    xp: "+3",
                    description: "Finish ahead of estimate"
                )
                XPSourceRow(
                    icon: "checkmark.shield.fill",
                    source: "Verification bonus",
                    xp: "+25",
                    description: "One-time for ID verification"
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var nextTierName: String {
        switch user.trustTier {
        case .rookie: return "Verified"
        case .verified: return "Trusted"
        case .trusted: return "Elite"
        case .elite: return "Master"
        case .master: return "Max Level"
        }
    }
}

// MARK: - XP Source Row

struct XPSourceRow: View {
    let icon: String
    let source: String
    let xp: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundStyle(Color.brandPurple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(source, style: .subheadline)
                HXText(description, style: .caption, color: .textSecondary)
            }
            
            Spacer()
            
            HXText(xp, style: .headline, color: .brandPurple)
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        XPBreakdownScreen()
    }
    .environment(LiveDataService.shared)
}
