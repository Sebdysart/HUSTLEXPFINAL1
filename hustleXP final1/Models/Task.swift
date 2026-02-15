//
//  Task.swift
//  hustleXP final1
//
//  Core Task model
//

import Foundation

enum TaskState: String, Codable, CaseIterable {
    case posted = "posted"
    case matching = "MATCHING"
    case claimed = "claimed"
    case inProgress = "in_progress"
    case proofSubmitted = "proof_submitted"
    case completed = "completed"
    case cancelled = "cancelled"
    case disputed = "disputed"
    case expired = "EXPIRED"

    /// Custom decoder that handles both frontend lowercase and backend UPPER_CASE states
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Try direct match first
        if let state = TaskState(rawValue: rawValue) {
            self = state
            return
        }

        // Map backend UPPER_CASE states to frontend equivalents
        switch rawValue {
        case "OPEN":              self = .posted
        case "MATCHING":          self = .matching
        case "ACCEPTED":          self = .claimed
        case "IN_PROGRESS":       self = .inProgress
        case "PROOF_SUBMITTED":   self = .proofSubmitted
        case "COMPLETED":         self = .completed
        case "CANCELLED":         self = .cancelled
        case "DISPUTED":          self = .disputed
        case "EXPIRED":           self = .expired
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown task state: \(rawValue)"
            )
        }
    }
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

    // v1.8.0 additions
    var aiSuggestedPrice: Bool = false
    var paymentMethod: PaymentMethod? = nil
    var category: TaskCategory? = nil
    var hasActiveClaim: Bool = false

    var badgeStatus: HXBadgeVariant.StatusType {
        switch state {
        case .posted, .matching: return .active
        case .claimed, .inProgress: return .inProgress
        case .proofSubmitted: return .pending
        case .completed: return .completed
        case .cancelled, .disputed, .expired: return .cancelled
        }
    }
}

// MARK: - Task extensions for convenience
extension HXTask {
    var isAvailable: Bool {
        [.posted, .matching].contains(state)
    }

    var isActive: Bool {
        [.claimed, .inProgress, .proofSubmitted].contains(state)
    }

    var formattedPayment: String {
        "$\(String(format: "%.0f", payment))"
    }
}
