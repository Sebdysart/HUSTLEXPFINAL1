//
//  SplashScreen.swift
//  hustleXP final1
//
//  Branded splash screen shown during app launch
//  Matches the dark neon aesthetic while services initialize
//

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var showTagline = false
    
    var body: some View {
        ZStack {
            // Background
            Color.brandBlack.ignoresSafeArea()
            
            // Gradient orb background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brandPurple.opacity(0.3),
                            Color.brandPurple.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 60)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(spacing: 24) {
                // Logo
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .opacity(isAnimating ? 0.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Inner circle with icon
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPurple, Color.brandPurpleLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.brandPurple.opacity(0.5), radius: 20, y: 5)
                    
                    // HX Logo text
                    Text("HX")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(.white)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimating)
                
                // App name
                VStack(spacing: 8) {
                    Text("HustleXP")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.brandPurpleLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if showTagline {
                        Text("Get Paid. Level Up.")
                            .font(.system(size: 16, weight: .medium))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.textSecondary)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.brandPurple))
                    .scaleEffect(1.2)
                    .padding(.top, 32)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showTagline = true
            }
        }
    }
}

#Preview {
    SplashScreen()
}
