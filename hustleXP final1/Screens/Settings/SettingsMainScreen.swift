//
//  SettingsMainScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct SettingsMainScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    var body: some View {
        List {
            // Profile header section
            Section {
                HStack(spacing: 16) {
                    HXAvatar(initials: dataService.currentUser.initials, size: .large)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HXText(dataService.currentUser.name, style: .headline)
                        HXText(dataService.currentUser.email, style: .caption, color: .textSecondary)
                        HXBadge(variant: .tier(dataService.currentUser.trustTier))
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Account section
            Section {
                SettingsListItem(icon: "person.fill", title: "Account Settings") {
                    router.navigateToSettings(.account)
                }
                
                SettingsListItem(icon: "bell.fill", iconColor: .warningOrange, title: "Notifications") {
                    router.navigateToSettings(.notifications)
                }
                
                SettingsListItem(icon: "creditcard.fill", iconColor: .moneyGreen, title: "Payment Methods") {
                    router.navigateToSettings(.payments)
                }
            } header: {
                Text("Account")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Subscription
            Section {
                SettingsListItem(icon: "repeat.circle.fill", iconColor: .brandPurple, title: "Subscription") {
                    router.navigateToSettings(.subscription)
                }
            } header: {
                Text("Plan")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)

            // Privacy & Security
            Section {
                SettingsListItem(icon: "lock.fill", iconColor: .brandPurple, title: "Privacy") {
                    router.navigateToSettings(.privacy)
                }
                
                SettingsListItem(icon: "checkmark.shield.fill", iconColor: .successGreen, title: "Verification") {
                    router.navigateToSettings(.verification)
                }
            } header: {
                Text("Privacy & Security")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Support
            Section {
                SettingsListItem(icon: "questionmark.circle.fill", iconColor: .infoBlue, title: "Help & Support") {
                    router.navigateToSettings(.help)
                }
            } header: {
                Text("Support")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // App info
            Section {
                HStack {
                    HXText("Role", style: .body, color: .textSecondary)
                    Spacer()
                    HXText(appState.userRole?.rawValue.capitalized ?? "—", style: .body)
                }
                
                HStack {
                    HXText("Version", style: .body, color: .textSecondary)
                    Spacer()
                    HXText("1.0.0", style: .body)
                }
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Logout
            Section {
                Button(action: handleLogout) {
                    HStack {
                        Spacer()
                        HXText("Log Out", style: .headline, color: .errorRed)
                        Spacer()
                    }
                }
            }
            .listRowBackground(Color.surfaceElevated)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background(Color.brandBlack)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func handleLogout() {
        router.resetAll()
        appState.logout()
    }
}

// MARK: - Settings List Item

struct SettingsListItem: View {
    let icon: String
    var iconColor: Color = .infoBlue
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.textTertiary)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsMainScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
