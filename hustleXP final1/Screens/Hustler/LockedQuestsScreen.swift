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
    @Environment(LiveDataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var lockedQuests: [LockedQuest] = []
    @State private var currentLocation: GPSCoordinates?
    @State private var myVerifiedSkills: [WorkerSkillRecord] = []
    
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
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Go back")

            Spacer()

            Text("Locked Quests")
                .font(.system(size: 17, weight: .semibold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                router.navigateToHustler(.skillSelection)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Manage skills")
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
                .minimumScaleFactor(0.7)
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.textMuted)
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
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 8) {
                Text("All Caught Up!")
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("You're eligible for all nearby quests.\nKeep building your skills to unlock premium tasks.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
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
                .foregroundStyle(Color.brandPurple)
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
        let (coords, _) = await LocationService.current.captureLocation()
        currentLocation = coords

        // v2.2.0: Try real API first
        do {
            let mySkills = try await SkillService.shared.getMySkills()
            myVerifiedSkills = mySkills
            print("LockedQuests: Got \(mySkills.count) skills from API")

            // Check eligibility for each available task
            var locked: [LockedQuest] = []
            for task in dataService.availableTasks {
                do {
                    let eligibility = try await SkillService.shared.checkTaskEligibility(taskId: task.id)
                    if !eligibility.isEligible {
                        let blockReason: TaskEligibilityResult.EligibilityBlockReason
                        if eligibility.requiresLicense && !eligibility.licenseVerified {
                            blockReason = .licenseRequired
                        } else if let reqLevel = eligibility.requiredLevel,
                                  let curLevel = eligibility.currentLevel,
                                  curLevel < reqLevel {
                            blockReason = .levelTooLow
                        } else {
                            blockReason = .skillNotSelected
                        }

                        // Create a WorkerSkill for display
                        let skill = WorkerSkill(
                            id: eligibility.requiredSkill ?? "unknown",
                            name: eligibility.requiredSkill ?? "Required Skill",
                            category: .generalLabor,
                            type: eligibility.requiresLicense ? .licensed : .basic,
                            icon: "questionmark.circle",
                            licenseType: nil,
                            requiredLevel: eligibility.requiredLevel ?? 1,
                            xpToUnlock: 0,
                            tasksToUnlock: 0
                        )

                        locked.append(LockedQuest(
                            id: task.id,
                            task: task,
                            requiredSkill: skill,
                            blockReason: blockReason,
                            unlockAction: blockReason == .licenseRequired ? nil : .selectSkill(skill),
                            distanceMeters: nil,
                            potentialEarnings: task.payment
                        ))
                    }
                } catch {
                    // If individual check fails, skip this task
                    continue
                }
            }

            lockedQuests = locked
            print("LockedQuests: Found \(locked.count) locked quests via API")

        } catch {
            print("LockedQuests: API failed, using mock - \(error.localizedDescription)")

            // Fallback to mock
            let mockService = MockLicenseVerificationService.shared
            mockService.initializeProfile(for: appState.userId ?? "worker")
            let result = mockService.filterEligibleTasks(
                allTasks: dataService.availableTasks,
                location: coords
            )
            lockedQuests = result.lockedQuests
        }
    }
}

// MARK: - Preview

#Preview("Locked Quests") {
    LockedQuestsScreen()
        .environment(Router())
        .environment(AppState())
        .environment(LiveDataService.shared)
}
