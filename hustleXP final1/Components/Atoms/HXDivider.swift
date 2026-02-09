//
//  HXDivider.swift
//  hustleXP final1
//
//  Atom: Divider
//  Orientations: horizontal, vertical
//

import SwiftUI

enum HXDividerOrientation {
    case horizontal
    case vertical
}

struct HXDivider: View {
    let orientation: HXDividerOrientation
    let color: Color
    
    init(
        orientation: HXDividerOrientation = .horizontal,
        color: Color = Color(.separator)
    ) {
        self.orientation = orientation
        self.color = color
    }
    
    var body: some View {
        switch orientation {
        case .horizontal:
            Rectangle()
                .fill(color)
                .frame(height: 1)
            
        case .vertical:
            Rectangle()
                .fill(color)
                .frame(width: 1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Above")
        HXDivider()
        Text("Below")
        
        HStack(spacing: 20) {
            Text("Left")
            HXDivider(orientation: .vertical)
                .frame(height: 30)
            Text("Right")
        }
    }
    .padding()
}
