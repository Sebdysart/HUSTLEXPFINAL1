//
//  ForgotPasswordScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//

import SwiftUI

struct ForgotPasswordScreen: View {
    @Environment(Router.self) private var router
    
    @State private var email: String = ""
    @State private var isSubmitted: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var isEmailFocused: Bool
    
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Background
                LinearGradient.brandGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 24 : 32) {
                        Spacer(minLength: isCompact ? 30 : 50)
                        
                        // Icon and header
                        VStack(spacing: isCompact ? 14 : 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPurple.opacity(0.15))
                                    .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                                
                                Image(systemName: isSubmitted ? "envelope.badge.fill" : "lock.rotation")
                                    .font(.system(size: isCompact ? 32 : 40))
                                    .foregroundStyle(Color.brandPurple)
                            }
                            
                            VStack(spacing: isCompact ? 8 : 12) {
                                Text(isSubmitted ? "Check Your Email" : "Reset Password")
                                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                                    .foregroundStyle(Color.textPrimary)
                                
                                Text(isSubmitted
                                    ? "We've sent reset instructions to \(email)"
                                    : "Enter your email and we'll send you instructions to reset your password")
                                    .font(.system(size: isCompact ? 14 : 16))
                                    .foregroundStyle(Color.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, isCompact ? 18 : 24)
                        
                        Spacer(minLength: isCompact ? 20 : 40)
                
                        if !isSubmitted {
                            // Form
                            VStack(spacing: isCompact ? 16 : 20) {
                                // Email input
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Email Address")
                                        .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                                        .foregroundStyle(Color.textSecondary)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "envelope.fill")
                                            .foregroundStyle(Color.textSecondary)
                                        
                                        TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.textTertiary))
                                            .font(.system(size: isCompact ? 15 : 16))
                                            .foregroundStyle(Color.textPrimary)
                                            .textContentType(.emailAddress)
                                            .autocapitalization(.none)
                                            .keyboardType(.emailAddress)
                                            .focused($isEmailFocused)
                                    }
                                    .padding(isCompact ? 12 : 16)
                                    .background(Color.surfaceElevated)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isEmailFocused ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                                    )
                                }
                                
                                HXButton(
                                    isLoading ? "Sending..." : "Send Reset Link",
                                    variant: .primary,
                                    isLoading: isLoading
                                ) {
                                    handleSubmit()
                                }
                                .disabled(!isValidEmail || isLoading)
                                .opacity(isValidEmail ? 1 : 0.5)
                            }
                            .padding(.horizontal, isCompact ? 18 : 24)
                        } else {
                            // Success state
                            VStack(spacing: isCompact ? 16 : 20) {
                                // Success illustration
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.successGreen.opacity(0.15))
                                            .frame(width: isCompact ? 50 : 60, height: isCompact ? 50 : 60)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                                            .foregroundStyle(Color.successGreen)
                                    }
                                    
                                    Text("Email Sent!")
                                        .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                                        .foregroundStyle(Color.successGreen)
                                }
                                .padding(isCompact ? 16 : 20)
                                .background(Color.surfaceElevated)
                                .cornerRadius(16)
                                
                                HXButton("Back to Sign In", variant: .primary) {
                                    router.popAuth()
                                }
                                
                                Button(action: { isSubmitted = false }) {
                                    Text("Didn't receive it? Try again")
                                        .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                                        .foregroundStyle(Color.brandPurple)
                                }
                            }
                            .padding(.horizontal, isCompact ? 18 : 24)
                        }
                        
                        Spacer(minLength: max(16, geometry.safeAreaInsets.bottom + 8))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func handleSubmit() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation(.spring(response: 0.5)) {
                isSubmitted = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordScreen()
    }
    .environment(Router())
}
