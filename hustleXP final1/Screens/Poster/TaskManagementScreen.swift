//
//  TaskManagementScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//

import SwiftUI
import Combine

struct TaskManagementScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    let taskId: String

    @State private var task: HXTask?
    @State private var isLoading = true
    @State private var showReportSheet = false
    @State private var lastSSEUpdate: Date?
    @State private var sseSubscription: AnyCancellable?

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            if isLoading {
                LoadingState(message: "Loading...")
            } else if let task = task {
                ScrollView {
                    VStack(spacing: 20) {
                        // Task summary card
                        TaskSummaryCard(task: task)

                        // Smart Dispatch status card (shown when task uses smart_dispatch)
                        if task.fulfillmentMode == "smart_dispatch" {
                            DispatchStatusCard(taskId: task.id)
                        }

                        // Progress tracker
                        if task.state == .inProgress || task.state == .claimed {
                            TaskProgressCard(task: task, lastSSEUpdate: lastSSEUpdate)
                        }

                        // Hustler info card
                        HustlerInfoCard(task: task, router: router)
                        
                        // Quick actions
                        QuickActionsSection(task: task, router: router, onReport: {
                            showReportSheet = true
                        })
                        
                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
                
                // Bottom action
                if task.state == .proofSubmitted {
                    VStack {
                        Spacer()
                        ReviewProofCTA(task: task, router: router)
                    }
                }
            } else {
                ErrorState(
                    title: "Task Not Found",
                    message: "Unable to load task details",
                    retryAction: { loadTask() }
                )
            }
        }
        .navigationTitle("Manage Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showReportSheet) {
            ReportIssueSheet(taskId: taskId)
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
                HXLogger.info("TaskManagement: Loaded task from API", category: "Task")
            } catch {
                HXLogger.error("TaskManagement: API failed - \(error.localizedDescription)", category: "Task")
                task = LiveDataService.shared.getTask(by: taskId)
            }
            isLoading = false
        }
    }

    /// Subscribe to SSE events and auto-refresh task on relevant updates
    private func subscribeToSSE() {
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                // Refresh on task-related events (state changes, check-in, proof submitted)
                let relevantEvents = [
                    "task_updated", "task_state_changed", "worker_checkin",
                    "worker_checkout", "proof_submitted", "task_completed",
                    "worker_location_update"
                ]
                if relevantEvents.contains(message.event) {
                    // Check if this event is for our task
                    if let json = try? JSONSerialization.jsonObject(with: message.data) as? [String: Any],
                       let eventTaskId = json["taskId"] as? String,
                       eventTaskId == taskId {
                        lastSSEUpdate = Date()
                        Task {
                            do {
                                task = try await TaskService.shared.getTask(id: taskId)
                                HXLogger.info("TaskManagement: Refreshed via SSE event '\(message.event)'", category: "Task")
                            } catch {
                                HXLogger.error("TaskManagement: SSE refresh failed - \(error.localizedDescription)", category: "Task")
                            }
                        }
                    }
                }
            }
    }
}

// MARK: - Task Summary Card
private struct TaskSummaryCard: View {
    let task: HXTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HXText(task.title, style: .headline)
                    HXText(task.location, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HXText("$\(Int(task.payment))", style: .title2, color: .moneyGreen)
                    TaskStateBadge(state: task.state)
                }
            }
            
            HXDivider()
            
            HStack(spacing: 24) {
                InfoPill(icon: "clock.fill", text: task.estimatedDuration)
                InfoPill(icon: "shield.fill", text: task.requiredTier.name)
                Spacer()
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Info Pill
private struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
            HXText(text, style: .caption, color: .textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.surfaceSecondary)
        .cornerRadius(8)
    }
}

// MARK: - Task State Badge
private struct TaskStateBadge: View {
    let state: TaskState
    
    var color: Color {
        switch state {
        case .posted, .matching: return .infoBlue
        case .claimed, .proofSubmitted: return .warningOrange
        case .inProgress: return .brandPurple
        case .completed: return .successGreen
        case .cancelled, .disputed, .expired: return .errorRed
        }
    }
    
    var body: some View {
        HXText(state.rawValue, style: .caption, color: color)
    }
}

// MARK: - Task Progress Card
private struct TaskProgressCard: View {
    let task: HXTask
    var lastSSEUpdate: Date?

