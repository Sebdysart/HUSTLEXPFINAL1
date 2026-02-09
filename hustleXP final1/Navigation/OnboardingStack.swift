//
//  OnboardingStack.swift
//  hustleXP final1
//
//  Navigation stack for onboarding screens
//  Archetype: D (Calibration/Capability)
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
                    case .roleSelection:
                        RoleSelectionScreen()
                    case .permissions:
                        PermissionsScreen()
                    case .profileSetup:
                        ProfileSetupScreen()
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
