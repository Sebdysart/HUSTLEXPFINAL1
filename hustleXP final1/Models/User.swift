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
    
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(name.prefix(2))
    }
}

// MARK: - XP Progression
extension HXUser {
    var xpToNextTier: Int {
        switch trustTier {
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
