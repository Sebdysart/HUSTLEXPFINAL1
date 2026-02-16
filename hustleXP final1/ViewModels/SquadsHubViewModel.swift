//
//  SquadsHubViewModel.swift
//  hustleXP final1
//
//  Extracted from SquadsHubScreen.swift
//  Archetype: B (Feed/Opportunity) + E (Progress/Status)
//
//  Contains all business logic, API calls, and state management
//  for the Squads Hub feature.
//

import SwiftUI

// MARK: - SquadsHubViewModel

@Observable
@MainActor
final class SquadsHubViewModel {

    // MARK: - Dependencies (injected after init)

    var appState: AppState?

    // MARK: - State

    var mySquads: [HXSquad] = []
    var pendingInvites: [SquadInvite] = []
    var selectedTab: SquadsTab = .mySquads
    var showCreateSheet = false
    var isLoading = true
    var showContent = false

    // MARK: - Computed Properties

    var isUnlocked: Bool {
        guard let appState else { return false }
        return SquadTierGate.isUnlocked(tier: appState.trustTier)
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        do {
            async let squadsTask = SquadService.shared.getMySquads()
            async let invitesTask = SquadService.shared.getPendingInvites()

            let (squads, invites) = try await (squadsTask, invitesTask)
            mySquads = squads
            pendingInvites = invites
        } catch {
            HXLogger.error("SquadsHub: Load failed - \(error.localizedDescription)", category: "General")
            mySquads = []
            pendingInvites = []
        }
        isLoading = false
    }

    // MARK: - Actions

    func respondToInvite(inviteId: String, accept: Bool) {
        Task {
            try? await SquadService.shared.respondToInvite(
                inviteId: inviteId,
                accept: accept
            )
            await loadData()
        }
    }

    func animateContentIn() {
        withAnimation(.easeOut(duration: 0.4)) {
            showContent = true
        }
    }
}
