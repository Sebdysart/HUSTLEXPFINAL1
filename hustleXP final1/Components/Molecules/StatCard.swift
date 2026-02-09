//
//  StatCard.swift
//  hustleXP final1
//
//  Molecule: StatCard
//  Premium stats display with glassmorphism and accent colors
//

import SwiftUI

enum StatCardType {
    case xp
    case tasks
    case earnings
    case rating
    case streak
    
    var icon: String {
        switch self {
        case .xp: return "star.fill"
        case .tasks: return "checkmark.circle.fill"
        case .earnings: return "dollarsign.circle.fill"
        case .rating: return "heart.fill"
        case .streak: return "flame.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .xp: return .brandPurple
        case .tasks: return .infoBlue
        case .earnings: return .moneyGreen
        case .rating: return .warningOrange
        case .streak: return .errorRed
        }
    }
    
    var label: String {
        switch self {
        case .xp: return "XP"
        case .tasks: return "Tasks"
        case .earnings: return "Earnings"
        case .rating: return "Rating"
        case .streak: return "Streak"
        }
    }
}

struct HXStatCard: View {
    let type: StatCardType
    let value: String
    let subtitle: String?
    let trend: Double?  // Percentage change, positive or negative
    
    init(
        type: StatCardType,
        value: String,
        subtitle: String? = nil,
        trend: Double? = nil
    ) {
        self.type = type
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(type.accentColor.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .blur(radius: 8)
                
                // Icon background
                Circle()
                    .fill(type.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(type.accentColor)
            }
            
            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            
            // Label and trend
            HStack(spacing: 4) {
                Text(subtitle ?? type.label)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                
                if let trend = trend {
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(abs(Int(trend)))%")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(trend >= 0 ? Color.successGreen : Color.errorRed)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Base
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                
                // Gradient highlight
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                type.accentColor.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                type.accentColor.opacity(0.3),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: type.accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Compact variant for horizontal layouts
struct StatCardCompact: View {
    let type: StatCardType
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(type.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(type.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                
                Text(type.label)
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Grid of stat cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                HXStatCard(type: .xp, value: "1,245", trend: 12)
                HXStatCard(type: .tasks, value: "28", trend: -3)
                HXStatCard(type: .earnings, value: "$2,450", subtitle: "This Month")
                HXStatCard(type: .rating, value: "4.9")
            }
            
            // Compact variants
            HStack(spacing: 12) {
                StatCardCompact(type: .streak, value: "7 days")
                StatCardCompact(type: .xp, value: "45")
            }
        }
        .padding(20)
    }
}
