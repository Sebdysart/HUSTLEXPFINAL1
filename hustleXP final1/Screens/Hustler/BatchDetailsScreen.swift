//
//  BatchDetailsScreen.swift
//  hustleXP final1
//
//  Task batch details screen for v1.9.0 Spatial Intelligence
//

import SwiftUI

struct BatchDetailsScreen: View {
    let batchId: String
    
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    @State private var batch: BatchRecommendation?
    @State private var isAcceptingBatch: Bool = false
    
    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            if let batch = batch {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header card with total earnings
                        batchHeaderCard(batch)
                        
                        // Map showing all tasks
                        batchMapCard(batch)
                        
                        // Savings breakdown
                        savingsBreakdownCard(batch)
                        
                        // Task list
                        taskListSection(batch)
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomActionBar(batch)
                }
            } else {
                loadingView
            }
        }
        .navigationTitle("Task Batch")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            loadBatch()
        }
    }
    
    // MARK: - Header Card
    
    private func batchHeaderCard(_ batch: BatchRecommendation) -> some View {
        VStack(spacing: 16) {
            // AI Badge
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                    Text("SMART BATCH")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.5)
                }
                .foregroundStyle(Color.aiPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.aiPurple.opacity(0.15))
                .clipShape(Capsule())
                
                Spacer()
                
                // Task count
                Text("\(batch.taskCount) tasks")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Total earnings
            HStack(alignment: .bottom, spacing: 8) {
                Text(batch.formattedTotalPayment)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moneyGreen)
                
                Text("total earnings")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.bottom, 8)
                
                Spacer()
            }
            
            // Time estimate
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.brandPurple)
                    Text(batch.totalEstimatedTime)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.warningOrange)
                    Text(batch.savings.formattedEfficiencyBoost + " efficiency")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aiPurple.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.aiPurple.opacity(0.15), radius: 16, y: 8)
    }
    
    // MARK: - Map Card
    
    private func batchMapCard(_ batch: BatchRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
                Text("Route Overview")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            // Mini cluster map
            TaskClusterMapView(tasks: batch.allTasks)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Savings Breakdown
    
    private func savingsBreakdownCard(_ batch: BatchRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.moneyGreen)
                Text("Your Savings")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            HStack(spacing: 16) {
                SavingsStatCard(
                    icon: "clock.arrow.circlepath",
                    title: "Time Saved",
                    value: batch.savings.formattedTimeSaved,
                    color: .warningOrange
                )
                
                SavingsStatCard(
                    icon: "dollarsign.arrow.circlepath",
                    title: "Extra Earned",
                    value: batch.savings.formattedExtraEarnings,
                    color: .moneyGreen
                )
            }
            
            // Explanation
            Text("By completing these tasks together, you avoid travel time between separate trips.")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Task List
    
    private func taskListSection(_ batch: BatchRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
                Text("Tasks in Batch")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            VStack(spacing: 12) {
                // Primary task
                BatchTaskRow(
                    task: batch.primaryTask,
                    isPrimary: true,
                    order: 1
                ) {
                    router.navigateToHustler(.taskDetail(taskId: batch.primaryTask.id))
                }
                
                // Nearby tasks
                ForEach(Array(batch.nearbyTasks.enumerated()), id: \.element.id) { index, task in
                    BatchTaskRow(
                        task: task,
                        isPrimary: false,
                        order: index + 2
                    ) {
                        router.navigateToHustler(.taskDetail(taskId: task.id))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Bottom Action Bar
    
    private func bottomActionBar(_ batch: BatchRecommendation) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
            
            HStack(spacing: 16) {
                // Individual tasks button
                Button(action: {
                    router.popHustler()
                }) {
                    Text("Pick Individual")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 120, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
                
                // Accept batch button
                Button(action: {
                    acceptBatch(batch)
                }) {
                    HStack(spacing: 8) {
                        if isAcceptingBatch {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text("Accept Batch")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.brandPurple.opacity(0.3), radius: 12, y: 4)
                }
                .disabled(isAcceptingBatch)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .colorScheme(.dark)
            )
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.brandPurple)
            
            Text("Loading batch...")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private func loadBatch() {
        // In production, would load from service
        // For now, use current recommendation
        batch = MockTaskBatchingService.shared.currentRecommendation
    }
    
    private func acceptBatch(_ batch: BatchRecommendation) {
        isAcceptingBatch = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Accept primary task
            dataService.claimTask(batch.primaryTask.id)
            
            // Navigate to task in progress
            router.navigateToHustler(.taskInProgress(taskId: batch.primaryTask.id))
        }
    }
}

// MARK: - Task Cluster Map View

struct TaskClusterMapView: View {
    let tasks: [HXTask]
    
    // SF map bounds
    private let minLat = 37.70
    private let maxLat = 37.82
    private let minLon = -122.52
    private let maxLon = -122.35
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                MapGridBackground()
                    .background(Color.surfaceSecondary)
                
                // Route lines connecting tasks
                if tasks.count > 1 {
                    RouteLines(
                        tasks: tasks,
                        size: geometry.size,
                        minLat: minLat,
                        maxLat: maxLat,
                        minLon: minLon,
                        maxLon: maxLon
                    )
                }
                
                // Task markers
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    if let lat = task.latitude, let lon = task.longitude {
                        let x = (lon - minLon) / (maxLon - minLon) * geometry.size.width
                        let y = (1 - (lat - minLat) / (maxLat - minLat)) * geometry.size.height
                        
                        ClusterTaskMarker(order: index + 1, isPrimary: index == 0)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

struct RouteLines: View {
    let tasks: [HXTask]
    let size: CGSize
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    
    var body: some View {
        Canvas { context, size in
            guard tasks.count > 1 else { return }
            
            var path = Path()
            var started = false
            
            for task in tasks {
                guard let lat = task.latitude, let lon = task.longitude else { continue }
                
                let x = (lon - minLon) / (maxLon - minLon) * size.width
                let y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height
                
                if !started {
                    path.move(to: CGPoint(x: x, y: y))
                    started = true
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(
                path,
                with: .color(Color.brandPurple.opacity(0.6)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4])
            )
        }
    }
}

struct ClusterTaskMarker: View {
    let order: Int
    let isPrimary: Bool
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(isPrimary ? Color.brandPurple.opacity(0.3) : Color.aiPurple.opacity(0.2))
                .frame(width: 32, height: 32)
            
            // Marker
            Circle()
                .fill(isPrimary ? Color.brandPurple : Color.aiPurple)
                .frame(width: 24, height: 24)
            
            // Order number
            Text("\(order)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Savings Stat Card

struct SavingsStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Batch Task Row

struct BatchTaskRow: View {
    let task: HXTask
    let isPrimary: Bool
    let order: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Order indicator
                ZStack {
                    Circle()
                        .fill(isPrimary ? Color.brandPurple : Color.aiPurple.opacity(0.5))
                        .frame(width: 32, height: 32)
                    
                    Text("\(order)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)
                        
                        if isPrimary {
                            Text("PRIMARY")
                                .font(.system(size: 8, weight: .heavy))
                                .tracking(1)
                                .foregroundStyle(Color.brandPurple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.brandPurple.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(task.location)
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                        
                        Text("•")
                            .foregroundStyle(Color.textMuted)
                        
                        Text(task.estimatedDuration)
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                
                Spacer()
                
                // Payment
                Text(task.formattedPayment)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.moneyGreen)
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceSecondary)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BatchDetailsScreen(batchId: "batch_1")
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
