//
//  ColorTokens.swift
//  hustleXP final1
//
//  Color Semantics per COLOR_SEMANTICS_LAW.md
//  Brand: Black + Purple (NOT green as primary)
//
//  AUTHORITY: This file implements the official HustleXP color system
//  Reference: https://github.com/Sebdysart/HUSTLEXP-DOCS/COLOR_SEMANTICS_LAW.md
//

import SwiftUI

// MARK: - HustleXP Color System

extension Color {
    
    // MARK: Layer 1: Brand Canvas (Identity)
    
    /// Premium foundation - use for backgrounds, entry screens
    /// Hex: #0B0B0F
    static let brandBlack = Color(hex: "0B0B0F")
    
    /// Primary accent - brand identity color, CTAs, glow effects
    /// Hex: #5B2DFF
    static let brandPurple = Color(hex: "5B2DFF")
    
    /// For gradient transitions and lighter accents
    /// Hex: #7A4DFF
    static let brandPurpleLight = Color(hex: "7A4DFF")
    
    /// Glow effects, emphasis
    /// Hex: #8B5CF6
    static let brandPurpleGlow = Color(hex: "8B5CF6")
    
    // MARK: Layer 2: Brand Accent (Energy)
    
    /// Highlights, progress bars, focus states (use sparingly)
    /// Hex: #8B5CF6
    static let accentPurple = Color(hex: "8B5CF6")
    
    /// Lighter emphasis, depth creation
    /// Hex: #A78BFA
    static let accentViolet = Color(hex: "A78BFA")
    
    // MARK: Layer 3: Success/Money (Conditional)
    // CRITICAL: 🚨 NEVER on entry screens or as primary brand color
    // CRITICAL: 🚨 ONLY appears AFTER user action succeeds
    
    /// Success states only - task completion, confirmations
    /// Hex: #34C759 (Apple HIG Green)
    static let successGreen = Color(hex: "34C759")
    
    /// Money received, escrow release displays only
    /// Hex: #1FAD7E
    static let moneyGreen = Color(hex: "1FAD7E")
    
    // MARK: Layer 4: Status Colors
    
    /// Errors, destructive actions, alerts, disputes
    /// Hex: #FF3B30 (Apple HIG Red)
    static let errorRed = Color(hex: "FF3B30")
    
    /// Warnings, XP/streak indicators, pending states
    /// Hex: #FF9500 (Apple HIG Orange)
    static let warningOrange = Color(hex: "FF9500")
    
    /// Alias for warningOrange (backward compatibility)
    static let warningYellow = warningOrange
    
    /// Information, trust badges, links
    /// Hex: #007AFF (Apple HIG Blue)
    static let infoBlue = Color(hex: "007AFF")
    
    /// Live mode indicators
    /// Hex: #FF3B30
    static let liveRed = Color(hex: "FF3B30")
    
    /// Instant mode accents only
    /// Hex: #FFD900
    static let instantYellow = Color(hex: "FFD900")
    
    // MARK: Layer 5a: v2.4.0 Unlockable Feature Colors

    /// Squads Mode (Gold-tier) — warm amber/gold
    /// Hex: #F59E0B (Amber-500)
    static let squadGold = Color(hex: "F59E0B")

    /// Squads Mode lighter variant for backgrounds
    /// Hex: #FCD34D (Amber-300)
    static let squadGoldLight = Color(hex: "FCD34D")

    /// Recurring Tasks (Silver-tier) — cool blue
    /// Hex: #3B82F6 (Blue-500)
    static let recurringBlue = Color(hex: "3B82F6")

    /// Recurring Tasks lighter variant for backgrounds
    /// Hex: #93C5FD (Blue-300)
    static let recurringBlueLight = Color(hex: "93C5FD")

    // MARK: Layer 5: v1.8.0 Feature Colors

