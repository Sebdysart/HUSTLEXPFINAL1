//
//  PosterHistoryScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct PosterHistoryScreen: View {
    @Environment(MockDataService.self) private var dataService
    
    @State private var selectedFilter: HistoryFilter = .all
    @State private var completedTasks: [HXTask] = []
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter tabs
                FilterTabsView(selectedFilter: $selectedFilter)
                
                if completedTasks.isEmpty {
                    // Empty state
                    EmptyHistoryView()
                } else {
                    // Task list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTasks) { task in
                                PosterCompletedTaskCard(task: task)
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private var filteredTasks: [HXTask] {
        switch selectedFilter {
        case .all:
            return completedTasks
        case .completed:
            return completedTasks.filter { $0.state == .completed }
        case .cancelled:
            return completedTasks.filter { $0.state == .cancelled }
        }
    }
}

// MARK: - History Filter
private enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Filter Tabs View
private struct FilterTabsView: View {
    @Binding var selectedFilter: HistoryFilter
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                FilterTab(
                    title: filter.rawValue,
                    isSelected: selectedFilter == filter
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Filter Tab
private struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HXText(
                title,
                style: .subheadline,
                color: isSelected ? .white : .textSecondary
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandPurple : Color.surfaceElevated)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty History View
private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.textSecondary)
            }
            
            VStack(spacing: 12) {
                HXText("No Completed Tasks", style: .title2)
                
                HXText(
                    "Tasks you complete will appear here.\nPost a task to get started!",
                    style: .body,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Poster Completed Task Card
private struct PosterCompletedTaskCard: View {
    let task: HXTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HXText(task.title, style: .headline)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textTertiary)
                        
                        HXText(
                            formatDate(task.completedAt ?? task.createdAt),
                            style: .caption,
                            color: .textTertiary
                        )
                    }
                }
                
                Spacer()
                
                TaskStateBadge(state: task.state)
            }
            
            HXDivider()
            
            // Details
            HStack(spacing: 24) {
                DetailItem(
                    icon: "dollarsign.circle.fill",
                    iconColor: .moneyGreen,
                    value: "$\(Int(task.payment))",
                    label: "Paid"
                )
                
                if let hustlerName = task.hustlerName {
                    DetailItem(
                        icon: "person.fill",
                        iconColor: .brandPurple,
                        value: hustlerName,
                        label: "Hustler"
                    )
                }
                
                Spacer()
            }
            
            // Rating given (if completed)
            if task.state == .completed {
                HStack(spacing: 8) {
                    HXText("Rating given:", style: .caption, color: .textSecondary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(index < 5 ? Color.warningOrange : Color.textTertiary)
                        }
                    }
                }
                .padding(12)
                .background(Color.surfaceSecondary)
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Task State Badge
private struct TaskStateBadge: View {
    let state: TaskState
    
    var color: Color {
        switch state {
        case .completed: return .successGreen
        case .cancelled: return .errorRed
        default: return .textSecondary
        }
    }
    
    var body: some View {
        HXText(state.rawValue.capitalized, style: .caption, color: color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Detail Item
private struct DetailItem: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(value, style: .subheadline)
                HXText(label, style: .caption, color: .textTertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PosterHistoryScreen()
    }
    .environment(MockDataService.shared)
}
