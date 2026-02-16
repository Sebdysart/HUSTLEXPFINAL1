//
//  HXAvatar.swift
//  hustleXP final1
//
//  Atom: Avatar
//  Premium avatar with gradient, glow, and online indicator
//

import SwiftUI

enum HXAvatarSize {
    case tiny    // For list items
    case small   // For compact UI
    case medium  // Default
    case large   // Profile headers
    case xlarge  // Hero sections
    
    var dimension: CGFloat {
        switch self {
        case .tiny: return 28
        case .small: return 36
        case .medium: return 48
        case .large: return 72
        case .xlarge: return 100
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .tiny: return 11
        case .small: return 14
        case .medium: return 18
        case .large: return 28
        case .xlarge: return 40
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .tiny: return 12
        case .small: return 14
        case .medium: return 20
        case .large: return 28
        case .xlarge: return 40
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .tiny, .small: return 2
        case .medium: return 2.5
        case .large, .xlarge: return 3
        }
    }
    
    var glowRadius: CGFloat {
        switch self {
        case .tiny, .small: return 4
        case .medium: return 6
        case .large: return 10
        case .xlarge: return 14
        }
    }
}

struct HXAvatar: View {
    let imageURL: URL?
    let initials: String?
    let size: HXAvatarSize
    let isOnline: Bool
    let showBorder: Bool
    let borderColor: Color
    
    init(
        imageURL: URL? = nil,
        initials: String? = nil,
        size: HXAvatarSize = .medium,
        isOnline: Bool = false,
        showBorder: Bool = true,
        borderColor: Color = .brandPurple
    ) {
        self.imageURL = imageURL
        self.initials = initials
        self.size = size
        self.isOnline = isOnline
        self.showBorder = showBorder
        self.borderColor = borderColor
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main avatar
            avatarContent
                .frame(width: size.dimension, height: size.dimension)
            
            // Online indicator
            if isOnline {
                onlineIndicator
            }
        }
    }
    
    private var avatarContent: some View {
        ZStack {
            // Glow effect
            if showBorder {
                Circle()
                    .fill(borderColor.opacity(0.4))
                    .frame(width: size.dimension + 4, height: size.dimension + 4)
                    .blur(radius: size.glowRadius)
            }
            
            // Background with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            borderColor.opacity(0.3),
                            borderColor.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Border ring
            if showBorder {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                borderColor.opacity(0.8),
                                borderColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size.borderWidth
                    )
            }
            
            // Content
            if let initials = initials {
                Text(initials.prefix(2).uppercased())
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size.iconSize, weight: .medium))
                    .foregroundStyle(borderColor)
            }
        }
    }
    
    private var onlineIndicator: some View {
        let indicatorSize: CGFloat = {
            switch size {
            case .tiny, .small: return 10
            case .medium: return 12
            case .large, .xlarge: return 16
            }
        }()
        
        return ZStack {
            // Glow
            Circle()
                .fill(Color.successGreen.opacity(0.5))
                .frame(width: indicatorSize + 4, height: indicatorSize + 4)
                .blur(radius: 3)
            
            // Outer ring
            Circle()
                .fill(Color.brandBlack)
                .frame(width: indicatorSize + 3, height: indicatorSize + 3)
            
            // Inner dot
            Circle()
                .fill(Color.successGreen)
                .frame(width: indicatorSize, height: indicatorSize)
        }
        .offset(x: 2, y: 2)
    }
}

// Variant for displaying trust tier
struct HXTierAvatar: View {
    let initials: String?
    let tier: TrustTier
    let size: HXAvatarSize
    let isOnline: Bool
    
    init(
        initials: String? = nil,
        tier: TrustTier = .rookie,
        size: HXAvatarSize = .medium,
        isOnline: Bool = false
    ) {
        self.initials = initials
        self.tier = tier
        self.size = size
        self.isOnline = isOnline
    }
    
    var body: some View {
        HXAvatar(
            initials: initials,
            size: size,
            isOnline: isOnline,
            showBorder: true,
            borderColor: tierColor
        )
    }
    
    private var tierColor: Color {
        switch tier {
        case .unranked, .rookie: return .textSecondary
        case .verified: return .infoBlue
        case .trusted: return .successGreen
        case .elite: return .brandPurple
        case .master: return .warningOrange
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 32) {
            // Size variants
            VStack(alignment: .leading, spacing: 8) {
                Text("Sizes").font(.caption).foregroundStyle(.gray)
                HStack(spacing: 20) {
                    HXAvatar(initials: "JD", size: .tiny)
                    HXAvatar(initials: "JD", size: .small)
                    HXAvatar(initials: "JD", size: .medium)
                    HXAvatar(initials: "JD", size: .large)
                    HXAvatar(initials: "JD", size: .xlarge)
                }
            }
            
            // Online indicator
            VStack(alignment: .leading, spacing: 8) {
                Text("Online Status").font(.caption).foregroundStyle(.gray)
                HStack(spacing: 20) {
                    HXAvatar(initials: "ON", size: .medium, isOnline: true)
                    HXAvatar(initials: "OFF", size: .medium, isOnline: false)
                }
            }
            
            // Trust tier variants
            VStack(alignment: .leading, spacing: 8) {
                Text("Trust Tiers").font(.caption).foregroundStyle(.gray)
                HStack(spacing: 16) {
                    HXTierAvatar(initials: "R", tier: .rookie, size: .medium)
                    HXTierAvatar(initials: "V", tier: .verified, size: .medium)
                    HXTierAvatar(initials: "T", tier: .trusted, size: .medium)
                    HXTierAvatar(initials: "E", tier: .elite, size: .medium)
                    HXTierAvatar(initials: "M", tier: .master, size: .medium, isOnline: true)
                }
            }
            
            // No initials (placeholder)
            VStack(alignment: .leading, spacing: 8) {
                Text("Placeholder").font(.caption).foregroundStyle(.gray)
                HXAvatar(size: .large, showBorder: false)
            }
        }
        .padding(24)
    }
}
