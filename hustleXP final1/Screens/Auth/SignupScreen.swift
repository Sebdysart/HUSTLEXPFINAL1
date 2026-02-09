//
//  SignupScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//  Premium signup with elegant forms and smooth animations
//

import SwiftUI

struct SignupScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showContent = false
    @State private var errors: [String: String] = [:]
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
        ZStack {
            // Background
            backgroundLayer
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 40)
                    
                    // Logo and header
                    headerSection
                    
                    Spacer(minLength: 32)
                    
                    // Signup form
                    formSection
                    
                    Spacer(minLength: 24)
                    
                    // Divider with "or"
                    dividerSection
                    
                    Spacer(minLength: 24)
                    
                    // Social signup options
                    socialSignupSection
                    
                    Spacer(minLength: 32)
                    
                    // Sign in link
                    signInSection
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 24)
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Logo
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 32, weight: .semibold))
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
            
            VStack(spacing: 8) {
                Text("Join HustleXP")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Start your hustle journey today")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
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
            
            // Create account button
            HXButton("Create Account", icon: isLoading ? nil : "arrow.right", variant: .primary, isLoading: isLoading) {
                handleSignup()
            }
            .padding(.top, 8)
            .disabled(!isValid || isLoading)
            .opacity(isValid ? 1 : 0.6)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 30)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
    }
    
    // MARK: - Password Requirements
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 6) {
            requirementRow(text: "At least 8 characters", met: password.count >= 8)
            requirementRow(text: "Passwords match", met: !confirmPassword.isEmpty && password == confirmPassword)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(focusedField == field ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                
                TextField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .textContentType(contentType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .keyboardType(keyboardType)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: field)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        focusedField == field ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == field ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(focusedField == field ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                
                SecureField("", text: text, prompt: Text(placeholder).foregroundColor(.textMuted))
                    .textContentType(.password)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: field)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        focusedField == field ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == field ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
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
    
    private var socialSignupSection: some View {
        HStack(spacing: 16) {
            socialButton(icon: "apple.logo", label: "Apple")
            socialButton(icon: "g.circle.fill", label: "Google")
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
    }
    
    private func socialButton(icon: String, label: String) -> some View {
        Button(action: {
            // Handle social signup
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            print("[Signup] Creating account for: \(email)")
            router.navigateToAuth(.phoneVerification)
        }
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
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            
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

#Preview {
    NavigationStack {
        SignupScreen()
    }
    .environment(AppState())
    .environment(Router())
}
