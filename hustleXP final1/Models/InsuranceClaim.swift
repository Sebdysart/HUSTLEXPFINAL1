//
//  InsuranceClaim.swift
//  hustleXP final1
//
//  Insurance Claims models for v1.8.0
//

import Foundation

// MARK: - Insurance Pool Status

struct InsurancePoolStatus: Codable {
    let poolBalanceCents: Int
    let totalContributionsCents: Int
    let totalPaidClaimsCents: Int
    let activeClaimsCount: Int
    let userContributionsCents: Int
    
    /// Formatted pool balance as dollars
    var formattedPoolBalance: String {
        let dollars = Double(poolBalanceCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted total contributions as dollars
    var formattedTotalContributions: String {
        let dollars = Double(totalContributionsCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted user contributions as dollars
    var formattedUserContributions: String {
        let dollars = Double(userContributionsCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

// MARK: - Claim Status

enum ClaimStatus: String, Codable, CaseIterable {
    case filed
    case underReview = "under_review"
    case approved
    case denied
    case paid

    /// Safe decode — unknown values default to .filed
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = ClaimStatus(rawValue: raw) ?? .filed
    }

    var displayName: String {
        switch self {
        case .filed: return "Filed"
        case .underReview: return "Under Review"
        case .approved: return "Approved"
        case .denied: return "Denied"
        case .paid: return "Paid"
        }
    }
    
    var icon: String {
        switch self {
        case .filed: return "doc.text"
        case .underReview: return "clock"
        case .approved: return "checkmark.circle"
        case .denied: return "xmark.circle"
        case .paid: return "banknote"
        }
    }
    
    /// Whether this is a terminal state
    var isFinal: Bool {
        switch self {
        case .denied, .paid: return true
        default: return false
        }
    }
}

// MARK: - Insurance Claim

struct InsuranceClaim: Identifiable, Codable {
    let id: String
    let taskId: String
    let taskTitle: String
    let incidentDescription: String
    let requestedAmountCents: Int
    let approvedAmountCents: Int?
    let status: ClaimStatus
    let filedAt: Date
    let reviewedAt: Date?
    let reviewerNotes: String?
    
    /// Formatted requested amount as dollars
    var formattedRequestedAmount: String {
        let dollars = Double(requestedAmountCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted approved amount as dollars (if available)
    var formattedApprovedAmount: String? {
        guard let cents = approvedAmountCents else { return nil }
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Short description preview (first 100 chars)
    var descriptionPreview: String {
        if incidentDescription.count > 100 {
            return String(incidentDescription.prefix(100)) + "..."
        }
        return incidentDescription
    }
}

// MARK: - File Claim Request

struct FileClaimRequest {
    let taskId: String
    let incidentDescription: String
    let requestedAmountCents: Int
    
    /// Validate the claim request
    var validationErrors: [String] {
        var errors: [String] = []
        
        if incidentDescription.isEmpty {
            errors.append("Please describe the incident")
        } else if incidentDescription.count < 20 {
            errors.append("Description must be at least 20 characters")
        } else if incidentDescription.count > 500 {
            errors.append("Description must be 500 characters or less")
        }
        
        if requestedAmountCents < 100 {
            errors.append("Minimum claim amount is $1.00")
        } else if requestedAmountCents > 500000 {
            errors.append("Maximum claim amount is $5,000.00")
        }
        
        return errors
    }
    
    var isValid: Bool {
        validationErrors.isEmpty
    }
}
