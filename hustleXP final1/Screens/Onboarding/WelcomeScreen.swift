//
//  WelcomeScreen.swift
//  hustleXP final1
//
//  Clean welcome screen for onboarding
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Progress
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.welcome.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)
                        
                        Spacer().frame(height: isCompact ? 24 : 48)
                        
                        // Logo
                        logoSection(isCompact: isCompact)
                        
                        Spacer().frame(height: isCompact ? 24 : 40)
                        
                        // Features
                        featuresSection(isCompact: isCompact)
                            .padding(.horizontal, 20)
                        
                        Spacer().frame(height: isCompact ? 24 : 40)
                        
                        // CTA
                        ctaSection
                            .padding(.horizontal, 20)
                        
                        Spacer().frame(height: max(geometry.safeAreaInsets.bottom + 20, 32))
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Logo Section
    
    private func logoSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            // Logo icon
            Circle()
                .fill(Color.brandPurple)
                .frame(width: isCompact ? 72 : 88, height: isCompact ? 72 : 88)
                .overlay(
                    Image(systemName: "bolt.fill")
                        .font(.system(size: isCompact ? 32 : 40, weight: .medium))
                        .foregroundStyle(.white)
                )
            
            // Title
            VStack(spacing: 4) {
                Text("HustleXP")
                    .font(.system(size: isCompact ? 32 : 38, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Your hustle. Rewarded.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
    
    // MARK: - Features Section
    
    private func featuresSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            FeatureRow(
                icon: "briefcase.fill",
                title: "Find Tasks",
                description: "Discover opportunities near you",
                color: .brandPurple,
                isCompact: isCompact
            )
            
            FeatureRow(
                icon: "star.fill",
                title: "Build Reputation",
                description: "Level up with every completed task",
                color: .warningOrange,
                isCompact: isCompact
            )
            
            FeatureRow(
                icon: "dollarsign.circle.fill",
                title: "Get Paid",
                description: "Secure payments, fast transfers",
                color: .moneyGreen,
                isCompact: isCompact
            )
        }
        .padding(isCompact ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
        )
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                router.navigateToOnboarding(.howItWorks)
            }) {
                HStack(spacing: 8) {
                    Text("Get Started")
                        .font(.body.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brandPurple)
                )
            }
            .accessibilityLabel("Get started with onboarding")
            
            Text("Join thousands of hustlers")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: isCompact ? 40 : 44, height: isCompact ? 40 : 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundStyle(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(description)
                    .font(.system(size: isCompact ? 12 : 13))
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeScreen()
    }
    .environment(Router())
}
