//
//  TierProgressCard.swift
//  hustleXP final1
//
//  Molecule: Tier Progress Card
//  Shows current tier, XP progress bar toward next tier, and XP stats
//

import SwiftUI

struct TierProgressCard: View {
    let tier: TrustTier
    let xp: Int
    let xpProgress: Double
    let xpToNextTier: Int

    /// XP remaining until the next tier threshold
    private var xpRemaining: Int {
        max(xpToNextTier - xp, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: tier badge + XP remaining label
            HStack {
                HXBadge(variant: .tier(tier))
                Spacer()
                if tier != .master {
                    HXText(
                        "\(xpRemaining) XP to \(tier.nextTierName)",
                        style: .caption,
                        color: .textSecondary
                    )
                } else {
                    HXText("Max Tier Reached", style: .caption, color: .brandPurple)
                }
            }

            // Progress bar (hidden at max tier)
            if tier != .master {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.surfaceSecondary)
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [tier.color, tier.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * max(0.02, min(xpProgress, 1.0)),
                                height: 10
                            )
                            .animation(.easeInOut(duration: 0.5), value: xpProgress)
                    }
                }
                .frame(height: 10)
            }

            // Footer: total XP + percentage
            HStack {
                HXText("\(xp) XP total", style: .caption, color: .textTertiary)
                Spacer()
                if tier != .master {
                    HXText(
                        "\(Int(min(xpProgress, 1.0) * 100))%",
                        style: .caption,
                        color: .textSecondary
                    )
                }
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            tier != .master
                ? "\(tier.name) tier, \(xp) XP, \(Int(min(xpProgress, 1.0) * 100)) percent toward \(tier.nextTierName)"
                : "Master tier, \(xp) XP, maximum tier reached"
        )
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        VStack(spacing: 16) {
            TierProgressCard(tier: .rookie, xp: 45, xpProgress: 0.45, xpToNextTier: 100)
            TierProgressCard(tier: .verified, xp: 180, xpProgress: 0.4, xpToNextTier: 300)
            TierProgressCard(tier: .elite, xp: 820, xpProgress: 0.55, xpToNextTier: 1000)
            TierProgressCard(tier: .master, xp: 1500, xpProgress: 1.0, xpToNextTier: 0)
        }
        .padding(24)
    }
}
