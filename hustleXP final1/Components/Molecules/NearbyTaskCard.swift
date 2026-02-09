//
//  NearbyTaskCard.swift
//  hustleXP final1
//
//  Task batching recommendation card for v1.9.0
//

import SwiftUI

struct NearbyTaskCard: View {
    let recommendation: BatchRecommendation
    var onAccept: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    var isCompact: Bool = false
    
    @State private var isExpanded: Bool = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with AI badge
            HStack {
                // Smart Batch badge
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                    Text("SMART BATCH")
                        .font(.system(size: isCompact ? 9 : 10, weight: .heavy))
                        .tracking(1.5)
                }
                .foregroundStyle(Color.aiPurple)
                .padding(.horizontal, isCompact ? 8 : 10)
                .padding(.vertical, isCompact ? 4 : 6)
                .background(Color.aiPurple.opacity(0.15))
                .clipShape(Capsule())
                
                Spacer()
                
                // Dismiss button
                Button(action: { onDismiss?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 28, height: 28)
                        .background(Color.surfaceSecondary)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, isCompact ? 10 : 14)
            
            // Main content
            VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
                Text("Another task nearby!")
                    .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Complete \"\(recommendation.primaryTask.title.prefix(25))...\" and pick up another in \(recommendation.savings.timeSavedMinutes) min")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Stats row
            HStack(spacing: isCompact ? 12 : 16) {
                StatPill(
                    icon: "dollarsign",
                    value: recommendation.formattedTotalPayment,
                    color: .moneyGreen,
                    isCompact: isCompact
                )
                
                StatPill(
                    icon: "clock",
                    value: recommendation.totalEstimatedTime,
                    color: .warningOrange,
                    isCompact: isCompact
                )
                
                StatPill(
                    icon: "bolt.fill",
                    value: recommendation.savings.formattedEfficiencyBoost,
                    color: .brandPurple,
                    isCompact: isCompact
                )
            }
            .padding(.top, isCompact ? 10 : 14)
            
            // Task count indicator
            HStack(spacing: 6) {
                ForEach(0..<recommendation.taskCount, id: \.self) { index in
                    Circle()
                        .fill(index == 0 ? Color.brandPurple : Color.aiPurple.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
                
                Text("\(recommendation.taskCount) tasks in batch")
                    .font(.system(size: isCompact ? 10 : 11, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.top, isCompact ? 8 : 10)
            
            // Action button
            Button(action: { onAccept?() }) {
                HStack(spacing: 8) {
                    Text("View Batch")
                        .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: isCompact ? 12 : 14, weight: .bold))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isCompact ? 12 : 14)
                .background(
                    LinearGradient(
                        colors: [Color.brandPurple, Color.aiPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, isCompact ? 12 : 16)
        }
        .padding(isCompact ? 14 : 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aiPurple.opacity(0.3), lineWidth: 1)
                )
        )
        .overlay(
            // Shimmer effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.aiPurple.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .mask(RoundedRectangle(cornerRadius: 20))
        )
        .shadow(color: Color.aiPurple.opacity(0.2), radius: 16, y: 8)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let icon: String
    let value: String
    let color: Color
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 10 : 12, weight: .semibold))
            Text(value)
                .font(.system(size: isCompact ? 11 : 13, weight: .bold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 5 : 6)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Mini Nearby Indicator

struct MiniNearbyIndicator: View {
    let nearbyCount: Int
    let walkingTime: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aiPurple)
            
            Text("+\(nearbyCount) nearby")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.aiPurple)
            
            Text("•")
                .foregroundStyle(Color.textMuted)
            
            Text("\(walkingTime) min walk")
                .font(.system(size: 11))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.aiPurple.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Batch Summary Card

struct BatchSummaryCard: View {
    let batch: BatchRecommendation
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: isCompact ? 12 : 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.aiPurple)
                        
                        Text("Task Batch")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    
                    Text("\(batch.taskCount) tasks • \(batch.totalEstimatedTime)")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
                
                // Total earnings
                VStack(alignment: .trailing, spacing: 2) {
                    Text(batch.formattedTotalPayment)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.moneyGreen)
                    
                    Text("total")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            
            Divider()
                .background(Color.borderSubtle)
            
            // Savings breakdown
            HStack(spacing: 20) {
                SavingItem(
                    icon: "clock.arrow.circlepath",
                    label: "Time Saved",
                    value: batch.savings.formattedTimeSaved,
                    color: .warningOrange
                )
                
                SavingItem(
                    icon: "bolt.fill",
                    label: "Efficiency",
                    value: batch.savings.formattedEfficiencyBoost,
                    color: .brandPurple
                )
            }
        }
        .padding(isCompact ? 14 : 18)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.aiPurple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SavingItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        NearbyTaskCard(
            recommendation: BatchRecommendation(
                id: "batch_1",
                primaryTask: HXTask(
                    id: "1",
                    title: "Pick up groceries from Whole Foods",
                    description: "Description",
                    payment: 25,
                    location: "Downtown SF",
                    latitude: 37.7749,
                    longitude: -122.4194,
                    estimatedDuration: "30 min",
                    posterId: "p1",
                    posterName: "John",
                    posterRating: 4.5,
                    state: .posted,
                    requiredTier: .rookie,
                    createdAt: Date()
                ),
                nearbyTasks: [
                    HXTask(
                        id: "2",
                        title: "Drop off package",
                        description: "Description",
                        payment: 15,
                        location: "Mission",
                        latitude: 37.7599,
                        longitude: -122.4148,
                        estimatedDuration: "15 min",
                        posterId: "p2",
                        posterName: "Jane",
                        posterRating: 4.8,
                        state: .posted,
                        requiredTier: .rookie,
                        createdAt: Date()
                    )
                ],
                totalPayment: 40,
                totalEstimatedTime: "50 min",
                savings: BatchSavings(
                    timeSavedMinutes: 15,
                    extraEarnings: 15,
                    efficiencyBoost: 25
                ),
                expiresAt: nil
            )
        )
        
        MiniNearbyIndicator(nearbyCount: 2, walkingTime: 8)
    }
    .padding()
    .background(Color.brandBlack)
}
