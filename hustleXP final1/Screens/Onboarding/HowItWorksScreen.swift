//
//  HowItWorksScreen.swift
//  hustleXP final1
//
//  Clean tutorial carousel showing how HustleXP works
//

import SwiftUI

struct HowItWorksScreen: View {
    @Environment(Router.self) private var router

    @State private var currentPage = 0

    private let pages: [TutorialPage] = [
        TutorialPage(
            icon: "magnifyingglass",
            title: "Discover Tasks",
            subtitle: "Browse local tasks posted by people in your area",
            color: .brandPurple
        ),
        TutorialPage(
            icon: "checkmark.shield.fill",
            title: "Complete & Prove",
            subtitle: "Finish the task and submit photo proof for verification",
            color: .infoBlue
        ),
        TutorialPage(
            icon: "dollarsign.circle.fill",
            title: "Get Paid",
            subtitle: "Receive instant payout when your work is approved",
            color: .moneyGreen
        ),
    ]

    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                Color.brandBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress
                    OnboardingProgressBar(
                        currentStep: OnboardingRoute.howItWorks.stepIndex,
                        totalSteps: OnboardingRoute.totalSteps
                    )
                    .padding(.top, 8)

                    // Carousel
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            pageView(pages[index], isCompact: isCompact)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[index].color : Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, isCompact ? 20 : 32)

                    // CTA
                    VStack(spacing: 12) {
                        Button(action: handleNext) {
                            HStack(spacing: 8) {
                                Text(currentPage < pages.count - 1 ? "Next" : "Continue")
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
                        .accessibilityLabel(currentPage < pages.count - 1 ? "Next page" : "Continue to role selection")

                        if currentPage < pages.count - 1 {
                            Button(action: { router.navigateToOnboarding(.roleSelection) }) {
                                Text("Skip")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textMuted)
                            }
                            .accessibilityLabel("Skip tutorial")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 16))
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Page View

    private func pageView(_ page: TutorialPage, isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 24 : 32) {
            Spacer()

            // Icon
            Circle()
                .fill(page.color)
                .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                .overlay(
                    Image(systemName: page.icon)
                        .font(.system(size: isCompact ? 36 : 44, weight: .medium))
                        .foregroundStyle(.white)
                )

            // Text
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Actions

    private func handleNext() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            router.navigateToOnboarding(.roleSelection)
        }
    }
}

// MARK: - Page Model

private struct TutorialPage {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

#Preview {
    NavigationStack {
        HowItWorksScreen()
    }
    .environment(Router())
}
