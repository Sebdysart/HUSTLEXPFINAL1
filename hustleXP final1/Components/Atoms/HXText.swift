//
//  HXText.swift
//  hustleXP final1
//
//  Atom: Text
//  Styles: heading, body, caption, label
//

import SwiftUI

/// Typography styles per TYPOGRAPHY_AUTHORITY_RESOLUTION.md
/// Reference: STITCH HTML / Apple HIG specifications
enum HXTextStyle {
    case display      // 36px Bold - Hero text, major headings
    case largeTitle   // 34px Bold - Screen titles
    case title        // 28px Bold - Section headers
    case title2       // 24px SemiBold - Subsections
    case title3       // 20px SemiBold - Card titles
    case headline     // 18px SemiBold - Emphasized content
    case body         // 16px Regular - Primary content
    case callout      // 14px Regular - Supporting content
    case subheadline  // 15px Regular - Secondary content
    case footnote     // 13px Regular - Tertiary content
    case caption      // 12px Medium - Labels, timestamps
    case caption2     // 11px Regular - Fine print
    case micro        // 10px SemiBold - Badges, status indicators
    
    var font: Font {
        switch self {
        case .display: return .system(size: 36, weight: .bold)
        case .largeTitle: return .largeTitle.weight(.bold)
        case .title: return .title.weight(.bold)
        case .title2: return .title2.weight(.semibold)
        case .title3: return .title3.weight(.semibold)
        case .headline: return .headline.weight(.semibold)
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption.weight(.medium)
        case .caption2: return .caption2
        case .micro: return .system(size: 10, weight: .semibold)
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
        color: Color = .textPrimary,
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
        HXText("Subheadline", style: .subheadline, color: .textSecondary)
        HXText("Caption", style: .caption, color: .textSecondary)
    }
    .padding()
}
