//
//  PaywallSheet.swift
//  hustleXP final1
//
//  Subscription upsell bottom sheet shown when a free user attempts
//  to use a subscription-gated feature (recurring tasks).
//

import SwiftUI

struct PaywallSheet: View {
    let onViewPlans: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.textTertiary)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Icon
            ZStack {
                Circle()
                    .fill(Color.recurringBlue.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "repeat.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.recurringBlue)
            }

            Spacer().frame(height: 20)

            // Title
            VStack(spacing: 8) {
                Text("Unlock Recurring Tasks")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textPrimary)

                Text("Subscribe to schedule tasks that repeat automatically and save time on regular help.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 8)

            Spacer().frame(height: 24)

            // Plan teasers
            VStack(spacing: 10) {
                planRow(
                    icon: "star.circle.fill",
                    name: "Premium",
                    detail: "Up to 5 recurring tasks",
                    price: "$9.99/mo",
                    color: Color.brandPurple
                )
                planRow(
                    icon: "bolt.circle.fill",
                    name: "Pro",
                    detail: "Unlimited recurring tasks",
                    price: "$19.99/mo",
                    color: Color.aiPurple
                )
            }

            Spacer().frame(height: 28)

            // CTAs
            VStack(spacing: 12) {
                HXButton("View Plans", icon: "arrow.right", variant: .primary) {
                    onViewPlans()
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Not Now")
                        .font(.subheadline)
                        .foregroundColor(.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("Dismiss subscription paywall")
            }

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.surfaceElevated)
    }

    // MARK: - Plan Row

    private func planRow(icon: String, name: String, detail: String, price: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Text(price)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .padding(14)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        PaywallSheet(onViewPlans: {}, onDismiss: {})
            .padding(.horizontal, 4)
    }
}
