//
//  TaxStatus.swift
//  hustleXP final1
//
//  XP Tax System models for v1.8.0
//

import Foundation

// MARK: - Tax Status

struct TaxStatus: Codable {
    let unpaidTaxCents: Int
    let xpHeldBack: Int
    let blocked: Bool
    let lastPaymentAt: Date?
    
    /// Formatted unpaid tax amount as dollars
    var formattedUnpaidAmount: String {
        let dollars = Double(unpaidTaxCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Check if user has any unpaid taxes
    var hasUnpaidTax: Bool {
        unpaidTaxCents > 0
    }
}

// MARK: - Tax Ledger Entry

struct TaxLedgerEntry: Identifiable, Codable {
    let id: String
    let taskId: String
    let taskTitle: String
    let paymentMethod: PaymentMethod
    let grossPayoutCents: Int
    let taxAmountCents: Int
    let taxPaid: Bool
    let paidAt: Date?
    let createdAt: Date
    
    /// Formatted gross payout as dollars
    var formattedGrossPayout: String {
        let dollars = Double(grossPayoutCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted tax amount as dollars
    var formattedTaxAmount: String {
        let dollars = Double(taxAmountCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable, CaseIterable {
    case offlineCash = "offline_cash"
    case offlineVenmo = "offline_venmo"
    case offlineCashApp = "offline_cashapp"
    case escrow
    
    var displayName: String {
        switch self {
        case .offlineCash: return "Cash"
        case .offlineVenmo: return "Venmo"
        case .offlineCashApp: return "Cash App"
        case .escrow: return "Escrow"
        }
    }
    
    var icon: String {
        switch self {
        case .offlineCash: return "banknote"
        case .offlineVenmo: return "v.circle.fill"
        case .offlineCashApp: return "dollarsign.square.fill"
        case .escrow: return "lock.shield.fill"
        }
    }
    
    /// Whether this payment method incurs XP tax
    var incursTax: Bool {
        switch self {
        case .escrow: return false
        default: return true
        }
    }
}

// MARK: - Tax Payment Result

struct TaxPaymentResult: Codable {
    let success: Bool
    let xpReleased: Int
    let newTaxStatus: TaxStatus
}
