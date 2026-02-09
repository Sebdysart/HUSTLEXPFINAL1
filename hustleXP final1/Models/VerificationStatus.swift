//
//  VerificationStatus.swift
//  hustleXP final1
//
//  Earned Verification Unlock models for v1.8.0
//

import Foundation

// MARK: - Verification Unlock Status

struct VerificationUnlockStatus: Codable {
    let earnedCents: Int
    let thresholdCents: Int // Always 4000 ($40.00)
    let percentage: Double
    let unlocked: Bool
    let tasksCompleted: Int
    let remainingCents: Int
    
    /// Formatted earned amount as dollars
    var formattedEarned: String {
        let dollars = Double(earnedCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted threshold amount as dollars
    var formattedThreshold: String {
        let dollars = Double(thresholdCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted remaining amount as dollars
    var formattedRemaining: String {
        let dollars = Double(remainingCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Progress as a value from 0.0 to 1.0
    var progress: Double {
        min(percentage / 100.0, 1.0)
    }
    
    /// Estimated tasks remaining (assuming $20 avg per task)
    var estimatedTasksRemaining: Int {
        guard remainingCents > 0 else { return 0 }
        return max(1, Int(ceil(Double(remainingCents) / 2000.0)))
    }
}

// MARK: - Verification Earnings Entry

struct VerificationEarningsEntry: Identifiable, Codable {
    let id: String
    let taskId: String
    let taskTitle: String
    let escrowId: String
    let netPayoutCents: Int // After 20% platform fee
    let earnedAt: Date
    
    /// Formatted net payout as dollars
    var formattedNetPayout: String {
        let dollars = Double(netPayoutCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

// MARK: - Verification Submission Status

enum VerificationSubmissionStatus: String, Codable {
    case notStarted = "not_started"
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .pending: return "Pending Review"
        case .approved: return "Verified"
        case .rejected: return "Rejected"
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "shield"
        case .pending: return "clock"
        case .approved: return "checkmark.shield.fill"
        case .rejected: return "xmark.shield"
        }
    }
}
