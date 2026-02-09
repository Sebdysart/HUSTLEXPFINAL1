//
//  ColorTokens.swift
//  hustleXP final1
//
//  Color Semantics per COLOR_SEMANTICS_LAW.md
//  Brand: Black + Purple (NOT green as primary)
//

import SwiftUI

// MARK: - HustleXP Color System

extension Color {
    
    // MARK: Layer 1: Brand Canvas (Identity)
    
    /// Premium foundation - use for backgrounds, entry screens
    static let brandBlack = Color(hex: "0B0B0F")
    
    /// Primary accent - brand identity color
    static let brandPurple = Color(hex: "5B2DFF")
    
    /// For gradients and lighter accents
    static let brandPurpleLight = Color(hex: "7A4DFF")
    
    // MARK: Layer 2: Brand Accent (Energy)
    
    /// Highlights, progress bars, selection states (use sparingly)
    static let accentPurple = Color(hex: "8B5CF6")
    
    /// Secondary accent for visual variety
    static let accentViolet = Color(hex: "A78BFA")
    
    // MARK: Layer 3: Success/Money (Conditional)
    // CRITICAL: Never on entry screens or as primary brand color
    
    /// Success states only - task completion, verification passed
    static let successGreen = Color(hex: "34C759")
    
    /// Money/payment displays only
    static let moneyGreen = Color(hex: "1FAD7E")
    
    // MARK: Layer 4: Status Colors
    
    /// Errors, destructive actions, disputes
    static let errorRed = Color(hex: "FF3B30")
    
    /// Warnings, pending states, caution
    static let warningOrange = Color(hex: "FF9500")
    
    /// Information, links, interactive elements
    static let infoBlue = Color(hex: "007AFF")
    
    // MARK: Layer 5: Neutrals
    
    /// Primary text on dark backgrounds
    static let textPrimary = Color.white
    
    /// Secondary/muted text
    static let textSecondary = Color(white: 0.6)
    
    /// Pure black background
    static let backgroundBlack = Color.black
    
    /// Glass/frosted surface effect
    static let glassSurface = Color(hex: "1C1C1E").opacity(0.6)
    
    /// Card/container backgrounds
    static let surfaceElevated = Color(hex: "1C1C1E")
    
    /// Subtle borders and dividers
    static let borderSubtle = Color(white: 0.2)
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Brand Gradients

extension LinearGradient {
    /// Primary brand gradient for entry screens
    static let brandGradient = LinearGradient(
        colors: [Color.brandBlack, Color.brandPurple.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Purple glow effect
    static let purpleGlow = LinearGradient(
        colors: [Color.brandPurple.opacity(0.5), Color.brandPurple.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Semantic Color Aliases (for component use)

extension Color {
    // Button colors
    static let buttonPrimary = brandPurple
    static let buttonSecondary = surfaceElevated
    static let buttonDanger = errorRed
    
    // Badge colors by status
    static let badgeActive = infoBlue
    static let badgePending = warningOrange
    static let badgeComplete = successGreen
    static let badgeCancelled = errorRed
    
    // Trust tier colors
    static let tierRookie = Color.gray
    static let tierVerified = infoBlue
    static let tierTrusted = successGreen
    static let tierElite = accentPurple
    static let tierMaster = warningOrange
}
