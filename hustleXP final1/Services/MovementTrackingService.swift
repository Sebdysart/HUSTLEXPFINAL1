//
//  MovementTrackingService.swift
//  hustleXP final1
//
//  Local movement tracking during task execution
//  Replaces the removed tracking API contract with client-side session state
//

import Foundation
import CoreLocation

// MARK: - Types

struct MovementSession: Codable, Identifiable {
    let id: String
    let taskId: String
    let userId: String
    let startedAt: Date
    var endedAt: Date?
    var gpsTrail: [GPSPoint]
    var totalDistance: Double // meters
    var averageSpeed: Double // m/s
    var status: String // active, completed, cancelled
}

struct GPSPoint: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let timestamp: Date
}

struct MovementStats: Codable {
    let totalDistance: Double
    let duration: Double // seconds
    let averageSpeed: Double
    let topSpeed: Double
    let estimatedArrival: Date?
}

// MARK: - Movement Tracking Service

@MainActor
@Observable
final class MovementTrackingService {
    static let shared = MovementTrackingService()

    // MARK: - State

    private(set) var activeSession: MovementSession?
    private(set) var isTracking = false
    private(set) var error: Error?

    private init() {}

    // MARK: - Session Management

    /// Start tracking movement for a task
    func startTracking(taskId: String, initialLocation: GPSCoordinates) async throws -> MovementSession {
        isTracking = true
        error = nil
        let startingPoint = GPSPoint(
            latitude: initialLocation.latitude,
            longitude: initialLocation.longitude,
            accuracy: initialLocation.accuracyMeters,
            timestamp: initialLocation.timestamp
        )

        let session = MovementSession(
            id: "local-track-\(UUID().uuidString)",
            taskId: taskId,
            userId: "local-tracker",
            startedAt: initialLocation.timestamp,
            endedAt: nil,
            gpsTrail: [startingPoint],
            totalDistance: 0,
            averageSpeed: 0,
            status: "ACTIVE"
        )

        activeSession = session
        HXLogger.info("Movement tracking started locally for task: \(taskId)", category: "Tracking")
        return session
    }

    /// Update location during tracking
    func updateLocation(_ location: GPSCoordinates) {
        guard isTracking, let session = activeSession else { return }

        let point = GPSPoint(
            latitude: location.latitude,
            longitude: location.longitude,
            accuracy: location.accuracyMeters,
            timestamp: location.timestamp
        )

        var updatedSession = session
        updatedSession.gpsTrail.append(point)
        updatedSession.totalDistance = calculateDistance(for: updatedSession.gpsTrail)
        updatedSession.averageSpeed = calculateAverageSpeed(
            distance: updatedSession.totalDistance,
            startedAt: updatedSession.startedAt,
            endedAt: point.timestamp
        )
        activeSession = updatedSession
    }

    /// Stop tracking
    func stopTracking() async throws -> MovementSession? {
        guard let session = activeSession else { return nil }

        isTracking = false
        var finalSession = session
        finalSession.endedAt = Date()
        finalSession.totalDistance = calculateDistance(for: finalSession.gpsTrail)
        finalSession.averageSpeed = calculateAverageSpeed(
            distance: finalSession.totalDistance,
            startedAt: finalSession.startedAt,
            endedAt: finalSession.endedAt ?? Date()
        )
        finalSession.status = "COMPLETED"
        activeSession = nil
        HXLogger.info("Movement tracking stopped locally. Distance: \(String(format: "%.0f", finalSession.totalDistance))m", category: "Tracking")
        return finalSession
    }

    /// Get session statistics
    func getStats(sessionId: String) async throws -> MovementStats {
        guard let session = activeSession, session.id == sessionId else {
            return MovementStats(
                totalDistance: 0,
                duration: 0,
                averageSpeed: 0,
                topSpeed: 0,
                estimatedArrival: nil
            )
        }

        let duration = max(0, Date().timeIntervalSince(session.startedAt))
        return MovementStats(
            totalDistance: session.totalDistance,
            duration: duration,
            averageSpeed: session.averageSpeed,
            topSpeed: session.averageSpeed,
            estimatedArrival: nil
        )
    }

    private func calculateDistance(for trail: [GPSPoint]) -> Double {
        guard trail.count > 1 else { return 0 }

        var distance: Double = 0
        for index in 1..<trail.count {
            let previous = CLLocation(
                latitude: trail[index - 1].latitude,
                longitude: trail[index - 1].longitude
            )
            let current = CLLocation(
                latitude: trail[index].latitude,
                longitude: trail[index].longitude
            )
            distance += current.distance(from: previous)
        }
        return distance
    }

    private func calculateAverageSpeed(distance: Double, startedAt: Date, endedAt: Date) -> Double {
        let duration = max(endedAt.timeIntervalSince(startedAt), 1)
        return distance / duration
    }
}
