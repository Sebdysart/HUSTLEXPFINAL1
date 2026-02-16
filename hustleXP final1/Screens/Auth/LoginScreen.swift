//
//  LoginScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//  Clean, professional login screen - adaptive to all screen sizes
//

import SwiftUI
import AuthenticationServices
import FirebaseCore

struct LoginScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @EnvironmentObject private var authService: AuthService

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var loginError: String?
    @State private var showContent = false
    @State private var isSocialLoading = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    private var isValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError == nil && passwordError == nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompactHeight = safeHeight < 600
            
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()
                
                // Subtle accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandPurple.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width * 0.3, y: 50)
                    .blur(radius: 50)
                    .ignoresSafeArea()
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top spacing
                        Spacer()
                            .frame(height: isCompactHeight ? 30 : 50)
                        
                        // Logo and header
                        headerSection(isCompact: isCompactHeight)
                        
                        // Spacing
                        Spacer()
                            .frame(height: isCompactHeight ? 28 : 40)
                        
                        // Login form
                        formSection(isCompact: isCompactHeight)
                        
                        // Spacing
                        Spacer()
                            .frame(height: isCompactHeight ? 18 : 24)
                        
                        // Divider
                        dividerSection
                        
                        // Spacing
                        Spacer()
                            .frame(height: isCompactHeight ? 18 : 24)
                        
                        // Social login
                        socialLoginSection(isCompact: isCompactHeight)
                        
                        // Spacing
                        Spacer()
                            .frame(height: isCompactHeight ? 24 : 32)
                        
                        // Sign up link
                        signUpSection
                        
                        // Bottom spacing
                        Spacer()
                            .frame(height: max(16, geometry.safeAreaInsets.bottom + 8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 16 : 20) {
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 70 : 80, height: isCompact ? 70 : 80)
                    .shadow(color: Color.brandPurple.opacity(0.3), radius: 15)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: isCompact ? 28 : 32, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 6) {
                Text("Welcome back")
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Sign in to continue your hustle")
                    .font(.system(size: isCompact ? 14 : 15))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
        }
        .animation(.easeOut(duration: 0.5), value: showContent)
    }
    
    // MARK: - Form Section
    
    private func formSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 14 : 18) {
            // Login error message
            if let loginError = loginError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.errorRed)
                    Text(loginError)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                }
                .padding()
                .background(Color.errorRed.opacity(0.1))
                .cornerRadius(12)
            }

            // Email field
            FormTextField(
                label: "Email",
                placeholder: "your@email.com",
                text: $email,
                icon: "envelope.fill",
                isFocused: focusedField == .email,
                error: emailError,
                isCompact: isCompact
            )
            .focused($focusedField, equals: .email)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .onChange(of: email) { _, newValue in
                validateEmail(newValue)
                loginError = nil  // Clear error when user types
            }

            // Password field
            FormSecureField(
                label: "Password",
                placeholder: "Enter password",
                text: $password,
                icon: "lock.fill",
                isFocused: focusedField == .password,
                error: passwordError,
                isCompact: isCompact,
                forgotAction: { router.navigateToAuth(.forgotPassword) }
            )
            .focused($focusedField, equals: .password)
            .onChange(of: password) { _, _ in
                loginError = nil  // Clear error when user types
            }

            // Sign in button
            HXButton("Sign In", icon: isLoading ? nil : "arrow.right", variant: .primary, isLoading: isLoading) {
                handleLogin()
            }
            .accessibilityLabel("Sign in to your account")
            .padding(.top, isCompact ? 4 : 8)
            .disabled(!isValid || isLoading)
            .opacity(isValid ? 1 : 0.6)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
    }
    
    // MARK: - Divider Section
    
    private var dividerSection: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.borderSubtle)
                .frame(height: 1)
            
            Text("or continue with")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textMuted)
                .layoutPriority(1)
            
            Rectangle()
                .fill(Color.borderSubtle)
                .frame(height: 1)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
    }
    
    // MARK: - Social Login Section

    private func socialLoginSection(isCompact: Bool) -> some View {
        HStack(spacing: 12) {
            SocialButton(icon: "apple.logo", label: "Apple", isCompact: isCompact) {
                handleAppleSignIn()
            }
            .accessibilityLabel("Sign in with Apple")
            SocialButton(icon: "g.circle.fill", label: "Google", isCompact: isCompact) {
                handleGoogleSignIn()
            }
            .accessibilityLabel("Sign in with Google")
        }
        .disabled(isSocialLoading)
        .opacity(isSocialLoading ? 0.6 : 1)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
    }
    
    // MARK: - Sign Up Section
    
    private var signUpSection: some View {
        HStack(spacing: 4) {
            Text("New to HustleXP?")
                .foregroundStyle(Color.textSecondary)
            
            Button(action: { router.navigateToAuth(.signup) }) {
                Text("Create Account")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.brandPurple)
            }
            .accessibilityLabel("Create a new account")
        }
        .font(.subheadline)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
    }
    
    // MARK: - Validation
    
    private func validateEmail(_ email: String) {
        if email.isEmpty {
            emailError = nil
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Please enter a valid email"
        } else {
            emailError = nil
        }
    }
    
    // MARK: - Actions

    private func handleLogin() {
        guard isValid else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isLoading = true
        focusedField = nil
        loginError = nil

        Task {
            do {
                try await authService.signIn(email: email, password: password)

                // Success - AuthService will update isAuthenticated
                // App will automatically navigate to RootNavigator
                HapticFeedback.success()
            } catch {
                // Handle error
                isLoading = false
                loginError = error.localizedDescription
                HapticFeedback.error()
            }
        }
    }

    // MARK: - Apple Sign-In

    private func handleAppleSignIn() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        let request = ASAuthorizationAppleIDProvider().createRequest()
        authService.prepareAppleSignInRequest(request)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate { result in
            Task { @MainActor in
                switch result {
                case .success(let authorization):
                    isSocialLoading = true
                    loginError = nil
                    do {
                        try await authService.signInWithApple(authorization: authorization)
                        HapticFeedback.success()
                    } catch {
                        loginError = error.localizedDescription
                        HapticFeedback.error()
                    }
                    isSocialLoading = false
                case .failure(let error):
                    if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                        loginError = error.localizedDescription
                        HapticFeedback.error()
                    }
                }
            }
        }
        // Keep a strong reference to the delegate
        appleSignInDelegate = delegate
        controller.delegate = delegate
        controller.performRequests()
    }

    @State private var appleSignInDelegate: AppleSignInDelegate?

    // MARK: - Google Sign-In

    private func handleGoogleSignIn() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isSocialLoading = true
        loginError = nil

        Task {
            do {
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    throw NSError(domain: "AuthService", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found."])
                }

                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController else {
                    throw NSError(domain: "AuthService", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "No root view controller found."])
                }

                let result = try await GIDSignInHelper.signIn(
                    withClientID: clientID,
                    presenting: rootViewController
                )

                try await authService.signInWithGoogle(
                    idToken: result.idToken,
                    accessToken: result.accessToken
                )
                HapticFeedback.success()
            } catch {
                if (error as NSError).code != GIDSignInHelper.cancelledCode {
                    loginError = error.localizedDescription
                    HapticFeedback.error()
                }
            }
            isSocialLoading = false
        }
    }
}

