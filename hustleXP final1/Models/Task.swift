//
//  Task.swift
//  hustleXP final1
//
//  Core Task model
//

import Foundation

enum TaskState: String, Codable, CaseIterable {
    case posted = "posted"
    case claimed = "claimed"
    case inProgress = "in_progress"
    case proofSubmitted = "proof_submitted"
    case completed = "completed"
    case cancelled = "cancelled"
    case disputed = "disputed"
}

struct HXTask: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let payment: Double
    let location: String
    let latitude: Double?
    let longitude: Double?
    let estimatedDuration: String
    let posterId: String
    let posterName: String
    let posterRating: Double
    var hustlerId: String?
    var hustlerName: String?
    var state: TaskState
    let requiredTier: TrustTier
    let createdAt: Date
    var claimedAt: Date?
    var completedAt: Date?
    
    var badgeStatus: HXBadgeVariant.StatusType {
        switch state {
        case .posted: return .active
        case .claimed, .inProgress: return .inProgress
        case .proofSubmitted: return .pending
        case .completed: return .completed
        case .cancelled, .disputed: return .cancelled
        }
    }
}

// MARK: - Task extensions for convenience
extension HXTask {
    var isAvailable: Bool {
        state == .posted
    }
    
    var isActive: Bool {
        [.claimed, .inProgress, .proofSubmitted].contains(state)
    }
    
    var formattedPayment: String {
        "$\(String(format: "%.0f", payment))"
    }
}
