//
//  RiskBadge.swift
//  hustleXP final1
//
//  Molecule: Risk Level Badge
//  Color-coded badge for risk levels
//

import SwiftUI

struct RiskBadge: View {
    let level: RiskLevel
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case medium
        case large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var paddingH: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }
        }
        
        var paddingV: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    init(level: RiskLevel, size: BadgeSize = .medium) {
        self.level = level
        self.size = size
    }
    
    private var badgeColor: Color {
        switch level {
        case .low: return .riskLow
        case .medium: return .riskMedium
        case .high: return .riskHigh
        case .critical: return .riskCritical
        }
    }
    
    private var icon: String {
        switch level {
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.shield.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.shield.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: size.fontSize))
            
            Text(level.displayName)
                .font(.system(size: size.fontSize, weight: .semibold))
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, size.paddingH)
        .padding(.vertical, size.paddingV)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Risk Indicator Dot

struct RiskIndicatorDot: View {
    let level: RiskLevel
    let animated: Bool
    
    @State private var isAnimating = false
    
    init(level: RiskLevel, animated: Bool = false) {
        self.level = level
        self.animated = animated
    }
    
    private var dotColor: Color {
        switch level {
        case .low: return .riskLow
        case .medium: return .riskMedium
        case .high: return .riskHigh
        case .critical: return .riskCritical
        }
    }
    
    var body: some View {
        ZStack {
            if animated && (level == .high || level == .critical) {
                // Pulsing ring
                Circle()
                    .stroke(dotColor.opacity(0.4), lineWidth: 2)
                    .frame(width: 16, height: 16)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.0)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            if animated {
                isAnimating = true
            }
        }
    }
}

// MARK: - Risk Level Indicator Bar

struct RiskLevelBar: View {
    let level: RiskLevel
    
    private var filledSegments: Int {
        level.sortOrder + 1
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < filledSegments ? segmentColor(for: index) : Color.surfaceSecondary)
                    .frame(width: 20, height: 6)
            }
        }
    }
    
    private func segmentColor(for index: Int) -> Color {
        switch index {
        case 0: return .riskLow
        case 1: return .riskMedium
        case 2: return .riskHigh
        case 3: return .riskCritical
        default: return .surfaceSecondary
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 24) {
            // Badges
            VStack(alignment: .leading, spacing: 12) {
                HXText("Risk Badges", style: .caption, color: .textMuted)
                
                HStack(spacing: 12) {
                    RiskBadge(level: .low)
                    RiskBadge(level: .medium)
                    RiskBadge(level: .high)
                    RiskBadge(level: .critical)
                }
            }
            
            // Size variants
            VStack(alignment: .leading, spacing: 12) {
                HXText("Size Variants", style: .caption, color: .textMuted)
                
                HStack(spacing: 12) {
                    RiskBadge(level: .high, size: .small)
                    RiskBadge(level: .high, size: .medium)
                    RiskBadge(level: .high, size: .large)
                }
            }
            
            // Indicator dots
            VStack(alignment: .leading, spacing: 12) {
                HXText("Indicator Dots", style: .caption, color: .textMuted)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        RiskIndicatorDot(level: .low)
                        Text("Low").font(.caption2).foregroundStyle(Color.textMuted)
                    }
                    VStack(spacing: 4) {
                        RiskIndicatorDot(level: .medium)
                        Text("Med").font(.caption2).foregroundStyle(Color.textMuted)
                    }
                    VStack(spacing: 4) {
                        RiskIndicatorDot(level: .high, animated: true)
                        Text("High").font(.caption2).foregroundStyle(Color.textMuted)
                    }
                    VStack(spacing: 4) {
                        RiskIndicatorDot(level: .critical, animated: true)
                        Text("Crit").font(.caption2).foregroundStyle(Color.textMuted)
                    }
                }
            }
            
            // Level bars
            VStack(alignment: .leading, spacing: 12) {
                HXText("Level Bars", style: .caption, color: .textMuted)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Low").font(.caption).foregroundStyle(Color.textSecondary)
                        Spacer()
                        RiskLevelBar(level: .low)
                    }
                    HStack {
                        Text("Medium").font(.caption).foregroundStyle(Color.textSecondary)
                        Spacer()
                        RiskLevelBar(level: .medium)
                    }
                    HStack {
                        Text("High").font(.caption).foregroundStyle(Color.textSecondary)
                        Spacer()
                        RiskLevelBar(level: .high)
                    }
                    HStack {
                        Text("Critical").font(.caption).foregroundStyle(Color.textSecondary)
                        Spacer()
                        RiskLevelBar(level: .critical)
                    }
                }
            }
        }
        .padding()
    }
}
