//
//  ReferralScreen.swift
//  hustleXP final1
//
//  Referral program screen — invite friends, earn rewards
//

import SwiftUI

struct ReferralScreen: View {
    @StateObject private var referralService = ReferralService()
    @State private var showShareSheet = false
    @State private var redeemCode = ""
    @State private var showRedeemField = false
    @State private var redeemSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 12) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.brandPurple)

                    Text("Invite Friends, Earn Cash")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.textPrimary)

                    Text("You and your friend each get $5 when they complete their first task")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)

                // Referral Code Card
                VStack(spacing: 16) {
                    Text("Your Referral Code")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.textTertiary)
                        .textCase(.uppercase)

                    if referralService.isLoading {
                        ProgressView()
                            .tint(.brandPurple)
                    } else {
                        Text(referralService.referralCode ?? "---")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.brandPurple)
                            .padding(.vertical, 8)
                    }

                    // Share button
                    Button {
                        showShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Code")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Copy button
                    Button {
                        if let code = referralService.referralCode {
                            UIPasteboard.general.string = code
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Code")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.brandPurple)
                    }
                }
                .padding(24)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Stats
                HStack(spacing: 16) {
                    ReferralStatCard(title: "Friends Referred", value: "\(referralService.referralCount)", icon: "person.2.fill")
                    ReferralStatCard(title: "Earned", value: "$\(String(format: "%.2f", Double(referralService.totalEarned) / 100))", icon: "dollarsign.circle.fill")
                }

                // How it works
                VStack(alignment: .leading, spacing: 16) {
                    Text("How It Works")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    ReferralStepRow(number: 1, text: "Share your referral code with friends")
                    ReferralStepRow(number: 2, text: "They sign up and enter your code")
                    ReferralStepRow(number: 3, text: "They complete their first task")
                    ReferralStepRow(number: 4, text: "You both receive $5 reward!")
                }
                .padding(20)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Redeem code section
                VStack(spacing: 12) {
                    Button {
                        withAnimation { showRedeemField.toggle() }
                    } label: {
                        HStack {
                            Image(systemName: "ticket")
                            Text("Have a referral code?")
                            Spacer()
                            Image(systemName: showRedeemField ? "chevron.up" : "chevron.down")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.textSecondary)
                    }

                    if showRedeemField {
                        HStack(spacing: 12) {
                            TextField("Enter code", text: $redeemCode)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.surfaceDefault)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .textInputAutocapitalization(.characters)
                                .foregroundStyle(Color.textPrimary)

                            Button("Redeem") {
                                Task {
                                    redeemSuccess = await referralService.redeemCode(redeemCode)
                                }
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(redeemCode.isEmpty ? Color.gray : Color.brandPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .disabled(redeemCode.isEmpty)
                        }

                        if redeemSuccess {
                            Text("Code redeemed! You'll receive $5 after your first task.")
                                .font(.caption)
                                .foregroundColor(.successGreen)
                        }
                    }
                }
                .padding(20)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color.brandBlack.ignoresSafeArea())
        .navigationTitle("Referrals")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await referralService.getOrCreateReferralCode()
        }
        .sheet(isPresented: $showShareSheet) {
            ReferralShareSheet(items: [referralService.shareReferralCode()])
        }
    }
}

// MARK: - Helper Views
private struct ReferralStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brandPurple)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct ReferralStepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.brandPurple)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Share Sheet
private struct ReferralShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
