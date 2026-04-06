//
//  ChangePasswordScreen.swift
//  hustleXP final1
//
//  Change password via Firebase Auth reauthentication + update
//

import SwiftUI
import FirebaseAuth

struct ChangePasswordScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case current, new, confirm
    }

    private var isValid: Bool {
        !currentPassword.isEmpty
        && newPassword.count >= 8
        && newPassword == confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Info
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brandPurple)

                    Text("Update your password")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Text("Enter your current password and choose a new one.")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                // Form
                formSection

                // Requirements
                if !newPassword.isEmpty {
                    passwordRequirements
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.errorRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Save
                saveButton
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBlack)
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Password Updated", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your password has been changed successfully.")
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 20) {
            // Current password
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                SecureField("Enter current password", text: $currentPassword)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .current ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .current)
                    .textContentType(.password)
            }

            // New password
            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                SecureField("Enter new password", text: $newPassword)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .new ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .new)
                    .textContentType(.newPassword)
            }

            // Confirm new password
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm New Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                SecureField("Re-enter new password", text: $confirmPassword)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .confirm ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .confirm)
                    .textContentType(.newPassword)
            }
        }
    }

    // MARK: - Requirements

    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 6) {
            requirementRow(text: "8+ characters", met: newPassword.count >= 8)
            requirementRow(text: "Passwords match", met: !confirmPassword.isEmpty && newPassword == confirmPassword)
        }
        .padding(.horizontal, 4)
    }

    private func requirementRow(text: String, met: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(met ? Color.successGreen : Color.textMuted)

            Text(text)
                .font(.caption)
                .foregroundStyle(met ? Color.textPrimary : Color.textMuted)
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button(action: changePassword) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Update Password")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isValid && !isLoading ? Color.brandPurple : Color.textMuted.opacity(0.5))
            )
        }
        .disabled(!isValid || isLoading)
        .padding(.top, 8)
    }

    // MARK: - Action

    private func changePassword() {
        guard isValid else { return }
        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                guard let user = Auth.auth().currentUser,
                      let email = user.email else {
                    errorMessage = "No authenticated user found. Please sign in again."
                    isLoading = false
                    return
                }

                // Step 1: Re-authenticate with current password
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                try await user.reauthenticate(with: credential)

                // Step 2: Update to new password
                try await user.updatePassword(to: newPassword)

                // Step 3: Refresh token so backend gets the new session
                try await AuthService.shared.refreshToken()

                HXLogger.info("Auth: Password changed successfully", category: "Auth")
                isLoading = false
                showSuccess = true
            } catch let error as NSError {
                isLoading = false
                if error.code == AuthErrorCode.wrongPassword.rawValue {
                    errorMessage = "Current password is incorrect."
                } else if error.code == AuthErrorCode.weakPassword.rawValue {
                    errorMessage = "New password is too weak. Please choose a stronger one."
                } else if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    errorMessage = "Session expired. Please sign out and sign in again."
                } else {
                    errorMessage = error.localizedDescription
                }
                HXLogger.error("Auth: Password change failed - \(error.localizedDescription)", category: "Auth")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordScreen()
    }
}
