//
//  TaskManagementScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//

import SwiftUI

struct TaskManagementScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    
    let taskId: String
    
    @State private var task: HXTask?
    @State private var isLoading = true
    @State private var showReportSheet = false
    
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
                        
                        // Progress tracker
                        if task.state == .inProgress {
                            TaskProgressCard(task: task)
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
                if task.state == .pendingVerification {
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
        }
    }
    
    private func loadTask() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            task = MockDataService.shared.getTask(by: taskId)
            isLoading = false
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
        case .posted: return .infoBlue
        case .claimed, .pendingVerification: return .warningOrange
        case .inProgress: return .brandPurple
        case .completed: return .successGreen
        case .cancelled, .disputed: return .errorRed
        }
    }
    
    var body: some View {
        HXText(state.rawValue, style: .caption, color: color)
    }
}

// MARK: - Task Progress Card
private struct TaskProgressCard: View {
    let task: HXTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Progress", style: .headline)
                Spacer()
                HXText("In Progress", style: .caption, color: .brandPurple)
            }
            
            // Progress steps
            HStack(spacing: 0) {
                ProgressStep(title: "Claimed", isComplete: true, isCurrent: false)
                ProgressConnector(isComplete: true)
                ProgressStep(title: "En Route", isComplete: true, isCurrent: false)
                ProgressConnector(isComplete: false)
                ProgressStep(title: "Working", isComplete: false, isCurrent: true)
                ProgressConnector(isComplete: false)
                ProgressStep(title: "Done", isComplete: false, isCurrent: false)
            }
            
            HXDivider()
            
            // Live update
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 8, height: 8)
                
                HXText("Hustler is working on your task", style: .subheadline, color: .textSecondary)
                
                Spacer()
                
                HXText("Updated 2m ago", style: .caption, color: .textTertiary)
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
                HXAvatar(imageURL: nil, size: .medium, initials: "JD")
                
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

#Preview {
    NavigationStack {
        TaskManagementScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
