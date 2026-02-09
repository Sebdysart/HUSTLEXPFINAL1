//
//  LiveMode.swift
//  hustleXP final1
//
//  LIVE Mode - Real-time urgent task matching system
//  "Uber for Random Help" - The first app people open in a real-life pinch
//

import Foundation
import SwiftUI

// MARK: - Quest Alert (ASAP Task)

/// High-urgency task that appears on the radar with special treatment
struct QuestAlert: Identifiable {
    let id: String
    let task: HXTask
    let createdAt: Date
    let expiresAt: Date
    let initialPayment: Double
    var currentPayment: Double
    var surgeMultiplier: Double
    let urgencyPremium: Double // 20-30% added automatically
    let decisionWindowSeconds: Int // 60 seconds default
    var priceBoosts: Int // Number of $2-5 boosts applied
    let maxRadius: Double // 2 miles = 3218 meters
    let posterLocation: GPSCoordinates
    var status: QuestStatus
    var assignedWorkerId: String?
    var workerETA: Int? // seconds
    
    // Eligibility - Level 5+ workers only for reliability
    let minimumTrustTier: TrustTier = .elite
    let minimumCompletedTasks: Int = 25
    let maximumCancellationRate: Double = 0.05 // 5% max
    
    var timeRemaining: Int {
        max(0, Int(expiresAt.timeIntervalSince(Date())))
    }
    
    var isExpired: Bool {
        Date() >= expiresAt
    }
    
    var distanceMeters: Double?
    
    var distanceText: String {
        guard let distance = distanceMeters else { return "Calculating..." }
        if distance < 1000 {
            return "\(Int(distance))m away"
        } else {
            return String(format: "%.1f mi", distance / 1609.34)
        }
    }
    
    var totalPayment: Double {
        currentPayment + urgencyPremium
    }
}

enum QuestStatus: String, Codable {
    case broadcasting    // Pulsing on radar, waiting for acceptance
    case claimed        // Worker accepted, heading to location
    case inProgress     // Worker arrived, task started
    case completed      // Task finished
    case expired        // No one accepted in time
    case cancelled      // Poster cancelled
    case ghosted        // Worker accepted but didn't show (penalty applied)
}

// MARK: - Live Mode Session

/// Worker's active "on the hunt" session
struct LiveModeSession: Identifiable {
    let id: String
    let workerId: String
    let startedAt: Date
    var lastPingAt: Date
    var location: GPSCoordinates
    var heading: Double // Direction worker is facing/moving
    var speed: Double // m/s
    var isMoving: Bool
    var batteryLevel: Double // Ensure they have battery
    var signalStrength: SignalStrength
    var availableFor: [LiveTaskCategory]
    var maxDistance: Double // How far they're willing to go
    
    // Stats for this session
    var questsReceived: Int = 0
    var questsAccepted: Int = 0
    var questsCompleted: Int = 0
    var earningsThisSession: Double = 0
    
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(startedAt)
    }
    
    var sessionDurationText: String {
        let minutes = Int(sessionDuration / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
    }
}

enum SignalStrength: String, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var icon: String {
        switch self {
        case .excellent: return "wifi"
        case .good: return "wifi"
        case .fair: return "wifi.exclamationmark"
        case .poor: return "wifi.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .successGreen
        case .good: return .successGreen
        case .fair: return .warningOrange
        case .poor: return .errorRed
        }
    }
}

enum LiveTaskCategory: String, Codable, CaseIterable {
    case lifting = "Heavy Lifting"
    case driving = "Driving/Transport"
    case lockout = "Lockout Help"
    case jumpstart = "Jump Start"
    case moving = "Moving Help"
    case delivery = "Urgent Delivery"
    case emergency = "Emergency Assist"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .lifting: return "figure.strengthtraining.traditional"
        case .driving: return "car.fill"
        case .lockout: return "key.fill"
        case .jumpstart: return "bolt.car.fill"
        case .moving: return "shippingbox.fill"
        case .delivery: return "box.truck.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .lifting: return .orange
        case .driving: return .blue
        case .lockout: return .red
        case .jumpstart: return .yellow
        case .moving: return .purple
        case .delivery: return .green
        case .emergency: return .red
        case .other: return .gray
        }
    }
}

// MARK: - Radar Blip (Worker on Map)

