//
//  SavedTasksScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity) — displays tasks bookmarked by the hustler
//

import SwiftUI

struct SavedTasksScreen: View {
    @Environment(Router.self) private var router
    @StateObject private var taskService = TaskService.shared

    @State private var savedTasks: [HXTask] = []
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            Group {
                if isLoading && savedTasks.isEmpty {
                    loadingView
                } else if let error = loadError, savedTasks.isEmpty {
                    errorView(error)
                } else if savedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
        }
        .navigationTitle("Saved Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await loadSavedTasks() }
        .refreshable { await loadSavedTasks() }
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                HStack {
                    Text("\(savedTasks.count) saved task\(savedTasks.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                ForEach(savedTasks) { task in
                    TaskCard(
                        title: task.title,
                        payment: task.hustlerNet,
                        location: task.location,
                        duration: task.estimatedDuration,
                        status: task.badgeStatus,
                        variant: .expanded,
                        posterName: task.posterName,
                        category: task.category?.rawValue
                    ) {
                        router.navigateToHustler(.taskDetail(taskId: task.id))
                    }
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.brandPurple)
                .scaleEffect(1.2)
            Text("Loading saved tasks...")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.warningOrange)
            Text("Couldn't load saved tasks")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                Task { await loadSavedTasks() }
            }
            .foregroundStyle(Color.brandPurple)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.brandPurple.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bookmark.slash")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(Color.textTertiary)
            Text("No Saved Tasks")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text("Tap the bookmark icon on any task to save it here for later.")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                router.navigateToHustler(.feed)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Browse Tasks")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.brandPurple)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
    }

    // MARK: - Data Loading

    private func loadSavedTasks() async {
        isLoading = true
        loadError = nil
        do {
            savedTasks = try await taskService.getBookmarkedTasks()
        } catch {
            loadError = error.localizedDescription
            HXLogger.error("SavedTasks: Failed to load - \(error.localizedDescription)", category: "Task")
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SavedTasksScreen()
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
