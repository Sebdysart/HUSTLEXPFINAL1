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

    // Balance & cash out
    @State private var availableCents: Int = 0
    @State private var pendingCents: Int = 0
    @State private var isCashingOut = false
    @State private var showCashOutConfirm = false
    @State private var cashOutSuccess = false
    @State private var connectSetup = false

    private var isHustler: Bool {
        dataService.currentUser.role == .hustler
    }

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Test mode banner — visible to all users when Stripe is in test mode
                    if AppConfig.isStripeTestMode {
                        testModeBanner
                    }

                    if isHustler {
                        // Hustler: balance + payout setup — set up bank account via Stripe onboarding
                        balanceCard

                        payoutSection
                    } else {
                        // Poster: payment methods for funding tasks
                        paymentMethodsSection

                        addCardButton

                        // Test mode helper: show test cards in test mode
                        if AppConfig.isStripeTestMode {
                            testCardsSection
                        }
                    }

                    // Both roles: transaction history
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
        .task {
            await fetchPaymentMethods()
            await fetchBalance()
        }
        .alert("Cash Out", isPresented: $showCashOutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Cash Out \(formatCents(availableCents))") { cashOut() }
        } message: {
            Text("Transfer \(formatCents(availableCents)) to your bank account? Standard payouts arrive in 1-2 business days.")
        }
        .alert("Cash Out Successful", isPresented: $cashOutSuccess) {
            Button("OK") {}
        } message: {
            Text("Your payout has been submitted. Funds will arrive in 1-2 business days.")
        }
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

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                HXText("Available Balance", style: .caption, color: .textSecondary)
                HXText(formatCents(availableCents), style: .largeTitle, color: .moneyGreen)
            }

            HXDivider()

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    HXText("Pending", style: .caption, color: .textTertiary)
                    HXText(formatCents(pendingCents), style: .headline)
                }

                VStack(spacing: 4) {
                    HXText("Lifetime", style: .caption, color: .textTertiary)
                    HXText(String(format: "$%.2f", dataService.currentUser.totalEarnings), style: .headline)
                }
            }

            if connectSetup && availableCents > 0 {
                Button {
                    showCashOutConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        if isCashingOut {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Cash Out \(formatCents(availableCents))")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.moneyGreen, in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isCashingOut)
            } else if !connectSetup {
                Button { openStripeDashboard() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 14))
                        Text("Set Up Payouts")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.brandPurple, in: RoundedRectangle(cornerRadius: 12))
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

    // MARK: - Payout Section

    private var payoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Payout", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            Button { openStripeDashboard() } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.brandPurple)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HXText(connectSetup ? "Manage Payout Settings" : "Set Up Bank Account", style: .body)
                        HXText(connectSetup ? "Change payout schedule or method" : "Connect a bank to receive payouts", style: .caption, color: .textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
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

    // MARK: - Test Mode

    /// Banner shown at top of screen when in Stripe test mode
    private var testModeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "flask.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.warningOrange)

            VStack(alignment: .leading, spacing: 2) {
                HXText("Test Mode", style: .subheadline, color: .warningOrange)
                HXText("No real money will be charged or transferred.", style: .caption, color: .textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warningOrange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                )
        )
    }

    /// Test card numbers (poster only) — tap to copy
    private var testCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Test Cards", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(AppConfig.TestCard.allCases.enumerated()), id: \.offset) { index, card in
                    Button {
                        UIPasteboard.general.string = card.rawNumber
                        errorMessage = "Copied \(card.label) to clipboard"
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            await MainActor.run { errorMessage = nil }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.brandPurple)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                HXText(card.label, style: .subheadline)
                                HXText(card.rawValue, style: .caption, color: .textTertiary)
                            }

                            Spacer()

                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textTertiary)
                        }
                        .padding(14)
                    }
                    .buttonStyle(.plain)

                    if index < AppConfig.TestCard.allCases.count - 1 {
                        Divider().background(Color.borderSubtle).padding(.leading, 50)
                    }
                }
            }
            .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))

            HXText("Use any future expiry (e.g. 12/30) and any 3-digit CVC.", style: .caption2, color: .textTertiary)
                .padding(.leading, 4)
        }
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
                }

                print("🔵 [Payment] Calling createSetupIntent...")
                let response: SetupResponse = try await TRPCClient.shared.call(
                    router: "paymentMethods",
                    procedure: "createSetupIntent",
                    input: EmptyInput()
                )

                // Log the client secret prefix to verify it matches the publishable key's account
                let secretPrefix = String(response.clientSecret.prefix(25))
                let pubKeyPrefix = String((StripeAPI.defaultPublishableKey ?? "NOT SET").prefix(20))
                print("🔵 [Payment] SetupIntent clientSecret prefix: \(secretPrefix)...")
                print("🔵 [Payment] Publishable key prefix: \(pubKeyPrefix)...")
                print("🔵 [Payment] Preparing PaymentSheet...")

                // Present Stripe PaymentSheet for adding card
                StripePaymentManager.shared.prepareSetupSheet(
                    clientSecret: response.clientSecret
                )

                print("🔵 [Payment] Presenting PaymentSheet...")
                let result = await StripePaymentManager.shared.presentPaymentSheet()
                StripePaymentManager.shared.reset()

                switch result {
                case .completed:
                    print("🔵 [Payment] PaymentSheet completed successfully")
                    await fetchPaymentMethods()
                case .canceled:
                    print("🔵 [Payment] PaymentSheet canceled by user")
                case .failed(let error):
                    print("🔵 [Payment] PaymentSheet FAILED: \(error.localizedDescription)")
                    print("🔵 [Payment] Full error: \(error)")
                    errorMessage = error.localizedDescription
                }

                isAdding = false
            } catch {
                print("🔵 [Payment] createSetupIntent call FAILED: \(error)")
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

    private func fetchBalance() async {
        struct EmptyInput: Codable {}
        struct BalanceResponse: Codable {
            let availableCents: Int
            let pendingCents: Int
        }

        do {
            let balance: BalanceResponse = try await TRPCClient.shared.call(
                router: "stripeConnect",
                procedure: "getBalance",
                type: .query,
                input: EmptyInput()
            )
            availableCents = balance.availableCents
            pendingCents = balance.pendingCents
            connectSetup = true
        } catch {
            // Connect not set up or error — show 0 balance
            connectSetup = false
        }
    }

    private func cashOut() {
        guard availableCents > 0 else { return }
        isCashingOut = true
        errorMessage = nil

        Task {
            do {
                struct PayoutInput: Codable {
                    let amountCents: Int
                    let method: String
                }
                struct PayoutResponse: Codable {
                    let payoutId: String
                    let status: String
                }

                let _: PayoutResponse = try await TRPCClient.shared.call(
                    router: "stripeConnect",
                    procedure: "requestPayout",
                    input: PayoutInput(amountCents: availableCents, method: "standard")
                )

                isCashingOut = false
                cashOutSuccess = true
                // Refresh balance
                await fetchBalance()
            } catch {
                isCashingOut = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func openStripeDashboard() {
        Task {
            // Step 1: Check onboarding status first
            struct EmptyInput: Codable {}
            struct StatusResponse: Codable {
                let onboardingComplete: Bool?
                let detailsSubmitted: Bool?
                let payoutsEnabled: Bool?
                let chargesEnabled: Bool?
            }

            var isComplete = false
            do {
                let status: StatusResponse = try await TRPCClient.shared.call(
                    router: "stripeConnect",
                    procedure: "getOnboardingStatus",
                    type: .query,
                    input: EmptyInput()
                )
                isComplete = status.payoutsEnabled == true && status.detailsSubmitted == true
                HXLogger.info("PaymentSettings: Onboarding status — complete=\(isComplete), payouts=\(status.payoutsEnabled ?? false)", category: "Payment")
            } catch {
                // No Connect account exists — go straight to onboarding
                HXLogger.info("PaymentSettings: No Connect account yet — starting onboarding", category: "Payment")
                await startStripeOnboarding()
                return
            }

            // Step 2: If onboarding complete, open Express dashboard. Otherwise, continue onboarding.
            if isComplete {
                await openExpressDashboard()
            } else {
                HXLogger.info("PaymentSettings: Onboarding incomplete — resuming setup", category: "Payment")
                await startStripeOnboarding()
            }
        }
    }

    private func openExpressDashboard() async {
        do {
            struct EmptyInput: Codable {}
            struct LinkResponse: Codable {
                let url: String
            }

            let response: LinkResponse = try await TRPCClient.shared.call(
                router: "stripeConnect",
                procedure: "getDashboardLink",
                type: .query,
                input: EmptyInput()
            )

            HXLogger.info("PaymentSettings: Opening Express dashboard - \(response.url.prefix(50))...", category: "Payment")

            if let url = URL(string: response.url) {
                await UIApplication.shared.open(url)
            }
        } catch {
            HXLogger.error("PaymentSettings: Dashboard link failed - \(error.localizedDescription)", category: "Payment")
            await openFallbackPayoutHelp(reason: error.localizedDescription)
        }
    }

    private func startStripeOnboarding() async {
        do {
            struct OnboardingInput: Codable {
                let refreshUrl: String
                let returnUrl: String
                let collectTaxInfo: Bool
            }
            struct OnboardingResponse: Codable {
                let url: String
            }

            let response: OnboardingResponse = try await TRPCClient.shared.call(
                router: "stripeConnect",
                procedure: "createOnboardingLink",
                input: OnboardingInput(
                    refreshUrl: "https://hustlexp.app/settings/payments?refresh=1",
                    returnUrl: "https://hustlexp.app/settings/payments?return=1",
                    collectTaxInfo: true
                )
            )

            if let url = URL(string: response.url) {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        } catch {
            HXLogger.error("PaymentSettings: Onboarding failed - \(error.localizedDescription)", category: "Payment")
            // Fallback: open Stripe Express help page so the user isn't stuck
            await openFallbackPayoutHelp(reason: error.localizedDescription)
        }
    }

    /// Opens a fallback web page when both Stripe API calls fail.
    /// Lets the user understand the issue and provides a path to set up payouts manually.
    @MainActor
    private func openFallbackPayoutHelp(reason: String) async {
        errorMessage = "Couldn't connect to Stripe. Opening setup info..."

        // Open Stripe Connect Express info page as a safe fallback
        if let url = URL(string: "https://stripe.com/connect/express") {
            await UIApplication.shared.open(url)
        }

        // Clear error after brief delay so user has time to read it
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        errorMessage = nil
    }

    private func formatCents(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
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
