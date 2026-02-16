//
//  HXBadge.swift
//  hustleXP final1
//
//  Atom: Badge
//  Premium badges with gradients, glows, and refined styling
//

import SwiftUI

enum HXBadgeVariant {
    case status(StatusType)
    case count(Int)
    case tier(TrustTier)
    case custom(text: String, color: Color, icon: String?)
    
    enum StatusType {
        case active
        case pending
        case completed
        case cancelled
        case inProgress
        case live
        case instant
        
        var color: Color {
            switch self {
            case .active: return .infoBlue
            case .pending: return .warningOrange
            case .completed: return .successGreen
            case .cancelled: return .errorRed
            case .inProgress: return .brandPurple
            case .live: return .liveRed
            case .instant: return .instantYellow
            }
        }
        
        var text: String {
            switch self {
            case .active: return "Active"
            case .pending: return "Pending"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .inProgress: return "In Progress"
            case .live: return "LIVE"
            case .instant: return "Instant"
            }
        }
        
        var icon: String? {
            switch self {
            case .live: return "circle.fill"
            case .instant: return "bolt.fill"
            case .inProgress: return "arrow.triangle.2.circlepath"
            default: return nil
            }
        }
    }
}

struct HXBadge: View {
    let variant: HXBadgeVariant

    var body: some View {
        Group {
            switch variant {
            case .status(let status):
                statusBadge(text: status.text, color: status.color, icon: status.icon)
                    .accessibilityLabel("Status: \(status.text)")
                    .accessibilityAddTraits(.isStaticText)

            case .count(let count):
                countBadge(count: count)
                    .accessibilityLabel("\(count) notifications")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityValue(count > 99 ? "More than 99" : "\(count)")

            case .tier(let tier):
                tierBadge(tier: tier)
                    .accessibilityLabel("Trust tier: \(tier.name)")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityHint("User verification level")

            case .custom(let text, let color, let icon):
                statusBadge(text: text, color: color, icon: icon)
                    .accessibilityLabel(text)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
    }
    
    private func statusBadge(text: String, color: Color, icon: String?) -> some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            ZStack {
                Capsule()
                    .fill(color.opacity(0.15))
                
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            }
        )
        .foregroundStyle(color)
    }
    
    private func countBadge(count: Int) -> some View {
        let displayCount = count > 99 ? "99+" : "\(count)"
        
        return ZStack {
            // Glow effect
            Circle()
                .fill(Color.errorRed.opacity(0.5))
                .frame(width: 24, height: 24)
                .blur(radius: 4)
            
            // Badge
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.errorRed, Color.errorRed.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 22, height: 22)
            
            Text(displayCount)
                .font(.system(size: count > 99 ? 9 : 11, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 24, height: 24)
    }
    
    private func tierBadge(tier: TrustTier) -> some View {
        let color = tierColor(for: tier)
        let icon = tierIcon(for: tier)
        
        return HStack(spacing: 5) {
            // Animated icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 18, height: 18)
                
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(tier.name)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.2)
        }
        .padding(.leading, 4)
        .padding(.trailing, 12)
        .padding(.vertical, 6)
        .background(
            ZStack {
                // Base
                Capsule()
                    .fill(Color.surfaceElevated)
                
                // Gradient overlay
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Border
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.4), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .foregroundStyle(color)
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func tierIcon(for tier: TrustTier) -> String {
        switch tier {
        case .unranked, .rookie: return "star"
        case .verified: return "checkmark.seal.fill"
        case .trusted: return "shield.fill"
        case .elite: return "crown.fill"
        case .master: return "bolt.shield.fill"
        }
    }
    
    private func tierColor(for tier: TrustTier) -> Color {
        switch tier {
        case .unranked, .rookie: return .textSecondary
        case .verified: return .infoBlue
        case .trusted: return .successGreen
        case .elite: return .brandPurple
        case .master: return .warningOrange
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 24) {
            // Status badges
            VStack(alignment: .leading, spacing: 8) {
                Text("Status").font(.caption).foregroundStyle(.gray)
                HStack(spacing: 8) {
                    HXBadge(variant: .status(.active))
                    HXBadge(variant: .status(.pending))
                    HXBadge(variant: .status(.completed))
                }
                HStack(spacing: 8) {
                    HXBadge(variant: .status(.inProgress))
                    HXBadge(variant: .status(.live))
                    HXBadge(variant: .status(.instant))
                }
            }
            
            // Count badges
            VStack(alignment: .leading, spacing: 8) {
                Text("Notifications").font(.caption).foregroundStyle(.gray)
                HStack(spacing: 16) {
                    HXBadge(variant: .count(3))
                    HXBadge(variant: .count(12))
                    HXBadge(variant: .count(99))
                    HXBadge(variant: .count(150))
                }
            }
            
            // Trust tiers
            VStack(alignment: .leading, spacing: 8) {
                Text("Trust Tiers").font(.caption).foregroundStyle(.gray)
                VStack(spacing: 10) {
                    HXBadge(variant: .tier(.rookie))
                    HXBadge(variant: .tier(.verified))
                    HXBadge(variant: .tier(.trusted))
                    HXBadge(variant: .tier(.elite))
                    HXBadge(variant: .tier(.master))
                }
            }
        }
        .padding(24)
    }
}
