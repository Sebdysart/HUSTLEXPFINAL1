//
//  Squad.swift
//  hustleXP final1
//
//  v2.4.0: Squads Mode — Gold-tier unlockable
//  Team up with trusted hustlers to tackle bigger tasks together
//
//  Gated by: Trust Tier 4 (Elite) — "Gold Tier"
//  Unlock: 100+ completed tasks, 4.8+ rating, 30+ days active
//

import Foundation
import SwiftUI

// MARK: - Squad Model

struct HXSquad: Identifiable, Codable {
    let id: String
    let name: String
    let organizerId: String
    let organizerName: String
    var members: [SquadMember]
    var status: SquadStatus
    let maxMembers: Int
    let createdAt: Date
    var lastActiveAt: Date

    // Stats
    var totalTasksCompleted: Int
    var totalEarnings: Double
    var averageRating: Double
    var squadXP: Int
    var squadLevel: Int

    // Branding
    var emoji: String  // Squad icon (user picks)
    var tagline: String?

    var memberCount: Int { members.count }
    var isFull: Bool { members.count >= maxMembers }
    var isActive: Bool { status == .active }

    var formattedEarnings: String {
        "$\(String(format: "%.0f", totalEarnings))"
    }

    var levelProgress: Double {
        let thresholds = [0, 500, 1500, 3500, 7000, 12000]
        guard squadLevel < thresholds.count else { return 1.0 }
        let current = squadLevel < thresholds.count ? thresholds[squadLevel] : thresholds.last!
        let previous = squadLevel > 0 ? thresholds[squadLevel - 1] : 0
        let range = current - previous
        guard range > 0 else { return 1.0 }
        return Double(squadXP - previous) / Double(range)
    }
}

// MARK: - Squad Member

struct SquadMember: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let userInitials: String
    let role: SquadRole
    let trustTier: TrustTier
    let rating: Double
    let completedTasks: Int
    let joinedAt: Date
    var lastActiveAt: Date
    var isOnline: Bool

    var tierColor: Color {
        switch trustTier {
        case .rookie: return .tierRookie
        case .verified: return .tierVerified
        case .trusted: return .tierTrusted
        case .elite: return .tierElite
        case .master: return .tierMaster
        }
    }
}

enum SquadRole: String, Codable {
    case organizer = "organizer"
    case member = "member"

    var label: String {
        switch self {
        case .organizer: return "Captain"
        case .member: return "Member"
        }
    }

    var icon: String {
        switch self {
        case .organizer: return "crown.fill"
        case .member: return "person.fill"
        }
    }
}

enum SquadStatus: String, Codable {
    case active = "active"
    case paused = "paused"
    case disbanded = "disbanded"
}

// MARK: - Squad Task (Multi-Worker Task)

struct SquadTask: Identifiable, Codable {
    let id: String
    let taskId: String
    let squadId: String
    let task: HXTask
    let requiredWorkers: Int
    var acceptedWorkers: [String]  // worker IDs
    var paymentSplit: PaymentSplitMode
    let perWorkerPayment: Double
    var status: SquadTaskStatus
    let createdAt: Date

    var spotsRemaining: Int {
        requiredWorkers - acceptedWorkers.count
    }

    var isFull: Bool { spotsRemaining <= 0 }

    var formattedPerWorkerPay: String {
        "$\(String(format: "%.0f", perWorkerPayment))"
    }
}

enum PaymentSplitMode: String, Codable {
    case equal = "equal"
    case weighted = "weighted"  // Based on contribution

    var label: String {
        switch self {
        case .equal: return "Equal Split"
        case .weighted: return "Weighted"
        }
    }

    var icon: String {
        switch self {
        case .equal: return "equal.circle.fill"
        case .weighted: return "chart.pie.fill"
        }
    }
}

enum SquadTaskStatus: String, Codable {
    case recruiting = "recruiting"  // Looking for squad members
    case ready = "ready"            // All spots filled
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Squad Invite

struct SquadInvite: Identifiable, Codable {
    let id: String
    let squadId: String
    let squadName: String
    let squadEmoji: String
    let inviterId: String
    let inviterName: String
    let inviteeId: String
    let status: InviteStatus
    let sentAt: Date
    let expiresAt: Date

    var isExpired: Bool {
        Date() >= expiresAt
    }
}

enum InviteStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case expired = "expired"
}

// MARK: - Squad Tier Gate

/// Defines which trust tier is required to access Squads Mode
struct SquadTierGate {
    static let requiredTier: TrustTier = .elite  // Gold = Tier 4 (Elite)
    static let requiredCompletedTasks: Int = 100
    static let requiredRating: Double = 4.8
    static let requiredDaysActive: Int = 30
    static let maxSquadSize: Int = 5

    static func isUnlocked(tier: TrustTier) -> Bool {
        tier.rawValue >= requiredTier.rawValue
    }

    static var unlockRequirements: [UnlockRequirement] {
        [
            UnlockRequirement(
                icon: "shield.checkered",
                title: "Elite Trust Tier",
                description: "Reach Trust Tier 4 (Elite)",
                color: .tierElite
            ),
            UnlockRequirement(
                icon: "checkmark.circle.fill",
                title: "100+ Tasks",
                description: "Complete at least 100 tasks",
                color: .successGreen
            ),
            UnlockRequirement(
                icon: "star.fill",
                title: "4.8+ Rating",
                description: "Maintain a 4.8+ average rating",
                color: .warningOrange
            ),
            UnlockRequirement(
                icon: "calendar",
                title: "30+ Days Active",
                description: "Be active for at least 30 days",
                color: .infoBlue
            ),
        ]
    }
}

struct UnlockRequirement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}
