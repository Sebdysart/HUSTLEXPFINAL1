//
//  TaxBalanceCard.swift
//  hustleXP final1
//
//  Molecule: Tax Balance Warning Card
//  Shows unpaid tax balance with Pay Now CTA
//

import SwiftUI

struct TaxBalanceCard: View {
    let taxStatus: TaxStatus
    let onPayNow: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with warning icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.taxWarning.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.taxWarning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Unpaid Tax Balance", style: .headline)
                    HXText("XP rewards are blocked", style: .caption, color: .textSecondary)
                }
                
                Spacer()
            }
            
            // Amount display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(taxStatus.formattedUnpaidAmount)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.taxWarning)
                
                Text("owed")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            
            // XP held back indicator
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandPurple)
                
                Text("\(taxStatus.xpHeldBack) XP locked")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
            }
            .padding(12)
            .background(Color.brandPurple.opacity(0.1))
            .cornerRadius(10)
            
            // Pay Now button
            HXButton("Pay Now", variant: .primary, icon: "creditcard.fill") {
                onPayNow()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.taxWarning.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.taxWarning.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Compact Variant

struct TaxBalanceCardCompact: View {
    let taxStatus: TaxStatus
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.taxWarning.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.taxWarning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Tax Balance", style: .subheadline)
                    HXText("\(taxStatus.xpHeldBack) XP locked", style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                Text(taxStatus.formattedUnpaidAmount)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.taxWarning)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.taxWarning.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            TaxBalanceCard(
                taxStatus: TaxStatus(
                    unpaidTaxCents: 1500,
                    xpHeldBack: 150,
                    blocked: true,
                    lastPaymentAt: nil
                ),
                onPayNow: {}
            )
            
            TaxBalanceCardCompact(
                taxStatus: TaxStatus(
                    unpaidTaxCents: 1500,
                    xpHeldBack: 150,
                    blocked: true,
                    lastPaymentAt: nil
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
