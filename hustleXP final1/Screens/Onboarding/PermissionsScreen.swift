//
//  PermissionsScreen.swift
//  hustleXP final1
//
//  Clean permissions request screen
//

import SwiftUI
import CoreLocation
import UserNotifications
import Combine

struct PermissionsScreen: View {
    @Environment(Router.self) private var router

    @State private var locationEnabled: Bool = false
    @State private var notificationsEnabled: Bool = false
    @StateObject private var locationDelegate = LocationPermissionDelegate()

    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 24 : 32) {
                        // Progress
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.permissions.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)

                        // Header
                        VStack(spacing: 8) {
                            Text("Enable Permissions")
                                .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                            
                            Text("These help us give you the best experience")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, isCompact ? 8 : 16)
                        
                        // Permission cards
                        VStack(spacing: isCompact ? 12 : 16) {
                            PermissionCard(
                                icon: "location.fill",
                                title: "Location",
                                description: "Find nearby tasks and verify task completion",
                                isEnabled: $locationEnabled
                            )
                            
                            PermissionCard(
                                icon: "bell.fill",
                                title: "Notifications",
                                description: "Get alerts for new tasks and messages",
                                isEnabled: $notificationsEnabled
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Privacy note
                        HStack(spacing: 10) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.brandPurple)
                            
                            Text("Your data is encrypted and never sold")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: safeHeight)
                }
                
                // Bottom CTA
                VStack {
                    Spacer()
                    bottomBar(isCompact: isCompact, bottomInset: geometry.safeAreaInsets.bottom)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Bottom Bar
    
    private func bottomBar(isCompact: Bool, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 12) {
                Button(action: { router.navigateToOnboarding(.profileSetup) }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.body.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandPurple)
                    )
                }
                .accessibilityLabel("Continue to profile setup")
                
                Button(action: { router.navigateToOnboarding(.profileSetup) }) {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .accessibilityLabel("Skip permissions")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, max(16, bottomInset))
            .background(Color.brandBlack)
        }
    }
}

// MARK: - Permission Card

private struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .fill(isEnabled ? Color.brandPurple.opacity(0.15) : Color.surfaceSecondary)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isEnabled ? Color.brandPurple : Color.textSecondary)
                )
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(Color.brandPurple)
                .accessibilityLabel("Enable \(title)")
        }
        .padding(16)
        .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isEnabled ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Location Permission Delegate

class LocationPermissionDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var isAuthorized = false

    override init() {
        super.init()
        manager.delegate = self
        checkStatus()
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func checkStatus() {
        let status = manager.authorizationStatus
        isAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.checkStatus()
        }
    }
}

#Preview {
    NavigationStack {
        PermissionsScreen()
    }
    .environment(Router())
}
