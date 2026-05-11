//
//  DispatchServiceClient.swift
//  hustleXP final1
//
//  tRPC client wrapper for the Smart Dispatch / Ping System.
//  Maps to the backend dispatch.* router (Phase 1).
//

import Foundation

@MainActor
final class DispatchServiceClient {
    static let shared = DispatchServiceClient()
    private let trpc = TRPCClient.shared
    private init() {}

    // MARK: - Go Mode

    func setGoMode(enabled: Bool) async throws -> GoModeStatus {
        struct Input: Codable { let enabled: Bool }
        return try await trpc.call(
            router: "dispatch",
            procedure: "setGoMode",
            input: Input(enabled: enabled)
        )
    }

    func updateLocation(lat: Double, lng: Double) async throws -> GoModeStatus {
        struct Input: Codable { let lat: Double; let lng: Double }
        return try await trpc.call(
            router: "dispatch",
            procedure: "updateLocation",
            input: Input(lat: lat, lng: lng)
        )
    }

    func getStatus() async throws -> GoModeStatus {
        struct EmptyInput: Codable {}
        return try await trpc.call(
            router: "dispatch",
            procedure: "getStatus",
            type: .query,
            input: EmptyInput()
        )
    }

    // MARK: - Dispatch Prefs

    func getPrefs() async throws -> DispatchPrefs {
        struct EmptyInput: Codable {}
        return try await trpc.call(
            router: "dispatch",
            procedure: "getPrefs",
            type: .query,
            input: EmptyInput()
        )
    }

    func setPrefs(
        maxDistanceMiles: Int? = nil,
        minPayoutCents: Int? = nil,
        preferredCategories: [String]? = nil,
        autoAccept: Bool? = nil,
        pingSoundEnabled: Bool? = nil
    ) async throws {
        struct Input: Codable {
            let maxDistanceMiles: Int?
            let minPayoutCents: Int?
            let preferredCategories: [String]?
            let autoAccept: Bool?
            let pingSoundEnabled: Bool?
        }
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await trpc.call(
            router: "dispatch",
            procedure: "setPrefs",
            input: Input(
                maxDistanceMiles: maxDistanceMiles,
                minPayoutCents: minPayoutCents,
                preferredCategories: preferredCategories,
                autoAccept: autoAccept,
                pingSoundEnabled: pingSoundEnabled
            )
        )
    }

    // MARK: - Ping Events

    func recordPingEvent(
        taskId: String,
        eventType: String,
        waveNumber: Int? = nil
    ) async throws {
        struct Input: Codable {
            let taskId: String
            let eventType: String
            let waveNumber: Int?
        }
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await trpc.call(
            router: "dispatch",
            procedure: "recordPingEvent",
            input: Input(taskId: taskId, eventType: eventType, waveNumber: waveNumber)
        )
    }

    // MARK: - Soft Hold

    func acquireSoftHold(taskId: String, ttlSeconds: Int? = nil) async throws -> SoftHoldAcquireResult {
        struct Input: Codable { let taskId: String; let ttlSeconds: Int? }
        return try await trpc.call(
            router: "dispatch",
            procedure: "acquireSoftHold",
            input: Input(taskId: taskId, ttlSeconds: ttlSeconds)
        )
    }

    func releaseSoftHold(taskId: String) async throws {
        struct Input: Codable { let taskId: String }
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await trpc.call(
            router: "dispatch",
            procedure: "releaseSoftHold",
            input: Input(taskId: taskId)
        )
    }

    // MARK: - Claim Conversion

    func confirmClaim(taskId: String) async throws -> ConfirmClaimResult {
        struct Input: Codable { let taskId: String }
        return try await trpc.call(
            router: "dispatch",
            procedure: "confirmClaim",
            input: Input(taskId: taskId)
        )
    }

    // MARK: - Active Ping Poll (Simulator + FCM fallback)

    func getActivePing() async throws -> ActivePingResponse? {
        struct EmptyInput: Codable {}
        return try await trpc.call(
            router: "dispatch",
            procedure: "getActivePing",
            type: .query,
            input: EmptyInput()
        )
    }

    func getPingDebugState() async throws -> PingDebugState {
        struct EmptyInput: Codable {}
        return try await trpc.call(
            router: "dispatch",
            procedure: "getPingDebugState",
            type: .query,
            input: EmptyInput()
        )
    }

    // MARK: - Poster: Dispatch Status

    func getPosterDispatchStatus(taskId: String) async throws -> PosterDispatchStatus {
        struct Input: Codable { let taskId: String }
        return try await trpc.call(
            router: "dispatch",
            procedure: "getPosterDispatchStatus",
            type: .query,
            input: Input(taskId: taskId)
        )
    }
}
