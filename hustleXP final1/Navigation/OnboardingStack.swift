//
//  OnboardingStack.swift
//  hustleXP final1
//
//  Navigation stack for onboarding screens
//  Archetype: D (Calibration/Capability)
//  v2.3.0: Premium onboarding with progress indicator, How It Works, and skill selection
//

import SwiftUI

struct OnboardingStack: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var nav = router

        NavigationStack(path: $nav.onboardingPath) {
            WelcomeScreen()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .welcome:
                        WelcomeScreen()
                    case .howItWorks:
                        HowItWorksScreen()
                    case .roleSelection:
                        RoleSelectionScreen()
                    case .permissions:
                        PermissionsScreen()
                    case .profileSetup:
                        ProfileSetupScreen()
                    case .skillSelection:
                        SkillGridSelectionScreen()
                    case .complete:
                        OnboardingCompleteScreen()
                    }
                }
        }
    }
}

#Preview {
    OnboardingStack()
        .environment(AppState())
        .environment(Router())
}
