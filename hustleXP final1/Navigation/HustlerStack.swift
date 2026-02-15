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
                    // v1.8.0 routes
                    case .taxPayment:
                        TaxPaymentScreen()
                    case .fileClaim:
                        FileClaimScreen()
                    case .claimsHistory:
                        ClaimsHistoryScreen()
                    // v1.9.0 Spatial Intelligence routes
                    case .heatMapFullscreen:
                        HeatMapFullscreenScreen()
                    case .batchDetails(let batchId):
                        BatchDetailsScreen(batchId: batchId)
                    // v2.0.0 LIVE Mode routes
                    case .liveRadar:
                        LiveRadarScreen()
                    case .onTheWayTracking(let trackingId):
                        OnTheWayTrackingScreen(trackingId: trackingId)
                    // v2.1.0 Professional Licensing routes
                    case .skillSelection:
                        SkillGridSelectionScreen()
                    case .licenseUpload(let type):
                        LicenseUploadScreen(licenseType: type)
                    case .lockedQuests:
                        LockedQuestsScreen()
                    // v2.4.0 Squads Mode routes
                    case .squadsHub:
                        SquadsHubScreen()
                    case .squadDetail(_):
                        // TODO: Build SquadDetailScreen
                        SquadsHubScreen()
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
