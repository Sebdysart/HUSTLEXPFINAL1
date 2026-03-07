//
//  PaywallSheet.swift
//  hustleXP final1
//
//  Subscription upsell bottom sheet shown when a user cannot create more recurring tasks.
//  Two contexts:
//   - .freeUser: No subscription — prompt to subscribe to Premium or Pro
//   - .premiumAtLimit: Premium plan, 5/5 slots used — prompt to upgrade to Pro
//

import SwiftUI

struct PaywallSheet: View {
    enum Context {
        case freeUser
        case premiumAtLimit
    }

    let context: Context
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
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(iconColor)
            }

            Spacer().frame(height: 20)

            // Title + subtitle
            VStack(spacing: 8) {
                Text(titleText)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 8)

            Spacer().frame(height: 24)

            // Plan teasers
            VStack(spacing: 10) {
                switch context {
                case .freeUser:
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
                case .premiumAtLimit:
                    planRow(
                        icon: "bolt.circle.fill",
                        name: "Pro",
                        detail: "Unlimited recurring tasks",
                        price: "$19.99/mo",
                        color: Color.aiPurple
                    )
                }
            }

            Spacer().frame(height: 28)

            // CTAs
            VStack(spacing: 12) {
                HXButton(ctaLabel, icon: "arrow.right", variant: .primary) {
                    onViewPlans()
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Not Now")
                        .font(.subheadline)
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("Dismiss paywall")
            }

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Color.surfaceElevated)
    }

    // MARK: - Context-Derived Properties

    private var iconName: String {
        switch context {
        case .freeUser:     return "repeat.circle.fill"
        case .premiumAtLimit: return "bolt.circle.fill"
        }
    }

    private var iconColor: Color {
        switch context {
        case .freeUser:     return Color.recurringBlue
        case .premiumAtLimit: return Color.aiPurple
        }
    }

    private var titleText: String {
        switch context {
        case .freeUser:     return "Unlock Recurring Tasks"
        case .premiumAtLimit: return "Upgrade to Pro"
        }
    }

    private var subtitleText: String {
        switch context {
        case .freeUser:
            return "Subscribe to schedule tasks that repeat automatically and save time on regular help."
        case .premiumAtLimit:
            return "You've used all 5 Premium slots. Upgrade to Pro for unlimited recurring tasks."
        }
    }

    private var ctaLabel: String {
        switch context {
        case .freeUser:     return "View Plans"
        case .premiumAtLimit: return "Upgrade to Pro"
        }
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
                    .foregroundStyle(Color.textPrimary)

                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(price)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(14)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Free User") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        PaywallSheet(context: .freeUser, onViewPlans: {}, onDismiss: {})
            .padding(.horizontal, 4)
    }
}

#Preview("Premium at Limit") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        PaywallSheet(context: .premiumAtLimit, onViewPlans: {}, onDismiss: {})
            .padding(.horizontal, 4)
    }
}
