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
        ZStack {
            // Background
            LinearGradient.brandGradient
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon and header
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.15))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: isSubmitted ? "envelope.badge.fill" : "lock.rotation")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.brandPurple)
                    }
                    
                    VStack(spacing: 12) {
                        HXText(
                            isSubmitted ? "Check Your Email" : "Reset Password",
                            style: .title
                        )
                        
                        HXText(
                            isSubmitted
                                ? "We've sent reset instructions to \(email)"
                                : "Enter your email and we'll send you instructions to reset your password",
                            style: .body,
                            color: .textSecondary
                        )
                        .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                if !isSubmitted {
                    // Form
                    VStack(spacing: 20) {
                        // Email input
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Email Address", style: .subheadline, color: .textSecondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(Color.textSecondary)
                                
                                TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.textTertiary))
                                    .font(.body)
                                    .foregroundStyle(Color.textPrimary)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($isEmailFocused)
                            }
                            .padding(16)
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
                    .padding(.horizontal, 24)
                } else {
                    // Success state
                    VStack(spacing: 20) {
                        // Success illustration
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.successGreen.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.successGreen)
                            }
                            
                            HXText("Email Sent!", style: .headline, color: .successGreen)
                        }
                        .padding(20)
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                        
                        HXButton("Back to Sign In", variant: .primary) {
                            router.popAuth()
                        }
                        
                        Button(action: { isSubmitted = false }) {
                            HXText("Didn't receive it? Try again", style: .subheadline, color: .brandPurple)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
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
