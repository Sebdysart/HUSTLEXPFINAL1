//
//  HustlerHistoryScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct HustlerHistoryScreen: View {
    @Environment(LiveDataService.self) private var dataService
    @Environment(Router.self) private var router
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                if dataService.completedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .refreshable {
                await dataService.refreshAll()
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Task List
    
    private var taskList: some View {
        LazyVStack(spacing: 12) {
            // Stats summary
            statsSummary

            // Completed tasks
            ForEach(dataService.completedTasks) { task in
                CompletedTaskCard(task: task)
            }
        }
        .padding()
    }
    
    // MARK: - Stats Summary
    
    private var statsSummary: some View {
        HStack(spacing: 16) {
            HistoryStatCard(
                title: "Completed",
                value: "\(dataService.currentUser.tasksCompleted)",
                color: .successGreen
            )
            HistoryStatCard(
                title: "Earned",
                value: "$\(Int(dataService.currentUser.totalEarnings))",
                color: .moneyGreen
            )
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: "No Completed Tasks Yet",
            message: "Your completed tasks will appear here.",
            ctaLabel: "Browse Tasks",
            ctaAction: { router.navigateToHustler() }
        )
    }
}

// MARK: - History Stat Card

struct HistoryStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HXText(value, style: .title2, color: color)
            HXText(title, style: .caption, color: .textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Completed Task Card

struct CompletedTaskCard: View {
    let task: HXTask
    @State private var showRating = false
    @State private var hasRated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HXText(task.title, style: .headline)
                    HXText(task.location, style: .caption, color: .textSecondary)
                }

                Spacer()

                PriceDisplay(amount: task.payment, size: .small, color: .successGreen)
            }

            HXDivider()

            HStack {
                if let completedAt = task.completedAt {
                    HXText(completedAt.formatted(date: .abbreviated, time: .omitted), style: .caption, color: .textSecondary)
                }

                Spacer()

                if hasRated {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(Color.warningOrange)
                        Text("Rated")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                } else {
                    Button {
                        showRating = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "star")
                                .font(.caption)
                            Text("Rate")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(Color.brandPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.brandPurple.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(12)
        .sheet(isPresented: $showRating) {
            RateTaskSheet(
                taskId: task.id,
                taskTitle: task.title,
                otherUserName: task.posterName,
                isPresented: $showRating
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onDisappear {
                // If rating was submitted, mark as rated
                // RateTaskSheet sets isPresented = false on success
                // We optimistically mark as rated since the sheet auto-dismisses after success
            }
        }
        .onChange(of: showRating) { _, newValue in
            // When sheet closes, if it was open before, assume rated
            // (RateTaskSheet shows success view then closes)
            if !newValue && !hasRated {
                // Check if rating was actually submitted by trying to load it
                Task {
                    do {
                        let ratings = try await RatingService.shared.getTaskRatings(taskId: task.id)
                        if !ratings.isEmpty { hasRated = true }
                    } catch {
                        // Ignore — we'll check again next time
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HustlerHistoryScreen()
    }
    .environment(LiveDataService.shared)
    .environment(Router())
}
