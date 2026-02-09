//
//  PriceDisplay.swift
//  hustleXP final1
//
//  Molecule: PriceDisplay
//  Shows amount, currency, and status
//

import SwiftUI

enum PriceDisplaySize {
    case small
    case medium
    case large
    
    var amountStyle: HXTextStyle {
        switch self {
        case .small: return .headline
        case .medium: return .title2
        case .large: return .largeTitle
        }
    }
    
    var labelStyle: HXTextStyle {
        switch self {
        case .small: return .caption
        case .medium: return .subheadline
        case .large: return .body
        }
    }
}

struct PriceDisplay: View {
    let amount: Double
    let label: String?
    let size: PriceDisplaySize
    let color: Color
    
    init(
        amount: Double,
        label: String? = nil,
        size: PriceDisplaySize = .medium,
        color: Color = .moneyGreen
    ) {
        self.amount = amount
        self.label = label
        self.size = size
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text("$")
                    .font(size.amountStyle.font)
                    .foregroundStyle(color)
                
                Text(formattedAmount)
                    .font(size.amountStyle.font)
                    .foregroundStyle(color)
            }
            
            if let label = label {
                HXText(label, style: size.labelStyle, color: .textSecondary)
            }
        }
    }
    
    private var formattedAmount: String {
        if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        }
        return String(format: "%.2f", amount)
    }
}

#Preview {
    VStack(spacing: 24) {
        PriceDisplay(amount: 25.00, label: "Task Payment", size: .small)
        PriceDisplay(amount: 150.50, label: "Earnings", size: .medium)
        PriceDisplay(amount: 1250.00, label: "Total", size: .large)
    }
    .padding()
}
