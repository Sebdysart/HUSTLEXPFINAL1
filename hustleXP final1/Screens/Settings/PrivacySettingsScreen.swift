//
//  PrivacySettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct PrivacySettingsScreen: View {
    @State private var locationSharing: Bool = true
    @State private var profileVisible: Bool = true
    @State private var showOnlineStatus: Bool = true
    @State private var showLastActive: Bool = true
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Location Section
                    PrivacySection(title: "Location") {
                        VStack(spacing: 0) {
                            PrivacyToggleRow(
                                icon: "location.fill",
                                iconColor: .infoBlue,
                                title: "Share Location During Tasks",
                                subtitle: "Required for EN_ROUTE tracking",
                                isOn: $locationSharing
                            )
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(Color.textTertiary)
                            
                            HXText(
                                "Your location is only shared with task posters when you're actively working on a task.",
                                style: .caption,
                                color: .textTertiary
                            )
                        }
                        .padding(.top, 8)
                    }
                    
                    // Profile Visibility Section
                    PrivacySection(title: "Profile Visibility") {
                        VStack(spacing: 0) {
                            PrivacyToggleRow(
                                icon: "person.fill",
                                iconColor: .brandPurple,
                                title: "Public Profile",
                                subtitle: "Let others see your profile and ratings",
                                isOn: $profileVisible
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            PrivacyToggleRow(
                                icon: "circle.fill",
                                iconColor: .successGreen,
                                title: "Show Online Status",
                                subtitle: "Let others see when you're active",
                                isOn: $showOnlineStatus
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            PrivacyToggleRow(
                                icon: "clock.fill",
                                iconColor: .textSecondary,
                                title: "Show Last Active",
                                subtitle: "Display when you were last online",
                                isOn: $showLastActive
                            )
                        }
                    }
                    
                    // Data Section
                    PrivacySection(title: "Your Data") {
                        VStack(spacing: 0) {
                            PrivacyLinkRow(
                                icon: "arrow.down.doc.fill",
                                iconColor: .brandPurple,
                                title: "Download My Data",
                                subtitle: "Get a copy of your data"
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            PrivacyLinkRow(
                                icon: "trash.fill",
                                iconColor: .errorRed,
                                title: "Delete My Data",
                                subtitle: "Permanently delete your account"
                            )
                        }
                    }
                    
                    // Legal Section
                    PrivacySection(title: "Legal") {
                        VStack(spacing: 0) {
                            PrivacyLinkRow(
                                icon: "doc.text.fill",
                                iconColor: .textSecondary,
                                title: "Privacy Policy",
                                subtitle: "How we handle your data"
                            )
                            
                            HXDivider()
                                .padding(.leading, 56)
                            
                            PrivacyLinkRow(
                                icon: "doc.fill",
                                iconColor: .textSecondary,
                                title: "Terms of Service",
                                subtitle: "Our terms and conditions"
                            )
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Privacy Section
private struct PrivacySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText(title, style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Privacy Toggle Row
private struct PrivacyToggleRow: View {
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

// MARK: - Privacy Link Row
private struct PrivacyLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {}) {
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
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsScreen()
    }
}
