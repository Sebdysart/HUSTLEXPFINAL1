//
//  VerificationSettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//  Fetches real verification status from backend verification.getStatus
//

import SwiftUI
import FirebaseAuth

struct VerificationSettingsScreen: View {
    @Environment(AppState.self) private var appState

    @State private var phoneVerified = false
    @State private var emailVerified = false
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var showPhoneVerify = false
    @State private var showEmailVerify = false

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header card
                    VerificationHeaderCard(trustTier: appState.trustTier)

                    // Current tier info
                    CurrentTierCard(trustTier: appState.trustTier)

                    // Verification steps (real data)
                    if isLoading {
                        ProgressView()
                            .tint(.brandPurple)
                            .padding(40)
                    } else {
                        verificationStepsSection
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }

                    // Benefits section
                    VerificationBenefitsSection()

                    Spacer(minLength: 100)
                }
                .padding(24)
            }

            // Bottom CTA
            VStack {
                Spacer()
                VerificationCTA()
            }
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await fetchStatus() }
        .sheet(isPresented: $showPhoneVerify) {
            PhoneVerifySheet(onVerified: {
                phoneVerified = true
                showPhoneVerify = false
            })
        }
        .sheet(isPresented: $showEmailVerify) {
            EmailVerifySheet(onVerified: {
                emailVerified = true
                showEmailVerify = false
            })
        }
    }

    // MARK: - Steps Section

    private var verificationStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Verification Steps", style: .headline)

            VStack(spacing: 12) {
                VerificationStepRow(
                    title: "Phone Number",
                    subtitle: phoneVerified ? "Verified" : "Verify via SMS code",
                    status: phoneVerified ? .complete : .notStarted
                ) {
                    if !phoneVerified { showPhoneVerify = true }
                }

                VerificationStepRow(
                    title: "Email Address",
                    subtitle: emailVerified ? "Verified" : "Verify via email link",
                    status: emailVerified ? .complete : .notStarted
                ) {
                    if !emailVerified { showEmailVerify = true }
                }

                VerificationStepRow(
                    title: "Identity Verification",
                    subtitle: "Upload your ID to verify",
                    status: .notStarted
                ) {}

                VerificationStepRow(
                    title: "Background Check",
                    subtitle: "Complete after ID verification",
                    status: .notStarted
                ) {}
            }
        }
    }

    // MARK: - Fetch

    private func fetchStatus() async {
        isLoading = true
        errorMessage = nil

        do {
            struct StatusResponse: Codable {
                let phoneVerified: Bool
                let emailVerified: Bool
            }

            let status: StatusResponse = try await TRPCClient.shared.call(
                router: "verification",
                procedure: "getStatus",
                type: .query,
                input: EmptyInput()
            )

            phoneVerified = status.phoneVerified
            emailVerified = status.emailVerified
        } catch {
            errorMessage = "Failed to load verification status"
            HXLogger.error("Verification: \(error.localizedDescription)", category: "Network")
        }

        isLoading = false
    }
}

private struct EmptyInput: Codable {}

// MARK: - Verification Status
enum VerificationStatus {
    case notStarted
    case pending
    case complete

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .pending: return "clock.fill"
        case .complete: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .textTertiary
        case .pending: return .warningOrange
        case .complete: return .successGreen
        }
    }

    var label: String {
        switch self {
        case .notStarted: return "Not Started"
        case .pending: return "In Progress"
        case .complete: return "Complete"
        }
    }
}

// MARK: - Verification Step Row
private struct VerificationStepRow: View {
    let title: String
    let subtitle: String
    let status: VerificationStatus
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: status.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(status.color)

                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }

                Spacer()

                if status == .notStarted || status == .pending {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(status == .complete)
    }
}

// MARK: - Verification Header Card
private struct VerificationHeaderCard: View {
    let trustTier: TrustTier

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(spacing: 8) {
                HXText("Get Verified", style: .title2)

                HXText(
                    "Verified users unlock premium tasks, earn trust faster, and get priority matching.",
                    style: .subheadline,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.brandPurple.opacity(0.1), Color.surfaceElevated],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Current Tier Card
private struct CurrentTierCard: View {
    let trustTier: TrustTier

    var body: some View {
        HStack(spacing: 16) {
            HXBadge(variant: .tier(trustTier))

            VStack(alignment: .leading, spacing: 2) {
                HXText("Current Tier", style: .caption, color: .textSecondary)
                HXText(trustTier.name, style: .headline)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Verification Benefits Section
private struct VerificationBenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Benefits of Verification", style: .headline)

            VStack(spacing: 12) {
                BenefitRow(
                    icon: "star.fill",
                    iconColor: .warningOrange,
                    title: "Premium Tasks",
                    description: "Access high-paying tasks from verified posters"
                )

                BenefitRow(
                    icon: "bolt.fill",
                    iconColor: .brandPurple,
                    title: "Priority Matching",
                    description: "Get matched to tasks faster"
                )

                BenefitRow(
                    icon: "shield.fill",
                    iconColor: .successGreen,
                    title: "Trust Badge",
                    description: "Stand out with a verified badge on your profile"
                )

                BenefitRow(
                    icon: "arrow.up.circle.fill",
                    iconColor: .infoBlue,
                    title: "Higher Limits",
                    description: "Increased earning and task limits"
                )
            }
        }
    }
}

// MARK: - Benefit Row
private struct BenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HXText(title, style: .subheadline)
                HXText(description, style: .caption, color: .textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

// MARK: - Verification CTA
private struct VerificationCTA: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)

            HXButton("Start Identity Verification", variant: .primary) {
                // Start verification — future implementation
            }
            .accessibilityLabel("Start identity verification")
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

#Preview {
    NavigationStack {
        VerificationSettingsScreen()
    }
    .environment(AppState())
}
