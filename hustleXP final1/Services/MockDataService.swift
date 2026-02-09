//
//  MockDataService.swift
//  hustleXP final1
//
//  Mock data service for development
//

import Foundation

@MainActor
@Observable
final class MockDataService {
    static let shared = MockDataService()
    
    // MARK: - Current User
    var currentUser: HXUser = HXUser(
        id: "user-001",
        name: "Demo User",
        email: "demo@hustlexp.com",
        phone: "+1 (555) 123-4567",
        bio: "Ready to hustle!",
        avatarURL: nil,
        role: .hustler,
        trustTier: .rookie,
        rating: 4.5,
        totalRatings: 12,
        xp: 45,
        tasksCompleted: 8,
        tasksPosted: 3,
        totalEarnings: 325.00,
        totalSpent: 150.00,
        isVerified: false,
        createdAt: Date().addingTimeInterval(-86400 * 30)
    )
    
    // MARK: - Mock Tasks
    var availableTasks: [HXTask] = [
        HXTask(
            id: "task-001",
            title: "Deliver Package Downtown",
            description: "Need someone to pick up a package from my office and deliver it to a client downtown. Package is small (under 5 lbs).",
            payment: 25.00,
            location: "Downtown",
            latitude: 37.7749,
            longitude: -122.4194,
            estimatedDuration: "30 min",
            posterId: "poster-001",
            posterName: "John D.",
            posterRating: 4.8,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-3600),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-002",
            title: "Help Moving Furniture",
            description: "Moving a couch and dining table from apartment to storage unit. Need someone with a vehicle or willing to help load.",
            payment: 75.00,
            location: "Westside",
            latitude: 37.7849,
            longitude: -122.4294,
            estimatedDuration: "2 hrs",
            posterId: "poster-002",
            posterName: "Sarah M.",
            posterRating: 4.9,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .verified,
            createdAt: Date().addingTimeInterval(-7200),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-003",
            title: "Grocery Shopping & Delivery",
            description: "Need groceries picked up from Whole Foods and delivered. List will be provided. About 15 items.",
            payment: 35.00,
            location: "Midtown",
            latitude: 37.7649,
            longitude: -122.4094,
            estimatedDuration: "1 hr",
            posterId: "poster-003",
            posterName: "Mike R.",
            posterRating: 4.7,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-1800),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-004",
            title: "Dog Walking",
            description: "Need someone to walk my golden retriever for 45 minutes. He's friendly and well-trained.",
            payment: 20.00,
            location: "Park District",
            latitude: 37.7549,
            longitude: -122.4394,
            estimatedDuration: "45 min",
            posterId: "poster-004",
            posterName: "Lisa K.",
            posterRating: 5.0,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-900),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-005",
            title: "Assemble IKEA Furniture",
            description: "Need help assembling a KALLAX shelf unit and a desk. Tools provided.",
            payment: 50.00,
            location: "Eastside",
            latitude: 37.7949,
            longitude: -122.3994,
            estimatedDuration: "1.5 hrs",
            posterId: "poster-005",
            posterName: "Tom B.",
            posterRating: 4.6,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .trusted,
            createdAt: Date().addingTimeInterval(-5400),
            claimedAt: nil,
            completedAt: nil
        )
    ]
    
    var activeTask: HXTask? = nil
    
    var completedTasks: [HXTask] = []
    
    // MARK: - Mock Conversations
    var conversations: [HXConversation] = []
    
    // MARK: - v1.8.0 Tax System
    var taxStatus: TaxStatus = TaxStatus(
        unpaidTaxCents: 1500, // $15.00 unpaid
        xpHeldBack: 150,
        blocked: true,
        lastPaymentAt: nil
    )
    
    var taxHistory: [TaxLedgerEntry] = [
        TaxLedgerEntry(
            id: "tax-001",
            taskId: "task-past-001",
            taskTitle: "Move boxes to storage",
            paymentMethod: .offlineCash,
            grossPayoutCents: 5000,
            taxAmountCents: 500,
            taxPaid: false,
            paidAt: nil,
            createdAt: Date().addingTimeInterval(-86400 * 2)
        ),
        TaxLedgerEntry(
            id: "tax-002",
            taskId: "task-past-002",
            taskTitle: "Grocery delivery",
            paymentMethod: .offlineVenmo,
            grossPayoutCents: 3500,
            taxAmountCents: 350,
            taxPaid: false,
            paidAt: nil,
            createdAt: Date().addingTimeInterval(-86400 * 5)
        ),
        TaxLedgerEntry(
            id: "tax-003",
            taskId: "task-past-003",
            taskTitle: "Dog walking",
            paymentMethod: .offlineCashApp,
            grossPayoutCents: 2000,
            taxAmountCents: 200,
            taxPaid: false,
            paidAt: nil,
            createdAt: Date().addingTimeInterval(-86400 * 7)
        ),
        TaxLedgerEntry(
            id: "tax-004",
            taskId: "task-past-004",
            taskTitle: "Furniture assembly",
            paymentMethod: .offlineCash,
            grossPayoutCents: 4500,
            taxAmountCents: 450,
            taxPaid: true,
            paidAt: Date().addingTimeInterval(-86400 * 14),
            createdAt: Date().addingTimeInterval(-86400 * 14)
        )
    ]
    
    // MARK: - v1.8.0 Verification Unlock
    var verificationUnlockStatus: VerificationUnlockStatus = VerificationUnlockStatus(
        earnedCents: 2500, // $25.00 earned
        thresholdCents: 4000, // $40.00 threshold
        percentage: 62.5,
        unlocked: false,
        tasksCompleted: 8,
        remainingCents: 1500 // $15.00 remaining
    )
    
    var verificationEarnings: [VerificationEarningsEntry] = [
        VerificationEarningsEntry(
            id: "earn-001",
            taskId: "task-past-001",
            taskTitle: "Package delivery",
            escrowId: "escrow-001",
            netPayoutCents: 800, // $8.00 after fees
            earnedAt: Date().addingTimeInterval(-86400 * 2)
        ),
        VerificationEarningsEntry(
            id: "earn-002",
            taskId: "task-past-002",
            taskTitle: "Grocery shopping",
            escrowId: "escrow-002",
            netPayoutCents: 560, // $5.60 after fees
            earnedAt: Date().addingTimeInterval(-86400 * 5)
        ),
        VerificationEarningsEntry(
            id: "earn-003",
            taskId: "task-past-003",
            taskTitle: "Moving help",
            escrowId: "escrow-003",
            netPayoutCents: 1140, // $11.40 after fees
            earnedAt: Date().addingTimeInterval(-86400 * 10)
        )
    ]
    
    // MARK: - v1.8.0 Insurance
    var insurancePoolStatus: InsurancePoolStatus = InsurancePoolStatus(
        poolBalanceCents: 12500000, // $125,000
        totalContributionsCents: 15000000,
        totalPaidClaimsCents: 2500000,
        activeClaimsCount: 12,
        userContributionsCents: 650 // User's 2% contributions
    )
    
    var insuranceClaims: [InsuranceClaim] = [
        InsuranceClaim(
            id: "claim-001",
            taskId: "task-past-005",
            taskTitle: "Furniture delivery gone wrong",
            incidentDescription: "The poster never responded after I completed the work. I delivered the furniture as requested but they ghosted me.",
            requestedAmountCents: 7500,
            approvedAmountCents: 6000,
            status: .approved,
            filedAt: Date().addingTimeInterval(-86400 * 30),
            reviewedAt: Date().addingTimeInterval(-86400 * 25),
            reviewerNotes: "Claim approved at 80% coverage based on task completion evidence."
        )
    ]
    
    // MARK: - Actions
    
    func claimTask(_ taskId: String) {
        guard let index = availableTasks.firstIndex(where: { $0.id == taskId }) else { return }
        var task = availableTasks[index]
        task.state = .claimed
        task.hustlerId = currentUser.id
        task.hustlerName = currentUser.name
        task.claimedAt = Date()
        
        availableTasks.remove(at: index)
        activeTask = task
        
        print("[MockData] Task claimed: \(task.title)")
    }
    
    func updateTaskState(_ taskId: String, to state: TaskState) {
        if var task = activeTask, task.id == taskId {
            task.state = state
            if state == .completed {
                task.completedAt = Date()
                completedTasks.append(task)
                activeTask = nil
                currentUser.tasksCompleted += 1
                currentUser.totalEarnings += task.payment
                currentUser.xp += Int(task.payment / 2)
            } else {
                activeTask = task
            }
            print("[MockData] Task state updated: \(state.rawValue)")
        }
    }
    
    func postTask(_ task: HXTask) {
        var newTask = task
        newTask.state = .posted
        availableTasks.insert(newTask, at: 0)
        currentUser.tasksPosted += 1
        print("[MockData] Task posted: \(task.title)")
    }
    
    func getTask(by id: String) -> HXTask? {
        // Check available tasks
        if let task = availableTasks.first(where: { $0.id == id }) {
            return task
        }
        // Check active task
        if let task = activeTask, task.id == id {
            return task
        }
        // Check completed tasks
        if let task = completedTasks.first(where: { $0.id == id }) {
            return task
        }
        return nil
    }
    
    func getTasksForPoster() -> [HXTask] {
        // Return tasks posted by the current user
        let allTasks = availableTasks + [activeTask].compactMap { $0 } + completedTasks
        return allTasks.filter { $0.posterId == currentUser.id || $0.posterId.hasPrefix("poster-") }
    }
    
    // MARK: - v1.8.0 Tax Actions
    
    func payTax() -> TaxPaymentResult {
        let xpReleased = taxStatus.xpHeldBack
        
        // Mark all unpaid entries as paid
        for i in taxHistory.indices {
            if !taxHistory[i].taxPaid {
                taxHistory[i] = TaxLedgerEntry(
                    id: taxHistory[i].id,
                    taskId: taxHistory[i].taskId,
                    taskTitle: taxHistory[i].taskTitle,
                    paymentMethod: taxHistory[i].paymentMethod,
                    grossPayoutCents: taxHistory[i].grossPayoutCents,
                    taxAmountCents: taxHistory[i].taxAmountCents,
                    taxPaid: true,
                    paidAt: Date(),
                    createdAt: taxHistory[i].createdAt
                )
            }
        }
        
        // Update tax status
        let newStatus = TaxStatus(
            unpaidTaxCents: 0,
            xpHeldBack: 0,
            blocked: false,
            lastPaymentAt: Date()
        )
        taxStatus = newStatus
        
        // Release XP to user
        currentUser.xp += xpReleased
        currentUser.xpHeldBack = 0
        currentUser.unpaidTaxCents = 0
        
        print("[MockData] Tax paid! Released \(xpReleased) XP")
        
        return TaxPaymentResult(
            success: true,
            xpReleased: xpReleased,
            newTaxStatus: newStatus
        )
    }
    
    // MARK: - v1.8.0 Verification Actions
    
    func checkVerificationEligibility() -> Bool {
        verificationUnlockStatus.unlocked
    }
    
    func updateVerificationProgress(earnedCents: Int) {
        let newEarned = verificationUnlockStatus.earnedCents + earnedCents
        let threshold = verificationUnlockStatus.thresholdCents
        let percentage = min(Double(newEarned) / Double(threshold) * 100, 100)
        let remaining = max(threshold - newEarned, 0)
        let unlocked = newEarned >= threshold
        
        verificationUnlockStatus = VerificationUnlockStatus(
            earnedCents: newEarned,
            thresholdCents: threshold,
            percentage: percentage,
            unlocked: unlocked,
            tasksCompleted: verificationUnlockStatus.tasksCompleted + 1,
            remainingCents: remaining
        )
        
        currentUser.verificationEarnedCents = newEarned
        
        print("[MockData] Verification progress: \(percentage)%")
    }
    
    // MARK: - v1.8.0 Insurance Actions
    
    func fileClaim(_ request: FileClaimRequest) -> InsuranceClaim? {
        guard request.isValid else { return nil }
        
        let task = getTask(by: request.taskId)
        let claim = InsuranceClaim(
            id: "claim-\(UUID().uuidString.prefix(8))",
            taskId: request.taskId,
            taskTitle: task?.title ?? "Unknown Task",
            incidentDescription: request.incidentDescription,
            requestedAmountCents: request.requestedAmountCents,
            approvedAmountCents: nil,
            status: .filed,
            filedAt: Date(),
            reviewedAt: nil,
            reviewerNotes: nil
        )
        
        insuranceClaims.insert(claim, at: 0)
        insurancePoolStatus = InsurancePoolStatus(
            poolBalanceCents: insurancePoolStatus.poolBalanceCents,
            totalContributionsCents: insurancePoolStatus.totalContributionsCents,
            totalPaidClaimsCents: insurancePoolStatus.totalPaidClaimsCents,
            activeClaimsCount: insurancePoolStatus.activeClaimsCount + 1,
            userContributionsCents: insurancePoolStatus.userContributionsCents
        )
        
        // Mark task as having active claim
        if var task = activeTask, task.id == request.taskId {
            task.hasActiveClaim = true
            activeTask = task
        }
        
        print("[MockData] Claim filed: \(claim.id)")
        return claim
    }
    
    func getClaimsForTask(_ taskId: String) -> [InsuranceClaim] {
        insuranceClaims.filter { $0.taskId == taskId }
    }
    
    // MARK: - v1.8.0 AI Pricing
    
    func getAIPriceSuggestion(for request: AIPricingRequest) -> AIPriceSuggestion {
        // Use the mock suggestion generator from the model
        return request.generateMockSuggestion()
    }
    
    func getCompletedTasksForClaims() -> [HXTask] {
        completedTasks.filter { !$0.hasActiveClaim }
    }
    
    // MARK: - v1.8.0 Biometric Proof Validation
    
    func validateBiometricProof(submission: BiometricProofSubmission, taskId: String) -> BiometricValidationResult {
        // Get task location if available
        let task = getTask(by: taskId)
        let taskLat = task?.latitude ?? 37.7749
        let taskLon = task?.longitude ?? -122.4194
        
        // Calculate GPS proximity (simulated)
        let userLat = submission.gpsCoordinates.latitude
        let userLon = submission.gpsCoordinates.longitude
        
        // Simple distance calculation (for mock purposes)
        let latDiff = abs(taskLat - userLat)
        let lonDiff = abs(taskLon - userLon)
        let distanceApprox = sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111000 // Rough meters
        
        // Determine GPS proximity score (0-1)
        let gpsScore: Double = {
            if distanceApprox < 50 { return 0.98 }
            if distanceApprox < 100 { return 0.90 }
            if distanceApprox < 500 { return 0.70 }
            if distanceApprox < 1000 { return 0.50 }
            return 0.30
        }()
        
        // Mock scores (simulated ML results)
        let livenessScore = Double.random(in: 0.85...0.99)
        let deepfakeScore = Double.random(in: 0.01...0.15) // Lower is better
        
        // Determine flags
        var flags: [String] = []
        if gpsScore < 0.70 {
            flags.append("GPS_DISTANCE_WARNING")
        }
        if submission.gpsCoordinates.accuracyMeters > 30 {
            flags.append("LOW_GPS_ACCURACY")
        }
        if deepfakeScore > 0.10 {
            flags.append("DEEPFAKE_CHECK_NEEDED")
        }
        
        // Determine risk level
        let riskLevel: RiskLevel = {
            if gpsScore > 0.85 && livenessScore > 0.90 && deepfakeScore < 0.10 {
                return .low
            }
            if gpsScore > 0.60 && livenessScore > 0.80 {
                return .medium
            }
            if gpsScore > 0.40 {
                return .high
            }
            return .critical
        }()
        
        // Determine recommendation
        let recommendation: ValidationRecommendation = {
            switch riskLevel {
            case .low: return .approve
            case .medium: return .manualReview
            case .high: return .manualReview
            case .critical: return .reject
            }
        }()
        
        // Generate reasoning
        let reasoning: String = {
            switch recommendation {
            case .approve:
                return "Biometric proof validated. GPS coordinates match task location with high confidence. Liveness check passed."
            case .manualReview:
                if gpsScore < 0.70 {
                    return "GPS coordinates are outside expected range. Manual review recommended to verify task completion."
                } else {
                    return "Some validation checks require human review. Scores are within acceptable range but flagged for verification."
                }
            case .reject:
                return "Validation failed. GPS coordinates are too far from task location or biometric checks did not pass minimum thresholds."
            }
        }()
        
        let scores = ValidationScores(
            liveness: Int(livenessScore * 100),
            deepfake: Int(deepfakeScore * 100),
            gpsProximity: Int(gpsScore * 100)
        )
        
        return BiometricValidationResult(
            recommendation: recommendation,
            reasoning: reasoning,
            flags: flags,
            scores: scores,
            riskLevel: riskLevel
        )
    }
}
