//
//  MockGeofenceService.swift
//  hustleXP final1
//
//  Mock Geofence service for v1.9.0 - Smart Start auto clock-in
//

import Foundation
import CoreLocation

@MainActor
@Observable
final class MockGeofenceService {
    static let shared = MockGeofenceService()
    
    // MARK: - State
    
    var activeGeofences: [GeofenceRegion] = []
    var isMonitoring: Bool = false
    var lastGeofenceEvent: (event: GeofenceEvent, region: GeofenceRegion)?
    var smartStartEnabled: Bool = true
    
    // Track dwelling state
    private var dwellingTimers: [String: Date] = [:]
    private let dwellingThreshold: TimeInterval = 30 // 30 seconds to trigger dwelling
    
    // MARK: - Callbacks
    
    var onGeofenceEntered: ((GeofenceRegion) -> Void)?
    var onGeofenceExited: ((GeofenceRegion) -> Void)?
    var onDwellingDetected: ((GeofenceRegion) -> Void)?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Geofence Management
    
    /// Register a geofence for a task
    @discardableResult
    func registerGeofence(for task: HXTask, radius: Double = 50) -> GeofenceRegion? {
        guard let region = GeofenceRegion.forTask(task, radius: radius) else {
            print("[Geofence] Cannot register - task has no coordinates")
            return nil
        }
        
        // Remove existing geofence for this task if any
        removeGeofence(taskId: task.id)
        
        // Add new geofence
        activeGeofences.append(region)
        isMonitoring = true
        
        print("[Geofence] Registered geofence for task '\(task.title)' at (\(region.centerLatitude), \(region.centerLongitude)) - radius: \(radius)m")
        
        return region
    }
    
    /// Remove a geofence by task ID
    func removeGeofence(taskId: String) {
        activeGeofences.removeAll { $0.taskId == taskId }
        dwellingTimers.removeValue(forKey: taskId)
        
        if activeGeofences.isEmpty {
            isMonitoring = false
        }
        
        print("[Geofence] Removed geofence for task: \(taskId)")
    }
    
    /// Remove all geofences
    func removeAllGeofences() {
        activeGeofences.removeAll()
        dwellingTimers.removeAll()
        isMonitoring = false
        
        print("[Geofence] Removed all geofences")
    }
    
    // MARK: - Location Checking
    
    /// Check if current location is within any active geofence
    func checkProximity(currentLocation: GPSCoordinates) -> GeofenceRegion? {
        let userLocation = CLLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        
        for region in activeGeofences where region.isActive {
            let center = CLLocation(
                latitude: region.centerLatitude,
                longitude: region.centerLongitude
            )
            
            let distance = userLocation.distance(from: center)
            
            if distance <= region.radiusMeters {
                handleGeofenceEntered(region)
                return region
            }
        }
        
        // Check if user exited any geofence they were in
        checkForExits(currentLocation: currentLocation)
        
        return nil
    }
    
    /// Get distance to a geofence center
    func distanceToGeofence(from location: GPSCoordinates, region: GeofenceRegion) -> Double {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let center = CLLocation(latitude: region.centerLatitude, longitude: region.centerLongitude)
        return userLocation.distance(from: center)
    }
    
    /// Check if location is inside a specific geofence
    func isInsideGeofence(location: GPSCoordinates, region: GeofenceRegion) -> Bool {
        let distance = distanceToGeofence(from: location, region: region)
        return distance <= region.radiusMeters
    }
    
    // MARK: - Simulation Methods
    
    /// Simulate entering a geofence (for testing)
    func simulateEnterGeofence(region: GeofenceRegion) {
        handleGeofenceEntered(region)
    }
    
    /// Simulate exiting a geofence (for testing)
    func simulateExitGeofence(region: GeofenceRegion) {
        handleGeofenceExited(region)
    }
    
    /// Simulate dwelling detection (for testing)
    func simulateDwelling(region: GeofenceRegion) {
        handleDwellingDetected(region)
    }
    
    // MARK: - Private Handlers
    
    private func handleGeofenceEntered(_ region: GeofenceRegion) {
        // Start dwelling timer
        if dwellingTimers[region.taskId] == nil {
            dwellingTimers[region.taskId] = Date()
            
            lastGeofenceEvent = (.entered, region)
            onGeofenceEntered?(region)
            
            print("[Geofence] ENTERED - Task: \(region.taskId)")
            
            // Check for dwelling after threshold
            Task {
                try? await Task.sleep(nanoseconds: UInt64(dwellingThreshold * 1_000_000_000))
                
                // Verify still inside geofence
                if dwellingTimers[region.taskId] != nil {
                    handleDwellingDetected(region)
                }
            }
        }
    }
    
    private func handleGeofenceExited(_ region: GeofenceRegion) {
        dwellingTimers.removeValue(forKey: region.taskId)
        
        lastGeofenceEvent = (.exited, region)
        onGeofenceExited?(region)
        
        print("[Geofence] EXITED - Task: \(region.taskId)")
    }
    
    private func handleDwellingDetected(_ region: GeofenceRegion) {
        lastGeofenceEvent = (.dwelling, region)
        onDwellingDetected?(region)
        
        print("[Geofence] DWELLING DETECTED - Task: \(region.taskId) - Smart Start: \(smartStartEnabled ? "ENABLED" : "DISABLED")")
    }
    
    private func checkForExits(currentLocation: GPSCoordinates) {
        let userLocation = CLLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        
        // Check each geofence we're tracking for dwelling
        for (taskId, _) in dwellingTimers {
            guard let region = activeGeofences.first(where: { $0.taskId == taskId }) else {
                continue
            }
            
            let center = CLLocation(
                latitude: region.centerLatitude,
                longitude: region.centerLongitude
            )
            
            let distance = userLocation.distance(from: center)
            
            // If outside geofence, trigger exit
            if distance > region.radiusMeters {
                handleGeofenceExited(region)
            }
        }
    }
    
    // MARK: - Smart Start
    
    /// Check if Smart Start should trigger for a region
    func shouldTriggerSmartStart(for region: GeofenceRegion) -> Bool {
        guard smartStartEnabled else { return false }
        return lastGeofenceEvent?.event == .dwelling && lastGeofenceEvent?.region.taskId == region.taskId
    }
    
    /// Toggle Smart Start feature
    func setSmartStartEnabled(_ enabled: Bool) {
        smartStartEnabled = enabled
        print("[Geofence] Smart Start \(enabled ? "ENABLED" : "DISABLED")")
    }
}
