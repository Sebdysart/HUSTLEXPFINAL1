//
//  IDVerificationScreen.swift
//  hustleXP final1
//
//  Identity verification via Checkr.
//  Collects name + DOB, calls verification.startIdentityVerification,
//  then opens Checkr's hosted verification page in Safari.
//

import SwiftUI

struct IDVerificationScreen: View {
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var checkrURL: URL?
    @State private var showCheckrWeb = false
    @State private var checkStarted = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case first, last, dob }

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
        && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
        && dateOfBirth.count == 10
        && dateOfBirth.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    if !checkStarted {
                        // Form
                        formSection

                        // Submit
                        submitButton
                    } else {
                        // Verification in progress
                        inProgressSection
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBlack)
            .navigationTitle("Identity Verification")
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
            .sheet(isPresented: $showCheckrWeb) {
                if let url = checkrURL {
                    SafariView(url: url)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(spacing: 8) {
                Text("Verify Your Identity")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text("We use Checkr to securely verify your identity. Your information is encrypted and never stored on our servers.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 20) {
            // First name
            VStack(alignment: .leading, spacing: 6) {
                Text("First Name")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                TextField("John", text: $firstName)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .first ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .first)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
            }

            // Last name
            VStack(alignment: .leading, spacing: 6) {
                Text("Last Name")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                TextField("Doe", text: $lastName)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .last ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .last)
                    .textContentType(.familyName)
                    .autocorrectionDisabled()
            }

            // Date of birth
            VStack(alignment: .leading, spacing: 6) {
                Text("Date of Birth")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                TextField("YYYY-MM-DD", text: $dateOfBirth)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .dob ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .dob)
                    .keyboardType(.numbersAndPunctuation)
            }

        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button(action: startVerification) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                    Text("Start Verification")
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

    // MARK: - In Progress

    private var inProgressSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.successGreen)

            Text("Verification Started")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text("Complete the verification on Checkr's secure page. You'll be notified when it's done.")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            if checkrURL != nil {
                Button {
                    showCheckrWeb = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 14))
                        Text("Open Verification Page")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandPurple)
                    )
                }
            }

            Button("Done") {
                onComplete()
                dismiss()
            }
            .font(.body)
            .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, 16)
    }

    // MARK: - Action

    private func startVerification() {
        guard isValid else { return }
        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                struct StartInput: Codable {
                    let firstName: String
                    let lastName: String
                    let dateOfBirth: String
                }
                struct StartResponse: Codable {
                    let checkId: String
                    let status: String
                    let invitationUrl: String?
                }

                let response: StartResponse = try await TRPCClient.shared.call(
                    router: "verification",
                    procedure: "startIdentityVerification",
                    input: StartInput(
                        firstName: firstName.trimmingCharacters(in: .whitespaces),
                        lastName: lastName.trimmingCharacters(in: .whitespaces),
                        dateOfBirth: dateOfBirth
                    )
                )

                isLoading = false
                checkStarted = true

                if let urlString = response.invitationUrl, let url = URL(string: urlString) {
                    checkrURL = url
                    showCheckrWeb = true
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Safari View (for Checkr hosted page)

import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    IDVerificationScreen(onComplete: {})
}