// MARK: - Form Text Field

private struct FormTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isFocused: Bool
    let error: String?
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(isFocused ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .font(.system(size: isCompact ? 15 : 16))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(isCompact ? 12 : 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? Color.brandPurple : Color.borderSubtle,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
    }
}

// MARK: - Form Secure Field

private struct FormSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isFocused: Bool
    let error: String?
    var isCompact: Bool = false
    var forgotAction: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                if let forgotAction = forgotAction {
                    Button(action: forgotAction) {
                        Text("Forgot Password?")
                            .font(.system(size: isCompact ? 11 : 12, weight: .medium))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.brandPurple)
                    }
                    .accessibilityLabel("Forgot password")
                }
            }
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(isFocused ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .font(.system(size: isCompact ? 15 : 16))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(isCompact ? 12 : 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? Color.brandPurple : Color.borderSubtle,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
    }
}

// MARK: - Social Button

private struct SocialButton: View {
    let icon: String
    let label: String
    var isCompact: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                Text(label)
                    .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isCompact ? 12 : 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
        }
    }
}

// MARK: - Apple Sign-In Delegate

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let completion: (Result<ASAuthorization, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}

#Preview("Standard") {
    NavigationStack {
        LoginScreen()
    }
    .environment(AppState())
    .environment(Router())
}

#Preview("Compact (SE)", traits: .fixedLayout(width: 375, height: 667)) {
    NavigationStack {
        LoginScreen()
    }
    .environment(AppState())
    .environment(Router())
}
