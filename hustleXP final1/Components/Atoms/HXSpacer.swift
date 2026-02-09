//
//  HXSpacer.swift
//  hustleXP final1
//
//  Atom: Spacer
//  Sizes: xs, sm, md, lg, xl
//

import SwiftUI

enum HXSpacing: CGFloat {
    case xs = 4
    case sm = 8
    case md = 16
    case lg = 24
    case xl = 32
    case xxl = 48
}

struct HXSpacer: View {
    let size: HXSpacing
    let axis: Axis
    
    init(_ size: HXSpacing = .md, axis: Axis = .vertical) {
        self.size = size
        self.axis = axis
    }
    
    var body: some View {
        switch axis {
        case .vertical:
            Spacer()
                .frame(height: size.rawValue)
        case .horizontal:
            Spacer()
                .frame(width: size.rawValue)
        }
    }
}

// View extension for padding convenience
extension View {
    func hxPadding(_ size: HXSpacing) -> some View {
        self.padding(size.rawValue)
    }
    
    func hxPadding(_ edges: Edge.Set, _ size: HXSpacing) -> some View {
        self.padding(edges, size.rawValue)
    }
}

#Preview {
    VStack {
        Text("Item 1")
        HXSpacer(.xs)
        Text("Item 2 (xs)")
        HXSpacer(.sm)
        Text("Item 3 (sm)")
        HXSpacer(.md)
        Text("Item 4 (md)")
        HXSpacer(.lg)
        Text("Item 5 (lg)")
        HXSpacer(.xl)
        Text("Item 6 (xl)")
    }
    .padding()
}