    private var isClaimed: Bool {
        [.claimed, .inProgress, .proofSubmitted, .completed].contains(task.state)
    }
    private var isWorking: Bool {
        [.inProgress, .proofSubmitted, .completed].contains(task.state)
    }
    private var isProofSubmitted: Bool {
        [.proofSubmitted, .completed].contains(task.state)
    }
    private var isDone: Bool {
        task.state == .completed
    }

    private var statusLabel: String {
        switch task.state {
        case .claimed: return "Claimed"
        case .inProgress: return "In Progress"
        case .proofSubmitted: return "Proof Submitted"
        case .completed: return "Completed"
        default: return task.state.rawValue
        }
    }

    private var statusColor: Color {
        switch task.state {
        case .claimed: return .warningOrange
        case .inProgress: return .brandPurple
        case .proofSubmitted: return .warningOrange
        case .completed: return .successGreen
        default: return .textSecondary
        }
    }

    private var liveMessage: String {
        switch task.state {
        case .claimed: return "Hustler has claimed your task"
        case .inProgress: return "Hustler is working on your task"
        case .proofSubmitted: return "Proof submitted \u{2013} awaiting your review"
        case .completed: return "Task completed!"
        default: return "Monitoring task..."
        }
    }

    private var updatedAgoText: String {
        guard let date = lastSSEUpdate else { return "Live" }
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 10 { return "Just now" }
        if seconds < 60 { return "\(seconds)s ago" }
        let minutes = seconds / 60
        return "\(minutes)m ago"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Progress", style: .headline)
                Spacer()
                HXText(statusLabel, style: .caption, color: statusColor)
            }

            // Progress steps
            HStack(spacing: 0) {
                ProgressStep(title: "Claimed", isComplete: isClaimed, isCurrent: task.state == .claimed)
                ProgressConnector(isComplete: isClaimed)
                ProgressStep(title: "En Route", isComplete: isWorking, isCurrent: false)
                ProgressConnector(isComplete: isWorking)
                ProgressStep(title: "Working", isComplete: isProofSubmitted, isCurrent: task.state == .inProgress)
                ProgressConnector(isComplete: isProofSubmitted)
                ProgressStep(title: "Done", isComplete: isDone, isCurrent: task.state == .proofSubmitted)
            }

            HXDivider()

            // Live update
            HStack(spacing: 12) {
                Circle()
                    .fill(RealtimeSSEClient.shared.isConnected ? Color.successGreen : Color.warningOrange)
                    .frame(width: 8, height: 8)

                HXText(liveMessage, style: .subheadline, color: .textSecondary)

                Spacer()

                HXText(updatedAgoText, style: .caption, color: .textTertiary)
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Progress Step
private struct ProgressStep: View {
    let title: String
    let isComplete: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(isComplete ? Color.successGreen : (isCurrent ? Color.brandPurple : Color.surfaceSecondary))
                .frame(width: 24, height: 24)
                .overlay(
                    Group {
                        if isComplete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                )
            
            HXText(title, style: .caption, color: isComplete || isCurrent ? .textPrimary : .textTertiary)
        }
    }
}

// MARK: - Progress Connector
private struct ProgressConnector: View {
    let isComplete: Bool
    
    var body: some View {
        Rectangle()
            .fill(isComplete ? Color.successGreen : Color.surfaceSecondary)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)
    }
}

// MARK: - Hustler Info Card
private struct HustlerInfoCard: View {
    let task: HXTask
    let router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Assigned Hustler", style: .headline)
            
            HStack(spacing: 16) {
                HXAvatar(initials: "JD", size: .medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Jane Doe", style: .headline)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.warningOrange)
                            HXText("4.9", style: .caption)
                        }
                        
                        HXText("•", style: .caption, color: .textTertiary)
                        
                        HXText("127 tasks", style: .caption, color: .textSecondary)
                    }
                }
                
                Spacer()
                
                HXBadge(variant: .tier(.verified))
            }
            
            HXDivider()
            
            HStack(spacing: 12) {
                Button(action: {
                    router.navigateToPoster(.conversation(taskId: task.id))
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.fill")
                        HXText("Message", style: .subheadline)
                    }
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.brandPurple.opacity(0.15))
                    .cornerRadius(10)
                }
                .accessibilityLabel("Message hustler")
                
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                        HXText("Call", style: .subheadline)
                    }
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(10)
                }
                .accessibilityLabel("Call hustler")
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Quick Actions Section
private struct QuickActionsSection: View {
    let task: HXTask
    let router: Router
    let onReport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Quick Actions", style: .headline)
            
