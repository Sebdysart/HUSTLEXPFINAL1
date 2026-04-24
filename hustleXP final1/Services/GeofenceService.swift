//
//  GeofenceService.swift
//  hustleXP final1
//
//  Real tRPC service for geofence check-in/check-out and proximity
//  Maps to backend geofence.ts router
//
//  Also provides local CoreLocation-based geofence monitoring
//  for Smart Start auto clock-in and dwelling detection
//

import Foundation
import Combine
import CoreLocation

// MARK: - Geofence Types

struct ProximityCheckResult: Codable {
    let withinGeofence: Bool
    let distanceMeters: Double
    let eventLogged: Bool?
    let autoCheckinTriggered: Bool?

    /// Alias for readability
    var isWithinGeofence: Bool { withinGeofence }
}

struct GeofenceEventRecord: Codable, Identifiable {
    let id: String
    let taskId: String
    let userId: String
    let eventType: String
    let lat: Double
    let lng: Double
    let timestamp: Date
}

struct PresenceVerification: Codable {
    let taskId: String
    let userId: String
    let isPresent: Bool
    let lastSeenAt: Date?
    let totalPresenceMinutes: Int?
}

// MARK: - Geofence Service

/// Handles geofenced check-in/check-out and presence verification via tRPC,
/// plus local CoreLocation-based geofence monitoring for Smart Start
@MainActor
final class GeofenceService: ObservableObject {
    static let shared = GeofenceService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    // MARK: - Local Monitoring State

    @Published var activeGeofences: [GeofenceRegion] = []
    @Published var isMonitoring: Bool = false
    var lastGeofenceEvent: (event: GeofenceEvent, region: GeofenceRegion)?
    var smartStartEnabled: Bool = true

    // Dwelling state
    private var dwellingTimers: [String: Date] = [:]
    private let dwellingThreshold: TimeInterval = 30 // 30 seconds to trigger dwelling

    // MARK: - Callbacks

    var onGeofenceEntered: ((GeofenceRegion) -> Void)?
    var onGeofenceExited: ((GeofenceRegion) -> Void)?
    var onDwellingDetected: ((GeofenceRegion) -> Void)?

    private init() {}

    // MARK: - Remote API Methods

    /// Check proximity to a task location via backend
    func checkProximity(
        taskId: String,
        lat: Double,
        lng: Double
    ) async throws -> ProximityCheckResult {
        isLoading = true
        defer { isLoading = false }

        struct ProximityInput: Codable {
            let taskId: String
            let lat: Double
            let lng: Double
        }

        let result: ProximityCheckResult = try await trpc.call(
            router: "geofence",
            procedure: "checkProximity",
            input: ProximityInput(taskId: taskId, lat: lat, lng: lng)
        )

        HXLogger.info("GeofenceService: Proximity check - \(result.distanceMeters)m, inside: \(result.isWithinGeofence)", category: "General")
        return result
    }

    /// Get geofence events for a task
    func getTaskEvents(taskId: String) async throws -> [GeofenceEventRecord] {
        isLoading = true
        defer { isLoading = false }

        struct TaskInput: Codable {
            let taskId: String
        }

        let events: [GeofenceEventRecord] = try await trpc.call(
            router: "geofence",
            procedure: "getTaskEvents",
            type: .query,
            input: TaskInput(taskId: taskId)
        )

        HXLogger.info("GeofenceService: Fetched \(events.count) geofence events", category: "General")
        return events
    }

    /// Verify a user's presence during a task
    func verifyPresence(taskId: String) async throws -> PresenceVerification {
        isLoading = true
        defer { isLoading = false }

        struct PresenceInput: Codable {
            let taskId: String
        }

        let result: PresenceVerification = try await trpc.call(
            router: "geofence",
            procedure: "verifyPresence",
            type: .query,
            input: PresenceInput(taskId: taskId)
        )

        HXLogger.info("GeofenceService: Presence verified - present: \(result.isPresent)", category: "General")
        return result
    }

    // MARK: - Local Geofence Management

    /// Register a geofence for a task
    @discardableResult
    func registerGeofence(for task: HXTask, radius: Double = 50) -> GeofenceRegion? {
        guard let region = GeofenceRegion.forTask(task, radius: radius) else {
            HXLogger.debug("[Geofence] Cannot register - task has no coordinates", category: "General")
            return nil
        }

        // Remove existing geofence for this task if any
        removeGeofence(taskId: task.id)

        // Add new geofence
        activeGeofences.append(region)
        isMonitoring = true

        HXLogger.debug("[Geofence] Registered geofence for task '\(task.title)' at (\(region.centerLatitude), \(region.centerLongitude)) - radius: \(radius)m", category: "General")

        return region
    }

    /// Remove a geofence by task ID
    func removeGeofence(taskId: String) {
        activeGeofences.removeAll { $0.taskId == taskId }
        dwellingTimers.removeValue(forKey: taskId)

        if activeGeofences.isEmpty {
            isMonitoring = false
        }

        HXLogger.debug("[Geofence] Removed geofence for task: \(taskId)", category: "General")
    }

    /// Remove all geofences
    func removeAllGeofences() {
        activeGeofences.removeAll()
        dwellingTimers.removeAll()
        isMonitoring = false

        HXLogger.debug("[Geofence] Removed all geofences", category: "General")
    }

    // MARK: - Local Location Checking

    /// Check if current location is within any active geofence (local CLLocation check)
    func checkLocalProximity(currentLocation: GPSCoordinates) -> GeofenceRegion? {
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

    // MARK: - Smart Start

    /// Check if Smart Start should trigger for a region
    func shouldTriggerSmartStart(for region: GeofenceRegion) -> Bool {
        guard smartStartEnabled else { return false }
        return lastGeofenceEvent?.event == .dwelling && lastGeofenceEvent?.region.taskId == region.taskId
    }

    /// Toggle Smart Start feature
    func setSmartStartEnabled(_ enabled: Bool) {
        smartStartEnabled = enabled
        HXLogger.debug("[Geofence] Smart Start \(enabled ? "ENABLED" : "DISABLED")", category: "General")
    }

    // MARK: - Private Handlers

    private func handleGeofenceEntered(_ region: GeofenceRegion) {
        // Start dwelling timer
        if dwellingTimers[region.taskId] == nil {
            dwellingTimers[region.taskId] = Date()

            lastGeofenceEvent = (.entered, region)
            onGeofenceEntered?(region)

            HXLogger.debug("[Geofence] ENTERED - Task: \(region.taskId)", category: "General")

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

        HXLogger.debug("[Geofence] EXITED - Task: \(region.taskId)", category: "General")
    }

    private func handleDwellingDetected(_ region: GeofenceRegion) {
        lastGeofenceEvent = (.dwelling, region)
        onDwellingDetected?(region)

        HXLogger.debug("[Geofence] DWELLING DETECTED - Task: \(region.taskId) - Smart Start: \(smartStartEnabled ? "ENABLED" : "DISABLED")", category: "General")
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
}
