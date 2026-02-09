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
        ZStack {
            // Background
            LinearGradient.brandGradient
                .ignoresSafeArea()
            
            // Confetti particles (simple version)
            if confettiTrigger {
                ConfettiView()
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success illustration with animation
                ZStack {
                    // Outer rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.successGreen.opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                            .frame(width: CGFloat(120 + index * 40), height: CGFloat(120 + index * 40))
                            .scaleEffect(showContent ? 1 : 0.5)
                            .animation(.spring(response: 0.6).delay(Double(index) * 0.1), value: showContent)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(Color.successGreen)
                        .frame(width: 100, height: 100)
                        .scaleEffect(checkmarkScale)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
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
                VStack(spacing: 16) {
                    HXText("You're All Set!", style: .largeTitle)
                    
                    HXText(
                        "Welcome to HustleXP, \(appState.userName ?? "Hustler")!",
                        style: .body,
                        color: .textSecondary
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                
                Spacer()
                
                // Stats preview card
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        HXText("Your Profile", style: .headline)
                        Spacer()
                        HXBadge(variant: .tier(appState.trustTier))
                    }
                    .padding(20)
                    .background(Color.surfaceElevated)
                    
                    HXDivider()
                    
                    // Stats
                    VStack(spacing: 16) {
                        StatRow(
                            icon: "person.fill",
                            label: "Role",
                            value: appState.userRole?.rawValue.capitalized ?? "Hustler"
                        )
                        
                        StatRow(
                            icon: "star.fill",
                            label: "Starting XP",
                            value: "0 XP"
                        )
                        
                        StatRow(
                            icon: "shield.fill",
                            label: "Trust Tier",
                            value: appState.trustTier.name
                        )
                    }
                    .padding(20)
                    .background(Color.surfacePrimary)
                }
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                
                Spacer()
                
                // Start button
                HXButton("Start Hustling", variant: .primary) {
                    appState.completeOnboarding()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: showContent)
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
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 24)
                
                HXText(label, style: .body, color: .textSecondary)
            }
            
            Spacer()
            
            HXText(value, style: .headline)
        }
    }
}

// MARK: - Simple Confetti View
private struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
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
            createParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [.brandPurple, .accentPurple, .successGreen, .warningOrange, .infoBlue]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
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
            withAnimation(.easeIn(duration: Double.random(in: 2...4)).delay(Double.random(in: 0...0.5))) {
                particles[i].position.y = screenHeight + 50
                particles[i].position.x += CGFloat.random(in: -100...100)
                particles[i].opacity = 0
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
