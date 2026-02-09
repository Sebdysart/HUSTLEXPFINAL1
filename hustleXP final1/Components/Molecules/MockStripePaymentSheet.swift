//
//  MockStripePaymentSheet.swift
//  hustleXP final1
//
//  Molecule: Mock Stripe Payment Sheet
//  Simulates Stripe's payment UI for prototyping
//

import SwiftUI

struct MockStripePaymentSheet: View {
    let amount: Int // in cents
    let onPaymentComplete: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvc: String = ""
    @State private var isProcessing: Bool = false
    @State private var showSuccess: Bool = false
    @FocusState private var focusedField: PaymentField?
    
    private enum PaymentField {
        case cardNumber, expiry, cvc
    }
    
    private var formattedAmount: String {
        let dollars = Double(amount) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    private var isValid: Bool {
        cardNumber.count >= 16 && expiryDate.count >= 4 && cvc.count >= 3
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                
                if showSuccess {
                    successView
                } else {
                    paymentFormView
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Payment Form
    
    private var paymentFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Amount header
                VStack(spacing: 8) {
                    Text("Pay")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    
                    Text(formattedAmount)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.top, 20)
                
                // Apple Pay button (visual only)
                applePayButton
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.borderSubtle)
                        .frame(height: 1)
                    
                    Text("Or pay with card")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    
                    Rectangle()
                        .fill(Color.borderSubtle)
                        .frame(height: 1)
                }
                .padding(.vertical, 8)
                
                // Card form
                cardForm
                
                Spacer(minLength: 100)
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            payButton
        }
    }
    
    // MARK: - Apple Pay Button
    
    private var applePayButton: some View {
        Button(action: {
            processPayment()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18))
                Text("Pay")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Card Form
    
    private var cardForm: some View {
        VStack(spacing: 16) {
            // Card number
            VStack(alignment: .leading, spacing: 8) {
                Text("Card number")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "creditcard")
                        .foregroundStyle(Color.textMuted)
                    
                    TextField("", text: $cardNumber, prompt: Text("1234 5678 9012 3456").foregroundColor(.textMuted))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .cardNumber)
                        .onChange(of: cardNumber) { _, newValue in
                            cardNumber = formatCardNumber(newValue)
                        }
                }
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .padding(16)
                .background(Color.surfaceElevated)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .cardNumber ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                )
            }
            
            // Expiry and CVC row
            HStack(spacing: 12) {
                // Expiry
                VStack(alignment: .leading, spacing: 8) {
                    Text("Expiry")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    
                    TextField("", text: $expiryDate, prompt: Text("MM/YY").foregroundColor(.textMuted))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .expiry)
                        .onChange(of: expiryDate) { _, newValue in
                            expiryDate = formatExpiry(newValue)
                        }
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)
                        .padding(16)
                        .background(Color.surfaceElevated)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .expiry ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                        )
                }
                
                // CVC
                VStack(alignment: .leading, spacing: 8) {
                    Text("CVC")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    
                    HStack {
                        TextField("", text: $cvc, prompt: Text("123").foregroundColor(.textMuted))
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .cvc)
                            .onChange(of: cvc) { _, newValue in
                                cvc = String(newValue.prefix(4))
                            }
                        
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(Color.textMuted)
                    }
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .padding(16)
                    .background(Color.surfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .cvc ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                    )
                }
            }
            
            // Security note
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("Your payment info is secure")
                    .font(.caption)
            }
            .foregroundStyle(Color.textMuted)
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Pay Button
    
    private var payButton: some View {
        VStack(spacing: 8) {
            HXButton(
                isProcessing ? "Processing..." : "Pay \(formattedAmount)",
                variant: isValid ? .primary : .secondary,
                isLoading: isProcessing
            ) {
                processPayment()
            }
            .disabled(!isValid || isProcessing)
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Success View
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                HXText("Payment Successful!", style: .title)
                HXText(formattedAmount, style: .largeTitle, color: .successGreen)
            }
            
            Spacer()
            
            HXButton("Done") {
                onPaymentComplete(true)
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Helpers
    
    private func formatCardNumber(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        let limited = String(cleaned.prefix(16))
        
        var formatted = ""
        for (index, char) in limited.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(char)
        }
        return formatted
    }
    
    private func formatExpiry(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        let limited = String(cleaned.prefix(4))
        
        if limited.count > 2 {
            return "\(limited.prefix(2))/\(limited.suffix(from: limited.index(limited.startIndex, offsetBy: 2)))"
        }
        return limited
    }
    
    private func processPayment() {
        focusedField = nil
        isProcessing = true
        
        // Simulate payment processing (1.5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            withAnimation(.spring(response: 0.4)) {
                showSuccess = true
            }
        }
    }
}

#Preview {
    MockStripePaymentSheet(amount: 1500) { success in
        print("Payment completed: \(success)")
    }
}
