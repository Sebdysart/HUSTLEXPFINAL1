//
//  TaxPaymentScreen.swift
//  hustleXP final1
//
//  Screen: Tax Payment
//  Pay outstanding XP tax balance
//

import SwiftUI
import StripePaymentSheet

struct TaxPaymentScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    // v2.2.0: Real API services
    @StateObject private var taxService = TaxService.shared

    @State private var isProcessingPayment = false
    @State private var showSuccess = false
    @State private var paymentResult: TaxPaymentResult?
    @State private var paymentError: String?

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if showSuccess, let result = paymentResult {
                successView(result: result)
            } else {
                paymentView
            }
        }
        .navigationTitle("Pay Tax")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Payment View
    
    private var paymentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Tax breakdown
                taxBreakdownSection
                
                // History
                historySection
                
                // Info box
                infoSection
                
                Spacer(minLength: 120)
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            payButton
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Warning icon
            ZStack {
                Circle()
                    .fill(Color.taxWarning.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.taxWarning)
            }
            
            VStack(spacing: 8) {
                HXText("XP Tax Balance", style: .title2)
                HXText("Pay to unlock your earned XP", style: .subheadline, color: .textSecondary)
            }
            
            // Amount
            Text(dataService.taxStatus.formattedUnpaidAmount)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Color.taxWarning)
            
            // XP held
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                
                Text("\(dataService.taxStatus.xpHeldBack) XP locked")
                    .font(.headline)
            }
            .foregroundStyle(Color.brandPurple)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.brandPurple.opacity(0.15))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Tax Breakdown Section
    
    private var taxBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Tax Breakdown", style: .caption, color: .textMuted)
            
            VStack(spacing: 0) {
                ForEach(dataService.taxHistory.filter { !$0.taxPaid }) { entry in
                    TaxEntryRow(entry: entry)
                    
                    if entry.id != dataService.taxHistory.filter({ !$0.taxPaid }).last?.id {
                        HXDivider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
    
    // MARK: - History Section
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Payment History", style: .caption, color: .textMuted)
                Spacer()
            }
            
            let paidEntries = dataService.taxHistory.filter { $0.taxPaid }
            
            if paidEntries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundStyle(Color.textMuted)
                        HXText("No payment history yet", style: .caption, color: .textMuted)
                    }
                    Spacer()
                }
                .padding(24)
                .background(Color.surfaceElevated)
                .cornerRadius(16)
            } else {
                VStack(spacing: 0) {
                    ForEach(paidEntries) { entry in
                        TaxEntryRow(entry: entry, showPaidBadge: true)
                        
                        if entry.id != paidEntries.last?.id {
                            HXDivider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color.surfaceElevated)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.infoBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                HXText("Why do I owe tax?", style: .subheadline)
                HXText(
                    "When you receive payments outside of escrow (cash, Venmo, Cash App), a 10% XP tax is applied. This helps maintain the integrity of the XP reward system.",
                    style: .caption,
                    color: .textSecondary
                )
            }
        }
        .padding(16)
        .background(Color.infoBlue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Pay Button

    private var payButton: some View {
        VStack(spacing: 8) {
            HXButton(
                isProcessingPayment ? "Processing..." : "Pay \(dataService.taxStatus.formattedUnpaidAmount)",
                icon: "creditcard.fill",
                variant: .primary,
                isLoading: isProcessingPayment
            ) {
                presentStripePayment()
            }
            .disabled(isProcessingPayment)

            if let error = paymentError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }

            HXText("Secure payment powered by Stripe", style: .caption, color: .textMuted)
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }

    // MARK: - Success View
    
    private func successView(result: TaxPaymentResult) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                HXText("Tax Paid!", style: .title)
                HXText("Your XP rewards are now unlocked", style: .body, color: .textSecondary, alignment: .center)
            }
            
            // XP released
            VStack(spacing: 8) {
                HXText("XP Released", style: .caption, color: .textMuted)
                
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundStyle(Color.brandPurple)
                    
                    Text("+\(result.xpReleased)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brandPurple)
                    
                    Text("XP")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(24)
            .background(Color.brandPurple.opacity(0.1))
            .cornerRadius(16)
            
            Spacer()
            
            HXButton("Back to Profile") {
                router.popHustler()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Actions

    private func presentStripePayment() {
        isProcessingPayment = true
        paymentError = nil

        Task {
            do {
                // 1. Create payment intent via TaxService
                let paymentIntent = try await taxService.createTaxPaymentIntent()
                print("✅ TaxPayment: Payment intent created - \(paymentIntent.paymentIntentId)")

                // 2. Prepare and present real Stripe PaymentSheet
                let stripeManager = StripePaymentManager.shared
                stripeManager.preparePaymentSheet(clientSecret: paymentIntent.clientSecret)

                let result = await stripeManager.presentPaymentSheet()

                switch result {
                case .completed:
                    // 3. Payment succeeded - confirm with backend
                    print("✅ TaxPayment: Stripe payment completed")

                    do {
                        let taxResult = try await taxService.payTax(paymentIntentId: paymentIntent.paymentIntentId)
                        print("✅ TaxPayment: Tax payment confirmed, released \(taxResult.xpReleased) XP")

                        // Also update mock data for consistency
                        let mockResult = dataService.payTax()
                        _ = mockResult // Keep mock data in sync

                        stripeManager.reset()
                        isProcessingPayment = false

                        withAnimation(.spring(response: 0.4)) {
                            paymentResult = taxResult
                            showSuccess = true
                        }
                    } catch {
                        print("⚠️ TaxPayment: Backend confirm failed - \(error.localizedDescription)")
                        // Payment went through but backend confirm failed
                        // Webhook will reconcile; show success with mock data
                        let mockResult = dataService.payTax()

                        stripeManager.reset()
                        isProcessingPayment = false

                        withAnimation(.spring(response: 0.4)) {
                            paymentResult = mockResult
                            showSuccess = true
                        }
                    }

                case .canceled:
                    print("⚠️ TaxPayment: Payment canceled by user")
                    stripeManager.reset()
                    isProcessingPayment = false

                case .failed(error: let error):
                    print("⚠️ TaxPayment: Stripe payment failed - \(error.localizedDescription)")
                    stripeManager.reset()
                    isProcessingPayment = false
                    paymentError = "Payment failed. Please try again."
                }

            } catch {
                print("⚠️ TaxPayment: Failed to create payment intent - \(error.localizedDescription)")
                isProcessingPayment = false
                paymentError = "Could not start payment. Please try again."
            }
        }
    }
}

// MARK: - Tax Entry Row

private struct TaxEntryRow: View {
    let entry: TaxLedgerEntry
    var showPaidBadge: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Payment method icon
            ZStack {
                Circle()
                    .fill(entry.paymentMethod.incursTax ? Color.taxWarning.opacity(0.15) : Color.successGreen.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: entry.paymentMethod.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(entry.paymentMethod.incursTax ? Color.taxWarning : Color.successGreen)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(entry.taskTitle, style: .subheadline)
                
                HStack(spacing: 6) {
                    Text(entry.paymentMethod.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                    
                    Text(formatDate(entry.createdAt))
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.formattedTaxAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(showPaidBadge ? Color.successGreen : Color.taxWarning)
                
                if showPaidBadge {
                    Text("Paid")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.successGreen)
                } else {
                    Text("10% of \(entry.formattedGrossPayout)")
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .padding(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        TaxPaymentScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
