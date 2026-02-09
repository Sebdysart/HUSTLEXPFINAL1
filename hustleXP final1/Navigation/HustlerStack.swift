//
//  HustlerStack.swift
//  hustleXP final1
//
//  Navigation stack for Hustler (task performer) screens
//  Archetypes: B (Feed/Opportunity), C (Task Lifecycle), E (Progress/Status)
//

import SwiftUI

struct HustlerStack: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        @Bindable var nav = router
        
        NavigationStack(path: $nav.hustlerPath) {
            HustlerHomeScreen()
                .navigationDestination(for: HustlerRoute.self) { route in
                    switch route {
                    case .home:
                        HustlerHomeScreen()
                    case .feed:
                        HustlerFeedScreen()
                    case .taskDetail(let taskId):
                        HustlerTaskDetailScreen(taskId: taskId)
                    case .taskInProgress(let taskId):
                        TaskInProgressScreen(taskId: taskId)
                    case .proofSubmission(let taskId):
                        ProofSubmissionScreen(taskId: taskId)
                    case .history:
                        HustlerHistoryScreen()
                    case .profile:
                        HustlerProfileScreen()
                    case .earnings:
                        EarningsScreen()
                    case .xpBreakdown:
                        XPBreakdownScreen()
                    }
                }
        }
    }
}

#Preview {
    HustlerStack()
        .environment(AppState())
        .environment(Router())
}
