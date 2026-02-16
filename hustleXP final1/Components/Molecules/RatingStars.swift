//
//  RatingStars.swift
//  hustleXP final1
//
//  Molecule: RatingStars
//  Modes: display, input
//

import SwiftUI

enum RatingStarsMode {
    case display
    case input
}

struct RatingStars: View {
    let rating: Double
    let maxRating: Int
    let mode: RatingStarsMode
    let onRatingChanged: ((Int) -> Void)?
    
    @State private var selectedRating: Int
    
    init(
        rating: Double,
        maxRating: Int = 5,
        mode: RatingStarsMode = .display,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.mode = mode
        self.onRatingChanged = onRatingChanged
        self._selectedRating = State(initialValue: Int(rating))
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                starView(for: index)
            }
            
            if mode == .display {
                HXText(String(format: "%.1f", rating), style: .caption, color: .textSecondary)
            }
        }
    }
    
    @ViewBuilder
    private func starView(for index: Int) -> some View {
        let isFilled = mode == .input ? index <= selectedRating : Double(index) <= rating
        let isHalfFilled = mode == .display && Double(index) - 0.5 <= rating && Double(index) > rating
        
        Button(action: {
            if mode == .input {
                selectedRating = index
                onRatingChanged?(index)
            }
        }) {
            Image(systemName: isHalfFilled ? "star.leadinghalf.filled" : (isFilled ? "star.fill" : "star"))
                .foregroundStyle(isFilled || isHalfFilled ? Color.warningOrange : Color.textMuted.opacity(0.3))
                .font(mode == .input ? .title : .caption)
        }
        .disabled(mode == .display)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 24) {
        RatingStars(rating: 4.5, mode: .display)
        RatingStars(rating: 3.0, mode: .display)
        RatingStars(rating: 0, mode: .input) { rating in
            HXLogger.debug("Selected: \(rating)", category: "UI")
        }
    }
    .padding()
}
