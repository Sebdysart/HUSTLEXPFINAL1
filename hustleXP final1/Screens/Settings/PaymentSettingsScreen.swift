//
//  PaymentSettingsScreen.swift
//  hustleXP final1
//
//  Payment method management — lists saved cards, add/remove via Stripe.
//

import SwiftUI
import StripePaymentSheet

struct PaymentSettingsScreen: View {
    @Environment(LiveDataService.self) private var dataService

    @State private var paymentMethods: [SavedCard] = []
    @State private var isLoading = true
    @State private var isAdding = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Balance card
                    BalanceCard(user: dataService.currentUser)

                    // Saved payment methods
                    paymentMethodsSection

                    // Add payment method button
                    addCardButton

                    // Payout Section
                    payoutSection

                    // History Section
                    historySection

                    // Security note
                    securityNote
                }
                .padding(24)
            }
        }
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await fetchPaymentMethods() }
    }

    // MARK: - Payment Methods Section

    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Payment Methods", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView().tint(.brandPurple)
                    Spacer()
                }
                .padding(24)
                .background(Color.surfaceElevated)
                .cornerRadius(16)
            } else if paymentMethods.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textMuted)

                    HXText("No saved payment methods", style: .body, color: .textSecondary)

                    Spacer()
                }
                .padding(16)
                .background(Color.surfaceElevated)
                .cornerRadius(16)
            } else {
                VStack(spacing: 0) {
                    ForEach(paymentMethods) { card in
                        SavedCardRow(card: card, onRemove: { removeCard(card.id) }, onSetDefault: { setDefault(card.id) })

                        if card.id != paymentMethods.last?.id {
                            HXDivider().padding(.leading, 72)
                        }
                    }
                }
                .background(Color.surfaceElevated)
                .cornerRadius(16)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.errorRed)
            }
        }
    }

    // MARK: - Add Card Button

    private var addCardButton: some View {
        Button { addPaymentMethod() } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.brandPurple.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.brandPurple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HXText("Add Payment Method", style: .body)
                    HXText("Credit or debit card", style: .caption, color: .textSecondary)
                }

                Spacer()

                if isAdding {
                    ProgressView().tint(.brandPurple)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .disabled(isAdding)
    }

    // MARK: - Payout Section

    private var payoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Payout", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            EmptyPaymentMethodRow(
                icon: "building.columns.fill",
                title: "Add Bank Account",
                subtitle: "Connect a bank to receive payouts"
            ) {}
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("History", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            HistoryRow(
                icon: "clock.arrow.circlepath",
                title: "Transaction History",
                subtitle: "View all payments and payouts"
            )
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }

    // MARK: - Security Note

    private var securityNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(Color.successGreen)

            HXText(
                "Your payment information is encrypted and securely stored by Stripe. We never see your full card number.",
                style: .caption,
                color: .textTertiary
            )
        }
        .padding(16)
    }

    // MARK: - Actions

    private func fetchPaymentMethods() async {
        isLoading = true
        errorMessage = nil

        do {
            struct EmptyInput: Codable {}
            struct ListResponse: Codable {
                let methods: [SavedCard]
            }

            let response: ListResponse = try await TRPCClient.shared.call(
                router: "paymentMethods",
                procedure: "list",
                type: .query,
                input: EmptyInput()
            )
            paymentMethods = response.methods
        } catch {
            // Non-fatal — just show empty state
            HXLogger.error("PaymentMethods: \(error.localizedDescription)", category: "Payment")
        }

        isLoading = false
    }

    private func addPaymentMethod() {
        isAdding = true
        errorMessage = nil

        Task {
            do {
                struct EmptyInput: Codable {}
                struct SetupResponse: Codable {
                    let clientSecret: String
                    let customerId: String
                    let ephemeralKeySecret: String
                }

                let response: SetupResponse = try await TRPCClient.shared.call(
                    router: "paymentMethods",
                    procedure: "createSetupIntent",
                    input: EmptyInput()
                )

                // Present Stripe PaymentSheet for adding card
                StripePaymentManager.shared.prepareSetupSheet(
                    clientSecret: response.clientSecret,
                    customerId: response.customerId,
                    ephemeralKeySecret: response.ephemeralKeySecret
                )

                let result = await StripePaymentManager.shared.presentPaymentSheet()
                StripePaymentManager.shared.reset()

                switch result {
                case .completed:
                    // Refresh the list
                    await fetchPaymentMethods()
                case .canceled:
                    break
                case .failed(let error):
                    errorMessage = error.localizedDescription
                }

                isAdding = false
            } catch {
                isAdding = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func removeCard(_ paymentMethodId: String) {
        Task {
            do {
                struct RemoveInput: Codable { let paymentMethodId: String }
                struct RemoveResponse: Codable { let success: Bool }

                let _: RemoveResponse = try await TRPCClient.shared.call(
                    router: "paymentMethods",
                    procedure: "remove",
                    input: RemoveInput(paymentMethodId: paymentMethodId)
                )

                paymentMethods.removeAll { $0.id == paymentMethodId }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func setDefault(_ paymentMethodId: String) {
        Task {
            do {
                struct DefaultInput: Codable { let paymentMethodId: String }
                struct DefaultResponse: Codable { let success: Bool }

                let _: DefaultResponse = try await TRPCClient.shared.call(
                    router: "paymentMethods",
                    procedure: "setDefault",
                    input: DefaultInput(paymentMethodId: paymentMethodId)
                )

                // Update local state
                for i in paymentMethods.indices {
                    paymentMethods[i].isDefault = paymentMethods[i].id == paymentMethodId
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Saved Card Model

struct SavedCard: Codable, Identifiable {
    let id: String
    let brand: String
    let last4: String
    let expMonth: Int
    let expYear: Int
    var isDefault: Bool

    var brandIcon: String {
        switch brand.lowercased() {
        case "visa": return "creditcard.fill"
        case "mastercard": return "creditcard.fill"
        case "amex": return "creditcard.fill"
        default: return "creditcard.fill"
        }
    }

    var displayBrand: String {
        switch brand.lowercased() {
        case "visa": return "Visa"
        case "mastercard": return "Mastercard"
        case "amex": return "Amex"
        case "discover": return "Discover"
        default: return brand.capitalized
        }
    }
}

// MARK: - Saved Card Row

private struct SavedCardRow: View {
    let card: SavedCard
    let onRemove: () -> Void
    let onSetDefault: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 44, height: 30)

                Image(systemName: card.brandIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    HXText("\(card.displayBrand) ···· \(card.last4)", style: .body)
                    if card.isDefault {
                        Text("Default")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.brandPurple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brandPurple.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                HXText("Expires \(String(format: "%02d", card.expMonth))/\(String(card.expYear).suffix(2))", style: .caption, color: .textSecondary)
            }

            Spacer()

            Menu {
                if !card.isDefault {
                    Button { onSetDefault() } label: {
                        Label("Set as Default", systemImage: "star")
                    }
                }
                Button(role: .destructive) { onRemove() } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textTertiary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(16)
    }
}

// MARK: - Balance Card
private struct BalanceCard: View {
    let user: HXUser

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                HXText("Total Earnings", style: .caption, color: .textSecondary)
                HXText(String(format: "$%.2f", user.totalEarnings), style: .largeTitle, color: .moneyGreen)
            }

            HXDivider()

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    HXText("Tasks Done", style: .caption, color: .textTertiary)
                    HXText("\(user.tasksCompleted)", style: .headline)
                }

                VStack(spacing: 4) {
                    HXText("XP", style: .caption, color: .textTertiary)
                    HXText("\(user.xp)", style: .headline)
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.surfaceElevated, Color.moneyGreen.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Empty Payment Method Row
private struct EmptyPaymentMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.brandPurple.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.brandPurple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.brandPurple)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - History Row
private struct HistoryRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.textSecondary.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $isPresented) {
            TransactionHistoryView()
        }
    }
}

// MARK: - Transaction History View
private struct TransactionHistoryView: View {
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            VStack {
                EmptyState(
                    icon: "clock.arrow.circlepath",
                    title: "No Transactions Yet",
                    message: "Your payment history will appear here."
                )
            }
        }
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PaymentSettingsScreen()
    }
    .environment(LiveDataService.shared)
}
