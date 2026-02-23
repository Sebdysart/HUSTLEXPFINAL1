import SwiftUI

/// Animated skeleton loading placeholder
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray5),
                        Color(.systemGray4),
                        Color(.systemGray5),
                    ]),
                    startPoint: isAnimating ? .trailing : .leading,
                    endPoint: isAnimating ? .leading : .trailing
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// Skeleton card for task list loading state
struct SkeletonTaskCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(width: 200, height: 20)
            SkeletonView(height: 14)
            SkeletonView(width: 140, height: 14)
            HStack {
                SkeletonView(width: 60, height: 24, cornerRadius: 12)
                Spacer()
                SkeletonView(width: 80, height: 24, cornerRadius: 12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

/// Skeleton list for loading screens
struct SkeletonList: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonTaskCard()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonView(width: 200, height: 20)
        SkeletonTaskCard()
        SkeletonList(count: 2)
    }
    .padding()
}
