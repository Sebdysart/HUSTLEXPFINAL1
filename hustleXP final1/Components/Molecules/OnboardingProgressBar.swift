//
//  OnboardingProgressBar.swift
//  hustleXP final1
//
//  Premium onboarding progress indicator with animated step dots
//  v2.3.0
//

import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.brandPurple : Color.white.opacity(0.15))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 0, totalSteps: 6)
        OnboardingProgressBar(currentStep: 2, totalSteps: 6)
        OnboardingProgressBar(currentStep: 5, totalSteps: 6)
    }
    .padding()
    .background(Color.brandBlack)
}
