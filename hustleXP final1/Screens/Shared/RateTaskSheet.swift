//
//  RateTaskSheet.swift
//  hustleXP final1
//
//  v2.5.0: Reusable rating sheet for both poster→worker and worker→poster
//  Wired to backend rating.submitRating via RatingService
//

import SwiftUI

struct RateTaskSheet: View {
    let taskId: String
    let taskTitle: String
    let otherUserName: String
    @Binding var isPresented: Bool

    @State private var rating: Int = 0
    @State private var review: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var submitError: String?
    @State private var showError = false

    private let availableTags = ["On Time", "Professional", "Friendly", "Good Quality", "Fast", "Great Communication"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                if showSuccess {
                    successView
                } else {
                    ratingForm
                }
            }
            .navigationTitle("Rate Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(submitError ?? "Failed to submit rating")
            }
        }
    }

    private var ratingForm: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    HXText("How was your experience?", style: .title3)
                    HXText("Rate \(otherUserName) for \"\(taskTitle)\"", style: .subheadline, color: .textSecondary, alignment: .center)
                }
                .padding(.top, 8)

                // Star rating
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            withAnimation(.spring(response: 0.2)) {
                                rating = star
                            }
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundStyle(star <= rating ? Color.warningOrange : Color.textTertiary)
                                .scaleEffect(star <= rating ? 1.1 : 1.0)
                        }
                        .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                    }
                }

                // Rating label
                if rating > 0 {
                    HXText(ratingLabel, style: .headline, color: .brandPurple)
                        .transition(.opacity)
                }

                // Tags
                VStack(alignment: .leading, spacing: 12) {
                    HXText("What stood out? (optional)", style: .subheadline, color: .textSecondary)

                    RateTagsFlowLayout(spacing: 8) {
                        ForEach(availableTags, id: \.self) { tag in
                            Button {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            } label: {
                                Text(tag)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(selectedTags.contains(tag) ? .white : Color.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedTags.contains(tag) ? Color.brandPurple : Color.surfaceElevated)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Review text
                VStack(alignment: .leading, spacing: 8) {
                    HXText("Write a review (optional)", style: .subheadline, color: .textSecondary)

                    TextField("", text: $review, prompt: Text("Share your experience...").foregroundColor(.textTertiary), axis: .vertical)
                        .lineLimit(3...6)
                        .padding(16)
                        .background(Color.surfaceElevated)
                        .cornerRadius(12)
                        .foregroundStyle(Color.textPrimary)
                }

                // Submit button
                HXButton(
                    isSubmitting ? "Submitting..." : "Submit Rating",
                    variant: rating > 0 ? .primary : .secondary,
                    isLoading: isSubmitting
                ) {
                    submitRating()
                }
                .disabled(rating == 0 || isSubmitting)
            }
            .padding(24)
        }
    }

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.successGreen)
            }

            VStack(spacing: 8) {
                HXText("Rating Submitted", style: .title2)
                HXText("Thanks for your feedback!", style: .body, color: .textSecondary)
            }

            Spacer()

            HXButton("Done") {
                isPresented = false
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var ratingLabel: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Below Average"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent!"
        default: return ""
        }
    }

    private func submitRating() {
        isSubmitting = true

        Task {
            do {
                try await RatingService.shared.submitRating(
                    taskId: taskId,
                    rating: rating,
                    review: review.isEmpty ? nil : review,
                    tags: selectedTags.isEmpty ? nil : Array(selectedTags)
                )
                withAnimation { showSuccess = true }
            } catch {
                submitError = error.localizedDescription
                showError = true
            }
            isSubmitting = false
        }
    }
}

// MARK: - Flow Layout for Tags

private struct RateTagsFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    RateTaskSheet(
        taskId: "test-123",
        taskTitle: "Deliver Package",
        otherUserName: "Jane Doe",
        isPresented: .constant(true)
    )
}
