//
//  SignupScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//  Premium signup with elegant forms and smooth animations
//

import SwiftUI
import AuthenticationServices
import FirebaseCore

struct SignupScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @EnvironmentObject private var authService: AuthService

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showContent = false
    @State private var errors: [String: String] = [:]
    @State private var signupError: String?
    @State private var isSocialLoading = false
    @State private var appleSignInDelegate: AppleSignInDelegateSignup?
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, password, confirmPassword
    }
    
    private var isValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        password == confirmPassword &&
        password.count >= 8 &&
        errors.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Background
                backgroundLayer
                
                // Content - use VStack for non-scrolling layout
                VStack(spacing: isCompact ? 12 : 18) {
                    // Logo and header
                    headerSection(isCompact: isCompact)
                        .padding(.top, isCompact ? 4 : 12)
                    
                    // Signup form
                    formSection(isCompact: isCompact)
                    
                    Spacer(minLength: 0)
                    
                    // Divider with "or"
                    dividerSection
                    
                    // Social signup options
                    socialSignupSection(isCompact: isCompact)
                    
                    // Sign in link
                    signInSection
                        .padding(.bottom, isCompact ? 8 : 16)
                }
                .padding(.horizontal, isCompact ? 16 : 24)
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
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
                                Color.brandPurple.opacity(0.25),
                                Color.brandPurple.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: -150)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // Logo - smaller on compact screens
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: isCompact ? 48 : 72, height: isCompact ? 48 : 72)
                
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: isCompact ? 20 : 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.brandPurpleLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(showContent ? 1 : 0.5)
            .opacity(showContent ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)
            
            VStack(spacing: 4) {
                Text("Join HustleXP")
                    .font(.system(size: isCompact ? 22 : 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Start your hustle journey today")
                    .font(.system(size: isCompact ? 13 : 15))
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
        }
    }
    
    // MARK: - Form Section
    
    private func formSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // Name field
            premiumField(
                label: "Full Name",
                icon: "person.fill",
                placeholder: "Your name",
                text: $name,
                field: .name,
                error: errors["name"],
                contentType: .name,
                keyboardType: .default
            )
            
            // Email field
            premiumField(
                label: "Email",
                icon: "envelope.fill",
                placeholder: "your@email.com",
                text: $email,
                field: .email,
                error: errors["email"],
                contentType: .emailAddress,
                keyboardType: .emailAddress
            )
            .onChange(of: email) { _, newValue in
                validateEmail(newValue)
                signupError = nil
            }
            
            // Password field
            premiumSecureField(
                label: "Password",
                icon: "lock.fill",
                placeholder: "Min 8 characters",
                text: $password,
                field: .password,
                error: errors["password"]
            )
            .onChange(of: password) { _, newValue in
                validatePassword(newValue)
            }
            
            // Confirm password field
            premiumSecureField(
                label: "Confirm Password",
                icon: "lock.shield.fill",
                placeholder: "Re-enter password",
                text: $confirmPassword,
                field: .confirmPassword,
                error: errors["confirmPassword"]
            )
            .onChange(of: confirmPassword) { _, newValue in
                validateConfirmPassword(newValue)
            }
            
            // Password requirements
            if !password.isEmpty {
                passwordRequirements
            }

            // Error banner
            if let signupError = signupError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(signupError)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.errorRed.opacity(0.1))
                .cornerRadius(8)
            }

            // Create account button
            HXButton("Create Account", icon: isLoading ? nil : "arrow.right", variant: .primary, isLoading: isLoading) {
                handleSignup()
            }
            .padding(.top, 4)
            .disabled(!isValid || isLoading)
            .opacity(isValid ? 1 : 0.6)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 30)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
    }
    
    // MARK: - Password Requirements
    
    private var passwordRequirements: some View {
        HStack(spacing: 16) {
            requirementRow(text: "8+ characters", met: password.count >= 8)
            requirementRow(text: "Passwords match", met: !confirmPassword.isEmpty && password == confirmPassword)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    private func requirementRow(text: String, met: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(met ? Color.successGreen : Color.textMuted)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(met ? Color.textSecondary : Color.textMuted)
        }
    }
    
    // MARK: - Premium Field Components
    
    private func premiumField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        error: String?,
        contentType: UITextContentType?,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(focusedField == field ? Color.brandPurple : Color.textMuted)
                    .frame(width: 18)
                
                TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .font(.subheadline)
                    .textContentType(contentType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .keyboardType(keyboardType)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: field)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == field ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == field ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption2)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
    }
    
    private func premiumSecureField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        error: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(focusedField == field ? Color.brandPurple : Color.textMuted)
                    .frame(width: 18)
                
                SecureField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .font(.subheadline)
                    .textContentType(.password)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: field)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == field ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == field ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption2)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
    }
    
    // MARK: - Divider Section
    
    private var dividerSection: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
            
            Text("or sign up with")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
            
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
    }
    
    // MARK: - Social Signup Section

    private func socialSignupSection(isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 12 : 16) {
            socialButton(icon: "apple.logo", label: "Apple") {
                handleAppleSignIn()
            }
            socialButton(icon: "g.circle.fill", label: "Google") {
                handleGoogleSignIn()
            }
        }
        .disabled(isSocialLoading)
        .opacity(isSocialLoading ? 0.6 : 1)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
    }

    private func socialButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Sign In Section
    
    private var signInSection: some View {
        HStack(spacing: 6) {
            Text("Already have an account?")
                .foregroundStyle(Color.textSecondary)
            
            Button(action: { router.popAuth() }) {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.brandPurple)
            }
        }
        .font(.subheadline)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
    }
    
    // MARK: - Validation
    
    private func validateEmail(_ email: String) {
        if !email.isEmpty && (!email.contains("@") || !email.contains(".")) {
            errors["email"] = "Please enter a valid email"
        } else {
            errors.removeValue(forKey: "email")
        }
    }
    
    private func validatePassword(_ password: String) {
        if !password.isEmpty && password.count < 8 {
            errors["password"] = "Password must be at least 8 characters"
        } else {
            errors.removeValue(forKey: "password")
        }
        validateConfirmPassword(confirmPassword)
    }
    
    private func validateConfirmPassword(_ confirm: String) {
        if !confirm.isEmpty && confirm != password {
            errors["confirmPassword"] = "Passwords do not match"
        } else {
            errors.removeValue(forKey: "confirmPassword")
        }
    }
    
    // MARK: - Actions

    private func handleSignup() {
        guard isValid else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isLoading = true
        focusedField = nil
        signupError = nil

        Task {
            do {
                // Sign up with AuthService (Firebase + Backend)
                try await authService.signUp(
                    email: email,
                    password: password,
                    fullName: name,
                    defaultMode: .hustler // Default to hustler mode, can make this a selection later
                )

                // Success! AuthService will set isAuthenticated = true
                // App will automatically navigate to RootNavigator
                isLoading = false

                print("✅ Signup: Account created successfully for \(email)")

                // Haptic feedback
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)

            } catch {
                isLoading = false
                signupError = error.localizedDescription

                print("❌ Signup: Failed - \(error.localizedDescription)")

                // Error haptic
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
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
        let delegate = AppleSignInDelegateSignup { result in
            Task { @MainActor in
                switch result {
                case .success(let authorization):
                    isSocialLoading = true
                    signupError = nil
                    do {
                        try await authService.signInWithApple(authorization: authorization)
                        HapticFeedback.success()
                    } catch {
                        signupError = error.localizedDescription
                        HapticFeedback.error()
                    }
                    isSocialLoading = false
                case .failure(let error):
                    if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                        signupError = error.localizedDescription
                        HapticFeedback.error()
                    }
                }
            }
        }
        appleSignInDelegate = delegate
        controller.delegate = delegate
        controller.performRequests()
    }

    // MARK: - Google Sign-In

    private func handleGoogleSignIn() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isSocialLoading = true
        signupError = nil

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
                    signupError = error.localizedDescription
                    HapticFeedback.error()
                }
            }
            isSocialLoading = false
        }
    }
}

// MARK: - Apple Sign-In Delegate (Signup)

private class AppleSignInDelegateSignup: NSObject, ASAuthorizationControllerDelegate {
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

// MARK: - Auth Text Field (Legacy support)

struct AuthTextField: View {
    let label: String
    @Binding var text: String
    let error: String?
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            
            TextField("", text: $text)
                .textFieldStyle(BrandTextFieldStyle())
                .textContentType(contentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.errorRed)
            }
        }
    }
}

// MARK: - Auth Secure Field (Legacy support)

struct AuthSecureField: View {
    let label: String
    @Binding var text: String
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            
            SecureField("", text: $text)
                .textFieldStyle(BrandTextFieldStyle())
                .textContentType(.password)
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.errorRed)
            }
        }
    }
}

// MARK: - Brand Text Field Style

private struct BrandTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.surfaceElevated)
            .foregroundStyle(Color.textPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        SignupScreen()
    }
    .environment(AppState())
    .environment(Router())
}