/// Represents a worker visible on the poster's tracking map
struct RadarBlip: Identifiable {
    let id: String
    let workerId: String
    let workerName: String
    let workerInitials: String
    let trustTier: TrustTier
    let rating: Double
    let completedTasks: Int
    var location: GPSCoordinates
    var distanceMeters: Double
    var etaSeconds: Int
    var heading: Double
    var isMovingToward: Bool
    var lastUpdate: Date
    
    var etaText: String {
        if etaSeconds < 60 {
            return "< 1 min"
        } else {
            return "\(etaSeconds / 60) min"
        }
    }
    
    var distanceText: String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters))m"
        } else {
            return String(format: "%.1f mi", distanceMeters / 1609.34)
        }
    }
}

// MARK: - On-The-Way Tracking

/// Tracks worker movement after accepting ASAP task
struct OnTheWaySession: Identifiable {
    let id: String
    let questId: String
    let workerId: String
    let acceptedAt: Date
    var navigationStartedAt: Date?
    var arrivedAt: Date?
    let destinationLocation: GPSCoordinates
    var workerLocation: GPSCoordinates
    var pathPoints: [GPSCoordinates] // Breadcrumb trail
    var currentETA: Int // seconds
    var distanceRemaining: Double // meters
    var averageSpeed: Double // m/s
    var status: OnTheWayStatus
    
    // Ghosting prevention
    let navigationDeadline: Date // Must start within 60 seconds
    let movementDeadline: Date // Must be moving toward within 2 minutes
    var hasStartedNavigation: Bool { navigationStartedAt != nil }
    var isMovingToward: Bool = false
    var stationaryDuration: TimeInterval = 0
    
    var isAtRisk: Bool {
        // Risk of being marked as ghosting
        if !hasStartedNavigation && Date() > navigationDeadline {
            return true
        }
        if stationaryDuration > 120 { // 2 minutes stationary
            return true
        }
        return false
    }
}

enum OnTheWayStatus: String, Codable {
    case accepted       // Just accepted, waiting for navigation start
    case navigating     // Actively moving toward destination
    case arriving       // Within 100m of destination
    case arrived        // At destination
    case ghosting       // Flagged for not moving (penalty incoming)
}

// MARK: - Price Surge

struct ASAPSurge {
    let basePayment: Double
    let urgencyPremium: Double // 20-30%
    let distancePremium: Double // Based on how far
    let timePremium: Double // Late night/early morning
    let demandMultiplier: Double // How many workers available
    
    var totalPayment: Double {
        basePayment * (1 + urgencyPremium + distancePremium + timePremium) * demandMultiplier
    }
    
    var breakdownText: String {
        """
        Base: $\(String(format: "%.2f", basePayment))
        Urgency (+\(Int(urgencyPremium * 100))%): $\(String(format: "%.2f", basePayment * urgencyPremium))
        Distance: $\(String(format: "%.2f", basePayment * distancePremium))
        Time: $\(String(format: "%.2f", basePayment * timePremium))
        """
    }
}

// MARK: - Quest Ping (Special Notification)

struct QuestPing {
    let questId: String
    let category: LiveTaskCategory
    let payment: Double
    let distance: Double
    let expiresIn: Int
    let hapticPattern: HapticPattern
    
    enum HapticPattern {
        case questAlert      // Unique pattern for ASAP tasks
        case priceBoost      // Payment increased
        case lastChance      // 10 seconds remaining
        case claimed         // Someone else got it
    }
}

// MARK: - Live Mode Stats

struct LiveModeStats {
    var totalSessions: Int
    var totalTimeActive: TimeInterval
    var questsReceived: Int
    var questsAccepted: Int
    var questsCompleted: Int
    var totalEarnings: Double
    var averageResponseTime: TimeInterval // How fast they accept
    var averageArrivalTime: TimeInterval // How fast they arrive
    var ghostingStrikes: Int
    var reliabilityScore: Double // 0-100
    
    var acceptanceRate: Double {
        guard questsReceived > 0 else { return 0 }
        return Double(questsAccepted) / Double(questsReceived)
    }
    
    var completionRate: Double {
        guard questsAccepted > 0 else { return 0 }
        return Double(questsCompleted) / Double(questsAccepted)
    }
    
    var isEligibleForLiveMode: Bool {
        // Level 5+ (Elite), 25+ completed, <5% cancellation, no recent ghosting
        reliabilityScore >= 85 && ghostingStrikes < 3
    }
}
