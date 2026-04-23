//
//  PosterStack.swift
//  hustleXP final1
//
//  Navigation stack for Poster (task creator) screens
//  Archetypes: B (Feed/Opportunity), C (Task Lifecycle), E (Progress/Status)
//

import SwiftUI

struct PosterStack: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        @Bindable var nav = router
        
        NavigationStack(path: $nav.posterPath) {
            PosterHomeScreen()
                .navigationDestination(for: PosterRoute.self) { route in
                    switch route {
                    case .home:
                        PosterHomeScreen()
                    case .createTask:
                        CreateTaskScreen()
                    case .aiTaskCreation:
                        AITaskCreationScreen()
                    case .taskDetail(let taskId):
                        PosterTaskDetailScreen(taskId: taskId)
                    case .activeTasks:
                        PosterActiveTasksScreen()
                    case .taskManagement(let taskId):
                        TaskManagementScreen(taskId: taskId)
                    case .applicantList(let taskId):
                        ApplicantListScreen(taskId: taskId)
                    case .proofReview(let taskId):
                        ProofReviewScreen(taskId: taskId)
                    case .conversation(let taskId):
                        ConversationScreen(conversationId: taskId)
                    case .history:
                        PosterHistoryScreen()
                    case .profile:
                        PosterProfileScreen()
                    // v2.0.0 LIVE Mode routes
                    case .asapTaskCreation:
                        ASAPTaskCreationScreen()
                    case .questTracking(let questId):
                        // Would show poster's view of worker tracking
                        PosterTaskDetailScreen(taskId: questId)
                    // v2.4.0 Recurring Tasks routes
                    case .recurringTasks:
                        RecurringTasksScreen()
                    case .recurringTaskDetail(let seriesId):
                        RecurringTaskDetailScreen(seriesId: seriesId)
                    // v2.5.0 Messaging & Notifications
                    case .messagesInbox:
                        MessagesInboxScreen()
                    case .notificationCenter:
                        NotificationCenterScreen()
                    // v2.6.0 Dispute
                    case .dispute(let taskId):
                        DisputeScreen(taskId: taskId)
                    }
                }
        }
    }
}

#Preview {
    PosterStack()
        .environment(AppState())
        .environment(Router())
}
