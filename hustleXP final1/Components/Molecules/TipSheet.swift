//
//  TipSheet.swift
//  hustleXP final1
//
//  Post-completion tipping sheet for posters
//

import SwiftUI

struct TipSheet: View {
    let taskId: String
    let taskPrice: Int // cents
    let workerName: String
    let onTip: (Int) -> Void
    let onDismiss: () -> Void

    @State private var selectedAmount: Int? = nil
    @State private var customAmount: String = ""
    @State private var isProcessing = false

    private let presetPercentages = [10, 15, 20, 25]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.brandPurple)

                Text("Tip \(workerName)?")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textPrimary)

                Text("100% of tips go directly to the hustler")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 8)

            // Preset amounts
            HStack(spacing: 10) {
                ForEach(presetPercentages, id: \.self) { pct in
                    let amount = max(100, Int(Double(taskPrice) * Double(pct) / 100.0))
                    Button {
                        selectedAmount = amount
                        customAmount = ""
                    } label: {
                        VStack(spacing: 4) {
                            Text("$\(String(format: "%.2f", Double(amount) / 100.0))")
                                .font(.headline)
                            Text("\(pct)%")
                                .font(.caption2)
                                .foregroundColor(selectedAmount == amount ? .white.opacity(0.7) : .textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedAmount == amount ? Color.brandPurple : Color.surfaceElevated)
                        .foregroundColor(selectedAmount == amount ? .white : .textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            // Custom amount
            HStack {
                Text("$")
                    .foregroundColor(.textSecondary)
                TextField("Custom", text: $customAmount)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color.textPrimary)
                    .onChange(of: customAmount) { _, _ in
                        selectedAmount = nil
                    }
            }
            .padding(12)
            .background(Color.surfaceDefault)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Submit
            Button {
                isProcessing = true
                let amount = tipAmount
                if amount >= 100 {
                    onTip(amount)
                }
            } label: {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Send Tip")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(tipAmount >= 100 ? Color.brandPurple : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(tipAmount < 100 || isProcessing)

            // Skip
            Button {
                onDismiss()
            } label: {
                Text("Skip")
                    .font(.subheadline)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(24)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private var tipAmount: Int {
        selectedAmount ?? Int((Double(customAmount) ?? 0) * 100)
    }
}
