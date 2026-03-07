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
                        Color.surfaceSecondary,
                        Color.surfaceElevated,
                        Color.surfaceSecondary,
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

/// Skeleton row for conversation/message list loading state
struct SkeletonConversationRow: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(width: 48, height: 48, cornerRadius: 24) // avatar
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 140, height: 16) // name
                SkeletonView(height: 14) // preview text
            }
            Spacer()
            SkeletonView(width: 40, height: 12, cornerRadius: 6) // timestamp
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

/// Skeleton row for notification list loading state
struct SkeletonNotificationRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SkeletonView(width: 40, height: 40, cornerRadius: 20) // icon circle
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 200, height: 15) // title
                SkeletonView(height: 13) // body
                SkeletonView(width: 80, height: 11, cornerRadius: 5) // timestamp
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color.brandBlack
            .ignoresSafeArea()
        VStack(spacing: 20) {
            SkeletonView(width: 200, height: 20)
            SkeletonTaskCard()
            SkeletonList(count: 2)
            Divider()
            SkeletonConversationRow()
            SkeletonNotificationRow()
        }
        .padding()
    }
}
