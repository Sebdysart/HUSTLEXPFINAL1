//
//  VerificationSettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct VerificationSettingsScreen: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header card
                    VerificationHeaderCard(trustTier: appState.trustTier)
                    
                    // Current tier info
                    CurrentTierCard(trustTier: appState.trustTier)
                    
                    // Verification steps
                    VerificationStepsSection()
                    
                    // Benefits section
                    VerificationBenefitsSection()
                    
                    Spacer(minLength: 100)
                }
                .padding(24)
            }
            
            // Bottom CTA
            VStack {
                Spacer()
                VerificationCTA()
            }
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Verification Header Card
private struct VerificationHeaderCard: View {
    let trustTier: TrustTier
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.brandPurple)
            }
            
            VStack(spacing: 8) {
                HXText("Get Verified", style: .title2)
                
                HXText(
                    "Verified users unlock premium tasks, earn trust faster, and get priority matching.",
                    style: .subheadline,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.brandPurple.opacity(0.1), Color.surfaceElevated],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Current Tier Card
private struct CurrentTierCard: View {
    let trustTier: TrustTier
    
    var body: some View {
        HStack(spacing: 16) {
            HXBadge(variant: .tier(trustTier))
            
            VStack(alignment: .leading, spacing: 2) {
                HXText("Current Tier", style: .caption, color: .textSecondary)
                HXText(trustTier.name, style: .headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HXText("Progress", style: .caption, color: .textSecondary)
                HXText("25%", style: .headline, color: .brandPurple)
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Verification Steps Section
private struct VerificationStepsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Verification Steps", style: .headline)
            
            VStack(spacing: 12) {
                VerificationStepRow(
                    title: "Phone Number",
                    subtitle: "Verified",
                    status: .complete
                )
                
                VerificationStepRow(
                    title: "Email Address",
                    subtitle: "Verified",
                    status: .complete
                )
                
                VerificationStepRow(
                    title: "Identity Verification",
                    subtitle: "Upload your ID to verify",
                    status: .pending
                )
                
                VerificationStepRow(
                    title: "Background Check",
                    subtitle: "Complete after ID verification",
                    status: .notStarted
                )
            }
        }
    }
}

// MARK: - Verification Status
enum VerificationStatus {
    case notStarted
    case pending
    case complete
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .pending: return "clock.fill"
        case .complete: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notStarted: return .textTertiary
        case .pending: return .warningOrange
        case .complete: return .successGreen
        }
    }
    
    var label: String {
        switch self {
        case .notStarted: return "Not Started"
        case .pending: return "In Progress"
        case .complete: return "Complete"
        }
    }
}

// MARK: - Verification Step Row
private struct VerificationStepRow: View {
    let title: String
    let subtitle: String
    let status: VerificationStatus
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: status.icon)
                .font(.system(size: 24))
                .foregroundStyle(status.color)
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(title, style: .body)
                HXText(subtitle, style: .caption, color: .textSecondary)
            }
            
            Spacer()
            
            if status == .notStarted || status == .pending {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

// MARK: - Verification Benefits Section
private struct VerificationBenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Benefits of Verification", style: .headline)
            
            VStack(spacing: 12) {
                BenefitRow(
                    icon: "star.fill",
                    iconColor: .warningOrange,
                    title: "Premium Tasks",
                    description: "Access high-paying tasks from verified posters"
                )
                
                BenefitRow(
                    icon: "bolt.fill",
                    iconColor: .brandPurple,
                    title: "Priority Matching",
                    description: "Get matched to tasks faster"
                )
                
                BenefitRow(
                    icon: "shield.fill",
                    iconColor: .successGreen,
                    title: "Trust Badge",
                    description: "Stand out with a verified badge on your profile"
                )
                
                BenefitRow(
                    icon: "arrow.up.circle.fill",
                    iconColor: .infoBlue,
                    title: "Higher Limits",
                    description: "Increased earning and task limits"
                )
            }
        }
    }
}

// MARK: - Benefit Row
private struct BenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(title, style: .subheadline)
                HXText(description, style: .caption, color: .textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

// MARK: - Verification CTA
private struct VerificationCTA: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HXButton("Start Identity Verification", variant: .primary) {
                // Start verification
            }
            .accessibilityLabel("Start identity verification")
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

#Preview {
    NavigationStack {
        VerificationSettingsScreen()
    }
    .environment(AppState())
}
