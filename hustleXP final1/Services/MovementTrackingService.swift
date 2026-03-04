//
//  MovementTrackingService.swift
//  hustleXP final1
//
//  Real tRPC service for movement tracking during task execution
//  Maps to backend tracking.ts router
//  Replaces MockMovementTrackingService
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

    private let trpc = TRPCClient.shared

    // MARK: - State

    private(set) var activeSession: MovementSession?
    private(set) var isTracking = false
    private(set) var error: Error?

    // Local GPS buffer for periodic backend sync
    private var gpsBuffer: [GPSPoint] = []
    private var syncTimer: Timer?

    private init() {}

    // MARK: - Session Management

    /// Start tracking movement for a task
    func startTracking(taskId: String, initialLocation: GPSCoordinates) async throws -> MovementSession {
        isTracking = true
        error = nil

        struct StartInput: Codable {
            let taskId: String
            let initialLocation: GPSPointInput
        }

        struct GPSPointInput: Codable {
            let latitude: Double
            let longitude: Double
            let accuracy: Double
            let timestamp: Date
        }

        let input = StartInput(
            taskId: taskId,
            initialLocation: GPSPointInput(
                latitude: initialLocation.latitude,
                longitude: initialLocation.longitude,
                accuracy: initialLocation.accuracyMeters,
                timestamp: initialLocation.timestamp
            )
        )

        do {
            let session: MovementSession = try await trpc.call(
                router: "tracking",
                procedure: "startSession",
                input: input
            )

            self.activeSession = session
            gpsBuffer = []

            // Start periodic sync
            startPeriodicSync(sessionId: session.id)

            HXLogger.info("Movement tracking started for task: \(taskId)", category: "Tracking")
            return session
        } catch {
            self.error = error
            isTracking = false
            HXLogger.error("Failed to start movement tracking: \(error.localizedDescription)", category: "Tracking")
            throw error
        }
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

        gpsBuffer.append(point)

        // Update local session
        var updatedSession = session
        updatedSession.gpsTrail.append(point)
        activeSession = updatedSession
    }

    /// Stop tracking
    func stopTracking() async throws -> MovementSession? {
        guard let session = activeSession else { return nil }

        isTracking = false
        stopPeriodicSync()

        // Flush remaining GPS points
        if !gpsBuffer.isEmpty {
            await syncGPSPoints()
        }

        struct StopInput: Codable {
            let sessionId: String
        }

        let input = StopInput(sessionId: session.id)

        do {
            let finalSession: MovementSession = try await trpc.call(
                router: "tracking",
                procedure: "stopSession",
                input: input
            )

            activeSession = nil
            HXLogger.info("Movement tracking stopped. Distance: \(String(format: "%.0f", finalSession.totalDistance))m", category: "Tracking")
            return finalSession
        } catch {
            self.error = error
            HXLogger.error("Failed to stop movement tracking: \(error.localizedDescription)", category: "Tracking")
            throw error
        }
    }

    /// Get session statistics
    func getStats(sessionId: String) async throws -> MovementStats {
        struct StatsInput: Codable {
            let sessionId: String
        }

        let input = StatsInput(sessionId: sessionId)

        let stats: MovementStats = try await trpc.call(
            router: "tracking",
            procedure: "getStats",
            type: .query,
            input: input
        )

        return stats
    }

    // MARK: - Private - Periodic Sync

    private func startPeriodicSync(sessionId: String) {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncGPSPoints()
            }
        }
    }

    private func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }

    private func syncGPSPoints() async {
        guard !gpsBuffer.isEmpty, let session = activeSession else { return }

        let pointsToSync = gpsBuffer
        gpsBuffer = []

        // Send each point to backend
        for point in pointsToSync {
            do {
                struct UpdateInput: Codable {
                    let sessionId: String
                    let location: GPSPointInput
                }

                struct UpdateLocationResponse: Codable {
                    let success: Bool?
                }

                struct GPSPointInput: Codable {
                    let latitude: Double
                    let longitude: Double
                    let accuracy: Double
                    let timestamp: Date
                }

                let input = UpdateInput(
                    sessionId: session.id,
                    location: GPSPointInput(
                        latitude: point.latitude,
                        longitude: point.longitude,
                        accuracy: point.accuracy,
                        timestamp: point.timestamp
                    )
                )

                let _: UpdateLocationResponse = try await trpc.call(
                    router: "tracking",
                    procedure: "updateLocation",
                    input: input
                )
            } catch {
                HXLogger.error("Failed to sync GPS point: \(error.localizedDescription)", category: "Tracking")
                // Re-add to buffer for retry
                gpsBuffer.append(point)
            }
        }
    }
}
