//
//  MockLicenseVerificationService.swift
//  hustleXP final1
//
//  AI Judge + License Verification Service
//  - Instant state database lookup (mock)
//  - AI confidence scoring
//  - Hard gate enforcement
//  - Clean feed filtering
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MockLicenseVerificationService {
    static let shared = MockLicenseVerificationService()
    
    // MARK: - State
    
    private(set) var workerProfile: WorkerSkillProfile?
    private(set) var pendingVerifications: [ProfessionalLicense] = []
    private(set) var isVerifying: Bool = false
    
    // MARK: - Initialize Worker Profile
    
    func initializeProfile(for workerId: String) {
        if workerProfile == nil {
            workerProfile = WorkerSkillProfile(
                workerId: workerId,
                selectedSkills: Set(SkillCatalog.basicSkills().map { $0.id }),
                unlockedSkills: Set(SkillCatalog.basicSkills().map { $0.id }),
                licenses: [],
                skillLevels: [:],
                skillXP: [:],
                skillTasksCompleted: [:],
                generalLevel: 1,
                totalSkillXP: 0
            )
        }
    }
    
    // MARK: - Skill Selection
    
    func selectSkill(_ skillId: String) {
        guard var profile = workerProfile else { return }
        
        guard let skill = SkillCatalog.skill(byId: skillId) else { return }
        
        profile.selectedSkills.insert(skillId)
        
        // If it's a basic skill, automatically unlock it
        if skill.type == .basic {
            profile.unlockedSkills.insert(skillId)
        }
        
        workerProfile = profile
        print("[License] Selected skill: \(skill.name)")
    }
    
    func deselectSkill(_ skillId: String) {
        guard var profile = workerProfile else { return }
        profile.selectedSkills.remove(skillId)
        workerProfile = profile
    }
    
    func isSkillSelected(_ skillId: String) -> Bool {
        workerProfile?.selectedSkills.contains(skillId) ?? false
    }
    
    func isSkillUnlocked(_ skillId: String) -> Bool {
        workerProfile?.unlockedSkills.contains(skillId) ?? false
    }
    
    // MARK: - License Verification (Mock AI Judge)
    
    /// Upload license for verification - returns immediately with pending status
    func uploadLicense(
        type: LicenseType,
        licenseNumber: String,
        issuingState: String,
        documentURL: URL?
    ) -> ProfessionalLicense {
        let license = ProfessionalLicense(
            id: UUID().uuidString,
            workerId: workerProfile?.workerId ?? "unknown",
            type: type,
            licenseNumber: licenseNumber,
            issuingState: issuingState,
            issuedAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 2, to: Date()),
            verificationStatus: .pending,
            verifiedAt: nil,
            documentURL: documentURL
        )
        
        pendingVerifications.append(license)
        
        // Trigger async verification
        Task {
            await verifyLicense(license.id)
        }
        
        print("[License] Upload started for \(type.rawValue)")
        return license
    }
    
    /// Mock verification process (simulates state database lookup)
    private func verifyLicense(_ licenseId: String) async {
        isVerifying = true
        
        // Simulate API call delay (2-4 seconds for "instant" verification)
        try? await Task.sleep(nanoseconds: UInt64.random(in: 2_000_000_000...4_000_000_000))
        
        guard let pendingIndex = pendingVerifications.firstIndex(where: { $0.id == licenseId }) else {
            isVerifying = false
            return
        }
        
        var license = pendingVerifications[pendingIndex]
        license.verificationStatus = .processing
        pendingVerifications[pendingIndex] = license
        
        // Simulate state database lookup
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock AI confidence scoring (80% success rate for valid-looking licenses)
        let isValid = Double.random(in: 0...1) < 0.85
        let confidenceScore = isValid ? Double.random(in: 0.85...0.99) : Double.random(in: 0.3...0.6)
        
        license.aiConfidenceScore = confidenceScore
        
        if isValid && confidenceScore > 0.8 {
            license.verificationStatus = .verified
            license.verifiedAt = Date()
            
            // Unlock the skill
            if var profile = workerProfile {
                if let skill = SkillCatalog.licensedSkills().first(where: { $0.licenseType == license.type }) {
                    profile.unlockedSkills.insert(skill.id)
                    profile.licenses.append(license)
                }
                workerProfile = profile
            }
            
            print("[License] VERIFIED: \(license.type.rawValue) (confidence: \(String(format: "%.1f", confidenceScore * 100))%)")
        } else if confidenceScore > 0.5 {
            license.verificationStatus = .manualReview
            license.manualReviewRequired = true
            print("[License] MANUAL REVIEW: \(license.type.rawValue) (confidence: \(String(format: "%.1f", confidenceScore * 100))%)")
        } else {
            license.verificationStatus = .rejected
            license.rejectionReason = "Unable to verify license with state database. Please check your license number and try again."
            print("[License] REJECTED: \(license.type.rawValue)")
        }
        
        pendingVerifications[pendingIndex] = license
        isVerifying = false
    }
    
    // MARK: - Skill Progression
    
    /// Record task completion for skill progression
    func recordTaskCompletion(skillId: String, xpEarned: Int) {
        guard var profile = workerProfile else { return }
        
        // Update task count
        let currentTasks = profile.skillTasksCompleted[skillId] ?? 0
        profile.skillTasksCompleted[skillId] = currentTasks + 1
        
        // Update XP
        let currentXP = profile.skillXP[skillId] ?? 0
        profile.skillXP[skillId] = currentXP + xpEarned
        profile.totalSkillXP += xpEarned
        
        // Check for level up
        if let skill = SkillCatalog.skill(byId: skillId) {
            checkSkillUnlock(skill, profile: &profile)
        }
        
        // Update general level
        profile.generalLevel = calculateGeneralLevel(totalXP: profile.totalSkillXP)
        
        workerProfile = profile
    }
    
    private func checkSkillUnlock(_ skill: WorkerSkill, profile: inout WorkerSkillProfile) {
        guard skill.type == .experienceBased else { return }
        guard !profile.unlockedSkills.contains(skill.id) else { return }
        
        let completedTasks = profile.skillTasksCompleted[skill.id] ?? 0
        let earnedXP = profile.skillXP[skill.id] ?? 0
        
        let taskRequirementMet = skill.tasksToUnlock == 0 || completedTasks >= skill.tasksToUnlock
        let xpRequirementMet = skill.xpToUnlock == 0 || earnedXP >= skill.xpToUnlock
        
        if taskRequirementMet && xpRequirementMet {
            profile.unlockedSkills.insert(skill.id)
            print("[License] UNLOCKED skill: \(skill.name)")
        }
    }
    
    private func calculateGeneralLevel(totalXP: Int) -> Int {
        switch totalXP {
        case 0..<100: return 1
        case 100..<300: return 2
        case 300..<600: return 3
        case 600..<1000: return 4
        case 1000..<1500: return 5
        case 1500..<2500: return 6
        case 2500..<4000: return 7
        case 4000..<6000: return 8
        case 6000..<9000: return 9
        default: return 10
        }
    }
    
    // MARK: - Feed Filtering (AI Matchmaker)
    
    /// Filter tasks for worker's eligible feed
    func filterEligibleTasks(
        allTasks: [HXTask],
        location: GPSCoordinates?,
        settings: FeedFilterSettings? = nil
    ) -> AIMatchmakerResult {
        let filterSettings = settings ?? FeedFilterSettings()
        guard let profile = workerProfile else {
            return AIMatchmakerResult(
                eligibleTasks: [],
                lockedQuests: [],
                recommendations: [],
                filterStats: AIMatchmakerResult.FilterStats(
                    totalTasksInArea: allTasks.count,
                    eligibleCount: 0,
                    lockedCount: 0,
                    filteredByDistance: 0,
                    filteredBySkill: 0,
                    filteredByLicense: 0
                )
            )
        }
        
        var eligibleTasks: [HXTask] = []
        var lockedQuests: [LockedQuest] = []
        var filteredByDistance = 0
        var filteredBySkill = 0
        var filteredByLicense = 0
        
        for task in allTasks {
            // Check distance first
            var distance: Double? = nil
            if let loc = location, let taskLat = task.latitude, let taskLon = task.longitude {
                let taskCoords = GPSCoordinates(latitude: taskLat, longitude: taskLon)
                distance = LocationService.current.calculateDistance(from: loc, to: taskCoords)
                
                if distance! > filterSettings.maxRadiusMeters {
                    filteredByDistance += 1
                    continue
                }
            }
            
            // Check eligibility
            let eligibility = checkTaskEligibility(task, profile: profile)
            
            if eligibility.isEligible {
                eligibleTasks.append(task)
            } else {
                // Add to locked quests if we have a reason
                if let blockReason = eligibility.blockReason,
                   let requiredSkill = eligibility.requiredSkill {
                    
                    switch blockReason {
                    case .licenseRequired:
                        filteredByLicense += 1
                    case .skillNotSelected, .levelTooLow:
                        filteredBySkill += 1
                    default:
                        break
                    }
                    
                    let lockedQuest = LockedQuest(
                        id: task.id,
                        task: task,
                        requiredSkill: requiredSkill,
                        blockReason: blockReason,
                        unlockAction: eligibility.unlockAction,
                        distanceMeters: distance,
                        potentialEarnings: task.payment
                    )
                    lockedQuests.append(lockedQuest)
                }
            }
        }
        
        // Sort eligible tasks based on priority
        eligibleTasks = sortTasks(eligibleTasks, by: filterSettings.prioritySort, from: location)
        
        // Generate recommendations (top 5 best matches)
        let recommendations = generateRecommendations(from: eligibleTasks, profile: profile)
        
        // Sort locked quests by potential earnings (highest first)
        lockedQuests.sort { $0.potentialEarnings > $1.potentialEarnings }
        
        return AIMatchmakerResult(
            eligibleTasks: eligibleTasks,
            lockedQuests: Array(lockedQuests.prefix(10)), // Limit to top 10
            recommendations: recommendations,
            filterStats: AIMatchmakerResult.FilterStats(
                totalTasksInArea: allTasks.count,
                eligibleCount: eligibleTasks.count,
                lockedCount: lockedQuests.count,
                filteredByDistance: filteredByDistance,
                filteredBySkill: filteredBySkill,
                filteredByLicense: filteredByLicense
            )
        )
    }
    
    private func checkTaskEligibility(_ task: HXTask, profile: WorkerSkillProfile) -> TaskEligibilityResult {
        // For now, use a simple skill matching based on task category
        // In production, tasks would have explicit skill requirements
        
        guard let taskCategory = task.category else {
            // Tasks without category are available to all
            return TaskEligibilityResult(
                isEligible: true,
                task: task,
                requiredSkill: nil,
                blockReason: nil,
                unlockAction: nil
            )
        }
        
        // Map task category to skill category
        let relatedSkills = mapTaskCategoryToSkills(taskCategory)
        
        // Check if worker has any matching unlocked skill
        let hasMatchingSkill = relatedSkills.contains { profile.unlockedSkills.contains($0.id) }
        
        if hasMatchingSkill {
            return TaskEligibilityResult(
                isEligible: true,
                task: task,
                requiredSkill: nil,
                blockReason: nil,
                unlockAction: nil
            )
        }
        
        // Find the most relevant required skill
        if let requiredSkill = relatedSkills.first {
            let blockReason: TaskEligibilityResult.EligibilityBlockReason
            let unlockAction: TaskEligibilityResult.UnlockAction?
            
            if requiredSkill.type == .licensed {
                blockReason = .licenseRequired
                unlockAction = .uploadLicense(requiredSkill.licenseType!)
            } else if !profile.selectedSkills.contains(requiredSkill.id) {
                blockReason = .skillNotSelected
                unlockAction = .selectSkill(requiredSkill)
            } else {
                blockReason = .levelTooLow
                let xpNeeded = requiredSkill.xpToUnlock - (profile.skillXP[requiredSkill.id] ?? 0)
                unlockAction = .gainXP(max(0, xpNeeded))
            }
            
            return TaskEligibilityResult(
                isEligible: false,
                task: task,
                requiredSkill: requiredSkill,
                blockReason: blockReason,
                unlockAction: unlockAction
            )
        }
        
        return TaskEligibilityResult(
            isEligible: true,
            task: task,
            requiredSkill: nil,
            blockReason: nil,
            unlockAction: nil
        )
    }
    
    private func mapTaskCategoryToSkills(_ category: TaskCategory) -> [WorkerSkill] {
        switch category {
        case .delivery:
            return SkillCatalog.skills(for: .delivery)
        case .moving:
            return SkillCatalog.skills(for: .moving)
        case .cleaning:
            return SkillCatalog.skills(for: .cleaning)
        case .yardWork:
            return SkillCatalog.skills(for: .yardWork)
        case .assembly:
            return SkillCatalog.skills(for: .events).filter { $0.name.contains("Assembly") }
        case .petCare:
            return SkillCatalog.skills(for: .petCare)
        case .shopping:
            return SkillCatalog.skills(for: .delivery).filter { $0.name.contains("Shopping") }
        case .tech:
            return SkillCatalog.skills(for: .tech)
        case .other:
            return SkillCatalog.basicSkills()
        }
    }
    
    private func sortTasks(_ tasks: [HXTask], by priority: FeedFilterSettings.FeedPrioritySort, from location: GPSCoordinates?) -> [HXTask] {
        switch priority {
        case .bestMatch:
            // Sort by a combination of distance and payment
            return tasks.sorted { task1, task2 in
                let score1 = calculateMatchScore(task1, from: location)
                let score2 = calculateMatchScore(task2, from: location)
                return score1 > score2
            }
        case .nearest:
            guard let loc = location else { return tasks }
            return LocationService.current.sortTasksByDistance(tasks: tasks, from: loc)
        case .highestPay:
            return tasks.sorted { $0.payment > $1.payment }
        case .newest:
            return tasks.sorted { $0.createdAt > $1.createdAt }
        case .endingSoon:
            // Would sort by deadline if tasks had one
            return tasks
        }
    }
    
    private func calculateMatchScore(_ task: HXTask, from location: GPSCoordinates?) -> Double {
        var score = 50.0 // Base score
        
        // Payment bonus (up to 30 points)
        score += min(30, task.payment / 5)
        
        // Distance penalty (up to -20 points)
        if let loc = location, let lat = task.latitude, let lon = task.longitude {
            let taskCoords = GPSCoordinates(latitude: lat, longitude: lon)
            let distance = LocationService.current.calculateDistance(from: loc, to: taskCoords)
            let distanceKm = distance / 1000
            score -= min(20, distanceKm * 2)
        }
        
        return score
    }
    
    private func generateRecommendations(from tasks: [HXTask], profile: WorkerSkillProfile) -> [AIMatchmakerResult.TaskRecommendation] {
        return Array(tasks.prefix(5)).map { task in
            var reasons: [String] = []
            
            if task.payment >= 50 {
                reasons.append("High pay")
            }
            if task.estimatedDuration.contains("min") {
                reasons.append("Quick task")
            }
            if task.posterRating >= 4.8 {
                reasons.append("Great poster")
            }
            
            return AIMatchmakerResult.TaskRecommendation(
                task: task,
                matchScore: Double.random(in: 75...95),
                reasons: reasons.isEmpty ? ["Good match for your skills"] : reasons
            )
        }
    }
    
    // MARK: - License Status Helpers
    
    func getLicenseStatus(for type: LicenseType) -> LicenseVerificationStatus? {
        // Check pending first
        if let pending = pendingVerifications.first(where: { $0.type == type }) {
            return pending.verificationStatus
        }
        // Check verified
        if let verified = workerProfile?.licenses.first(where: { $0.type == type }) {
            return verified.verificationStatus
        }
        return nil
    }
    
    func hasVerifiedLicense(for type: LicenseType) -> Bool {
        workerProfile?.getVerifiedLicense(for: type) != nil
    }
    
    // MARK: - Stats
    
    func getSkillStats() -> (selected: Int, unlocked: Int, licensed: Int) {
        guard let profile = workerProfile else { return (0, 0, 0) }
        let licensedCount = profile.licenses.filter { $0.isValid }.count
        return (profile.selectedSkills.count, profile.unlockedSkills.count, licensedCount)
    }
}
