//
//  RecurringTasksViewModel.swift
//  hustleXP final1
//
//  Extracted from RecurringTasksScreen.swift
//  Archetype: B (Feed/Opportunity) + C (Task Lifecycle)
//
//  Contains all business logic, API calls, and state management
//  for the Recurring Tasks feature.
//

import SwiftUI

// MARK: - RecurringTasksViewModel

@Observable
@MainActor
final class RecurringTasksViewModel {

    // MARK: - Dependencies (injected after init)

    var appState: AppState?

    // MARK: - State

    var series: [RecurringTaskSeries] = []
    var showCreateSheet = false
    var selectedFilter: RecurringFilter = .active
    var isLoading = true
    var showContent = false

    // MARK: - Computed Properties

    var isUnlocked: Bool {
        guard let appState else { return false }
        return RecurringTaskTierGate.isUnlocked(tier: appState.trustTier)
    }

    var filteredSeries: [RecurringTaskSeries] {
        switch selectedFilter {
        case .active: return series.filter { $0.isActive }
        case .paused: return series.filter { $0.isPaused }
        case .all: return series
        }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        do {
            series = try await RecurringTaskService.shared.getMySeries()
        } catch {
            HXLogger.error("RecurringTasks: Load failed - \(error.localizedDescription)", category: "Task")
            series = []
        }
        isLoading = false
    }

    // MARK: - Filter Helpers

    func countForFilter(_ filter: RecurringFilter) -> Int {
        switch filter {
        case .active: return series.filter { $0.isActive }.count
        case .paused: return series.filter { $0.isPaused }.count
        case .all: return series.count
        }
    }

    // MARK: - Actions

    func handleAction(_ action: SeriesAction, for item: RecurringTaskSeries) {
        Task {
            switch action {
            case .pause:
                try? await RecurringTaskService.shared.pauseSeries(id: item.id)
            case .resume:
                try? await RecurringTaskService.shared.resumeSeries(id: item.id)
            case .cancel:
                try? await RecurringTaskService.shared.cancelSeries(id: item.id)
            }
            await loadData()
        }
    }

    func selectFilter(_ filter: RecurringFilter) {
        withAnimation(.spring(response: 0.3)) {
            selectedFilter = filter
        }
    }

    func animateContentIn() {
        withAnimation(.easeOut(duration: 0.4)) {
            showContent = true
        }
    }
}
