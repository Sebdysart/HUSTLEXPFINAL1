//
//  HXIcon.swift
//  hustleXP final1
//
//  Atom: Icon
//  Uses SF Symbols (approved icon set)
//

import SwiftUI

enum HXIconSize {
    case small
    case medium
    case large
    case xlarge
    case custom(CGFloat)
    
    var font: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title2
        case .xlarge: return .largeTitle
        case .custom(let size): return .system(size: size)
        }
    }
}

struct HXIcon: View {
    let name: String
    let size: HXIconSize
    let color: Color
    let accessibilityLabel: String?

    init(
        _ name: String,
        size: HXIconSize = .medium,
        color: Color = .primary,
        accessibilityLabel: String? = nil
    ) {
        self.name = name
        self.size = size
        self.color = color
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        Image(systemName: name)
            .font(size.font)
            .foregroundStyle(color)
            .accessibilityLabel(accessibilityLabel ?? iconDescription(for: name))
            .accessibilityAddTraits(.isImage)
    }

    /// Provides a default accessibility description based on common icon names
    private func iconDescription(for iconName: String) -> String {
        // Map common SF Symbol names to human-readable descriptions
        let descriptions: [String: String] = [
            "house.fill": "Home",
            "list.bullet": "Feed",
            "clock.fill": "History",
            "person.fill": "Profile",
            "gearshape.fill": "Settings",
            "briefcase.fill": "Task",
            "dollarsign.circle.fill": "Money",
            "star.fill": "Star",
            "mappin.circle.fill": "Location",
            "message.fill": "Message",
            "camera.fill": "Camera",
            "checkmark.circle.fill": "Checkmark",
            "exclamationmark.triangle.fill": "Warning",
            "xmark.circle.fill": "Error",
            "plus.circle.fill": "Add",
            "chevron.right": "Next",
            "chevron.left": "Back"
        ]

        return descriptions[iconName] ?? iconName.replacingOccurrences(of: ".", with: " ")
    }
}

// Common icon names as constants
extension HXIcon {
    static let home = "house.fill"
    static let feed = "list.bullet"
    static let history = "clock.fill"
    static let profile = "person.fill"
    static let settings = "gearshape.fill"
    static let task = "briefcase.fill"
    static let money = "dollarsign.circle.fill"
    static let star = "star.fill"
    static let location = "mappin.circle.fill"
    static let message = "message.fill"
    static let camera = "camera.fill"
    static let check = "checkmark.circle.fill"
    static let warning = "exclamationmark.triangle.fill"
    static let error = "xmark.circle.fill"
    static let add = "plus.circle.fill"
    static let chevronRight = "chevron.right"
    static let chevronLeft = "chevron.left"
}

#Preview {
    HStack(spacing: 24) {
        HXIcon(HXIcon.home, size: .small, color: .brandPurple)
        HXIcon(HXIcon.star, size: .medium, color: .warningOrange)
        HXIcon(HXIcon.money, size: .large, color: .moneyGreen)
        HXIcon(HXIcon.check, size: .xlarge, color: .successGreen)
    }
    .padding()
}