            VStack(spacing: 12) {
                ActionRow(
                    icon: "clock.arrow.circlepath",
                    title: "Extend Deadline",
                    subtitle: "Give the hustler more time",
                    action: {}
                )
                
                ActionRow(
                    icon: "dollarsign.circle",
                    title: "Add Tip",
                    subtitle: "Reward great work",
                    action: {}
                )
                
                ActionRow(
                    icon: "exclamationmark.triangle",
                    title: "Report Issue",
                    subtitle: "Something not right?",
                    iconColor: .errorRed,
                    action: onReport
                )
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Action Row
private struct ActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = .brandPurple
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .subheadline)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(12)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Review Proof CTA
private struct ReviewProofCTA: View {
    let task: HXTask
    let router: Router
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.viewfinder.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.warningOrange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HXText("Proof Submitted", style: .headline)
                        HXText("Review and approve to release payment", style: .caption, color: .textSecondary)
                    }
                    
                    Spacer()
                }
                
                HXButton("Review Proof", variant: .primary) {
                    router.navigateToPoster(.proofReview(taskId: task.id))
                }
                .accessibilityLabel("Review proof")
            }
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

// MARK: - Report Issue Sheet
private struct ReportIssueSheet: View {
    let taskId: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReason: String?
    @State private var details: String = ""
    
    let reasons = [
        "Hustler not responding",
        "Work quality issues",
        "Time concerns",
        "Safety concern",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HXText("What's the issue?", style: .headline)
                        
                        VStack(spacing: 12) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: { selectedReason = reason }) {
                                    HStack {
                                        HXText(reason, style: .body)
                                        Spacer()
                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.brandPurple)
                                        }
                                    }
                                    .padding(16)
                                    .background(selectedReason == reason ? Color.brandPurple.opacity(0.15) : Color.surfaceElevated)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Additional Details", style: .subheadline, color: .textSecondary)
                            
                            TextField("", text: $details, prompt: Text("Describe the issue...").foregroundColor(.textTertiary), axis: .vertical)
                                .font(.body)
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(4...8)
                                .padding(16)
                                .background(Color.surfaceElevated)
                                .cornerRadius(12)
                        }
                        
                        HXButton("Submit Report", variant: .primary) {
                            dismiss()
                        }
                        .disabled(selectedReason == nil)
                        .opacity(selectedReason != nil ? 1 : 0.5)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Report Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
}

// MARK: - Dispatch Status Card

private struct DispatchStatusCard: View {
    let taskId: String

