//
//  HowItWorksScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//  Premium animated tutorial showing how HustleXP works
//  v2.3.0: New onboarding step — interactive page-swiping carousel
//

import SwiftUI

struct HowItWorksScreen: View {
    @Environment(Router.self) private var router

    @State private var currentPage = 0
    @State private var showContent = false

    private let pages: [HowItWorksPage] = [
        HowItWorksPage(
            icon: "magnifyingglass",
            iconGradient: [Color.brandPurple, Color.brandPurpleLight],
            title: "Discover Tasks",
            subtitle: "Browse local tasks posted by people in your area. Filter by skill, distance, and payout.",
            detail: "AI-powered matching finds the best tasks for your skills and location.",
            accentColor: .brandPurple
        ),
        HowItWorksPage(
            icon: "checkmark.shield.fill",
            iconGradient: [Color.infoBlue, Color(hex: "5BA3FF")],
            title: "Complete & Prove",
            subtitle: "Accept a task, complete it, and submit photo proof. GPS verification ensures trust.",
            detail: "Escrow protects both parties. Money is held securely until work is verified.",
            accentColor: .infoBlue
        ),
        HowItWorksPage(
            icon: "star.circle.fill",
            iconGradient: [Color.moneyGreen, Color(hex: "34D399")],
            title: "Get Paid & Level Up",
            subtitle: "Instant payout when your proof is approved. Earn XP to unlock premium tasks.",
            detail: "Build your reputation with every completed task. Higher trust = better opportunities.",
            accentColor: .moneyGreen
        ),
    ]

    var body: some View {
        GeometryReader { geometry in
            // Use safe area-adjusted height for compact detection
            let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = usableHeight < 600

            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()

                // Animated gradient orb following current page
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                pages[currentPage].accentColor.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 500)
                    .offset(y: isCompact ? -80 : -60)
                    .blur(radius: 40)
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress bar
                    OnboardingProgressBar(
                        currentStep: OnboardingRoute.howItWorks.stepIndex,
                        totalSteps: OnboardingRoute.totalSteps
                    )
                    .padding(.top, 8)

                    // Tab view carousel
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            pageView(pages[index], isCompact: isCompact, geometry: geometry)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Custom page indicator
                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? pages[currentPage].accentColor : Color.white.opacity(0.2))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, isCompact ? 16 : 24)

                    // CTA
                    VStack(spacing: 12) {
                        HXButton(
                            currentPage < pages.count - 1 ? "Next" : "Choose Your Role",
                            icon: "arrow.right",
                            variant: .primary
                        ) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()

                            if currentPage < pages.count - 1 {
                                withAnimation(.spring(response: 0.4)) {
                                    currentPage += 1
                                }
                            } else {
                                router.navigateToOnboarding(.roleSelection)
                            }
                        }
                        .accessibilityLabel(currentPage < pages.count - 1 ? "Next page" : "Choose your role")

                        if currentPage < pages.count - 1 {
                            Button(action: {
                                router.navigateToOnboarding(.roleSelection)
                            }) {
                                Text("Skip")
                                    .font(.system(size: 14, weight: .medium))
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(Color.textMuted)
                            }
                            .accessibilityLabel("Skip tutorial")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(24, geometry.safeAreaInsets.bottom + 16))
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }

    // MARK: - Page View

    private func pageView(_ page: HowItWorksPage, isCompact: Bool, geometry: GeometryProxy) -> some View {
        VStack(spacing: isCompact ? 24 : 36) {
            Spacer()

            // Large icon with animated rings
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(page.accentColor.opacity(0.1), lineWidth: 2)
                    .frame(width: isCompact ? 160 : 200, height: isCompact ? 160 : 200)

                Circle()
                    .stroke(page.accentColor.opacity(0.15), lineWidth: 2)
                    .frame(width: isCompact ? 130 : 160, height: isCompact ? 130 : 160)

                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 100 : 120, height: isCompact ? 100 : 120)
                    .shadow(color: page.accentColor.opacity(0.4), radius: 30, y: 10)

                Image(systemName: page.icon)
                    .font(.system(size: isCompact ? 42 : 52, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            // Text content
            VStack(spacing: isCompact ? 12 : 16) {
                Text(page.title)
                    .font(.system(size: isCompact ? 26 : 32, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.subtitle)
                    .font(.system(size: isCompact ? 15 : 17))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                // Detail chip
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(page.accentColor)
                        .frame(width: 16)

                    Text(page.detail)
                        .font(.system(size: isCompact ? 12 : 13, weight: .medium))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(page.accentColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(page.accentColor.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)

            Spacer()
            Spacer()
        }
        .frame(width: geometry.size.width)
    }
}

// MARK: - Page Model

private struct HowItWorksPage {
    let icon: String
    let iconGradient: [Color]
    let title: String
    let subtitle: String
    let detail: String
    let accentColor: Color
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HowItWorksScreen()
    }
    .environment(Router())
}
