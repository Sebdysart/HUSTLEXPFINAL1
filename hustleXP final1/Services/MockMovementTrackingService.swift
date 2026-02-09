//
//  MockMovementTrackingService.swift
//  hustleXP final1
//
//  Mock Movement Tracking service for v1.9.0 - GPS fraud detection
//

import Foundation
import CoreLocation

@MainActor
@Observable
final class MockMovementTrackingService {
    static let shared = MockMovementTrackingService()
    
    // MARK: - State
    
    var activeSession: MovementTrackingSession?
    var isTracking: Bool = false
    var currentFlags: [MovementFlag] = []
    
    // MARK: - Configuration
    
    let trackingIntervalSeconds: Double = 30
    let stationaryThresholdMinutes: Int = 10
    let minimumMovementMeters: Double = 20
    let impossibleSpeedMps: Double = 27.8  // 100 km/h
    
    // MARK: - Private
    
    private var trackingTimer: Task<Void, Never>?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Tracking Control
    
    /// Start tracking movement for a task
    @discardableResult
    func startTracking(taskId: String, hustlerId: String) -> MovementTrackingSession {
        // Stop any existing tracking
        stopTracking()
        
        // Create new session
        let session = MovementTrackingSession(
            id: "track_\(taskId)_\(UUID().uuidString.prefix(8))",
            taskId: taskId,
            hustlerId: hustlerId,
            startedAt: Date(),
            locations: [],
            status: .active,
            flags: []
        )
        
        activeSession = session
        isTracking = true
        currentFlags = []
        
        // Start tracking timer
        startTrackingTimer()
        
        print("[MovementTracking] Started tracking for task: \(taskId)")
        
        return session
    }
    
    /// Stop tracking and return final session
    @discardableResult
    func stopTracking() -> MovementTrackingSession? {
        trackingTimer?.cancel()
        trackingTimer = nil
        
        guard var session = activeSession else { return nil }
        
        session.status = .completed
        
        let finalSession = session
        activeSession = nil
        isTracking = false
        currentFlags = []
        
        print("[MovementTracking] Stopped tracking. Total distance: \(String(format: "%.1f", session.totalDistanceMeters))m")
        
        return finalSession
    }
    
    /// Record a new location point
    func recordLocation(_ location: GPSCoordinates) {
        guard var session = activeSession else { return }
        
        // Calculate speed if we have a previous location
        var speed: Double? = nil
        if let lastLocation = session.locations.last {
            let lastCoords = GPSCoordinates(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let distance = MockLocationService.shared.calculateDistance(from: lastCoords, to: location)
            let timeDiff = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            if timeDiff > 0 {
                speed = distance / timeDiff
            }
        }
        
        let trackedLocation = TrackedLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: location.timestamp,
            accuracyMeters: location.accuracyMeters,
            speedMps: speed
        )
        
        session.locations.append(trackedLocation)
        
        // Analyze for anomalies
        let newFlags = detectAnomalies(in: session)
        if !newFlags.isEmpty {
            session.flags = Array(Set(session.flags + newFlags))
            currentFlags = session.flags
            
            // Update status based on flags
            if newFlags.contains(.impossibleSpeed) || newFlags.contains(.locationJump) {
                session.status = .suspicious
            } else if newFlags.contains(.stationaryTooLong) {
                session.status = .stationary
            }
        }
        
        activeSession = session
        
        print("[MovementTracking] Recorded location. Total points: \(session.locations.count)")
    }
    
    // MARK: - Analysis
    
    /// Detect anomalies in movement session
    func detectAnomalies(in session: MovementTrackingSession) -> [MovementFlag] {
        var flags: [MovementFlag] = []
        
        // Check for stationary too long
        if checkStationary(in: session) {
            flags.append(.stationaryTooLong)
        }
        
        // Check for impossible speed
        if let lastSpeed = session.locations.last?.speedMps, lastSpeed > impossibleSpeedMps {
            flags.append(.impossibleSpeed)
        }
        
        // Check for location jumps (teleportation)
        if checkLocationJump(in: session) {
            flags.append(.locationJump)
        }
        
        // Check for consistently low accuracy
        if checkLowAccuracy(in: session) {
            flags.append(.lowAccuracy)
        }
        
        return flags
    }
    
    /// Check if user has been stationary too long
    func checkStationary(in session: MovementTrackingSession) -> Bool {
        let thresholdSeconds = Double(stationaryThresholdMinutes * 60)
        let requiredPoints = Int(thresholdSeconds / trackingIntervalSeconds)
        
        guard session.locations.count >= requiredPoints else { return false }
        
        let recentLocations = Array(session.locations.suffix(requiredPoints))
        guard let first = recentLocations.first else { return false }
        
        let firstLoc = CLLocation(latitude: first.latitude, longitude: first.longitude)
        
        var maxDistance: Double = 0
        for loc in recentLocations {
            let currentLoc = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            maxDistance = max(maxDistance, currentLoc.distance(from: firstLoc))
        }
        
        return maxDistance < minimumMovementMeters
    }
    
