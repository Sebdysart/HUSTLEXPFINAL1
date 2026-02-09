//
//  PhoneVerificationScreen.swift
//  hustleXP final1
//
//  Archetype: A (Entry/Commitment)
//

import SwiftUI

struct PhoneVerificationScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var isCodeSent: Bool = false
    @State private var isLoading: Bool = false
    @State private var countdown: Int = 0
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case phone, code
    }
    
    private var isValidPhone: Bool {
        phoneNumber.filter { $0.isNumber }.count >= 10
    }
    
    private var isValidCode: Bool {
        verificationCode.count == 6
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
                        
                        Image(systemName: isCodeSent ? "lock.shield.fill" : "phone.badge.checkmark")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.brandPurple)
                    }
                    
                    VStack(spacing: 12) {
                        HXText(
                            isCodeSent ? "Enter Verification Code" : "Verify Your Phone",
                            style: .title
                        )
                        
                        HXText(
                            isCodeSent
                                ? "We sent a 6-digit code to \(formatPhoneNumber(phoneNumber))"
                                : "We'll send you a verification code to confirm your number",
                            style: .body,
                            color: .textSecondary
                        )
                        .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Form
                VStack(spacing: 20) {
                    if !isCodeSent {
                        // Phone input
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Phone Number", style: .subheadline, color: .textSecondary)
                            
                            HStack(spacing: 12) {
                                HXText("+1", style: .body, color: .textSecondary)
                                    .padding(.leading, 16)
                                
                                TextField("", text: $phoneNumber, prompt: Text("(555) 123-4567").foregroundColor(.textTertiary))
                                    .font(.body)
                                    .foregroundStyle(Color.textPrimary)
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                                    .focused($focusedField, equals: .phone)
                            }
                            .padding(.vertical, 16)
                            .padding(.trailing, 16)
                            .background(Color.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .phone ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                            )
                        }
                        
                        HXButton(
                            isLoading ? "Sending..." : "Send Code",
                            variant: .primary,
                            isLoading: isLoading
                        ) {
                            sendCode()
                        }
                        .disabled(!isValidPhone || isLoading)
                        .opacity(isValidPhone ? 1 : 0.5)
                    } else {
                        // Code input
                        VStack(spacing: 24) {
                            // OTP-style input display
                            HStack(spacing: 12) {
                                ForEach(0..<6, id: \.self) { index in
                                    CodeDigitBox(
                                        digit: getDigit(at: index),
                                        isFocused: focusedField == .code && verificationCode.count == index
                                    )
                                }
                            }
                            .onTapGesture {
                                focusedField = .code
                            }
                            
                            // Hidden text field for input
                            TextField("", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .focused($focusedField, equals: .code)
                                .frame(width: 0, height: 0)
                                .opacity(0)
                                .onChange(of: verificationCode) { _, newValue in
                                    // Limit to 6 digits
                                    if newValue.count > 6 {
                                        verificationCode = String(newValue.prefix(6))
                                    }
                                }
                            
                            // Resend option
                            if countdown > 0 {
                                HXText(
                                    "Resend code in \(countdown)s",
                                    style: .subheadline,
                                    color: .textTertiary
                                )
                            } else {
                                Button(action: resendCode) {
                                    HXText("Resend Code", style: .subheadline, color: .brandPurple)
                                }
                            }
                        }
                        
                        HXButton(
                            isLoading ? "Verifying..." : "Verify",
                            variant: .primary,
                            isLoading: isLoading
                        ) {
                            verifyCode()
                        }
                        .disabled(!isValidCode || isLoading)
                        .opacity(isValidCode ? 1 : 0.5)
                        
                        Button(action: { 
                            withAnimation {
                                isCodeSent = false
                                verificationCode = ""
                            }
                        }) {
                            HXText("Change Phone Number", style: .subheadline, color: .textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Verify Phone")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            focusedField = .phone
        }
    }
    
    private func getDigit(at index: Int) -> String {
        guard index < verificationCode.count else { return "" }
        return String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)])
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        guard digits.count >= 10 else { return number }
        let area = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(3)
        let last = digits.dropFirst(6).prefix(4)
        return "(\(area)) \(middle)-\(last)"
    }
    
    private func sendCode() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation(.spring(response: 0.5)) {
                isCodeSent = true
                focusedField = .code
                startCountdown()
            }
        }
    }
    
    private func resendCode() {
        startCountdown()
    }
    
    private func startCountdown() {
        countdown = 30
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func verifyCode() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // Move to onboarding after verification
            appState.login(userId: "mock-user-id", role: .hustler)
        }
    }
}

// MARK: - Code Digit Box
private struct CodeDigitBox: View {
    let digit: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceElevated)
                .frame(width: 48, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            digit.isEmpty ? (isFocused ? Color.brandPurple : Color.borderSubtle) : Color.brandPurple,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
            
            if digit.isEmpty && isFocused {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.brandPurple)
                    .frame(width: 2, height: 24)
                    .opacity(isFocused ? 1 : 0)
            } else {
                HXText(digit, style: .title2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhoneVerificationScreen()
    }
    .environment(AppState())
    .environment(Router())
}
