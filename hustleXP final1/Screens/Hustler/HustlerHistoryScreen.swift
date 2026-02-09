//
//  HustlerHistoryScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct HustlerHistoryScreen: View {
    @Environment(MockDataService.self) private var dataService
    @Environment(Router.self) private var router
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            Group {
                if dataService.completedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
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
        ScrollView {
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
        VStack {
            Spacer()
            EmptyState(
                icon: "clock.arrow.circlepath",
                title: "No Completed Tasks Yet",
                message: "Your completed tasks will appear here",
                actionTitle: "Browse Tasks"
            ) {
                // Navigate to feed - would need tab switching
            }
            Spacer()
        }
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
                
                HXBadge(variant: .status(.completed))
            }
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        HustlerHistoryScreen()
    }
    .environment(MockDataService.shared)
    .environment(Router())
}
