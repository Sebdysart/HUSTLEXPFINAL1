//
//  NotificationSettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct NotificationSettingsScreen: View {
    @State private var pushEnabled: Bool = true
    @State private var taskAlerts: Bool = true
    @State private var messageAlerts: Bool = true
    @State private var paymentAlerts: Bool = true
    @State private var reminderAlerts: Bool = true
    @State private var emailEnabled: Bool = true
    @State private var marketingEmails: Bool = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Push Notifications Section
                    SettingsSection(title: "Push Notifications") {
                        NotificationToggleRow(
                            icon: "bell.fill",
                            iconColor: .brandPurple,
                            title: "Push Notifications",
                            subtitle: "Receive notifications on your device",
                            isOn: $pushEnabled
                        )
                    }
                    
                    // Alert Types Section
                    SettingsSection(title: "Alert Types") {
                        VStack(spacing: 0) {
                            NotificationToggleRow(
                                icon: "briefcase.fill",
                                iconColor: .infoBlue,
                                title: "New Task Opportunities",
                                subtitle: "Tasks matching your skills nearby",
                                isOn: $taskAlerts
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            NotificationToggleRow(
                                icon: "message.fill",
                                iconColor: .brandPurple,
                                title: "Messages",
                                subtitle: "Chat messages from posters/hustlers",
                                isOn: $messageAlerts
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            NotificationToggleRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: .moneyGreen,
                                title: "Payments",
                                subtitle: "Payment received and payout updates",
                                isOn: $paymentAlerts
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            NotificationToggleRow(
                                icon: "clock.fill",
                                iconColor: .warningOrange,
                                title: "Reminders",
                                subtitle: "Task deadlines and follow-ups",
                                isOn: $reminderAlerts
                            )
                        }
                    }
                    .opacity(pushEnabled ? 1 : 0.5)
                    .disabled(!pushEnabled)
                    
                    // Email Section
                    SettingsSection(title: "Email") {
                        VStack(spacing: 0) {
                            NotificationToggleRow(
                                icon: "envelope.fill",
                                iconColor: .infoBlue,
                                title: "Email Notifications",
                                subtitle: "Summaries and important updates",
                                isOn: $emailEnabled
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            NotificationToggleRow(
                                icon: "megaphone.fill",
                                iconColor: .accentPurple,
                                title: "Marketing & Promotions",
                                subtitle: "Tips, promotions, and new features",
                                isOn: $marketingEmails
                            )
                        }
                    }
                    
                    // Info note
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.textTertiary)
                        
                        HXText(
                            "You can also manage notifications in your device's Settings app.",
                            style: .caption,
                            color: .textTertiary
                        )
                    }
                    .padding(16)
                }
                .padding(24)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Settings Section
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText(title, style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            content
                .background(Color.surfaceElevated)
                .cornerRadius(16)
        }
    }
}

// MARK: - Notification Toggle Row
private struct NotificationToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(title, style: .body)
                HXText(subtitle, style: .caption, color: .textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.brandPurple)
                .accessibilityLabel(title)
        }
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsScreen()
    }
}
