//
//  GeofenceService.swift
//  hustleXP final1
//
//  Real tRPC service for geofence check-in/check-out and proximity
//  Maps to backend geofence.ts router
//

import Foundation
import Combine

// MARK: - Geofence Types

struct ProximityCheckResult: Codable {
    let taskId: String
    let isWithinGeofence: Bool
    let distanceMeters: Double
    let checkInTime: Date?
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

/// Handles geofenced check-in/check-out and presence verification via tRPC
@MainActor
final class GeofenceService: ObservableObject {
    static let shared = GeofenceService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Check proximity to a task location
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

        print("✅ GeofenceService: Proximity check - \(result.distanceMeters)m, inside: \(result.isWithinGeofence)")
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

        print("✅ GeofenceService: Fetched \(events.count) geofence events")
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

        print("✅ GeofenceService: Presence verified - present: \(result.isPresent)")
        return result
    }
}
