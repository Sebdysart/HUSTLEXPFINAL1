//
//  PosterTaskDetailScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//

import SwiftUI
import Combine

struct PosterTaskDetailScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    let taskId: String

    @State private var task: HXTask?
    @State private var isLoading = true
    @State private var showCancelConfirmation = false
    @State private var showEditSheet = false
    @State private var showTipSheet = false
    @State private var tipSent = false
    @State private var loadError: Error?
    @State private var sseSubscription: AnyCancellable?
    
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

                                    Image(systemName: task.location == "Anywhere" ? "globe" : "mappin.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.brandPurple)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    HXText(task.location, style: .body)
                                    HXText(task.location == "Anywhere" ? "No location restriction" : "In-person task", style: .caption, color: .textSecondary)
                                }

                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(Color.surfaceElevated)
                        .cornerRadius(16)
                        
                        // Assigned hustler section (if in progress)
                        if task.state == .inProgress || task.state == .proofSubmitted {
                            AssignedHustlerSection(task: task, router: router)
                        }
                        
                        // Applicants section (if posted)
                        if task.state == .posted {
                            ApplicantsSection(taskId: task.id, router: router)
                        }
                        
                        // Timeline section
                        TaskTimelineSection(task: task)

                        // Tip prompt (shown when task is completed)
                        if task.state == .completed && !tipSent {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.brandPurple.opacity(0.15))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Color.brandPurple)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        HXText("Task Completed!", style: .headline, color: .successGreen)
                                        HXText("Would you like to leave a tip for the hustler?", style: .subheadline, color: .textSecondary)
                                    }

                                    Spacer()
                                }

                                HXButton("Leave a Tip", icon: "heart.fill", variant: .primary) {
                                    showTipSheet = true
                                }
                            }
                            .padding(20)
                            .background(Color.surfaceElevated)
                            .cornerRadius(16)
                        }

                        if tipSent {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.successGreen)
                                HXText("Tip sent! Thank you for your generosity.", style: .subheadline, color: .successGreen)
                            }
                            .padding(16)
                            .background(Color.successGreen.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // File Dispute (completed or disputed tasks)
                        if task.state == .completed || task.state == .disputed {
                            Button {
                                router.navigateToPoster(.dispute(taskId: task.id))
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 14))
                                    Text("File a Dispute")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(Color.errorRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.errorRed.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.errorRed.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(24)
                }
                
                // Bottom action bar
                VStack(spacing: 0) {
                    Spacer()
                    
                    TaskActionBar(task: task, router: router, onEdit: {
                        showEditSheet = true
                    }, onCancel: {
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
                    if task?.state == .posted {
                        Button { showEditSheet = true } label: {
                            Label("Edit Task", systemImage: "pencil")
                        }
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
                .accessibilityLabel("Task options")
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
        .sheet(isPresented: $showTipSheet) {
            if let task = task {
                TipSheet(
                    taskId: task.id,
                    taskPrice: Int(task.payment * 100),
                    workerName: "Hustler",
                    onTip: { amountCents in
                        sendTip(taskId: task.id, amountCents: amountCents)
                    },
                    onDismiss: {
                        showTipSheet = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let task = task {
                EditTaskSheet(task: task) { updatedTask in
                    self.task = updatedTask
                    showEditSheet = false
                }
            }
        }
        .onAppear {
            loadTask()
            subscribeToSSE()
        }
        .onDisappear {
            sseSubscription?.cancel()
            sseSubscription = nil
        }
    }
    
    private func loadTask() {
        isLoading = true
        Task {
            do {
                task = try await TaskService.shared.getTask(id: taskId)
                HXLogger.info("PosterTaskDetail: Loaded task from API", category: "Task")
            } catch {
                loadError = error
                HXLogger.error("PosterTaskDetail: API failed - \(error.localizedDescription)", category: "Task")
                // Fall back to mock data
                task = LiveDataService.shared.getTask(by: taskId)
            }
            isLoading = false
        }
    }
    
    private func sendTip(taskId: String, amountCents: Int) {
        Task {
            struct TipInput: Codable {
                let taskId: String
                let amountCents: Int
            }
            struct TipResponse: Codable {
                let success: Bool?
            }

            do {
                let _: TipResponse = try await TRPCClient.shared.call(
                    router: "tipping",
                    procedure: "createTip",
                    input: TipInput(taskId: taskId, amountCents: amountCents)
                )
                showTipSheet = false
                tipSent = true
                let haptic = UINotificationFeedbackGenerator()
                haptic.notificationOccurred(.success)
                HXLogger.info("PosterTaskDetail: Tip of \(amountCents) cents sent", category: "Task")
            } catch {
                HXLogger.error("PosterTaskDetail: Tip failed - \(error.localizedDescription)", category: "Task")
                showTipSheet = false
            }
        }
    }

    /// Subscribe to SSE for real-time task state updates
    private func subscribeToSSE() {
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                let relevantEvents = [
                    "task_updated", "task_state_changed", "proof_submitted",
                    "task_completed", "worker_checkin", "worker_checkout"
                ]
                if relevantEvents.contains(message.event) {
                    if let json = try? JSONSerialization.jsonObject(with: message.data) as? [String: Any],
                       let eventTaskId = json["taskId"] as? String,
                       eventTaskId == taskId {
                        Task {
                            do {
                                task = try await TaskService.shared.getTask(id: taskId)
                                HXLogger.info("PosterTaskDetail: Refreshed via SSE '\(message.event)'", category: "Task")
                            } catch {
                                HXLogger.error("PosterTaskDetail: SSE refresh failed", category: "Task")
                            }
                        }
                    }
                }
            }
    }

    private func cancelTask() {
        Task {
            do {
                _ = try await TaskService.shared.cancelTask(taskId: taskId, reason: nil)
                HXLogger.info("PosterTaskDetail: Task cancelled via API", category: "Task")
            } catch {
                HXLogger.error("PosterTaskDetail: Cancel API failed - \(error.localizedDescription)", category: "Task")
            }
            router.posterPath.removeLast()
        }
    }
}

// MARK: - Task Status Badge
private struct TaskStatusBadge: View {
    let state: TaskState
    
    var color: Color {
        switch state {
        case .posted, .matching: return .infoBlue
        case .claimed: return .warningOrange
        case .inProgress: return .brandPurple
        case .proofSubmitted: return .warningOrange
        case .completed: return .successGreen
        case .cancelled, .expired: return .errorRed
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
    
    private var hustlerInitials: String {
        let name = task.hustlerName ?? "?"
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Assigned Hustler", style: .headline)

            HStack(spacing: 16) {
                HXAvatar(initials: hustlerInitials, size: .medium)

                VStack(alignment: .leading, spacing: 4) {
                    HXText(task.hustlerName ?? "Hustler", style: .headline)

                    HStack(spacing: 4) {
                        HXBadge(variant: .tier(task.requiredTier))
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
                .accessibilityLabel("Message hustler")
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
    let taskId: String
    let router: Router

    @State private var applicantCount: Int = 0
    @State private var isLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Applicants", style: .headline)
                Spacer()
                if isLoaded {
                    HXBadge(variant: .count(applicantCount))
                }
            }

            if isLoaded {
                if applicantCount > 0 {
                    HXText(
                        "\(applicantCount) hustler\(applicantCount == 1 ? " has" : "s have") applied for this task",
                        style: .subheadline,
                        color: .textSecondary
                    )

                    HXButton("View Applicants", variant: .secondary) {
                        router.navigateToPoster(.applicantList(taskId: taskId))
                    }
                    .accessibilityLabel("View applicants")
                } else {
                    HXText(
                        "No applicants yet. Hustlers in the area will be notified.",
                        style: .subheadline,
                        color: .textSecondary
                    )
                }
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.textSecondary)
                    HXText("Loading applicants...", style: .subheadline, color: .textSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
        .task {
            do {
                let applicants = try await TaskService.shared.listApplicants(taskId: taskId)
                applicantCount = applicants.count
            } catch {
                HXLogger.error("ApplicantsSection: Failed to load count - \(error.localizedDescription)", category: "Task")
                applicantCount = 0
            }
            isLoaded = true
        }
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
                
                if task.state == .inProgress || task.state == .proofSubmitted || task.state == .completed {
                    TimelineRow(
                        title: "Task Started",
                        subtitle: "Dec 15, 2024 at 4:00 PM",
                        isCompleted: true,
                        isLast: task.state == .inProgress
                    )
                }
                
                if task.state == .proofSubmitted || task.state == .completed {
                    TimelineRow(
                        title: "Proof Submitted",
                        subtitle: task.state == .completed ? "Dec 15, 2024 at 5:30 PM" : "Awaiting your review",
                        isCompleted: task.state == .completed,
                        isLast: task.state == .proofSubmitted
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
    let onEdit: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HStack(spacing: 16) {
                if task.state == .proofSubmitted {
                    HXButton("Review Proof", variant: .primary) {
                        router.navigateToPoster(.proofReview(taskId: task.id))
                    }
                } else if task.state == .posted {
                    HXButton("Edit Task", variant: .secondary) {
                        onEdit()
                    }

                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.errorRed)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.errorRed.opacity(0.15))
                            .cornerRadius(12)
                    }
                } else if task.state == .claimed || task.state == .inProgress {
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
