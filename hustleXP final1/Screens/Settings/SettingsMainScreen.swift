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
                SettingsListItem(icon: "envelope.fill", iconColor: .infoBlue, title: "Contact Support") {
                    contactSupport()
                }
                SettingsListItem(icon: "exclamationmark.triangle.fill", iconColor: .warningOrange, title: "My Disputes") {
                    router.navigateToSettings(.disputes)
                }
            } header: {
                Text("Support")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)

            // Legal
            Section {
                SettingsListItem(icon: "doc.text.fill", iconColor: .textSecondary, title: "Terms of Service") {
                    openURL("https://hustlexp.app/terms")
                }
                SettingsListItem(icon: "hand.raised.fill", iconColor: .textSecondary, title: "Privacy Policy") {
                    openURL("https://hustlexp.app/privacy")
                }
            } header: {
                Text("Legal")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            
            // Admin dashboard — visible to admin role users or in debug builds
            if dataService.currentUser.role == .admin {
                Section {
                    SettingsListItem(icon: "chart.bar.fill", iconColor: .brandPurple, title: "Beta Dashboard") {
                        router.navigateToSettings(.betaDashboard)
                    }
                } header: {
                    Text("Admin")
                        .foregroundStyle(Color.textSecondary)
                }
                .listRowBackground(Color.surfaceElevated)
            }
            #if DEBUG
            // Always visible in debug for development
            if dataService.currentUser.role != .admin {
                Section {
                    SettingsListItem(icon: "chart.bar.fill", iconColor: .brandPurple, title: "Beta Dashboard") {
                        router.navigateToSettings(.betaDashboard)
                    }
                } header: {
                    Text("Admin (Debug)")
                        .foregroundStyle(Color.textSecondary)
                }
                .listRowBackground(Color.surfaceElevated)
            }
            #endif

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
                    HXText("\(appVersion) (\(buildNumber))", style: .body)
                }

                HStack {
                    HXText("Environment", style: .body, color: .textSecondary)
                    Spacer()
                    HXText(AppConfig.isProduction ? "Production" : "Staging", style: .body, color: AppConfig.isProduction ? .successGreen : .warningOrange)
                }

                // Tap to copy debug info to clipboard for support tickets
                Button(action: copyDebugInfo) {
                    HStack {
                        HXText("Copy Debug Info", style: .body, color: .infoBlue)
                        Spacer()
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(Color.infoBlue)
                    }
                }
                .accessibilityLabel("Copy debug info to clipboard")
            }
            .listRowBackground(Color.surfaceElevated)

            #if DEBUG
            // Notifications debug — verify push token + send test notification
            Section {
                HStack {
                    HXText("Push Permission", style: .body, color: .textSecondary)
                    Spacer()
                    HXText(
                        PushNotificationManager.shared.isAuthorized ? "Granted ✓" : "Not granted",
                        style: .body,
                        color: PushNotificationManager.shared.isAuthorized ? .successGreen : .errorRed
                    )
                }

                HStack {
                    HXText("FCM Token", style: .body, color: .textSecondary)
                    Spacer()
                    HXText(
                        PushNotificationManager.shared.fcmToken != nil ? "Registered ✓" : "Missing",
                        style: .body,
                        color: PushNotificationManager.shared.fcmToken != nil ? .successGreen : .errorRed
                    )
                }

                Button(action: requestNotificationPermission) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(Color.warningOrange)
                        HXText("Request Notification Permission", style: .body, color: .warningOrange)
                    }
                }
            } header: {
                Text("Debug — Notifications")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)

            // Crash test (debug only — used to verify Crashlytics is working)
            Section {
                Button(action: triggerTestCrash) {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundStyle(Color.errorRed)
                        HXText("Trigger Test Crash", style: .body, color: .errorRed)
                    }
                }
            } header: {
                Text("Debug")
                    .foregroundStyle(Color.textSecondary)
            }
            .listRowBackground(Color.surfaceElevated)
            #endif
            
            // Logout
            Section {
                Button(action: handleLogout) {
                    HStack {
                        Spacer()
                        HXText("Log Out", style: .headline, color: .errorRed)
                        Spacer()
                    }
                }
                .accessibilityLabel("Log out")
            }
            .listRowBackground(Color.surfaceElevated)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.brandBlack)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
    
    private func handleLogout() {
        router.resetAll()
        appState.logout()
    }

    // MARK: - App Info Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    // MARK: - Support / Legal Actions

    private func contactSupport() {
        let subject = "HustleXP Support — v\(appVersion) (\(buildNumber))"
        let body = """


        --- Debug info (please don't delete) ---
        User ID: \(dataService.currentUser.id)
        Role: \(appState.userRole?.rawValue ?? "unknown")
        Version: \(appVersion) (\(buildNumber))
        Environment: \(AppConfig.isProduction ? "Production" : "Staging")
        """
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:support@hustlexp.app?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func copyDebugInfo() {
        let info = """
        HustleXP Debug Info
        Version: \(appVersion) (\(buildNumber))
        Environment: \(AppConfig.isProduction ? "Production" : "Staging")
        User ID: \(dataService.currentUser.id)
        Email: \(dataService.currentUser.email)
        Role: \(appState.userRole?.rawValue ?? "unknown")
        Trust Tier: \(dataService.currentUser.trustTier.rawValue)
        Date: \(Date().formatted())
        """
        UIPasteboard.general.string = info
        ErrorToastManager.shared.show("Debug info copied — paste into your support email", style: .info)
    }

    #if DEBUG
    private func triggerTestCrash() {
        // Force a crash to verify Crashlytics is reporting correctly
        let _ = [Int]()[42]
    }

    private func requestNotificationPermission() {
        Task {
            let granted = await PushNotificationManager.shared.requestAuthorization()
            HXLogger.info("Settings: Notification permission \(granted ? "granted" : "denied")", category: "Push")
            if granted {
                PushNotificationManager.shared.registerForRemoteNotifications()
                ErrorToastManager.shared.show("Notifications enabled", style: .info)
            } else {
                ErrorToastManager.shared.show("Permission denied. Enable in iOS Settings → HustleXP → Notifications.")
            }
        }
    }
    #endif
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
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)
                
                Text(title)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.textTertiary)
                    .font(.system(size: 12, weight: .semibold))
            }
            .contentShape(Rectangle())
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
