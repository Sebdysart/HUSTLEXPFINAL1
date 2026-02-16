//
//  PermissionsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI
import CoreLocation
import UserNotifications
import Combine

struct PermissionsScreen: View {
    @Environment(Router.self) private var router

    @State private var locationEnabled: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var showContent = false
    @StateObject private var locationDelegate = LocationPermissionDelegate()

    var body: some View {
        GeometryReader { geometry in
            // Use safe area-adjusted height for compact detection
            let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = usableHeight < 600

            ZStack {
                // Premium background
                Color.brandBlack
                    .ignoresSafeArea()
                
                // Animated gradient orbs
                VStack {
                    HStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.brandPurple.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: -80, y: -50)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.infoBlue.opacity(0.12), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 250, height: 250)
                            .blur(radius: 50)
                            .offset(x: 60, y: 80)
                    }
                }
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 24 : 32) {
                        // Progress bar
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.permissions.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)

                        // Header
                        VStack(spacing: isCompact ? 8 : 12) {
                            Text("Enable Permissions")
                                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.textPrimary)
                            
                            Text("These help us give you the best experience")
                                .font(.system(size: isCompact ? 14 : 15))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, isCompact ? 16 : 24)
                        
                        // Permission toggles
                        VStack(spacing: isCompact ? 12 : 16) {
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
                        .padding(.horizontal, isCompact ? 18 : 24)
                        
                        // Info note
                        HStack(spacing: 12) {
                            Image(systemName: "shield.fill")
                                .foregroundStyle(Color.brandPurple)
                            
                            Text("Your data is encrypted and never sold. See our Privacy Policy for details.")
                                .font(.system(size: isCompact ? 11 : 12))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(isCompact ? 12 : 16)
                        .background(Color.surfaceSecondary)
                        .cornerRadius(12)
                        .padding(.horizontal, isCompact ? 18 : 24)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
                        
                        Spacer(minLength: isCompact ? 20 : 40)
                        
                        // Continue button
                        VStack(spacing: isCompact ? 12 : 16) {
                            HXButton("Continue", variant: .primary) {
                                router.navigateToOnboarding(.profileSetup)
                            }
                            .accessibilityLabel("Continue to profile setup")
                            
                            Button(action: { router.navigateToOnboarding(.profileSetup) }) {
                                Text("Skip for now")
                                    .font(.system(size: isCompact ? 13 : 14))
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .accessibilityLabel("Skip permissions setup")
                        }
                        .padding(.horizontal, isCompact ? 18 : 24)
                        .padding(.bottom, max(24, geometry.safeAreaInsets.bottom + 16))
                    }
                }
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
                    .disabled(isEnabled) // Once granted, can't toggle off from here
                    .accessibilityLabel("Toggle \(title) permission")
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
