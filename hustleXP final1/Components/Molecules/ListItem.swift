//
//  ListItem.swift
//  hustleXP final1
//
//  Molecule: ListItem
//  Icon, text, and action layout
//

import SwiftUI

struct ListItem: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    let trailing: AnyView?
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(
        icon: String? = nil,
        iconColor: Color = .infoBlue,
        title: String,
        subtitle: String? = nil,
        trailing: AnyView? = nil,
        showChevron: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                if let icon = icon {
                    HXIcon(icon, size: .medium, color: iconColor)
                        .frame(width: 28)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    
                    if let subtitle = subtitle {
                        HXText(subtitle, style: .caption, color: .textSecondary)
                    }
                }
                
                Spacer()
                
                if let trailing = trailing {
                    trailing
                }
                
                if showChevron {
                    HXIcon(HXIcon.chevronRight, size: .small, color: .textTertiary)
                }
            }
            .padding()
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

#Preview {
    VStack(spacing: 12) {
        ListItem(
            icon: "person.fill",
            title: "Account Settings",
            action: {}
        )
        
        ListItem(
            icon: "bell.fill",
            iconColor: .warningOrange,
            title: "Notifications",
            subtitle: "Manage your alerts"
        ) {}
        
        ListItem(
            icon: "creditcard.fill",
            iconColor: .moneyGreen,
            title: "Payment Methods",
            trailing: AnyView(HXBadge(variant: .count(2))),
            action: {}
        )
    }
    .padding()
}
