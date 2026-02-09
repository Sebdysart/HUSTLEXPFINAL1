//
//  SettingsStack.swift
//  hustleXP final1
//
//  Navigation stack for Settings screens
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct SettingsStack: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        @Bindable var nav = router
        
        NavigationStack(path: $nav.settingsPath) {
            SettingsMainScreen()
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .main:
                        SettingsMainScreen()
                    case .account:
                        AccountSettingsScreen()
                    case .notifications:
                        NotificationSettingsScreen()
                    case .payments:
                        PaymentSettingsScreen()
                    case .privacy:
                        PrivacySettingsScreen()
                    case .verification:
                        VerificationSettingsScreen()
                    case .help:
                        HelpScreen()
                    }
                }
        }
    }
}

#Preview {
    SettingsStack()
        .environment(AppState())
        .environment(Router())
}
