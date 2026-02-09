//
//  AuthStack.swift
//  hustleXP final1
//
//  Navigation stack for authentication screens
//  Archetype: A (Entry/Commitment)
//

import SwiftUI

struct AuthStack: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        @Bindable var nav = router

        NavigationStack(path: $nav.authPath) {
            LoginScreen()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginScreen()
                    case .signup:
                        SignupScreen()
                    case .forgotPassword:
                        ForgotPasswordScreen()
                    case .phoneVerification:
                        PhoneVerificationScreen()
                    }
                }
        }
    }
}

#Preview {
    AuthStack()
        .environment(AppState())
        .environment(Router())
}
