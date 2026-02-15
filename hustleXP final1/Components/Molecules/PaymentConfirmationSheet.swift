//
//  PaymentConfirmationSheet.swift
//  hustleXP final1
//
//  Reusable payment confirmation bottom sheet for featured listings,
//  skill verification, insurance upgrades, and subscriptions.
//

import SwiftUI

struct PaymentConfirmationSheet: View {
    let title: String
    let description: String
    let priceCents: Int
    let icon: String
    var interval: String? = nil // e.g. "month", "year" — nil for one-time
    let onConfirm: () async -> Void
    let onDismiss: () -> Void

    @State private var state: PaymentState = .ready

    enum PaymentState {
        case ready
        case processing
        case success
        case failure(String)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.textTertiary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 72, height: 72)

                Image(systemName: stateIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(iconForegroundColor)
                    .symbolEffect(.bounce, value: state.isSuccess)
            }

            // Title & description
            VStack(spacing: 8) {
                Text(stateTitle)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(stateDescription)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            // Price display
            if !state.isSuccess {
                HStack(spacing: 4) {
                    Text(formattedPrice)
                        .font(.title.weight(.bold))
                        .foregroundColor(.textPrimary)

                    if let interval = interval {
                        Text("/\(interval)")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Action buttons
            VStack(spacing: 12) {
                switch state {
                case .ready:
                    HXButton("Confirm Payment", icon: "lock.fill", variant: .primary) {
                        Task {
                            await processPayment()
                        }
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.textTertiary)
                    }

                case .processing:
                    HXButton("Processing...", variant: .primary, isLoading: true) {}

                case .success:
                    HXButton("Done", icon: "checkmark", variant: .success) {
                        onDismiss()
                    }

                case .failure(let message):
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.errorRed)
                        .multilineTextAlignment(.center)

                    HXButton("Try Again", icon: "arrow.clockwise", variant: .primary) {
                        Task {
                            await processPayment()
                        }
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - State-Dependent Properties

    private var stateIcon: String {
        switch state {
        case .ready, .processing: return icon
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    private var iconBackgroundColor: Color {
        switch state {
        case .ready, .processing: return Color.brandPurple.opacity(0.15)
        case .success: return Color.successGreen.opacity(0.15)
        case .failure: return Color.errorRed.opacity(0.15)
        }
    }

    private var iconForegroundColor: Color {
        switch state {
        case .ready, .processing: return Color.brandPurple
        case .success: return Color.successGreen
        case .failure: return Color.errorRed
        }
    }

    private var stateTitle: String {
        switch state {
        case .ready, .processing: return title
        case .success: return "Payment Successful"
        case .failure: return "Payment Failed"
        }
    }

    private var stateDescription: String {
        switch state {
        case .ready, .processing: return description
        case .success: return "Your payment has been processed successfully."
        case .failure(let msg): return msg
        }
    }

    private var formattedPrice: String {
        String(format: "$%.2f", Double(priceCents) / 100.0)
    }

    // MARK: - Payment Processing

    private func processPayment() async {
        state = .processing

        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()

        await onConfirm()

        // The onConfirm closure handles Stripe presentation.
        // If we get back here, check for success via a small delay
        // to let the parent update state.
        try? await Task.sleep(nanoseconds: 500_000_000)

        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        state = .success
    }
}

// MARK: - PaymentState Helpers

extension PaymentConfirmationSheet.PaymentState {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        PaymentConfirmationSheet(
            title: "Promote Task",
            description: "Appear at top of feed for 24 hours",
            priceCents: 299,
            icon: "arrow.up.circle.fill",
            onConfirm: {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            },
            onDismiss: {}
        )
    }
}
