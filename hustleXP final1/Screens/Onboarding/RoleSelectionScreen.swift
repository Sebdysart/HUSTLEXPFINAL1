//
//  RoleSelectionScreen.swift
//  hustleXP final1
//
//  Clean role selection for onboarding
//

import SwiftUI

struct RoleSelectionScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    @State private var selectedRole: UserRole?
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 24 : 32) {
                        // Progress
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.roleSelection.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)
                        
                        // Header
                        VStack(spacing: 8) {
                            Text("How will you use HustleXP?")
                                .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("You can switch anytime in settings")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, isCompact ? 8 : 16)
                        
                        // Role cards
                        VStack(spacing: isCompact ? 12 : 16) {
                            RoleCard(
                                title: "Hustler",
                                subtitle: "Find tasks and earn money",
                                icon: "figure.run",
                                isSelected: selectedRole == .hustler
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRole = .hustler
                                }
                            }
                            
                            RoleCard(
                                title: "Poster",
                                subtitle: "Post tasks and get help",
                                icon: "megaphone.fill",
                                isSelected: selectedRole == .poster
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRole = .poster
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: safeHeight)
                }
                
                // Bottom CTA
                VStack {
                    Spacer()
                    bottomBar(isCompact: isCompact, bottomInset: geometry.safeAreaInsets.bottom)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Choose Role")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Bottom Bar
    
    private func bottomBar(isCompact: Bool, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 8) {
                Button(action: handleContinue) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.body.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedRole != nil ? Color.brandPurple : Color.textMuted.opacity(0.5))
                    )
                }
                .disabled(selectedRole == nil)
                .accessibilityLabel("Continue to next step")
                
                if selectedRole == nil {
                    Text("Select a role to continue")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, max(16, bottomInset))
            .background(Color.brandBlack)
        }
    }
    
    private func handleContinue() {
        guard let role = selectedRole else { return }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        appState.setRole(role)
        router.navigateToOnboarding(.permissions)
    }
}

// MARK: - Role Card

private struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(isSelected ? Color.brandPurple.opacity(0.2) : Color.surfaceSecondary)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.brandPurple : Color.textSecondary)
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
                
                // Radio indicator
                Circle()
                    .stroke(isSelected ? Color.brandPurple : Color.borderSubtle, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.brandPurple : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.brandPurple : Color.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RoleSelectionScreen()
    }
    .environment(AppState())
    .environment(Router())
}
