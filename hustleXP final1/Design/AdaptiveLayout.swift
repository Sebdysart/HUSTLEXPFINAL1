//
//  AdaptiveLayout.swift
//  hustleXP final1
//
//  Shared adaptive layout utilities for consistent sizing across all devices
//  Supports: iPhone SE, iPhone 16e, iPhone 16, iPhone 16 Pro, iPhone 16 Pro Max
//

import SwiftUI

// MARK: - Device Size Categories

enum DeviceSizeCategory {
    case compact    // iPhone SE, mini phones (height < 700)
    case regular    // iPhone 16e, standard phones (height 700-850)
    case large      // iPhone Pro Max, large phones (height > 850)
    
    var isCompact: Bool { self == .compact }
    var isLarge: Bool { self == .large }
}

// MARK: - Adaptive Layout Environment Key

struct AdaptiveLayoutKey: EnvironmentKey {
    static let defaultValue = AdaptiveLayout()
}

extension EnvironmentValues {
    var adaptiveLayout: AdaptiveLayout {
        get { self[AdaptiveLayoutKey.self] }
        set { self[AdaptiveLayoutKey.self] = newValue }
    }
}

// MARK: - Adaptive Layout

struct AdaptiveLayout {
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let safeAreaTop: CGFloat
    let safeAreaBottom: CGFloat
    
    init(
        screenHeight: CGFloat = UIScreen.main.bounds.height,
        screenWidth: CGFloat = UIScreen.main.bounds.width,
        safeAreaTop: CGFloat = 0,
        safeAreaBottom: CGFloat = 0
    ) {
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.safeAreaTop = safeAreaTop
        self.safeAreaBottom = safeAreaBottom
    }
    
    // MARK: - Device Category
    
    var sizeCategory: DeviceSizeCategory {
        if screenHeight < 700 {
            return .compact
        } else if screenHeight > 850 {
            return .large
        } else {
            return .regular
        }
    }
    
    var isCompact: Bool { sizeCategory.isCompact }
    var isLarge: Bool { sizeCategory.isLarge }
    
    // MARK: - Spacing
    
    var spacingXS: CGFloat { isCompact ? 4 : 6 }
    var spacingSM: CGFloat { isCompact ? 8 : 12 }
    var spacingMD: CGFloat { isCompact ? 12 : 16 }
    var spacingLG: CGFloat { isCompact ? 16 : 24 }
    var spacingXL: CGFloat { isCompact ? 24 : 32 }
    var spacingXXL: CGFloat { isCompact ? 32 : 48 }
    
    // MARK: - Padding
    
    var paddingHorizontal: CGFloat { isCompact ? 16 : 20 }
    var paddingVertical: CGFloat { isCompact ? 12 : 16 }
    var cardPadding: CGFloat { isCompact ? 14 : 18 }
    
    // MARK: - Font Sizes
    
    var fontTitle: CGFloat { isCompact ? 28 : (isLarge ? 36 : 32) }
    var fontHeadline: CGFloat { isCompact ? 22 : (isLarge ? 28 : 26) }
    var fontSubheadline: CGFloat { isCompact ? 14 : 16 }
    var fontBody: CGFloat { isCompact ? 14 : 16 }
    var fontCaption: CGFloat { isCompact ? 11 : 12 }
    
    // MARK: - Icon/Logo Sizes
    
    var logoSize: CGFloat { isCompact ? 70 : (isLarge ? 100 : 85) }
    var iconSizeLarge: CGFloat { isCompact ? 28 : 36 }
    var iconSizeMedium: CGFloat { isCompact ? 20 : 24 }
    var iconSizeSmall: CGFloat { isCompact ? 14 : 18 }
    
    // MARK: - Component Sizes
    
    var buttonHeight: CGFloat { isCompact ? 48 : 54 }
    var inputHeight: CGFloat { isCompact ? 44 : 50 }
    var avatarSize: CGFloat { isCompact ? 40 : 48 }
    var cardCornerRadius: CGFloat { isCompact ? 14 : 18 }
    
    // MARK: - Top/Bottom Spacing
    
    var topSafeSpacing: CGFloat {
        max(safeAreaTop + (isCompact ? 8 : 16), isCompact ? 32 : 48)
    }
    
    var bottomSafeSpacing: CGFloat {
        max(safeAreaBottom + 8, isCompact ? 16 : 24)
    }
}

// MARK: - Adaptive Layout Modifier

struct AdaptiveLayoutModifier: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let layout = AdaptiveLayout(
                screenHeight: geometry.size.height,
                screenWidth: geometry.size.width,
                safeAreaTop: geometry.safeAreaInsets.top,
                safeAreaBottom: geometry.safeAreaInsets.bottom
            )
            
            content
                .environment(\.adaptiveLayout, layout)
        }
    }
}

extension View {
    func adaptiveLayout() -> some View {
        modifier(AdaptiveLayoutModifier())
    }
}

// MARK: - Adaptive Spacing View

struct AdaptiveVStack<Content: View>: View {
    @Environment(\.adaptiveLayout) var layout
    let alignment: HorizontalAlignment
    let content: Content
    
    init(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: layout.spacingMD) {
            content
        }
    }
}

// MARK: - Preview Helper

#Preview("Adaptive Layout Demo") {
    VStack {
        Text("Adaptive Layout Test")
            .font(.title)
    }
    .adaptiveLayout()
}
