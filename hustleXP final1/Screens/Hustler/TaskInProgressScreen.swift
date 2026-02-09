//
//  TaskInProgressScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Progress is visible, completion is within reach
//

import SwiftUI

struct TaskInProgressScreen: View {
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    let taskId: String
    
    @State private var currentStatus: TaskProgressStatus = .enRoute
    @State private var showMessageSheet: Bool = false
    
    private var task: HXTask? {
        dataService.activeTask
    }
    
    var body: some View {
        if let task = task {
            VStack(spacing: 0) {
                // Status card
                statusCard(task)
                
                // Progress steps
                progressSteps
                    .padding(.top, 32)
                
                Spacer()
                
                // Action buttons
                actionButtons(task)
            }
            .navigationTitle("Task In Progress")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMessageSheet) {
                ConversationScreen(conversationId: task.id)
            }
        } else {
            ErrorState(
                title: "No Active Task",
                message: "You don't have an active task"
            ) {
                router.hustlerPath = NavigationPath()
            }
        }
    }
    
    // MARK: - Status Card
    
    private func statusCard(_ task: HXTask) -> some View {
        VStack(spacing: 16) {
            // Status icon with animation
            ZStack {
                Circle()
                    .fill(currentStatus.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: currentStatus.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(currentStatus.color)
            }
            
            // Status text
            VStack(spacing: 4) {
                HXText(currentStatus.title, style: .title2)
                HXText(currentStatus.subtitle, style: .subheadline, color: .secondary)
            }
            
            // Task info
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    HXText(task.title, style: .headline)
                    HXText(task.location, style: .caption, color: .secondary)
                }
                
                Spacer()
                
                PriceDisplay(amount: task.payment, size: .small)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Progress Steps
    
    private var progressSteps: some View {
        VStack(spacing: 0) {
            ProgressStepRow(
                title: "En Route",
                subtitle: "Head to the task location",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.enRoute.rawValue,
                isCurrent: currentStatus == .enRoute
            )
            
            ProgressStepRow(
                title: "Arrived",
                subtitle: "You're at the location",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.arrived.rawValue,
                isCurrent: currentStatus == .arrived
            )
            
            ProgressStepRow(
                title: "Working",
                subtitle: "Complete the task",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.working.rawValue,
                isCurrent: currentStatus == .working
            )
            
            ProgressStepRow(
                title: "Submit Proof",
                subtitle: "Show your completed work",
                isComplete: false,
                isCurrent: false,
                isLast: true
            )
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(_ task: HXTask) -> some View {
        VStack(spacing: 12) {
            // Primary action based on status
            switch currentStatus {
            case .enRoute:
                HXButton("I've Arrived", variant: .primary) {
                    withAnimation(.spring(response: 0.3)) {
                        currentStatus = .arrived
                        dataService.updateTaskState(task.id, to: .inProgress)
                    }
                }
                
            case .arrived:
                HXButton("Start Working", variant: .primary) {
                    withAnimation(.spring(response: 0.3)) {
                        currentStatus = .working
                    }
                }
                
            case .working:
                HXButton("Submit Proof") {
                    router.navigateToHustler(.proofSubmission(taskId: task.id))
                }
            }
            
            // Message poster button
            Button(action: { showMessageSheet = true }) {
                HStack {
                    HXIcon(HXIcon.message, size: .small, color: .brandPurple)
                    HXText("Message Poster", style: .subheadline, color: .brandPurple)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Task Progress Status

enum TaskProgressStatus: Int {
    case enRoute = 0
    case arrived = 1
    case working = 2
    
    var title: String {
        switch self {
        case .enRoute: return "On Your Way"
        case .arrived: return "You've Arrived"
        case .working: return "Working..."
        }
    }
    
    var subtitle: String {
        switch self {
        case .enRoute: return "Head to the task location"
        case .arrived: return "Let the poster know you're here"
        case .working: return "Complete the task and submit proof"
        }
    }
    
    var icon: String {
        switch self {
        case .enRoute: return "car.fill"
        case .arrived: return "mappin.circle.fill"
        case .working: return "wrench.and.screwdriver.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .enRoute: return .infoBlue
        case .arrived: return .warningOrange
        case .working: return .brandPurple
        }
    }
}

// MARK: - Progress Step Row

struct ProgressStepRow: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let isCurrent: Bool
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isComplete ? Color.brandPurple : Color(.systemGray4))
                        .frame(width: 28, height: 28)
                    
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isComplete ? Color.brandPurple : Color(.systemGray4))
                        .frame(width: 2, height: 40)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                HXText(title, style: isCurrent ? .headline : .subheadline, color: isCurrent ? .primary : .secondary)
                HXText(subtitle, style: .caption, color: .secondary)
            }
            .padding(.bottom, isLast ? 0 : 16)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TaskInProgressScreen(taskId: "task-001")
    }
    .environment(Router())
    .environment(MockDataService.shared)
}
