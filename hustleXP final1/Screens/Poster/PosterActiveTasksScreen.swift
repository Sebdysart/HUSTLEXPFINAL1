//
//  PosterActiveTasksScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity)
//

import SwiftUI

struct PosterActiveTasksScreen: View {
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    @State private var selectedFilter: PosterTaskFilter = .all
    
    private var myTasks: [HXTask] {
        let tasks = dataService.availableTasks.filter { $0.posterId == dataService.currentUser.id }
        
        switch selectedFilter {
        case .all:
            return tasks
        case .posted:
            return tasks.filter { $0.state == .posted }
        case .inProgress:
            return tasks.filter { $0.isActive }
        case .completed:
            return dataService.completedTasks.filter { $0.posterId == dataService.currentUser.id }
        }
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter bar
                filterBar
                
                // Task list
                if myTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
        }
        .navigationTitle("Your Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { router.navigateToPoster(.createTask) }) {
                    HXIcon(HXIcon.add, size: .medium, color: .brandPurple)
                }
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PosterTaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.brandBlack)
    }
    
    // MARK: - Task List
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(myTasks) { task in
                    TaskCard(
                        title: task.title,
                        payment: task.payment,
                        location: task.location,
                        duration: task.estimatedDuration,
                        status: task.badgeStatus,
                        variant: .expanded
                    ) {
                        router.navigateToPoster(.taskDetail(taskId: task.id))
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyState(
                icon: selectedFilter == .all ? "doc.text" : "tray",
                title: emptyTitle,
                message: emptyMessage,
                actionTitle: selectedFilter == .all ? "Post a Task" : nil
            ) {
                router.navigateToPoster(.createTask)
            }
            Spacer()
        }
    }
    
    private var emptyTitle: String {
        switch selectedFilter {
        case .all: return "No Tasks Yet"
        case .posted: return "No Posted Tasks"
        case .inProgress: return "No Active Tasks"
        case .completed: return "No Completed Tasks"
        }
    }
    
    private var emptyMessage: String {
        switch selectedFilter {
        case .all: return "Post your first task to get started"
        case .posted: return "All your posted tasks have been claimed"
        case .inProgress: return "No tasks currently in progress"
        case .completed: return "Your completed tasks will appear here"
        }
    }
}

enum PosterTaskFilter: String, CaseIterable {
    case all = "All"
    case posted = "Posted"
    case inProgress = "In Progress"
    case completed = "Completed"
}

#Preview {
    NavigationStack {
        PosterActiveTasksScreen()
    }
    .environment(Router())
    .environment(MockDataService.shared)
}
