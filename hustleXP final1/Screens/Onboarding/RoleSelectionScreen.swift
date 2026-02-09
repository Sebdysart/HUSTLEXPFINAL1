//
//  RoleSelectionScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//  Premium role selection with animated cards
//

import SwiftUI

struct RoleSelectionScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    @State private var selectedRole: UserRole?
    @State private var showContent = true
    @State private var hasAnimated = false
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Background
                backgroundLayer
                
                VStack(spacing: 0) {
                    // Header
                    headerSection(isCompact: isCompact)
                        .padding(.top, isCompact ? 8 : 16)
                    
                    Spacer()
                    
                    // Role cards
                    roleCardsSection(isCompact: isCompact)
                    
                    Spacer()
                    
                    // Continue button
                    continueSection(isCompact: isCompact)
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom + 8))
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
            if !hasAnimated {
                animateIn()
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            // Gradient orbs
            VStack {
                HStack {
                    Circle()
                        .fill(Color.brandPurple.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: -50, y: -50)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Circle()
                        .fill(Color.accentViolet.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: 50, y: 50)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: isCompact ? 60 : 72, height: isCompact ? 60 : 72)
                
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: isCompact ? 24 : 28, weight: .medium))
                    .foregroundStyle(Color.brandPurple)
            }
            .scaleEffect(showContent ? 1 : 0.5)
            .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 6) {
                Text("Choose Your Role")
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Select how you want to use HustleXP")
                    .font(.system(size: isCompact ? 14 : 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .padding(.horizontal, isCompact ? 18 : 24)
        .animation(.easeOut(duration: 0.5), value: showContent)
    }
    
    // MARK: - Role Cards Section
    
    private func roleCardsSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            PremiumRoleCard(
                role: .hustler,
                title: "Hustler",
                subtitle: "Complete tasks & earn money",
                features: ["Find nearby opportunities", "Build your reputation", "Get paid fast"],
                icon: "figure.run",
                gradient: [Color.brandPurple, Color.brandPurpleLight],
                isSelected: selectedRole == .hustler
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedRole = .hustler
                }
            }
            .opacity(showContent ? 1 : 0)
            
            PremiumRoleCard(
                role: .poster,
                title: "Poster",
                subtitle: "Post tasks & get help",
                features: ["Create custom tasks", "Find reliable help", "Track progress easily"],
                icon: "megaphone.fill",
                gradient: [Color.accentPurple, Color.accentViolet],
                isSelected: selectedRole == .poster
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedRole = .poster
                }
            }
            .opacity(showContent ? 1 : 0)
        }
        .padding(.horizontal, isCompact ? 18 : 24)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
    }
    
    // MARK: - Continue Section
    
    private func continueSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            HXButton(
                "Continue",
                icon: selectedRole != nil ? "arrow.right" : nil,
                variant: .primary
            ) {
                handleContinue()
            }
            .opacity(selectedRole != nil ? 1 : 0.5)
            .disabled(selectedRole == nil)
            
            if selectedRole == nil {
                Text("Select a role to continue")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            } else {
                Text("You can switch roles anytime in settings")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.horizontal, isCompact ? 18 : 24)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
    }
    
    // MARK: - Animations
    
    private func animateIn() {
        showContent = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            hasAnimated = true
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

// MARK: - Premium Role Card

private struct PremiumRoleCard: View {
    let role: UserRole
    let title: String
    let subtitle: String
    let features: [String]
    let icon: String
    let gradient: [Color]
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon with glow
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                    }
                    
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.25) : gradient[0].opacity(0.2))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : gradient[0])
                }
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(isSelected ? .white : Color.textPrimary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.textSecondary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.white : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    if isSelected {
                        // Selected gradient background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        // Unselected glass background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.surfaceElevated)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: isSelected ? gradient[0].opacity(0.4) : Color.black.opacity(0.2),
                radius: isSelected ? 20 : 10,
                x: 0,
                y: isSelected ? 10 : 5
            )
            .scaleEffect(isPressed ? 0.98 : (isSelected ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(RoleCardButtonStyle(isPressed: $isPressed))
    }
}

private struct RoleCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    NavigationStack {
        RoleSelectionScreen()
    }
    .environment(AppState())
    .environment(Router())
}
