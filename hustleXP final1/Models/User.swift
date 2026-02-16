//
//  User.swift
//  hustleXP final1
//
//  Core User model
//

import Foundation

struct HXUser: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var bio: String?
    var avatarURL: URL?
    var role: UserRole
    var trustTier: TrustTier
    var rating: Double
    var totalRatings: Int
    var xp: Int
    var tasksCompleted: Int
    var tasksPosted: Int
    var totalEarnings: Double
    var totalSpent: Double
    var isVerified: Bool
    let createdAt: Date

    // v1.8.0 additions – backend may not send these yet, so they default to 0
    var unpaidTaxCents: Int = 0
    var xpHeldBack: Int = 0
    var verificationEarnedCents: Int = 0
    var insuranceContributionsCents: Int = 0

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(name.prefix(2))
    }

    // MARK: - Custom Codable (handle missing v1.8.0 keys gracefully)

    private enum CodingKeys: String, CodingKey {
        case id, name, email, phone, bio, avatarURL, role, trustTier
        case rating, totalRatings, xp, tasksCompleted, tasksPosted
        case totalEarnings, totalSpent, isVerified, createdAt
        case unpaidTaxCents, xpHeldBack, verificationEarnedCents, insuranceContributionsCents
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                         = try c.decode(String.self, forKey: .id)
        name                       = try c.decode(String.self, forKey: .name)
        email                      = try c.decode(String.self, forKey: .email)
        phone                      = try c.decodeIfPresent(String.self, forKey: .phone)
        bio                        = try c.decodeIfPresent(String.self, forKey: .bio)
        avatarURL                  = try c.decodeIfPresent(URL.self, forKey: .avatarURL)
        role                       = try c.decode(UserRole.self, forKey: .role)
        trustTier                  = try c.decode(TrustTier.self, forKey: .trustTier)
        rating                     = try c.decode(Double.self, forKey: .rating)
        totalRatings               = try c.decode(Int.self, forKey: .totalRatings)
        xp                         = try c.decode(Int.self, forKey: .xp)
        tasksCompleted             = try c.decode(Int.self, forKey: .tasksCompleted)
        tasksPosted                = try c.decode(Int.self, forKey: .tasksPosted)
        totalEarnings              = try c.decode(Double.self, forKey: .totalEarnings)
        totalSpent                 = try c.decode(Double.self, forKey: .totalSpent)
        isVerified                 = try c.decode(Bool.self, forKey: .isVerified)
        createdAt                  = try c.decode(Date.self, forKey: .createdAt)
        // v1.8.0 fields – default to 0 when absent from backend response
        unpaidTaxCents             = try c.decodeIfPresent(Int.self, forKey: .unpaidTaxCents) ?? 0
        xpHeldBack                 = try c.decodeIfPresent(Int.self, forKey: .xpHeldBack) ?? 0
        verificationEarnedCents    = try c.decodeIfPresent(Int.self, forKey: .verificationEarnedCents) ?? 0
        insuranceContributionsCents = try c.decodeIfPresent(Int.self, forKey: .insuranceContributionsCents) ?? 0
    }

    // Memberwise initializer for manual construction (demo mode, previews, etc.)
    init(
        id: String,
        name: String,
        email: String,
        phone: String? = nil,
        bio: String? = nil,
        avatarURL: URL? = nil,
        role: UserRole,
        trustTier: TrustTier,
        rating: Double,
        totalRatings: Int,
        xp: Int,
        tasksCompleted: Int,
        tasksPosted: Int,
        totalEarnings: Double,
        totalSpent: Double,
        isVerified: Bool,
        createdAt: Date,
        unpaidTaxCents: Int = 0,
        xpHeldBack: Int = 0,
        verificationEarnedCents: Int = 0,
        insuranceContributionsCents: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.bio = bio
        self.avatarURL = avatarURL
        self.role = role
        self.trustTier = trustTier
        self.rating = rating
        self.totalRatings = totalRatings
        self.xp = xp
        self.tasksCompleted = tasksCompleted
        self.tasksPosted = tasksPosted
        self.totalEarnings = totalEarnings
        self.totalSpent = totalSpent
        self.isVerified = isVerified
        self.createdAt = createdAt
        self.unpaidTaxCents = unpaidTaxCents
        self.xpHeldBack = xpHeldBack
        self.verificationEarnedCents = verificationEarnedCents
        self.insuranceContributionsCents = insuranceContributionsCents
    }
}

// MARK: - XP Progression
extension HXUser {
    var xpToNextTier: Int {
        switch trustTier {
        case .unranked: return 100
        case .rookie: return 100
        case .verified: return 300
        case .trusted: return 600
        case .elite: return 1000
        case .master: return 0 // Max level
        }
    }

    var xpProgress: Double {
        guard xpToNextTier > 0 else { return 1.0 }
        let tierStartXP: Int
        switch trustTier {
        case .unranked: tierStartXP = 0
        case .rookie: tierStartXP = 0
        case .verified: tierStartXP = 100
        case .trusted: tierStartXP = 300
        case .elite: tierStartXP = 600
        case .master: tierStartXP = 1000
        }
        let progressXP = xp - tierStartXP
        let tierXP = xpToNextTier - tierStartXP
        return Double(progressXP) / Double(tierXP)
    }
}
