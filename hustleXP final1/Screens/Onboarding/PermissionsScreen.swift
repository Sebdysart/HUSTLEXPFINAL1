//
//  PermissionsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct PermissionsScreen: View {
    @Environment(Router.self) private var router
    
    @State private var locationEnabled: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    HXText("Enable Permissions", style: .title)
                    
                    HXText(
                        "These help us give you the best experience",
                        style: .subheadline,
                        color: .textSecondary
                    )
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Permission toggles
                VStack(spacing: 16) {
                    PermissionCard(
                        icon: "location.fill",
                        title: "Location",
                        description: "Find nearby tasks and enable EN_ROUTE tracking for task verification",
                        benefit: "Required for most tasks",
                        isEnabled: $locationEnabled
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
                    
                    PermissionCard(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Get alerts for new tasks, messages, and payment updates",
                        benefit: "Never miss an opportunity",
                        isEnabled: $notificationsEnabled
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
                }
                .padding(.horizontal, 24)
                
                // Info note
                HStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(Color.brandPurple)
                    
                    HXText(
                        "Your data is encrypted and never sold. See our Privacy Policy for details.",
                        style: .caption,
                        color: .textSecondary
                    )
                }
                .padding(16)
                .background(Color.surfaceSecondary)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
                
                Spacer()
                
                // Continue button
                VStack(spacing: 16) {
                    HXButton("Continue", variant: .primary) {
                        router.navigateToOnboarding(.profileSetup)
                    }
                    
                    Button(action: { router.navigateToOnboarding(.profileSetup) }) {
                        HXText("Skip for now", style: .subheadline, color: .textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Permission Card
private struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let benefit: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isEnabled ? Color.brandPurple.opacity(0.2) : Color.surfaceSecondary)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isEnabled ? Color.brandPurple : Color.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HXText(title, style: .headline)
                    HXText(description, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(Color.brandPurple)
            }
            
            if isEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.successGreen)
                    
                    HXText(benefit, style: .caption, color: .successGreen)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isEnabled ? Color.brandPurple.opacity(0.5) : Color.borderSubtle, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    NavigationStack {
        PermissionsScreen()
    }
    .environment(Router())
}
