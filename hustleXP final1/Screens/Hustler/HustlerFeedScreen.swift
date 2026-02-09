//
//  HustlerFeedScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity)
//  Premium task discovery with filters and search
//

import SwiftUI

struct HustlerFeedScreen: View {
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    @State private var searchText: String = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var isLoading: Bool = false
    @State private var showFilters: Bool = false
    
    private var filteredTasks: [HXTask] {
        var tasks = dataService.availableTasks
        
        // Apply search filter
        if !searchText.isEmpty {
            tasks = tasks.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .nearby:
            // In production, would filter by distance
            break
        case .highPay:
            tasks = tasks.filter { $0.payment >= 50 }
        case .quickTask:
            tasks = tasks.filter { $0.estimatedDuration.contains("min") || $0.estimatedDuration.contains("30") }
        case .mySkills:
            // In production, would match user capabilities
            break
        }
        
        return tasks
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.brandBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Stats header
                feedHeader
                
                // Filter chips
                filterSection
                
                // Task list
                taskListSection
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $searchText, prompt: "Search tasks, locations...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilters.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(Color.surfaceElevated)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.brandPurple)
                    }
                }
            }
        }
    }
    
    // MARK: - Feed Header
    
    private var feedHeader: some View {
        HStack(spacing: 16) {
            // Available tasks count
            VStack(alignment: .leading, spacing: 4) {
                Text("\(filteredTasks.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                
                Text("tasks available")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            // Total potential earnings
            VStack(alignment: .trailing, spacing: 4) {
                let totalPotential = filteredTasks.reduce(0) { $0 + $1.payment }
                Text("$\(Int(totalPotential))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moneyGreen)
                
                Text("potential earnings")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.brandPurple.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Task List Section
    
    private var taskListSection: some View {
        Group {
            if isLoading {
                LoadingState(variant: .skeleton)
            } else if filteredTasks.isEmpty {
                emptyStateView
            } else {
                taskList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            
            VStack(spacing: 8) {
                Text("No tasks found")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Try adjusting your filters or check back later")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            HXButton("Clear Filters", variant: .secondary, size: .medium, isFullWidth: false) {
                selectedFilter = .all
                searchText = ""
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Featured task (first one with highest pay)
                if let featured = filteredTasks.max(by: { $0.payment < $1.payment }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.warningOrange)
                            
                            Text("HOT OPPORTUNITY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(Color.warningOrange)
                        }
                        
                        TaskCard(
                            title: featured.title,
                            payment: featured.payment,
                            location: featured.location,
                            duration: featured.estimatedDuration,
                            variant: .featured,
                            posterName: "Top Poster",
                            category: "Best Match"
                        ) {
                            router.navigateToHustler(.taskDetail(taskId: featured.id))
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Regular tasks
                ForEach(filteredTasks) { task in
                    TaskCard(
                        title: task.title,
                        payment: task.payment,
                        location: task.location,
                        duration: task.estimatedDuration,
                        variant: .expanded,
                        posterName: "Task Poster"
                    ) {
                        router.navigateToHustler(.taskDetail(taskId: task.id))
                    }
                }
            }
            .padding(20)
        }
        .refreshable {
            await refreshTasksAsync()
        }
    }
    
    private func refreshTasksAsync() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case nearby = "Nearby"
    case highPay = "High Pay"
    case quickTask = "Quick"
    case mySkills = "My Skills"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .nearby: return "location"
        case .highPay: return "dollarsign"
        case .quickTask: return "bolt"
        case .mySkills: return "star"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brandPurple, Color.brandPurpleLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Capsule()
                            .fill(Color.surfaceElevated)
                        
                        Capsule()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color.brandPurple.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        HustlerFeedScreen()
    }
    .environment(Router())
    .environment(MockDataService.shared)
}
