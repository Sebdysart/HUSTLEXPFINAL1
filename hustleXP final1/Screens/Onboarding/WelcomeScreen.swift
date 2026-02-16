//
//  WelcomeScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//  Clean, modern welcome experience - adaptive to all screen sizes
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(Router.self) private var router
    
    // Animation states
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            // Use safe area-adjusted height for compact detection
            // iPhone SE: ~553 usable, iPhone 14 Pro: ~759 usable, iPhone 14 Pro Max: ~818 usable
            let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompactHeight = usableHeight < 600
            
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()
                
                // Subtle gradient accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandPurple.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width / 2, y: 100)
                    .blur(radius: 60)
                    .ignoresSafeArea()
                
                // Main content in ScrollView - ALWAYS scrollable to prevent cutoff
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Progress bar
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.welcome.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)

                        // Top spacing - reduced for compact
                        Spacer()
                            .frame(height: isCompactHeight ? 20 : 40)
                        
                        // Logo section
                        logoSection(isCompact: isCompactHeight)
                        
                        // Spacing between logo and features - reduced for compact
                        Spacer()
                            .frame(height: isCompactHeight ? 16 : 32)
                        
                        // Features
                        featuresSection(isCompact: isCompactHeight)
                            .padding(.horizontal, 20)
                        
                        // Spacing before CTA - reduced for compact
                        Spacer()
                            .frame(height: isCompactHeight ? 16 : 32)
                        
                        // CTA section
                        ctaSection
                            .padding(.horizontal, 20)
                        
                        // Bottom spacing - ensure content doesn't get cut off
                        Spacer()
                            .frame(height: max(geometry.safeAreaInsets.bottom + 20, 36))
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Logo Section
    
    private func logoSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 16 : 20) {
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                    .shadow(color: Color.brandPurple.opacity(0.4), radius: 20)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: isCompact ? 36 : 44, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
            
            // Title
            VStack(spacing: 6) {
                Text("HustleXP")
                    .font(.system(size: isCompact ? 34 : 40, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Your hustle. Rewarded.")
                    .font(.system(size: isCompact ? 15 : 17, weight: .medium))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
        }
        .animation(.easeOut(duration: 0.5), value: showContent)
    }
    
    // MARK: - Features Section
    
    private func featuresSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            FeatureRow(
                icon: "briefcase.fill",
                title: "Find Tasks",
                description: "Discover opportunities that match your skills",
                color: .brandPurple,
                isCompact: isCompact
            )
            
            FeatureRow(
                icon: "star.fill",
                title: "Build Reputation",
                description: "Level up with every completed hustle",
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: 12) {
            HXButton("Get Started", icon: "arrow.right", variant: .primary) {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                router.navigateToOnboarding(.howItWorks)
            }
            .accessibilityLabel("Get started with onboarding")
            
            Text("Join thousands of hustlers")
                .font(.footnote)
                .foregroundStyle(Color.textMuted)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
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
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: isCompact ? 40 : 44, height: isCompact ? 40 : 44)
                
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text(description)
                    .font(.system(size: isCompact ? 12 : 13))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Preview

#Preview("Standard") {
    NavigationStack {
        WelcomeScreen()
    }
    .environment(Router())
}

#Preview("Compact (SE)", traits: .fixedLayout(width: 375, height: 667)) {
    NavigationStack {
        WelcomeScreen()
    }
    .environment(Router())
}
