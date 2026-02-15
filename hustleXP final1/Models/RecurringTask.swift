//
//  RecurringTask.swift
//  hustleXP final1
//
//  v2.4.0: Recurring Tasks — Silver-tier unlockable
//  Schedule tasks to repeat on a cadence — lawn mowing, dog walking, cleaning, etc.
//
//  Gated by: Trust Tier 3 (Trusted) — "Silver Tier"
//  Unlock: 20+ completed tasks, 95%+ on-time, 7+ days active
//

import Foundation
import SwiftUI

// MARK: - Recurring Task Series

struct RecurringTaskSeries: Identifiable, Codable {
    let id: String
    let posterId: String
    let templateTaskId: String  // The original task this repeats from

    // Schedule
    let pattern: RecurrencePattern
    let dayOfWeek: Int?          // 1=Mon...7=Sun (for weekly)
    let dayOfMonth: Int?         // 1-28 (for monthly)
    let timeOfDay: String?       // "09:00" (HH:mm)
    let startDate: Date
    var endDate: Date?           // nil = indefinite

    // Template
    let title: String
    let description: String
    let payment: Double
    let location: String
    let category: TaskCategory?
    let estimatedDuration: String
    let requiredTier: TrustTier

    // Status
    var status: RecurringSeriesStatus
    var occurrenceCount: Int     // How many have been generated
    var completedCount: Int      // How many completed successfully
    var preferredWorkerId: String?  // "Favorite hustler" auto-assign
    var preferredWorkerName: String?

    // Meta
    let createdAt: Date
    var updatedAt: Date
    var nextOccurrence: Date?

    var isActive: Bool { status == .active }
    var isPaused: Bool { status == .paused }
    var completionRate: Double {
        guard occurrenceCount > 0 else { return 0 }
        return Double(completedCount) / Double(occurrenceCount)
    }

    var formattedPayment: String {
        "$\(String(format: "%.0f", payment))"
    }

    var totalSpent: Double {
        payment * Double(completedCount)
    }

    var formattedTotalSpent: String {
        "$\(String(format: "%.0f", totalSpent))"
    }

    var patternDescription: String {
        switch pattern {
        case .daily:
            return "Every day"
        case .weekly:
            if let day = dayOfWeek {
                let days = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                return "Every \(day < days.count ? days[day] : "week")"
            }
            return "Every week"
        case .biweekly:
            return "Every 2 weeks"
        case .monthly:
            if let day = dayOfMonth {
                return "Monthly on the \(ordinal(day))"
            }
            return "Every month"
        }
    }

    var nextOccurrenceText: String {
        guard let next = nextOccurrence else { return "No upcoming" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: next, relativeTo: Date())
    }

    private func ordinal(_ n: Int) -> String {
        let suffix: String
        switch n % 10 {
        case 1 where n % 100 != 11: suffix = "st"
        case 2 where n % 100 != 12: suffix = "nd"
        case 3 where n % 100 != 13: suffix = "rd"
        default: suffix = "th"
        }
        return "\(n)\(suffix)"
    }
}

// MARK: - Recurrence Pattern

enum RecurrencePattern: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"

    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Bi-Weekly"
        case .monthly: return "Monthly"
        }
    }

    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar"
        case .monthly: return "calendar.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .daily: return .warningOrange
        case .weekly: return .brandPurple
        case .biweekly: return .infoBlue
        case .monthly: return .successGreen
        }
    }
}

// MARK: - Series Status

enum RecurringSeriesStatus: String, Codable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"  // End date reached
    case cancelled = "cancelled"
}

// MARK: - Recurring Task Occurrence

struct RecurringOccurrence: Identifiable, Codable {
    let id: String
    let seriesId: String
    let taskId: String         // The generated HXTask for this occurrence
    let occurrenceNumber: Int
    let scheduledDate: Date
    var status: OccurrenceStatus
    var workerId: String?
    var workerName: String?
    var completedAt: Date?
    var rating: Int?

    var isUpcoming: Bool { status == .scheduled }
    var wasCompleted: Bool { status == .completed }
}

enum OccurrenceStatus: String, Codable {
    case scheduled = "scheduled"
    case posted = "posted"       // Task was auto-created
    case inProgress = "in_progress"
    case completed = "completed"
    case skipped = "skipped"     // Poster skipped this one
    case cancelled = "cancelled"
}

// MARK: - Recurring Task Tier Gate

/// Defines which trust tier is required for Recurring Tasks
struct RecurringTaskTierGate {
    static let requiredTier: TrustTier = .trusted  // Silver = Tier 3 (Trusted)
    static let requiredCompletedTasks: Int = 20
    static let requiredOnTimeRate: Double = 0.95
    static let requiredDaysActive: Int = 7

    static func isUnlocked(tier: TrustTier) -> Bool {
        tier.rawValue >= requiredTier.rawValue
    }

    static var unlockRequirements: [UnlockRequirement] {
        [
            UnlockRequirement(
                icon: "shield.checkered",
                title: "Trusted Tier",
                description: "Reach Trust Tier 3 (Trusted)",
                color: .tierTrusted
            ),
            UnlockRequirement(
                icon: "checkmark.circle.fill",
                title: "20+ Tasks",
                description: "Complete at least 20 tasks",
                color: .successGreen
            ),
            UnlockRequirement(
                icon: "clock.badge.checkmark",
                title: "95%+ On-Time",
                description: "Maintain 95%+ on-time completion rate",
                color: .infoBlue
            ),
            UnlockRequirement(
                icon: "calendar",
                title: "7+ Days Active",
                description: "Be active for at least 7 days",
                color: .warningOrange
            ),
        ]
    }
}

// MARK: - Suggested Recurring Categories

/// Categories that naturally lend themselves to recurring tasks
struct RecurringCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let suggestedPattern: RecurrencePattern
    let examples: [String]

    static let suggested: [RecurringCategory] = [
        RecurringCategory(
            name: "Lawn & Garden",
            icon: "leaf.fill",
            color: .successGreen,
            suggestedPattern: .weekly,
            examples: ["Mow lawn", "Trim hedges", "Water plants"]
        ),
        RecurringCategory(
            name: "Dog Walking",
            icon: "pawprint.fill",
            color: .warningOrange,
            suggestedPattern: .daily,
            examples: ["Morning walk", "Evening walk", "Park run"]
        ),
        RecurringCategory(
            name: "House Cleaning",
            icon: "sparkles",
            color: .infoBlue,
            suggestedPattern: .weekly,
            examples: ["Deep clean", "Kitchen & bath", "Vacuuming"]
        ),
        RecurringCategory(
            name: "Grocery Shopping",
            icon: "cart.fill",
            color: .brandPurple,
            suggestedPattern: .weekly,
            examples: ["Weekly groceries", "Meal prep ingredients"]
        ),
        RecurringCategory(
            name: "Pool Maintenance",
            icon: "drop.fill",
            color: .infoBlue,
            suggestedPattern: .biweekly,
            examples: ["Chemical balance", "Skim & vacuum", "Filter clean"]
        ),
        RecurringCategory(
            name: "Trash & Recycling",
            icon: "trash.fill",
            color: .textMuted,
            suggestedPattern: .weekly,
            examples: ["Bins to curb", "Sort recycling"]
        ),
    ]
}
