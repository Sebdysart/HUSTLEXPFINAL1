//
//  ProfileSetupScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//  Premium profile setup with elegant animations
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
    @State private var showContent = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, bio, city
    }

    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Use safe area-adjusted height for compact detection
            let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = usableHeight < 600
            
            ZStack {
                // Background
                backgroundLayer
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 28) {
                        // Progress bar
                        OnboardingProgressBar(
                            currentStep: OnboardingRoute.profileSetup.stepIndex,
                            totalSteps: OnboardingRoute.totalSteps
                        )
                        .padding(.top, 8)

                        // Header
                        headerSection(isCompact: isCompact)
                        
                        // Avatar section
                        avatarSection(isCompact: isCompact)
                        
                        // Form fields
                        formSection(isCompact: isCompact)
                        
                        // Tips card
                        tipsCard(isCompact: isCompact)
                        
                        Spacer(minLength: isCompact ? 100 : 120)
                    }
                    .padding(.horizontal, isCompact ? 18 : 24)
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Bottom button
                bottomActionBar(isCompact: isCompact)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            // Top glow
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandPurple.opacity(0.2),
                                Color.brandPurple.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(y: -100)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 12) {
            Text("Set Up Your Profile")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            
            Text("Let people know who you are")
                .font(.system(size: isCompact ? 14 : 15))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, isCompact ? 16 : 24)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: showContent)
    }
    
    // MARK: - Avatar Section
    
    private func avatarSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            // Avatar with glow
            ZStack {
                // Glow background
                Circle()
                    .fill(Color.brandPurple.opacity(0.2))
                    .frame(width: isCompact ? 110 : 140, height: isCompact ? 110 : 140)
                    .blur(radius: 20)
                
                if let image = avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: isCompact ? 95 : 120, height: isCompact ? 95 : 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.brandPurple, Color.brandPurpleLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                } else {
                    Circle()
                        .fill(Color.surfaceElevated)
                        .frame(width: isCompact ? 95 : 120, height: isCompact ? 95 : 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: isCompact ? 38 : 48))
                                .foregroundStyle(Color.textSecondary)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                
                // Edit badge
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.brandPurpleLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 30 : 36, height: isCompact ? 30 : 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color.brandPurple.opacity(0.4), radius: 8, y: 2)
                    .offset(x: isCompact ? 34 : 42, y: isCompact ? 34 : 42)
            }
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showImagePicker = true
            }
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showImagePicker = true
            }) {
                Text("Add Photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandPurple)
            }
        }
        .opacity(showContent ? 1 : 0)
        .scaleEffect(showContent ? 1 : 0.9)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
    }
    
    // MARK: - Form Section
    
    private func formSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 16 : 20) {
            // Display Name field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Display Name")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    Text("*")
                        .font(.subheadline)
                        .foregroundStyle(Color.errorRed)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(focusedField == .name ? Color.brandPurple : Color.textMuted)
                        .frame(width: 20)
                    
                    TextField("", text: $displayName, prompt: Text("Your name").foregroundColor(.textMuted))
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)
                        .focused($focusedField, equals: .name)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            focusedField == .name ? Color.brandPurple : Color.white.opacity(0.08),
                            lineWidth: focusedField == .name ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: focusedField)
                
                Text("This is how you'll appear to others")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            
            // Bio field
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 16))
                        .foregroundStyle(focusedField == .bio ? Color.brandPurple : Color.textMuted)
                        .frame(width: 20)
                        .padding(.top, 2)
                    
                    TextField("", text: $bio, prompt: Text("Tell us about yourself (optional)").foregroundColor(.textMuted), axis: .vertical)
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .bio)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            focusedField == .bio ? Color.brandPurple : Color.white.opacity(0.08),
                            lineWidth: focusedField == .bio ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: focusedField)
                
                HStack {
                    Text("Share your skills, experience, or what you're looking for")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)

                    Spacer()

                    Text("\(bio.count)/200")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(bio.count > 200 ? Color.errorRed : Color.textMuted)
                }
            }

            // City/Location field
            VStack(alignment: .leading, spacing: 8) {
                Text("Your City")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(focusedField == .city ? Color.brandPurple : Color.textMuted)
                        .frame(width: 20)

                    TextField("", text: $city, prompt: Text("e.g. Austin, TX").foregroundColor(.textMuted))
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)
                        .focused($focusedField, equals: .city)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            focusedField == .city ? Color.brandPurple : Color.white.opacity(0.08),
                            lineWidth: focusedField == .city ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: focusedField)

                Text("Helps us show you nearby tasks and opportunities")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
    }
    
    // MARK: - Tips Card
    
    private func tipsCard(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.yellow)
                
                Text("Profile Tips")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                tipRow(icon: "checkmark.circle.fill", text: "Use your real name for trust", color: .successGreen)
                tipRow(icon: "camera.fill", text: "Add a clear photo to stand out", color: .brandPurple)
                tipRow(icon: "star.fill", text: "Complete profiles get more tasks", color: .yellow)
            }
        }
        .padding(isCompact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
    }
    
    private func tipRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private func bottomActionBar(isCompact: Bool) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                
                Button(action: handleContinue) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Complete Setup")
                                .font(.system(size: isCompact ? 15 : 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: isCompact ? 12 : 14, weight: .bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 48 : 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                isValid
                                    ? LinearGradient(
                                        colors: [Color.brandPurple, Color.brandPurpleLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.textMuted, Color.textMuted],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                    )
                    .shadow(color: isValid ? Color.brandPurple.opacity(0.3) : .clear, radius: 12, y: 4)
                }
                .disabled(!isValid || isLoading)
                .padding(.horizontal, isCompact ? 18 : 24)
                .padding(.vertical, isCompact ? 12 : 16)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .colorScheme(.dark)
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleContinue() {
        guard isValid else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isLoading = true
        focusedField = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            appState.userName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

            // Hustlers go to skill selection; Posters skip to complete
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
