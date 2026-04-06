//
//  PhoneVerifySheet.swift
//  hustleXP final1
//
//  Phone number verification via SMS OTP.
//  Calls verification.sendPhoneOTP → verification.verifyPhone
//

import SwiftUI

struct PhoneVerifySheet: View {
    let onVerified: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var phone = ""
    @State private var code = ""
    @State private var isCodeSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var countdown = 0
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case phone, code }

    private var isPhoneValid: Bool {
        // Basic E.164 check: starts with +, 8-16 chars
        phone.hasPrefix("+") && phone.count >= 8 && phone.count <= 16
    }

    private var isCodeValid: Bool {
        code.count == 6 && code.allSatisfy(\.isNumber)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "phone.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.brandPurple)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 8) {
                        Text("Verify Phone Number")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.textPrimary)

                        Text(isCodeSent
                             ? "Enter the 6-digit code sent to \(phone)"
                             : "We'll send a verification code via SMS")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Phone input or code input
                    if !isCodeSent {
                        phoneInputSection
                    } else {
                        codeInputSection
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }

                    // Action button
                    actionButton

                    if isCodeSent {
                        resendButton
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBlack)
            .navigationTitle("Phone Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    // MARK: - Phone Input

    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Phone Number")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            TextField("+1 555 123 4567", text: $phone)
                .font(.title3.monospacedDigit())
                .foregroundStyle(Color.textPrimary)
                .padding(14)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .phone ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                )
                .focused($focusedField, equals: .phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)

            Text("Include country code (e.g. +1 for US)")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
    }

    // MARK: - Code Input

    private var codeInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Verification Code")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            TextField("000000", text: $code)
                .font(.title.monospacedDigit())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(14)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .code ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                )
                .focused($focusedField, equals: .code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .onChange(of: code) { _, newValue in
                    // Auto-limit to 6 digits
                    if newValue.count > 6 {
                        code = String(newValue.prefix(6))
                    }
                }
        }
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button(action: isCodeSent ? verifyCode : sendCode) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(isCodeSent ? "Verify Code" : "Send Code")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonEnabled ? Color.brandPurple : Color.textMuted.opacity(0.5))
            )
        }
        .disabled(!buttonEnabled || isLoading)
    }

    private var buttonEnabled: Bool {
        isCodeSent ? isCodeValid : isPhoneValid
    }

    // MARK: - Resend

    private var resendButton: some View {
        Group {
            if countdown > 0 {
                Text("Resend in \(countdown)s")
                    .font(.subheadline)
                    .foregroundStyle(Color.textMuted)
            } else {
                Button("Resend Code") { sendCode() }
                    .font(.subheadline)
                    .foregroundStyle(Color.brandPurple)
            }
        }
    }

    // MARK: - Actions

    private func sendCode() {
        focusedField = nil
        isLoading = true
        errorMessage = nil

        // Strip spaces/dashes for E.164
        let cleanPhone = phone.filter { $0 == "+" || $0.isNumber }

        Task {
            do {
                struct SendInput: Codable { let phone: String }
                struct SendResponse: Codable { let success: Bool }

                let _: SendResponse = try await TRPCClient.shared.call(
                    router: "verification",
                    procedure: "sendPhoneOTP",
                    input: SendInput(phone: cleanPhone)
                )

                phone = cleanPhone
                isCodeSent = true
                isLoading = false
                startCountdown()
                focusedField = .code
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func verifyCode() {
        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                struct VerifyInput: Codable {
                    let phone: String
                    let code: String
                }
                struct VerifyResponse: Codable {
                    let success: Bool
                    let phoneVerified: Bool
                }

                let _: VerifyResponse = try await TRPCClient.shared.call(
                    router: "verification",
                    procedure: "verifyPhone",
                    input: VerifyInput(phone: phone, code: code)
                )

                isLoading = false
                onVerified()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func startCountdown() {
        countdown = 60
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    PhoneVerifySheet(onVerified: {})
}
