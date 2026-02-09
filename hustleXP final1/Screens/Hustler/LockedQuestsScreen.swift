//
//  LockedQuestsScreen.swift
//  hustleXP final1
//
//  Full screen view of locked quests with upgrade paths
//

import SwiftUI

struct LockedQuestsScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(MockDataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var lockedQuests: [LockedQuest] = []
    @State private var currentLocation: GPSCoordinates?
    
    private let licenseService = MockLicenseVerificationService.shared
    
    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Stats bar
                statsBar
                
                // Content
                if lockedQuests.isEmpty {
                    emptyState
                } else {
                    LockedQuestsTab(
                        lockedQuests: lockedQuests,
                        onUnlockAction: handleUnlockAction
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadData()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("Locked Quests")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.textPrimary)
            
            Spacer()
            
            Button {
                router.navigateToHustler(.skillSelection)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundStyle(.brandPurple)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        let totalPotential = lockedQuests.reduce(0) { $0 + $1.potentialEarnings }
        
        return HStack(spacing: 20) {
            statItem(
                value: "\(lockedQuests.count)",
                label: "Locked",
                color: .instantYellow
            )
            
            Divider()
                .frame(height: 24)
                .background(Color.borderSubtle)
            
            statItem(
                value: "$\(String(format: "%.0f", totalPotential))",
                label: "Potential",
                color: .successGreen
            )
            
            Divider()
                .frame(height: 24)
                .background(Color.borderSubtle)
            
            let licenseCount = lockedQuests.filter { $0.blockReason == .licenseRequired }.count
            statItem(
                value: "\(licenseCount)",
                label: "Need License",
                color: .warningOrange
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color.surfaceSecondary)
    }
    
    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.textMuted)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.successGreen)
            }
            
            VStack(spacing: 8) {
                Text("All Caught Up!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.textPrimary)
                
                Text("You're eligible for all nearby quests.\nKeep building your skills to unlock premium tasks.")
                    .font(.system(size: 14))
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                router.navigateToHustler(.skillSelection)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add More Skills")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.brandPurple)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    
    private func handleUnlockAction(_ quest: LockedQuest) {
        switch quest.blockReason {
        case .licenseRequired:
            if let licenseType = quest.requiredSkill.licenseType {
                router.navigateToHustler(.licenseUpload(type: licenseType))
            }
        case .skillNotSelected:
            router.navigateToHustler(.skillSelection)
        case .levelTooLow:
            // Could navigate to skill progress screen
            router.navigateToHustler(.xpBreakdown)
        default:
            break
        }
    }
    
    private func loadData() async {
        // Get current location
        let (coords, _) = await MockLocationService.shared.captureLocation()
        currentLocation = coords
        
        // Initialize service
        licenseService.initializeProfile(for: appState.userId ?? "worker")
        
        // Get filtered results
        let result = licenseService.filterEligibleTasks(
            allTasks: dataService.availableTasks,
            location: coords
        )
        
        lockedQuests = result.lockedQuests
    }
}

// MARK: - Preview

#Preview("Locked Quests") {
    LockedQuestsScreen()
        .environment(Router())
        .environment(AppState())
        .environment(MockDataService())
}
