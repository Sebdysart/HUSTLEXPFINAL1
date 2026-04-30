//
//  SkeletonView.swift
//  hustleXP final1
//
//  Animated shimmer placeholders for loading states.
//  Use instead of plain ProgressView for polished perceived-performance.
//

import SwiftUI

/// Animated skeleton loading placeholder — generic rounded rect.
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.surfaceElevated)
            .frame(width: width, height: height)
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0), location: 0),
                        .init(color: Color.white.opacity(0.08), location: 0.5),
                        .init(color: Color.white.opacity(0), location: 1),
                    ],
                    startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                    endPoint: UnitPoint(x: phase + 0.3, y: 0.5)
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

/// Alias for clarity in newer code — same as SkeletonView.
typealias SkeletonRect = SkeletonView

/// Skeleton card for task list loading state — matches real TaskCard layout.
struct SkeletonTaskCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonView(width: 180, height: 18, cornerRadius: 6)
                Spacer()
                SkeletonView(width: 60, height: 22, cornerRadius: 11) // status pill
            }

            HStack(spacing: 12) {
                SkeletonView(width: 50, height: 14)
                SkeletonView(width: 70, height: 14)
                Spacer()
            }

            SkeletonView(width: nil, height: 12)
            SkeletonView(width: 220, height: 12)

            HStack {
                SkeletonView(width: 60, height: 24, cornerRadius: 8)
                Spacer()
                SkeletonView(width: 80, height: 28, cornerRadius: 14)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surfaceElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

/// Skeleton list — drop-in replacement for "loading" state.
struct SkeletonTaskList: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonTaskCard()
            }
        }
    }
}

/// Older alias kept for compatibility with existing call sites.
typealias SkeletonList = SkeletonTaskList

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        VStack(spacing: 20) {
            SkeletonView(width: 200, height: 20)
            SkeletonTaskList(count: 2)
        }
        .padding()
    }
}