    /// Check for sudden location jumps
    private func checkLocationJump(in session: MovementTrackingSession) -> Bool {
        guard session.locations.count >= 2 else { return false }
        
        let recent = Array(session.locations.suffix(2))
        let from = CLLocation(latitude: recent[0].latitude, longitude: recent[0].longitude)
        let to = CLLocation(latitude: recent[1].latitude, longitude: recent[1].longitude)
        
        let distance = to.distance(from: from)
        let timeDiff = recent[1].timestamp.timeIntervalSince(recent[0].timestamp)
        
        // If moved more than 500m in less than 30 seconds, it's suspicious
        if distance > 500 && timeDiff < 30 {
            return true
        }
        
        return false
    }
    
    /// Check for consistently low GPS accuracy
    private func checkLowAccuracy(in session: MovementTrackingSession) -> Bool {
        guard session.locations.count >= 5 else { return false }
        
        let recentLocations = Array(session.locations.suffix(5))
        let avgAccuracy = recentLocations.reduce(0) { $0 + $1.accuracyMeters } / Double(recentLocations.count)
        
        return avgAccuracy > 75 // More than 75m average accuracy is concerning
    }
    
    /// Get movement summary for session
    func getMovementSummary() -> MovementSummary? {
        guard let session = activeSession else { return nil }
        
        let totalDistance = session.totalDistanceMeters
        let totalTime = session.locations.last?.timestamp.timeIntervalSince(session.startedAt) ?? 0
        let avgSpeed = session.averageSpeed
        
        // Count stationary periods
        var stationaryPeriods = 0
        let windowSize = 5
        for i in stride(from: windowSize, to: session.locations.count, by: windowSize) {
            let window = Array(session.locations[(i - windowSize)..<i])
            if checkStationaryWindow(window) {
                stationaryPeriods += 1
            }
        }
        
        // Determine risk level
        let riskLevel: RiskLevel
        if currentFlags.contains(.impossibleSpeed) || currentFlags.contains(.locationJump) {
            riskLevel = .critical
        } else if currentFlags.contains(.stationaryTooLong) {
            riskLevel = .high
        } else if currentFlags.contains(.lowAccuracy) || stationaryPeriods > 2 {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }
        
        return MovementSummary(
            totalDistance: totalDistance,
            totalTime: totalTime,
            averageSpeed: avgSpeed,
            stationaryPeriods: stationaryPeriods,
            flags: currentFlags,
            riskLevel: riskLevel
        )
    }
    
    // MARK: - Mock Data Generation
    
    /// Generate a mock movement path between two points
    func generateMockMovementPath(from: GPSCoordinates, to: GPSCoordinates, points: Int = 20) -> [TrackedLocation] {
        var locations: [TrackedLocation] = []
        let startTime = Date()
        
        let latStep = (to.latitude - from.latitude) / Double(points)
        let lonStep = (to.longitude - from.longitude) / Double(points)
        
        for i in 0...points {
            // Add slight random variation
            let jitter = Double.random(in: -0.0001...0.0001)
            let accuracy = Double.random(in: 5...30)
            
            let location = TrackedLocation(
                latitude: from.latitude + (latStep * Double(i)) + jitter,
                longitude: from.longitude + (lonStep * Double(i)) + jitter,
                timestamp: startTime.addingTimeInterval(Double(i) * trackingIntervalSeconds),
                accuracyMeters: accuracy,
                speedMps: Double.random(in: 1.0...1.8) // Walking speed
            )
            
            locations.append(location)
        }
        
        return locations
    }
    
    // MARK: - Private Helpers
    
    private func startTrackingTimer() {
        trackingTimer = Task {
            while !Task.isCancelled && isTracking {
                try? await Task.sleep(nanoseconds: UInt64(trackingIntervalSeconds * 1_000_000_000))
                
                // Simulate getting current location
                let (coords, _) = await MockLocationService.shared.captureLocation()
                recordLocation(coords)
            }
        }
    }
    
    private func checkStationaryWindow(_ locations: [TrackedLocation]) -> Bool {
        guard locations.count >= 2, let first = locations.first else { return false }
        
        let firstLoc = CLLocation(latitude: first.latitude, longitude: first.longitude)
        var maxDistance: Double = 0
        
        for loc in locations {
            let currentLoc = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            maxDistance = max(maxDistance, currentLoc.distance(from: firstLoc))
        }
        
        return maxDistance < minimumMovementMeters
    }
}