    /// AI/Scoper purple for AI-suggested pricing
    /// Hex: #8B5CF6
    static let aiPurple = Color(hex: "8B5CF6")
    
    /// Risk level: Low (same as success)
    static let riskLow = successGreen
    
    /// Risk level: Medium (same as warning)
    static let riskMedium = warningOrange
    
    /// Risk level: High (same as error)
    static let riskHigh = errorRed
    
    /// Risk level: Critical
    /// Hex: #DC2626
    static let riskCritical = Color(hex: "DC2626")
    
    /// Insurance pool indicator
    static let insurancePool = infoBlue
    
    /// Insurance claim accent
    static let insuranceClaim = accentPurple
    
    /// Tax warning (unpaid taxes)
    static let taxWarning = warningOrange
    
    /// Verification progress
    static let verificationProgress = brandPurple
    
    // MARK: Layer 6: Neutrals
    
    /// Primary text content on dark backgrounds
    /// Hex: #FFFFFF
    static let textPrimary = Color.white
    
    /// Secondary text, reduced prominence
    /// Hex: #E5E5EA
    static let textSecondary = Color(hex: "E5E5EA")
    
    /// Disabled states, hints
    /// Hex: #8E8E93 (Apple HIG Gray)
    static let textMuted = Color(hex: "8E8E93")
    
    /// Tertiary text (darker than muted)
    static let textTertiary = Color(white: 0.4)
    
    /// Primary background foundation
    /// Hex: #000000
    static let backgroundBlack = Color.black
    
    /// Elevated surface layers
    /// Hex: #1C1C1E
    static let backgroundElevated = Color(hex: "1C1C1E")
    
    /// Glass-morphism backgrounds
    /// Hex: rgba(28, 28, 30, 0.6)
    static let glassSurface = Color(hex: "1C1C1E").opacity(0.6)
    
    /// Glass-morphism borders
    /// Hex: rgba(255, 255, 255, 0.1)
    static let glassBorder = Color.white.opacity(0.1)
    
    /// Card/container backgrounds (alias for backgroundElevated)
    static let surfaceElevated = Color(hex: "1C1C1E")
    
    /// Primary surface
    static let surfacePrimary = Color(hex: "1C1C1E")
    
    /// Secondary surface (darker)
    static let surfaceSecondary = Color(hex: "141417")
    
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
    static let tierRookie = textMuted  // Use muted gray, not raw .gray
    static let tierVerified = infoBlue
    static let tierTrusted = successGreen
    static let tierElite = accentPurple
    static let tierMaster = warningOrange
    
    // MARK: - v1.9.0 Heat Map Colors
    
    /// Heat zone: Low density (1-2 tasks) - cool blue
    /// Hex: #3B82F6
    static let heatLow = Color(hex: "3B82F6")
    
    /// Heat zone: Medium density (3-4 tasks) - warm yellow
    /// Hex: #FBBF24
    static let heatMedium = Color(hex: "FBBF24")
    
    /// Heat zone: High density (5-7 tasks) - hot orange
    /// Hex: #F97316
    static let heatHigh = Color(hex: "F97316")
    
    /// Heat zone: Hot density (8+ tasks) - blazing red
    /// Hex: #EF4444
    static let heatHot = Color(hex: "EF4444")
    
    /// Geofence boundary color
    static let geofenceBoundary = brandPurple
    
    /// Movement tracking path color
    static let movementPath = infoBlue
    
    /// Walking route color
    static let walkingRoute = brandPurple
    
    /// Map grid lines
    static let mapGrid = Color(white: 0.15)

    // MARK: - Additional Tokens

    /// XP gold accent for celebrations and XP displays
    /// Hex: #FFD700
    static let xpGold = Color(hex: "FFD700")

    /// Default surface (slightly lighter than brandBlack)
    static let surfaceDefault = Color(hex: "141417")

    /// Surface border for dividers and outlines
    static let surfaceBorder = Color(white: 0.2)
}
