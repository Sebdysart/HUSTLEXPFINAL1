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
            // Fallback: unknown states default to .posted to avoid crash
            HXLogger.error("TaskState: Unknown value '\(rawValue)', defaulting to .posted", category: "Task")
            self = .posted
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

    // MARK: - Custom Codable (bulletproof against backend variations)

    private enum CodingKeys: String, CodingKey {
        case id, title, description, payment, location, latitude, longitude
        case estimatedDuration, posterId, posterName, posterRating
        case hustlerId, hustlerName, state, requiredTier, createdAt
        case claimedAt, completedAt, aiSuggestedPrice, paymentMethod
        case category, hasActiveClaim
        // Backend snake_case aliases (decode-only)
        case poster_id, worker_id, worker_name, poster_name, poster_rating
        case created_at, accepted_at, completed_at, estimated_duration
        case required_tier, price, has_active_claim
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(description, forKey: .description)
        try c.encode(payment, forKey: .payment)
        try c.encode(location, forKey: .location)
        try c.encodeIfPresent(latitude, forKey: .latitude)
        try c.encodeIfPresent(longitude, forKey: .longitude)
        try c.encode(estimatedDuration, forKey: .estimatedDuration)
        try c.encode(posterId, forKey: .posterId)
        try c.encode(posterName, forKey: .posterName)
        try c.encode(posterRating, forKey: .posterRating)
        try c.encodeIfPresent(hustlerId, forKey: .hustlerId)
        try c.encodeIfPresent(hustlerName, forKey: .hustlerName)
        try c.encode(state, forKey: .state)
        try c.encode(requiredTier, forKey: .requiredTier)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(claimedAt, forKey: .claimedAt)
        try c.encodeIfPresent(completedAt, forKey: .completedAt)
        try c.encode(aiSuggestedPrice, forKey: .aiSuggestedPrice)
        try c.encodeIfPresent(paymentMethod, forKey: .paymentMethod)
        try c.encodeIfPresent(category, forKey: .category)
        try c.encode(hasActiveClaim, forKey: .hasActiveClaim)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(String.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? "Untitled Task"
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""

        // Payment: backend sends cents as Int ("price"), frontend uses dollars as Double
        if let dollars = try? c.decode(Double.self, forKey: .payment) {
            payment = dollars
        } else if let cents = try? c.decode(Int.self, forKey: .price) {
            payment = Double(cents) / 100.0
        } else if let cents = try? c.decode(Double.self, forKey: .price) {
            payment = cents / 100.0
        } else {
            payment = 0
        }

        location = try c.decodeIfPresent(String.self, forKey: .location) ?? "Unknown"
        latitude = try c.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try c.decodeIfPresent(Double.self, forKey: .longitude)

        // estimatedDuration: may be absent from backend
        estimatedDuration = try c.decodeIfPresent(String.self, forKey: .estimatedDuration)
            ?? c.decodeIfPresent(String.self, forKey: .estimated_duration)
            ?? "~30 min"

        // posterId: try camelCase first, then snake_case
        posterId = try c.decodeIfPresent(String.self, forKey: .posterId)
            ?? c.decodeIfPresent(String.self, forKey: .poster_id)
            ?? ""

        // posterName: backend may not include this field
        posterName = try c.decodeIfPresent(String.self, forKey: .posterName)
            ?? c.decodeIfPresent(String.self, forKey: .poster_name)
            ?? "Unknown"

        // posterRating: may be absent
        posterRating = try c.decodeIfPresent(Double.self, forKey: .posterRating)
            ?? c.decodeIfPresent(Double.self, forKey: .poster_rating)
            ?? 5.0

        // hustlerId: try camelCase and snake_case
        hustlerId = try c.decodeIfPresent(String.self, forKey: .hustlerId)
            ?? c.decodeIfPresent(String.self, forKey: .worker_id)

        // hustlerName
        hustlerName = try c.decodeIfPresent(String.self, forKey: .hustlerName)
            ?? c.decodeIfPresent(String.self, forKey: .worker_name)

        // state: has its own safe decoder via TaskState.init(from:)
        state = try c.decodeIfPresent(TaskState.self, forKey: .state) ?? .posted

        // requiredTier: try camelCase then snake_case, default to .rookie
        requiredTier = try c.decodeIfPresent(TrustTier.self, forKey: .requiredTier)
            ?? c.decodeIfPresent(TrustTier.self, forKey: .required_tier)
            ?? .rookie

        // createdAt: try camelCase then snake_case
        if let date = try? c.decode(Date.self, forKey: .createdAt) {
            createdAt = date
        } else if let date = try? c.decode(Date.self, forKey: .created_at) {
            createdAt = date
        } else {
            createdAt = Date()
        }

        // claimedAt: try camelCase then snake_case (accepted_at in backend)
        claimedAt = try c.decodeIfPresent(Date.self, forKey: .claimedAt)
            ?? c.decodeIfPresent(Date.self, forKey: .accepted_at)

        // completedAt: try camelCase then snake_case
        completedAt = try c.decodeIfPresent(Date.self, forKey: .completedAt)
            ?? c.decodeIfPresent(Date.self, forKey: .completed_at)

        // v1.8.0 optional fields
        aiSuggestedPrice = try c.decodeIfPresent(Bool.self, forKey: .aiSuggestedPrice) ?? false
        paymentMethod = try c.decodeIfPresent(PaymentMethod.self, forKey: .paymentMethod)
        category = try c.decodeIfPresent(TaskCategory.self, forKey: .category)
        hasActiveClaim = try c.decodeIfPresent(Bool.self, forKey: .hasActiveClaim)
            ?? c.decodeIfPresent(Bool.self, forKey: .has_active_claim)
            ?? false
    }

    // Memberwise initializer for previews / mock data
    init(
        id: String, title: String, description: String, payment: Double,
        location: String, latitude: Double? = nil, longitude: Double? = nil,
        estimatedDuration: String = "~30 min", posterId: String, posterName: String,
        posterRating: Double = 5.0, hustlerId: String? = nil, hustlerName: String? = nil,
        state: TaskState, requiredTier: TrustTier = .rookie, createdAt: Date = Date(),
        claimedAt: Date? = nil, completedAt: Date? = nil,
        aiSuggestedPrice: Bool = false, paymentMethod: PaymentMethod? = nil,
        category: TaskCategory? = nil, hasActiveClaim: Bool = false
    ) {
        self.id = id; self.title = title; self.description = description
        self.payment = payment; self.location = location
        self.latitude = latitude; self.longitude = longitude
        self.estimatedDuration = estimatedDuration; self.posterId = posterId
        self.posterName = posterName; self.posterRating = posterRating
        self.hustlerId = hustlerId; self.hustlerName = hustlerName
        self.state = state; self.requiredTier = requiredTier
        self.createdAt = createdAt; self.claimedAt = claimedAt
        self.completedAt = completedAt; self.aiSuggestedPrice = aiSuggestedPrice
        self.paymentMethod = paymentMethod; self.category = category
        self.hasActiveClaim = hasActiveClaim
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
