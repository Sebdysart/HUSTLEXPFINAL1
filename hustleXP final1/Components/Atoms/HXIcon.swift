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
    
    var font: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title2
        case .xlarge: return .largeTitle
        }
    }
}

struct HXIcon: View {
    let name: String
    let size: HXIconSize
    let color: Color
    
    init(
        _ name: String,
        size: HXIconSize = .medium,
        color: Color = .primary
    ) {
        self.name = name
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(systemName: name)
            .font(size.font)
            .foregroundStyle(color)
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
        HXIcon(HXIcon.home, size: .small, color: .blue)
        HXIcon(HXIcon.star, size: .medium, color: .yellow)
        HXIcon(HXIcon.money, size: .large, color: .green)
        HXIcon(HXIcon.check, size: .xlarge, color: .green)
    }
    .padding()
}
