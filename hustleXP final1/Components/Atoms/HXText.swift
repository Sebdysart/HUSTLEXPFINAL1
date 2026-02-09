//
//  HXText.swift
//  hustleXP final1
//
//  Atom: Text
//  Styles: heading, body, caption, label
//

import SwiftUI

enum HXTextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2
    
    var font: Font {
        switch self {
        case .largeTitle: return .largeTitle.weight(.bold)
        case .title: return .title.weight(.bold)
        case .title2: return .title2.weight(.bold)
        case .title3: return .title3.weight(.semibold)
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption
        case .caption2: return .caption2
        }
    }
}

struct HXText: View {
    let text: String
    let style: HXTextStyle
    let color: Color
    let alignment: TextAlignment
    
    init(
        _ text: String,
        style: HXTextStyle = .body,
        color: Color = .primary,
        alignment: TextAlignment = .leading
    ) {
        self.text = text
        self.style = style
        self.color = color
        self.alignment = alignment
    }
    
    var body: some View {
        Text(text)
            .font(style.font)
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HXText("Large Title", style: .largeTitle)
        HXText("Title", style: .title)
        HXText("Title 2", style: .title2)
        HXText("Title 3", style: .title3)
        HXText("Headline", style: .headline)
        HXText("Body text", style: .body)
        HXText("Subheadline", style: .subheadline, color: .secondary)
        HXText("Caption", style: .caption, color: .secondary)
    }
    .padding()
}
