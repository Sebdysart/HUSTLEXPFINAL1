//
//  PosterTaskDetailScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//

import SwiftUI

struct PosterTaskDetailScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    
    let taskId: String
    
    @State private var task: HXTask?
    @State private var isLoading = true
    @State private var showCancelConfirmation = false
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            if isLoading {
                LoadingState(message: "Loading task...")
            } else if let task = task {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Task header card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HXText(task.title, style: .title2)
                                Spacer()
                                TaskStatusBadge(state: task.state)
                            }
                            
                            HStack(spacing: 20) {
                                // Price
                                HStack(spacing: 6) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundStyle(Color.moneyGreen)
                                    HXText("$\(Int(task.payment))", style: .headline, color: .moneyGreen)
                                }
                                
                                // Duration
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .foregroundStyle(Color.textSecondary)
                                    HXText(task.estimatedDuration, style: .subheadline, color: .textSecondary)
                                }
                                
                                Spacer()
                                
                                // Tier requirement
                                HXBadge(variant: .tier(task.requiredTier))
                            }
                        }
                        .padding(20)
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                        
                        // Description section
                        VStack(alignment: .leading, spacing: 12) {
                            HXText("Description", style: .headline)
                            
                            HXText(task.description, style: .body, color: .textSecondary)
                        }
                        .padding(20)
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                        
                        // Location section
                        VStack(alignment: .leading, spacing: 12) {
                            HXText("Location", style: .headline)
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPurple.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.brandPurple)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HXText(task.location, style: .body)
                                    HXText("0.5 miles away", style: .caption, color: .textSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    HXText("View Map", style: .subheadline, color: .brandPurple)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                        
                        // Assigned hustler section (if in progress)
                        if task.state == .inProgress || task.state == .pendingVerification {
                            AssignedHustlerSection(task: task, router: router)
                        }
                        
                        // Applicants section (if posted)
                        if task.state == .posted {
                            ApplicantsSection()
                        }
                        
                        // Timeline section
                        TaskTimelineSection(task: task)
                        
                        Spacer(minLength: 120)
                    }
                    .padding(24)
                }
                
                // Bottom action bar
                VStack(spacing: 0) {
                    Spacer()
                    
                    TaskActionBar(task: task, router: router, onCancel: {
                        showCancelConfirmation = true
                    })
                }
            } else {
                ErrorState(
                    title: "Task Not Found",
                    message: "This task may have been removed or is no longer available.",
                    retryAction: { loadTask() }
                )
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("Edit Task", systemImage: "pencil")
                    }
                    Button(action: {}) {
                        Label("Share Task", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(role: .destructive, action: { showCancelConfirmation = true }) {
                        Label("Cancel Task", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
        .alert("Cancel Task?", isPresented: $showCancelConfirmation) {
            Button("Keep Task", role: .cancel) {}
            Button("Cancel Task", role: .destructive) {
                cancelTask()
            }
        } message: {
            Text("This will cancel the task and notify any assigned hustler. This action cannot be undone.")
        }
        .onAppear {
            loadTask()
        }
    }
    
    private func loadTask() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            task = MockDataService.shared.getTask(by: taskId)
            isLoading = false
        }
    }
    
    private func cancelTask() {
        // Handle cancellation
        router.posterPath.removeLast()
    }
}

// MARK: - Task Status Badge
private struct TaskStatusBadge: View {
    let state: TaskState
    
    var color: Color {
        switch state {
        case .posted: return .infoBlue
        case .claimed: return .warningOrange
        case .inProgress: return .brandPurple
        case .pendingVerification: return .warningOrange
        case .completed: return .successGreen
        case .cancelled: return .errorRed
        case .disputed: return .errorRed
        }
    }
    
    var body: some View {
        HXText(state.rawValue, style: .caption, color: color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Assigned Hustler Section
private struct AssignedHustlerSection: View {
    let task: HXTask
    let router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Assigned Hustler", style: .headline)
            
            HStack(spacing: 16) {
                HXAvatar(imageURL: nil, size: .medium, initials: "JD")
                
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Jane Doe", style: .headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.warningOrange)
                        HXText("4.9", style: .caption)
                        HXText("•", style: .caption, color: .textTertiary)
                        HXBadge(variant: .tier(.verified))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    router.navigateToPoster(.conversation(taskId: task.id))
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "message.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Applicants Section
private struct ApplicantsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Applicants", style: .headline)
                Spacer()
                HXBadge(variant: .count(3))
            }
            
            HXText(
                "3 hustlers have applied for this task",
                style: .subheadline,
                color: .textSecondary
            )
            
            HXButton("View Applicants", variant: .secondary) {
                // Navigate to applicants
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Task Timeline Section
private struct TaskTimelineSection: View {
    let task: HXTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Timeline", style: .headline)
            
            VStack(spacing: 0) {
                TimelineRow(
                    title: "Task Posted",
                    subtitle: "Dec 15, 2024 at 2:30 PM",
                    isCompleted: true,
                    isLast: false
                )
                
                if task.state != .posted {
                    TimelineRow(
                        title: "Hustler Assigned",
                        subtitle: "Dec 15, 2024 at 3:15 PM",
                        isCompleted: true,
                        isLast: false
                    )
                }
                
                if task.state == .inProgress || task.state == .pendingVerification || task.state == .completed {
                    TimelineRow(
                        title: "Task Started",
                        subtitle: "Dec 15, 2024 at 4:00 PM",
                        isCompleted: true,
                        isLast: task.state == .inProgress
                    )
                }
                
                if task.state == .pendingVerification || task.state == .completed {
                    TimelineRow(
                        title: "Proof Submitted",
                        subtitle: task.state == .completed ? "Dec 15, 2024 at 5:30 PM" : "Awaiting your review",
                        isCompleted: task.state == .completed,
                        isLast: task.state == .pendingVerification
                    )
                }
                
                if task.state == .completed {
                    TimelineRow(
                        title: "Completed",
                        subtitle: "Dec 15, 2024 at 6:00 PM",
                        isCompleted: true,
                        isLast: true
                    )
                }
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Timeline Row
private struct TimelineRow: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? Color.successGreen : Color.surfaceSecondary)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(isCompleted ? Color.successGreen : Color.borderSubtle, lineWidth: 2)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.successGreen.opacity(0.5) : Color.borderSubtle)
                        .frame(width: 2, height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HXText(title, style: .subheadline, color: isCompleted ? .textPrimary : .textSecondary)
                HXText(subtitle, style: .caption, color: .textTertiary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Task Action Bar
private struct TaskActionBar: View {
    let task: HXTask
    let router: Router
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HStack(spacing: 16) {
                if task.state == .pendingVerification {
                    HXButton("Review Proof", variant: .primary) {
                        router.navigateToPoster(.proofReview(taskId: task.id))
                    }
                } else if task.state == .posted {
                    HXButton("Edit Task", variant: .secondary) {
                        // Edit task
                    }
                    
                    HXButton("Cancel", variant: .ghost) {
                        onCancel()
                    }
                    .frame(width: 100)
                } else if task.state == .inProgress {
                    HXButton("Message Hustler", variant: .primary) {
                        router.navigateToPoster(.conversation(taskId: task.id))
                    }
                }
            }
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

#Preview {
    NavigationStack {
        PosterTaskDetailScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
