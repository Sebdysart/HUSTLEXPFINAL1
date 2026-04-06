//
//  EmailVerifySheet.swift
//  hustleXP final1
//
//  Email verification flow.
//  Calls verification.sendEmailVerification to trigger Firebase email link,
//  then polls verification.checkEmailVerification after user clicks the link.
//

import SwiftUI
import FirebaseAuth

struct EmailVerifySheet: View {
    let onVerified: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var isSending = false
    @State private var isChecking = false
    @State private var emailSent = false
    @State private var errorMessage: String?
    @State private var userEmail: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: emailSent ? "envelope.open.fill" : "envelope.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.brandPurple)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 8) {
                        Text(emailSent ? "Check Your Email" : "Verify Email Address")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.textPrimary)

                        Text(emailSent
                             ? "We sent a verification link to **\(userEmail)**. Open the link, then tap the button below."
                             : "We'll send a verification link to your email address.")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }

                    if !emailSent {
                        // Send button
                        Button(action: sendVerificationEmail) {
                            HStack(spacing: 8) {
                                if isSending {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 14))
                                    Text("Send Verification Email")
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSending ? Color.textMuted.opacity(0.5) : Color.brandPurple)
                            )
                        }
                        .disabled(isSending)
                    } else {
                        // Check verification button
                        Button(action: checkVerification) {
                            HStack(spacing: 8) {
                                if isChecking {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("I've Verified My Email")
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isChecking ? Color.textMuted.opacity(0.5) : Color.brandPurple)
                            )
                        }
                        .disabled(isChecking)

                        // Resend
                        Button("Resend Email") { sendVerificationEmail() }
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPurple)
                            .disabled(isSending)
                    }
                }
                .padding(20)
            }
            .background(Color.brandBlack)
            .navigationTitle("Email Verification")
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
            .onAppear {
                userEmail = AuthService.shared.currentUser?.email ?? ""
            }
        }
    }

    // MARK: - Actions

    private func sendVerificationEmail() {
        isSending = true
        errorMessage = nil

        Task {
            do {
                // Use Firebase client SDK directly — free, no SendGrid credits needed
                guard let firebaseUser = Auth.auth().currentUser else {
                    errorMessage = "No authenticated user. Please sign in again."
                    isSending = false
                    return
                }

                try await firebaseUser.sendEmailVerification()
                isSending = false
                emailSent = true
            } catch {
                isSending = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func checkVerification() {
        isChecking = true
        errorMessage = nil

        Task {
            do {
                struct EmptyInput: Codable {}
                struct CheckResponse: Codable { let emailVerified: Bool }

                let response: CheckResponse = try await TRPCClient.shared.call(
                    router: "verification",
                    procedure: "checkEmailVerification",
                    input: EmptyInput()
                )

                isChecking = false

                if response.emailVerified {
                    onVerified()
                } else {
                    errorMessage = "Email not yet verified. Please click the link in the email first."
                }
            } catch {
                isChecking = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    EmailVerifySheet(onVerified: {})
}
