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
    @State private var showImagePicker = false
    @State private var avatarImage: UIImage?
    @State private var showContent = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, bio
    }
    
    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    headerSection
                    
                    // Avatar section
                    avatarSection
                    
                    // Form fields
                    formSection
                    
                    // Tips card
                    tipsCard
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Bottom button
            bottomActionBar
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
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Set Up Your Profile")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            
            Text("Let people know who you are")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, 24)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: showContent)
    }
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            // Avatar with glow
            ZStack {
                // Glow background
                Circle()
                    .fill(Color.brandPurple.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                if let image = avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
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
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
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
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color.brandPurple.opacity(0.4), radius: 8, y: 2)
                    .offset(x: 42, y: 42)
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
    
    private var formSection: some View {
        VStack(spacing: 20) {
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
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
    }
    
    // MARK: - Tips Card
    
    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
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
    
    private var bottomActionBar: some View {
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
                                .font(.headline.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
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
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
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
            router.navigateToOnboarding(.complete)
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
