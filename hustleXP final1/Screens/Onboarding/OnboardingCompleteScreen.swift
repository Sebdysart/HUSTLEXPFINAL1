//
//  OnboardingCompleteScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//  Chosen-state: Success achieved, ready to proceed
//

import SwiftUI

struct OnboardingCompleteScreen: View {
    @Environment(AppState.self) private var appState
    
    @State private var showContent = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var confettiTrigger = false
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Background
                LinearGradient.brandGradient
                    .ignoresSafeArea()
                
                // Confetti particles (simple version)
                if confettiTrigger {
                    ConfettiView()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 24 : 32) {
                        Spacer(minLength: isCompact ? 30 : 50)
                        
                        // Success illustration with animation
                        ZStack {
                            // Outer rings
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .stroke(Color.successGreen.opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                                    .frame(width: CGFloat((isCompact ? 90 : 120) + index * (isCompact ? 30 : 40)), height: CGFloat((isCompact ? 90 : 120) + index * (isCompact ? 30 : 40)))
                                    .scaleEffect(showContent ? 1 : 0.5)
                                    .animation(.spring(response: 0.6).delay(Double(index) * 0.1), value: showContent)
                            }
                            
                            // Main circle
                            Circle()
                                .fill(Color.successGreen)
                                .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                                .scaleEffect(checkmarkScale)
                            
                            // Checkmark
                            Image(systemName: "checkmark")
                                .font(.system(size: isCompact ? 36 : 48, weight: .bold))
                                .foregroundStyle(.white)
                                .scaleEffect(checkmarkScale)
                        }
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                        checkmarkScale = 1.0
                        showContent = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        confettiTrigger = true
                    }
                }
                
                        // Header
                        VStack(spacing: isCompact ? 12 : 16) {
                            Text("You're All Set!")
                                .font(.system(size: isCompact ? 28 : 34, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                            
                            Text("Welcome to HustleXP, \(appState.userName ?? "Hustler")!")
                                .font(.system(size: isCompact ? 15 : 17))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                        
                        Spacer(minLength: isCompact ? 20 : 30)
                        
                        // Stats preview card
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("Your Profile")
                                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                HXBadge(variant: .tier(appState.trustTier))
                            }
                            .padding(isCompact ? 16 : 20)
                            .background(Color.surfaceElevated)
                            
                            HXDivider()
                            
                            // Stats
                            VStack(spacing: isCompact ? 12 : 16) {
                                StatRow(
                                    icon: "person.fill",
                                    label: "Role",
                                    value: appState.userRole?.rawValue.capitalized ?? "Hustler",
                                    isCompact: isCompact
                                )
                                
                                StatRow(
                                    icon: "star.fill",
                                    label: "Starting XP",
                                    value: "0 XP",
                                    isCompact: isCompact
                                )
                                
                                StatRow(
                                    icon: "shield.fill",
                                    label: "Trust Tier",
                                    value: appState.trustTier.name,
                                    isCompact: isCompact
                                )
                            }
                            .padding(isCompact ? 16 : 20)
                            .background(Color.surfacePrimary)
                        }
                        .cornerRadius(isCompact ? 16 : 20)
                        .padding(.horizontal, isCompact ? 18 : 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                        
                        Spacer(minLength: isCompact ? 20 : 30)
                        
                        // Start button
                        HXButton("Start Hustling", variant: .primary) {
                            appState.completeOnboarding()
                        }
                        .padding(.horizontal, isCompact ? 18 : 24)
                        .padding(.bottom, max(24, geometry.safeAreaInsets.bottom + 16))
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.8), value: showContent)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Stat Row
private struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    var isCompact: Bool = false
    
    var body: some View {
        HStack {
            HStack(spacing: isCompact ? 10 : 12) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: isCompact ? 20 : 24)
                
                Text(label)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: isCompact ? 15 : 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}

// MARK: - Simple Confetti View
private struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var hasCreatedParticles = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                guard !hasCreatedParticles else { return }
                hasCreatedParticles = true
                createParticles(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
            }
        }
    }
    
    private func createParticles(screenWidth: CGFloat, screenHeight: CGFloat) {
        let colors: [Color] = [.brandPurple, .accentPurple, .successGreen, .warningOrange, .infoBlue]
        
        for i in 0..<30 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                position: CGPoint(x: CGFloat.random(in: 0...screenWidth), y: -20),
                opacity: 1.0
            )
            particles.append(particle)
            
            // Animate falling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: Double.random(in: 2...4)).delay(Double.random(in: 0...0.5))) {
                    if i < particles.count {
                        particles[i].position.y = screenHeight + 50
                        particles[i].position.x += CGFloat.random(in: -100...100)
                        particles[i].opacity = 0
                    }
                }
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

#Preview {
    OnboardingCompleteScreen()
        .environment(AppState())
}
