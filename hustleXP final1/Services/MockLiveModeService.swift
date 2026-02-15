//
//  MockLiveModeService.swift
//  hustleXP final1
//
//  LIVE Mode Service - Real-time urgent task matching
//  Handles Quest Alerts, Live Sessions, Radar Matching, and On-The-Way Tracking
//

import Foundation
import SwiftUI

@Observable
final class MockLiveModeService {
    static let shared = MockLiveModeService()
    
    // MARK: - State
    
    /// Active quest alerts broadcasting on the radar
    private(set) var activeQuests: [QuestAlert] = []
    
    /// Current worker's live mode session (nil if not in live mode)
    private(set) var currentSession: LiveModeSession?
    
    /// Active on-the-way tracking sessions
    private(set) var activeTrackingSessions: [OnTheWaySession] = []
    
    /// Workers visible on radar (for posters)
    private(set) var nearbyWorkers: [RadarBlip] = []
    
    /// Worker's live mode stats
    private(set) var workerStats: LiveModeStats = LiveModeStats(
        totalSessions: 47,
        totalTimeActive: 86400 * 3, // 3 days
        questsReceived: 156,
        questsAccepted: 89,
        questsCompleted: 85,
        totalEarnings: 2847.50,
        averageResponseTime: 8.5,
        averageArrivalTime: 420, // 7 minutes
        ghostingStrikes: 0,
        reliabilityScore: 94.5
    )
    
    // MARK: - Configuration
    
    let maxRadiusMeters: Double = 3218 // 2 miles
    let decisionWindowSeconds: Int = 60
    let navigationDeadlineSeconds: Int = 60
    let movementDeadlineSeconds: Int = 120
    let baseUrgencyPremium: Double = 0.25 // 25%
    let priceBoostAmount: Double = 3.0 // $3 per boost
    let priceBoostIntervalSeconds: Int = 30
    let headStartSeconds: Int = 3 // Live mode workers see quests 3 seconds early
    let minimumTrustTier: TrustTier = .elite
    let gpsUpdateIntervalSeconds: Double = 2.0 // High-frequency in live mode
    
    // MARK: - Timers
    
    private var questTimer: Timer?
    private var sessionTimer: Timer?
    private var trackingTimer: Timer?
    
    private init() {
        // Generate some mock active quests
        generateMockQuests()
    }
    
    // MARK: - Live Mode Session Management
    
    /// Start a live mode session for the worker
    func startLiveMode(
        workerId: String,
        location: GPSCoordinates,
        categories: [LiveTaskCategory],
        maxDistance: Double = 3218
    ) -> LiveModeSession {
        let session = LiveModeSession(
            id: UUID().uuidString,
            workerId: workerId,
            startedAt: Date(),
            lastPingAt: Date(),
            location: location,
            heading: 0,
            speed: 0,
            isMoving: false,
            batteryLevel: 0.85,
            signalStrength: .excellent,
            availableFor: categories,
            maxDistance: maxDistance
        )
        
        currentSession = session
        startSessionTimer()
        
        print("[LiveMode] Session started for worker \(workerId)")
        return session
    }
    
