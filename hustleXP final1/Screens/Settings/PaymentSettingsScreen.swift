//
//  PaymentSettingsScreen.swift
//  hustleXP final1
//
//  Archetype: D (Calibration/Capability)
//

import SwiftUI

struct PaymentSettingsScreen: View {
    @State private var showAddPaymentMethod = false
    @State private var showAddBankAccount = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Balance card
                    BalanceCard()
                    
                    // Payment Methods Section
                    VStack(alignment: .leading, spacing: 12) {
                        HXText("Payment Methods", style: .caption, color: .textSecondary)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            // Empty state or cards
                            EmptyPaymentMethodRow(
                                icon: "creditcard.fill",
                                title: "Add Payment Method",
                                subtitle: "Add a card to pay for tasks"
                            ) {
                                showAddPaymentMethod = true
                            }
                        }
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                    }
                    
                    // Payout Section
                    VStack(alignment: .leading, spacing: 12) {
                        HXText("Payout", style: .caption, color: .textSecondary)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            EmptyPaymentMethodRow(
                                icon: "building.columns.fill",
                                title: "Add Bank Account",
                                subtitle: "Connect a bank to receive payouts"
                            ) {
                                showAddBankAccount = true
                            }
                        }
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                    }
                    
                    // History Section
                    VStack(alignment: .leading, spacing: 12) {
                        HXText("History", style: .caption, color: .textSecondary)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            HistoryRow(
                                icon: "clock.arrow.circlepath",
                                title: "Transaction History",
                                subtitle: "View all payments and payouts"
                            )
                        }
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                    }
                    
                    // Security note
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(Color.successGreen)
                        
                        HXText(
                            "Your payment information is encrypted and securely stored using industry-standard security.",
                            style: .caption,
                            color: .textTertiary
                        )
                    }
                    .padding(16)
                }
                .padding(24)
            }
        }
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAddPaymentMethod) {
            AddPaymentMethodSheet()
        }
        .sheet(isPresented: $showAddBankAccount) {
            AddBankAccountSheet()
        }
    }
}

// MARK: - Balance Card
private struct BalanceCard: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                HXText("Available Balance", style: .caption, color: .textSecondary)
                HXText("$325.00", style: .largeTitle, color: .moneyGreen)
            }
            
            HXDivider()
            
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    HXText("Pending", style: .caption, color: .textTertiary)
                    HXText("$50.00", style: .headline)
                }
                
                VStack(spacing: 4) {
                    HXText("This Month", style: .caption, color: .textTertiary)
                    HXText("$475.00", style: .headline)
                }
            }
            
            HXButton("Cash Out", variant: .primary) {
                // Handle cash out
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
    
    var body: some View {
        NavigationLink(destination: TransactionHistoryView()) {
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

// MARK: - Add Payment Method Sheet
private struct AddPaymentMethodSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    HXText("Add a payment method to pay for tasks you post.", style: .body, color: .textSecondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        PaymentOptionRow(icon: "creditcard.fill", title: "Credit or Debit Card")
                        PaymentOptionRow(icon: "apple.logo", title: "Apple Pay")
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
}

// MARK: - Add Bank Account Sheet
private struct AddBankAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    HXText("Connect a bank account to receive payouts from completed tasks.", style: .body, color: .textSecondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        PaymentOptionRow(icon: "building.columns.fill", title: "Connect Bank Account")
                        PaymentOptionRow(icon: "link", title: "Link with Plaid")
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Add Bank Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
}

// MARK: - Payment Option Row
private struct PaymentOptionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 32)
                
                HXText(title, style: .body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PaymentSettingsScreen()
    }
}
