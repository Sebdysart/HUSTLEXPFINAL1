//
//  ProfileSetupScreen.swift
//  hustleXP final1
//
//  Clean, professional profile setup
//

import SwiftUI

struct ProfileSetupScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var city: String = ""
    @State private var showImagePicker = false
    @State private var avatarImage: UIImage?
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, bio, city
    }

    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                            currentStep: OnboardingRoute.profileSetup.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)
                        
                        // Avatar
                        avatarSection(isCompact: isCompact)
                        
                        // Form
                        formSection(isCompact: isCompact)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, isCompact ? 100 : 120)
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Bottom CTA
                VStack {
                    Spacer()
                    bottomBar(isCompact: isCompact, bottomInset: geometry.safeAreaInsets.bottom)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Set Up Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Avatar Section
    
    private func avatarSection(isCompact: Bool) -> some View {
        VStack(spacing: 12) {
            Button(action: { showImagePicker = true }) {
                ZStack {
                    if let image = avatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: isCompact ? 88 : 100, height: isCompact ? 88 : 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.brandPurple, lineWidth: 3))
                    } else {
                        Circle()
                            .fill(Color.surfaceElevated)
                            .frame(width: isCompact ? 88 : 100, height: isCompact ? 88 : 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: isCompact ? 32 : 40))
                                    .foregroundStyle(Color.textMuted)
                            )
                            .overlay(Circle().stroke(Color.borderSubtle, lineWidth: 1))
                    }
                    
                    // Camera badge
                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: isCompact ? 30 : 35, y: isCompact ? 30 : 35)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add profile photo")
            
            Text("Add a photo")
                .font(.subheadline)
                .foregroundStyle(Color.brandPurple)
        }
        .padding(.top, isCompact ? 8 : 16)
    }
    
    // MARK: - Form Section
    
    private func formSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 20 : 24) {
            // Name field (required)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("Display Name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    Text("*")
                        .foregroundStyle(Color.errorRed)
                }
                
                TextField("Your name", text: $displayName)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .name ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }
            
            // Bio field (optional)
            VStack(alignment: .leading, spacing: 6) {
                Text("Bio")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2...4)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .bio ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .bio)
                
                HStack {
                    Text("Optional")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    Spacer()
                    Text("\(bio.count)/200")
                        .font(.caption)
                        .foregroundStyle(bio.count > 200 ? Color.errorRed : Color.textMuted)
                }
            }
            
            // City field (optional)
            VStack(alignment: .leading, spacing: 6) {
                Text("City")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("e.g. Austin, TX", text: $city)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .city ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .city)
                    .textContentType(.addressCity)
                    .autocorrectionDisabled()
                
                Text("Helps match you with nearby tasks")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
        }
    }
    
    // MARK: - Bottom Bar
    
    private func bottomBar(isCompact: Bool, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 12) {
                Button(action: handleContinue) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.body.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isValid ? Color.brandPurple : Color.textMuted.opacity(0.5))
                    )
                }
                .disabled(!isValid || isLoading)
                .accessibilityLabel("Continue to next step")
                
                if !isValid {
                    Text("Enter your name to continue")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, max(16, bottomInset))
            .background(Color.brandBlack)
        }
    }
    
    // MARK: - Actions
    
    private func handleContinue() {
        guard isValid else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isLoading = true
        focusedField = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.userName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

            if appState.userRole == .hustler {
                router.navigateToOnboarding(.skillSelection)
            } else {
                router.navigateToOnboarding(.complete)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSetupScreen()
    }
    .environment(AppState())
    .environment(Router())
}
