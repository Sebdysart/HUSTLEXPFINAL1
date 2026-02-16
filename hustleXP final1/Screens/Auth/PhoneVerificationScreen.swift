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
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                // Background
                LinearGradient.brandGradient
                    .ignoresSafeArea()
                
                VStack(spacing: isCompact ? 20 : 28) {
                    Spacer()
                    
                    // Icon and header
                    VStack(spacing: isCompact ? 12 : 16) {
                        ZStack {
                            Circle()
                                .fill(Color.brandPurple.opacity(0.15))
                                .frame(width: isCompact ? 64 : 80, height: isCompact ? 64 : 80)
                            
                            Image(systemName: isCodeSent ? "lock.shield.fill" : "phone.badge.checkmark")
                                .font(.system(size: isCompact ? 26 : 32))
                                .foregroundStyle(Color.brandPurple)
                        }
                        
                        VStack(spacing: isCompact ? 6 : 10) {
                            Text(isCodeSent ? "Enter Verification Code" : "Verify Your Phone")
                                .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.textPrimary)
                            
                            Text(isCodeSent
                                ? "We sent a 6-digit code to \(formatPhoneNumber(phoneNumber))"
                                : "We'll send you a verification code to confirm your number")
                                .font(.system(size: isCompact ? 13 : 15))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, isCompact ? 18 : 24)
                    
                    Spacer()
                
                        // Form
                        VStack(spacing: isCompact ? 16 : 20) {
                            if !isCodeSent {
                                // Phone input
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Phone Number")
                                        .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                                        .foregroundStyle(Color.textSecondary)
                                    
                                    HStack(spacing: 12) {
                                        Text("+1")
                                            .font(.system(size: isCompact ? 15 : 16))
                                            .foregroundStyle(Color.textSecondary)
                                            .padding(.leading, isCompact ? 12 : 16)
                                        
                                        TextField("", text: $phoneNumber, prompt: Text("(555) 123-4567").foregroundColor(.textTertiary))
                                            .font(.system(size: isCompact ? 15 : 16))
                                            .foregroundStyle(Color.textPrimary)
                                            .textContentType(.telephoneNumber)
                                            .keyboardType(.phonePad)
                                            .focused($focusedField, equals: .phone)
                                    }
                                    .padding(.vertical, isCompact ? 12 : 16)
                                    .padding(.trailing, isCompact ? 12 : 16)
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
                                .accessibilityLabel("Send verification code")
                                .disabled(!isValidPhone || isLoading)
                                .opacity(isValidPhone ? 1 : 0.5)
                            } else {
                                // Code input
                                VStack(spacing: isCompact ? 18 : 24) {
                                    // OTP-style input display
                                    HStack(spacing: isCompact ? 8 : 12) {
                                        ForEach(0..<6, id: \.self) { index in
                                            CodeDigitBox(
                                                digit: getDigit(at: index),
                                                isFocused: focusedField == .code && verificationCode.count == index,
                                                isCompact: isCompact
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
                                            if newValue.count > 6 {
                                                verificationCode = String(newValue.prefix(6))
                                            }
                                            // Auto-submit when 6 digits entered
                                            if newValue.count == 6 {
                                                verifyCode()
                                            }
                                        }
                                    
                                    // Resend option
                                    if countdown > 0 {
                                        Text("Resend code in \(countdown)s")
                                            .font(.system(size: isCompact ? 13 : 14))
                                            .foregroundStyle(Color.textTertiary)
                                    } else {
                                        Button(action: resendCode) {
                                            Text("Resend Code")
                                                .font(.system(size: isCompact ? 13 : 14, weight: .medium))
                                                .minimumScaleFactor(0.7)
                                                .foregroundStyle(Color.brandPurple)
                                        }
                                        .accessibilityLabel("Resend verification code")
                                    }
                                }
                                
                                // Loading indicator when verifying
                                if isLoading {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .tint(Color.brandPurple)
                                        Text("Verifying...")
                                            .font(.system(size: isCompact ? 14 : 15, weight: .medium))
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                    .padding(.top, 8)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        isCodeSent = false
                                        verificationCode = ""
                                    }
                                }) {
                                    Text("Change Phone Number")
                                        .font(.system(size: isCompact ? 13 : 14))
                                        .minimumScaleFactor(0.7)
                                        .foregroundStyle(Color.textSecondary)
                                }
                                .accessibilityLabel("Change phone number")
                            }
                        }
                        .padding(.horizontal, isCompact ? 18 : 24)
                    
                    Spacer()
                }
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
    var isCompact: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                .fill(Color.surfaceElevated)
                .frame(width: isCompact ? 42 : 48, height: isCompact ? 48 : 56)
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                        .stroke(
                            digit.isEmpty ? (isFocused ? Color.brandPurple : Color.borderSubtle) : Color.brandPurple,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
            
            if digit.isEmpty && isFocused {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.brandPurple)
                    .frame(width: 2, height: isCompact ? 20 : 24)
                    .opacity(isFocused ? 1 : 0)
            } else {
                Text(digit)
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
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