    @State private var status: PosterDispatchStatus?
    @State private var isLoading = true
    @State private var pulseScale: CGFloat = 1.0
    @State private var etaCountdown: Int = 0
    @State private var countdownTimer: Timer?
    @State private var sseSubscription: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(headerColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: headerIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(headerColor)
                }
                HXText("Smart Dispatch", style: .headline)
                Spacer()
                liveBadge
            }

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView().tint(Color.successGreen)
                    HXText("Loading dispatch status...", style: .subheadline, color: .textSecondary)
                }
            } else if let status {
                // ETA banner — shown when hustler has been claimed and ETA is available
                if status.isClaimed, let etaLabel = status.etaLabel {
                    etaBanner(label: etaLabel, status: status)
                }

                // State row
                HStack(spacing: 12) {
                    stateOrb(for: status)
                    VStack(alignment: .leading, spacing: 2) {
                        HXText(status.stateLabel, style: .subheadline)
                        if status.waveNumber > 0 && !status.isClaimed {
                            HXText("Wave \(status.waveNumber) of 3", style: .caption, color: .textSecondary)
                        }
                    }
                    Spacer()
                }

                // Searching animation hint
                if status.isSearching {
                    HStack(spacing: 8) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.successGreen.opacity(0.7))
                        HXText("Pinging nearby hustlers in Go Mode…", style: .caption, color: .textSecondary)
                    }
                }

                // Recent events
                if !status.events.isEmpty {
                    HXDivider()
                    VStack(alignment: .leading, spacing: 8) {
                        HXText("Recent Activity", style: .caption, color: .textMuted)
                        ForEach(status.events.prefix(3), id: \.createdAt) { event in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(eventColor(event.eventType))
                                    .frame(width: 6, height: 6)
                                HXText(eventLabel(event.eventType), style: .caption, color: .textSecondary)
                                Spacer()
                                HXText(relativeTime(event.createdAt), style: .caption, color: .textMuted)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(headerColor.opacity(0.2), lineWidth: 1)
            }
        )
        .task { await loadStatus() }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.12
            }
            subscribeToSSE()
        }
        .onDisappear {
            sseSubscription?.cancel()
            countdownTimer?.invalidate()
        }
    }

    // MARK: - ETA Banner

    @ViewBuilder
    private func etaBanner(label: String, status: PosterDispatchStatus) -> some View {
        HStack(spacing: 14) {
            // Animated car icon
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "car.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Your hustler is on the way!")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(label)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.brandPurple)

                if let arrivalAt = status.estimatedArrivalAt {
                    Text("Estimated arrival at \(arrivalAt, format: .dateTime.hour().minute())")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandPurple.opacity(0.08))
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandPurple.opacity(0.25), lineWidth: 1)
            }
        )
    }

    // MARK: - Live Badge

    @ViewBuilder
    private var liveBadge: some View {
        if let status {
            if status.isSearching {
                Text("LIVE")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.successGreen)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.successGreen.opacity(0.15))
                    .clipShape(Capsule())
                    .scaleEffect(pulseScale)
            } else if status.isClaimed {
                Text("ON THE WAY")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.brandPurple.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Computed helpers

    private var headerColor: Color {
        guard let status else { return Color.successGreen }
        if status.isClaimed { return Color.brandPurple }
        if status.isSearching { return Color.successGreen }
        return Color.textMuted
    }

    private var headerIcon: String {
        guard let status else { return "bolt.fill" }
        if status.isClaimed { return "car.fill" }
        if status.isSearching { return "bolt.fill" }
        return "bolt.fill"
    }

    // MARK: - Data Loading

    private func loadStatus() async {
        do {
            status = try await DispatchServiceClient.shared.getPosterDispatchStatus(taskId: taskId)
        } catch {
            HXLogger.error("DispatchStatusCard: \(error.localizedDescription)", category: "Dispatch")
        }
        isLoading = false
    }

    // MARK: - SSE Subscription

    private func subscribeToSSE() {
        let refreshEvents: Set<String> = ["task.dispatch_claimed", "task.eta_updated",
                                           "task.dispatch_claimed", "wave_dispatched"]
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                guard refreshEvents.contains(message.event) else { return }
                // Check event is for our task
                if let json = try? JSONSerialization.jsonObject(with: message.data) as? [String: Any],
                   let eventTaskId = json["taskId"] as? String,
                   eventTaskId == taskId {
                    Task { await loadStatus() }
                }
            }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func stateOrb(for status: PosterDispatchStatus) -> some View {
        let color = stateColor(status.dispatchState)
        ZStack {
            Circle().fill(color.opacity(0.2)).frame(width: 36, height: 36)
            Image(systemName: stateIcon(status.dispatchState))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    private func stateColor(_ state: String) -> Color {
        switch state {
        case "broadcasting", "soft_hold_active": return Color.successGreen
        case "claimed":                          return Color.brandPurple
        case "in_progress":                      return Color.brandPurple
        case "completed":                        return Color.moneyGreen
        case "expired", "cancelled":             return Color.errorRed
        default:                                 return Color.textMuted
        }
    }

    private func stateIcon(_ state: String) -> String {
        switch state {
        case "broadcasting":     return "antenna.radiowaves.left.and.right"
        case "soft_hold_active": return "timer"
        case "claimed":          return "car.fill"
        case "in_progress":      return "bolt.fill"
        case "completed":        return "star.fill"
        case "expired":          return "clock.badge.xmark"
        case "cancelled":        return "xmark.circle"
        default:                 return "hourglass"
        }
    }

    private func eventColor(_ type: String) -> Color {
        switch type {
        case "wave_dispatched":      return Color.successGreen
        case "ping_viewed":          return Color.infoBlue
        case "ping_declined":        return Color.warningOrange
        case "soft_hold_acquired":   return Color.brandPurple
        case "claimed":              return Color.moneyGreen
        case "dispatch_expired":     return Color.errorRed
        default:                     return Color.textMuted
        }
    }

    private func eventLabel(_ type: String) -> String {
        switch type {
        case "wave_dispatched":     return "Dispatch wave sent"
        case "ping_viewed":         return "Hustler viewed ping"
        case "ping_declined":       return "Hustler declined"
        case "soft_hold_acquired":  return "Hustler is considering"
        case "claimed":             return "Hustler accepted — on the way"
        case "dispatch_expired":    return "No hustler found"
        default:                    return type.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let s = Int(-date.timeIntervalSinceNow)
        if s < 60 { return "\(s)s ago" }
        if s < 3600 { return "\(s / 60)m ago" }
        return "\(s / 3600)h ago"
    }
}

#Preview {
    NavigationStack {
        TaskManagementScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
