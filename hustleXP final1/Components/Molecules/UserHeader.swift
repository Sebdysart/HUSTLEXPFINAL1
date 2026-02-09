//
//  UserHeader.swift
//  hustleXP final1
//
//  Molecule: UserHeader
//  Includes avatar and stats integration
//

import SwiftUI

struct UserHeader: View {
    let name: String
    let initials: String?
    let tier: TrustTier
    let rating: Double?
    let avatarSize: HXAvatarSize
    let showRating: Bool
    
    init(
        name: String,
        initials: String? = nil,
        tier: TrustTier = .rookie,
        rating: Double? = nil,
        avatarSize: HXAvatarSize = .medium,
        showRating: Bool = true
    ) {
        self.name = name
        self.initials = initials ?? String(name.prefix(2))
        self.tier = tier
        self.rating = rating
        self.avatarSize = avatarSize
        self.showRating = showRating
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HXAvatar(initials: initials, size: avatarSize)
            
            VStack(alignment: .leading, spacing: 4) {
                HXText(name, style: .headline)
                
                HStack(spacing: 8) {
                    HXBadge(variant: .tier(tier))
                    
                    if showRating, let rating = rating {
                        HStack(spacing: 2) {
                            HXIcon(HXIcon.star, size: .small, color: .warningOrange)
                            HXText(String(format: "%.1f", rating), style: .caption)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        UserHeader(name: "John Doe", tier: .rookie, rating: 4.5)
        UserHeader(name: "Jane Smith", tier: .verified, rating: 4.9, avatarSize: .large)
        UserHeader(name: "Pro User", tier: .elite, rating: 5.0)
    }
    .padding()
}
