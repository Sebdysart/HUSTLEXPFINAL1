//
//  LevelUpCelebration.swift
//  hustleXP final1
//
//  Full-screen celebration overlay when user reaches a new level
//

import SwiftUI

struct LevelUpCelebration: View {
    let newLevel: Int
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showParticles = false
    @State private var pulseScale: CGFloat = 0.5

    private var levelTitle: String {
        switch newLevel {
        case 1: return "Newcomer"
        case 2: return "Apprentice"
        case 3: return "Rising Star"
        case 4: return "Skilled Worker"
        case 5: return "Expert"
        case 6: return "Veteran"
        case 7: return "Master"
        case 8: return "Champion"
        case 9: return "Legend"
        case 10: return "Mythic"
        default: return "Level \(newLevel)"
        }
    }

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            // Particle effects
            if showParticles {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(i % 2 == 0 ? Color.brandPurple : Color.xpGold)
                        .frame(width: CGFloat.random(in: 4...12))
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: -300...300)
                        )
                        .opacity(showParticles ? 0 : 1)
                        .animation(
                            .easeOut(duration: Double.random(in: 1.5...3.0))
                            .delay(Double.random(in: 0...0.5)),
                            value: showParticles
                        )
                }
            }

            // Content
            VStack(spacing: 24) {
                Spacer()

                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.brandPurple.opacity(0.6), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(pulseScale)

                    VStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.xpGold)

                        Text("\(newLevel)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.brandPurple, .white],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.3)
                .opacity(showContent ? 1 : 0)

                // Text
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)

                    Text(levelTitle)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.brandPurple)

                    Text("Keep hustling to unlock new perks!")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .padding(.top, 4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)

                Spacer()

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 2.0)) {
                    showParticles = true
                }
            }
        }
    }
}

// MARK: - Streak At Risk Banner
struct StreakAtRiskBanner: View {
    let currentStreak: Int
    let onTakeAction: () -> Void

    @State private var pulse = false

    var body: some View {
        HStack(spacing: 12) {
            // Fire icon with pulse
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Color.white)
                .scaleEffect(pulse ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)

            VStack(alignment: .leading, spacing: 2) {
                Text("Streak at risk!")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)

                Text("Complete 1 task to keep your \(currentStreak)-day streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button {
                onTakeAction()
            } label: {
                Text("Go")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.warningOrange, Color.errorRed],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onAppear { pulse = true }
    }
}