    /// End the current live mode session
    func endLiveMode() {
        guard let session = currentSession else { return }
        
        print("[LiveMode] Session ended. Duration: \(session.sessionDurationText), Earned: $\(session.earningsThisSession)")
        
        // Update stats
        workerStats.totalSessions += 1
        workerStats.totalTimeActive += session.sessionDuration
        workerStats.questsReceived += session.questsReceived
        workerStats.questsAccepted += session.questsAccepted
        workerStats.questsCompleted += session.questsCompleted
        workerStats.totalEarnings += session.earningsThisSession
        
        currentSession = nil
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
    
    /// Update worker's location during live mode
    func updateLocation(_ location: GPSCoordinates, heading: Double, speed: Double) {
        guard var session = currentSession else { return }
        
        session.location = location
        session.heading = heading
        session.speed = speed
        session.isMoving = speed > 0.5 // Moving if > 0.5 m/s
        session.lastPingAt = Date()
        
        currentSession = session
        
        // Check for nearby quests
        checkForNearbyQuests(at: location)
    }
    
    var isInLiveMode: Bool {
        currentSession != nil
    }
    
    // MARK: - Quest Alert Management
    
    /// Create a new ASAP quest alert (for posters)
    func createQuestAlert(
        task: HXTask,
        posterLocation: GPSCoordinates,
        category: LiveTaskCategory
    ) -> QuestAlert {
        let basePayment = task.payment
        let urgencyPremium = basePayment * baseUrgencyPremium
        
        let quest = QuestAlert(
            id: UUID().uuidString,
            task: task,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(Double(decisionWindowSeconds)),
            initialPayment: basePayment,
            currentPayment: basePayment,
            surgeMultiplier: 1.0,
            urgencyPremium: urgencyPremium,
            decisionWindowSeconds: decisionWindowSeconds,
            priceBoosts: 0,
            maxRadius: maxRadiusMeters,
            posterLocation: posterLocation,
            status: .broadcasting
        )
        
        activeQuests.append(quest)
        startQuestTimer()
        
        // Send quest pings to eligible workers
        sendQuestPings(for: quest)
        
        print("[LiveMode] Quest Alert created: \(task.title) at $\(quest.totalPayment)")
        return quest
    }
    
    /// Worker accepts a quest
    func acceptQuest(_ questId: String, workerId: String, workerLocation: GPSCoordinates) -> OnTheWaySession? {
        guard let index = activeQuests.firstIndex(where: { $0.id == questId }) else {
            return nil
        }
        
        var quest = activeQuests[index]
        
        // Check if already claimed
        guard quest.status == .broadcasting else {
            print("[LiveMode] Quest already claimed")
            return nil
        }
        
        // Update quest status
        quest.status = .claimed
        quest.assignedWorkerId = workerId
        activeQuests[index] = quest
        
        // Create tracking session
        let tracking = OnTheWaySession(
            id: UUID().uuidString,
            questId: questId,
            workerId: workerId,
            acceptedAt: Date(),
            navigationStartedAt: nil,
            arrivedAt: nil,
            destinationLocation: quest.posterLocation,
            workerLocation: workerLocation,
            pathPoints: [workerLocation],
            currentETA: calculateETA(from: workerLocation, to: quest.posterLocation),
            distanceRemaining: calculateDistance(from: workerLocation, to: quest.posterLocation),
            averageSpeed: 1.4, // Walking speed
            status: .accepted,
            navigationDeadline: Date().addingTimeInterval(Double(navigationDeadlineSeconds)),
            movementDeadline: Date().addingTimeInterval(Double(movementDeadlineSeconds))
        )
        
        activeTrackingSessions.append(tracking)
        startTrackingTimer()
        
        // Update session stats
        if var session = currentSession {
            session.questsAccepted += 1
            currentSession = session
        }
        
        print("[LiveMode] Quest accepted by worker \(workerId). ETA: \(tracking.currentETA)s")
        return tracking
    }
    
    /// Worker starts navigation
    func startNavigation(trackingId: String) {
        guard let index = activeTrackingSessions.firstIndex(where: { $0.id == trackingId }) else {
            return
        }
        
        var tracking = activeTrackingSessions[index]
        tracking.navigationStartedAt = Date()
        tracking.status = .navigating
        activeTrackingSessions[index] = tracking
        
        print("[LiveMode] Navigation started for tracking \(trackingId)")
    }
    
    /// Update worker position during on-the-way
    func updateTrackingPosition(_ trackingId: String, location: GPSCoordinates) {
        guard let index = activeTrackingSessions.firstIndex(where: { $0.id == trackingId }) else {
            return
        }
        
        var tracking = activeTrackingSessions[index]
        let previousLocation = tracking.workerLocation
        
        // Calculate if moving toward destination
        let previousDistance = calculateDistance(from: previousLocation, to: tracking.destinationLocation)
        let currentDistance = calculateDistance(from: location, to: tracking.destinationLocation)
        tracking.isMovingToward = currentDistance < previousDistance
        
        // Update stationary duration
        let distanceMoved = calculateDistance(from: previousLocation, to: location)
        if distanceMoved < 5 { // Less than 5 meters
            tracking.stationaryDuration += gpsUpdateIntervalSeconds
        } else {
            tracking.stationaryDuration = 0
        }
        
        // Update tracking
        tracking.workerLocation = location
        tracking.pathPoints.append(location)
        tracking.distanceRemaining = currentDistance
        tracking.currentETA = calculateETA(from: location, to: tracking.destinationLocation)
        
        // Check for arrival (within 50 meters)
        if currentDistance < 50 {
            tracking.status = .arriving
        }
        if currentDistance < 20 {
            tracking.status = .arrived
            tracking.arrivedAt = Date()
        }
        
        // Check for ghosting
        if tracking.isAtRisk && tracking.status != .arrived {
            tracking.status = .ghosting
            handleGhosting(tracking)
        }
        
        activeTrackingSessions[index] = tracking
    }
    
    /// Mark worker as arrived
    func markArrived(trackingId: String) {
        guard let index = activeTrackingSessions.firstIndex(where: { $0.id == trackingId }) else {
            return
        }
        
        var tracking = activeTrackingSessions[index]
        tracking.status = .arrived
        tracking.arrivedAt = Date()
        activeTrackingSessions[index] = tracking
        
        // Update quest status
        if let questIndex = activeQuests.firstIndex(where: { $0.id == tracking.questId }) {
            var quest = activeQuests[questIndex]
            quest.status = .inProgress
            activeQuests[questIndex] = quest
        }
        
        print("[LiveMode] Worker arrived at destination")
    }
    
    // MARK: - Radar Matching
    
    /// Check for quests near the worker's location
    private func checkForNearbyQuests(at location: GPSCoordinates) {
        for quest in activeQuests where quest.status == .broadcasting {
            let distance = calculateDistance(from: location, to: quest.posterLocation)
            if distance <= quest.maxRadius {
                // Quest is within range - would trigger UI update
                print("[LiveMode] Quest within range: \(quest.task.title) at \(Int(distance))m")
            }
        }
    }
    
    /// Get quests visible to this worker
    func getVisibleQuests(at location: GPSCoordinates, isLiveMode: Bool) -> [QuestAlert] {
        let now = Date()
        
        return activeQuests
            .filter { quest in
                guard quest.status == .broadcasting else { return false }
                
                let distance = calculateDistance(from: location, to: quest.posterLocation)
                guard distance <= quest.maxRadius else { return false }
                
                // Live mode workers get 3-second head start
                if !isLiveMode {
                    let headStartDeadline = quest.createdAt.addingTimeInterval(Double(headStartSeconds))
                    if now < headStartDeadline {
                        return false
                    }
                }
                
                return true
            }
            .map { quest in
                var q = quest
                q.distanceMeters = calculateDistance(from: location, to: quest.posterLocation)
                return q
            }
            .sorted { ($0.distanceMeters ?? 0) < ($1.distanceMeters ?? 0) }
    }
    
    /// Generate nearby workers for poster's radar view
    func generateNearbyWorkers(around location: GPSCoordinates) -> [RadarBlip] {
        // Mock nearby workers
        let mockWorkers = [
            ("Marcus T.", "MT", TrustTier.elite, 4.9, 89),
            ("Sarah K.", "SK", TrustTier.elite, 4.8, 67),
            ("James R.", "JR", TrustTier.trusted, 4.7, 45),
            ("Elena M.", "EM", TrustTier.elite, 5.0, 112),
        ]
        
        return mockWorkers.enumerated().map { index, worker in
            // Generate random nearby location
            let offsetLat = Double.random(in: -0.01...0.01)
            let offsetLon = Double.random(in: -0.01...0.01)
            let workerLocation = GPSCoordinates(
                latitude: location.latitude + offsetLat,
                longitude: location.longitude + offsetLon
            )
            let distance = calculateDistance(from: location, to: workerLocation)
            
            return RadarBlip(
                id: "worker-\(index)",
                workerId: "worker-\(index)",
                workerName: worker.0,
                workerInitials: worker.1,
                trustTier: worker.2,
                rating: worker.3,
                completedTasks: worker.4,
                location: workerLocation,
                distanceMeters: distance,
                etaSeconds: Int(distance / 1.4), // Walking speed
                heading: Double.random(in: 0...360),
                isMovingToward: Bool.random(),
                lastUpdate: Date()
            )
        }
    }
    
    // MARK: - Price Boosting
    
    /// Boost quest price if no one accepts
    private func boostQuestPrice(_ questId: String) {
        guard let index = activeQuests.firstIndex(where: { $0.id == questId }) else {
            return
        }
        
        var quest = activeQuests[index]
        guard quest.status == .broadcasting else { return }
        
        // Add price boost
        let boostAmount = Double.random(in: 2...5)
        quest.currentPayment += boostAmount
        quest.priceBoosts += 1
        
        // Extend deadline slightly
        // quest.expiresAt = quest.expiresAt.addingTimeInterval(15)
        
        activeQuests[index] = quest
        
        print("[LiveMode] Quest price boosted by $\(Int(boostAmount)). New total: $\(quest.totalPayment)")
        
        // Send price boost ping
        sendPriceBoostPing(for: quest)
    }
    
    // MARK: - Notifications
    
    private func sendQuestPings(for quest: QuestAlert) {
        // In production, would send push notifications with custom haptic
        print("[LiveMode] Sending Quest Pings to eligible workers within \(quest.maxRadius)m")
    }
    
    private func sendPriceBoostPing(for quest: QuestAlert) {
        print("[LiveMode] Sending Price Boost notification for quest \(quest.id)")
    }
    
    // MARK: - Ghosting Handling
    
    private func handleGhosting(_ tracking: OnTheWaySession) {
        print("[LiveMode] GHOSTING DETECTED for tracking \(tracking.id)")
        
        // Strike worker's shadow level
        workerStats.ghostingStrikes += 1
        workerStats.reliabilityScore = max(0, workerStats.reliabilityScore - 10)
        
        // Re-list the quest
        if let questIndex = activeQuests.firstIndex(where: { $0.id == tracking.questId }) {
            var quest = activeQuests[questIndex]
            quest.status = .broadcasting
            quest.assignedWorkerId = nil
            // Extend expiration
            // quest.expiresAt = Date().addingTimeInterval(Double(decisionWindowSeconds))
            activeQuests[questIndex] = quest
        }
    }
    
    // MARK: - Timers
    
    private func startQuestTimer() {
        questTimer?.invalidate()
        questTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateQuests()
        }
    }
    
    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: gpsUpdateIntervalSeconds, repeats: true) { [weak self] _ in
            self?.updateSession()
        }
    }
    
    private func startTrackingTimer() {
        trackingTimer?.invalidate()
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTracking()
        }
    }
    
    private func updateQuests() {
        let now = Date()
        
        for (index, quest) in activeQuests.enumerated() {
            guard quest.status == .broadcasting else { continue }
            
            // Check expiration
            if quest.isExpired {
                var q = activeQuests[index]
                q.status = .expired
                activeQuests[index] = q
                continue
            }
            
            // Check for price boost (every 30 seconds)
            let elapsed = now.timeIntervalSince(quest.createdAt)
            let expectedBoosts = Int(elapsed) / priceBoostIntervalSeconds
            if expectedBoosts > quest.priceBoosts {
                boostQuestPrice(quest.id)
            }
        }
    }
    
    private func updateSession() {
        // Would update session ping time
        if var session = currentSession {
            session.lastPingAt = Date()
            currentSession = session
        }
    }
    
    private func updateTracking() {
        // Check tracking sessions for issues
        for tracking in activeTrackingSessions {
            if tracking.isAtRisk && tracking.status == .navigating {
                print("[LiveMode] Warning: Worker may be ghosting on tracking \(tracking.id)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func calculateDistance(from: GPSCoordinates, to: GPSCoordinates) -> Double {
        LocationService.current.calculateDistance(from: from, to: to)
    }
    
    private func calculateETA(from: GPSCoordinates, to: GPSCoordinates) -> Int {
        let distance = calculateDistance(from: from, to: to)
        // Assume walking speed of 1.4 m/s (about 5 km/h)
        return Int(distance / 1.4)
    }
    
    // MARK: - Mock Data
    
    private func generateMockQuests() {
        let categories: [LiveTaskCategory] = [.lockout, .jumpstart, .lifting, .delivery]
        let locations = LocationService.current.sfNeighborhoods
        
        // Generate 2-3 active quests
        for i in 0..<2 {
            guard let neighborhood = locations.randomElement() else { continue }
            let category = categories.randomElement() ?? .other
            
            let basePayment = Double.random(in: 35...75)
            let task = HXTask(
                id: "asap-\(i)",
                title: mockTitle(for: category),
                description: mockDescription(for: category),
                payment: basePayment,
                location: neighborhood.name,
                latitude: neighborhood.coords.latitude,
                longitude: neighborhood.coords.longitude,
                estimatedDuration: "15-30 min",
                posterId: "poster-live-\(i)",
                posterName: ["Alex M.", "Jordan K.", "Taylor S."].randomElement() ?? "User",
                posterRating: Double.random(in: 4.5...5.0),
                hustlerId: nil,
                hustlerName: nil,
                state: .posted,
                requiredTier: .elite,
                createdAt: Date(),
                claimedAt: nil,
                completedAt: nil
            )
            
            var quest = QuestAlert(
                id: "quest-\(i)",
                task: task,
                createdAt: Date().addingTimeInterval(Double.random(in: -30...0)),
                expiresAt: Date().addingTimeInterval(Double.random(in: 30...60)),
                initialPayment: basePayment,
                currentPayment: basePayment + Double.random(in: 0...10),
                surgeMultiplier: 1.0,
                urgencyPremium: basePayment * 0.25,
                decisionWindowSeconds: 60,
                priceBoosts: Int.random(in: 0...2),
                maxRadius: maxRadiusMeters,
                posterLocation: neighborhood.coords,
                status: .broadcasting
            )
            quest.distanceMeters = Double.random(in: 200...1500)
            
            activeQuests.append(quest)
        }
    }
    
    private func mockTitle(for category: LiveTaskCategory) -> String {
        switch category {
        case .lockout: return "Locked out of my apartment - URGENT"
        case .jumpstart: return "Car won't start - need jump NOW"
        case .lifting: return "Need help lifting couch into truck"
        case .delivery: return "Urgent pharmacy pickup needed"
        case .moving: return "Quick furniture move - 2 items"
        case .driving: return "Airport ride needed ASAP"
        case .emergency: return "Emergency assistance needed"
        case .other: return "Quick help needed NOW"
        }
    }
    
    private func mockDescription(for category: LiveTaskCategory) -> String {
        switch category {
        case .lockout: return "Locked myself out, keys inside. Need someone with lockout tools or to wait with me for locksmith."
        case .jumpstart: return "Battery dead in parking lot. Have cables, just need another car or portable jumper."
        case .lifting: return "Heavy couch needs to go from curb into moving truck. Takes 2 people, I'll help."
        case .delivery: return "Prescription ready at Walgreens on Mission. Can't leave work, need it delivered."
        default: return "Need immediate help with a quick task. Will explain when you arrive."
        }
    }
}
