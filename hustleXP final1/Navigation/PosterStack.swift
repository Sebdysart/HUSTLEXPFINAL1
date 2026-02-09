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
                    case .taskDetail(let taskId):
                        PosterTaskDetailScreen(taskId: taskId)
                    case .activeTasks:
                        PosterActiveTasksScreen()
                    case .taskManagement(let taskId):
                        TaskManagementScreen(taskId: taskId)
                    case .proofReview(let taskId):
                        ProofReviewScreen(taskId: taskId)
                    case .history:
                        PosterHistoryScreen()
                    case .profile:
                        PosterProfileScreen()
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
