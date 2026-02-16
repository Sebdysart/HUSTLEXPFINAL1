//
//  LiveModeService.swift
//  hustleXP final1
//
//  Real tRPC service for Live Mode and Instant Mode
//  Maps to backend live.ts and instant.ts routers
//  Handles: live mode toggle, broadcasts, instant task acceptance
//

import Foundation
import Combine

// MARK: - Live Mode Types

/// Live mode states matching backend
enum LiveModeState: String, Codable {
    case active = "ACTIVE"
    case off = "OFF"
    case cooldown = "COOLDOWN"

    /// Safe decode — unknown values default to .off
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = LiveModeState(rawValue: raw) ?? .off
    }
}

/// Live mode status response
struct LiveModeStatus: Codable {
    let state: LiveModeState
    let sessionStartedAt: Date?
    let bannedUntil: Date?
    let totalTasks: Int
    let completionRate: Double

    var isActive: Bool {
        state == .active
    }

    var isOnCooldown: Bool {
        state == .cooldown
    }
}

/// Active live broadcast from backend
struct LiveBroadcast: Codable, Identifiable {
    let id: String
    let taskId: String
    let title: String
    let price: Double
    let location: String
    let latitude: Double?
    let longitude: Double?
    let category: String?
    let deadline: Date?
    let createdAt: Date
}

// MARK: - Instant Mode Types

/// Instant task available for one-tap acceptance
struct InstantTask: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let price: Double
    let location: String
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    let matchedAt: Date?
    let waitingSeconds: Int?
}

/// Instant mode metrics (for testing/debugging)
struct InstantModeMetrics: Codable {
    let medianTimeToAccept: Double?
    let p90TimeToAccept: Double?
    let minTimeToAccept: Double?
    let maxTimeToAccept: Double?
    let dismissRate: Double?
}

// MARK: - Live Mode Service

/// Manages Live Mode operations via tRPC
@MainActor
final class LiveModeService: ObservableObject {
    static let shared = LiveModeService()

    private let trpc = TRPCClient.shared

    @Published var status: LiveModeStatus?
    @Published var broadcasts: [LiveBroadcast] = []
    @Published var isLoading = false
    @Published var error: Error?

    /// Polling timer for live broadcasts
    private var pollTask: Task<Void, Never>?

    private init() {}

    // MARK: - Live Mode Toggle

    /// Toggles live mode on/off
    func toggle(enabled: Bool? = nil) async throws -> LiveModeStatus {
        isLoading = true
        defer { isLoading = false }

        struct ToggleInput: Codable {
            let enabled: Bool
        }

        // If enabled not specified, toggle opposite of current state
        let shouldEnable = enabled ?? !(status?.isActive ?? false)

        let status: LiveModeStatus = try await trpc.call(
            router: "live",
            procedure: "toggle",
            input: ToggleInput(enabled: shouldEnable)
        )

        self.status = status

        if status.isActive {
            startPolling()
            print("✅ LiveModeService: Live mode ACTIVATED")
        } else {
            stopPolling()
            self.broadcasts = []
            print("✅ LiveModeService: Live mode DEACTIVATED")
        }

        return status
    }

    /// Gets current live mode status
    func getStatus() async throws -> LiveModeStatus {
        struct EmptyInput: Codable {}

        let status: LiveModeStatus = try await trpc.call(
            router: "live",
            procedure: "getStatus",
            type: .query,
            input: EmptyInput()
        )

        self.status = status
        return status
    }

    // MARK: - Live Broadcasts

    /// Gets active live broadcasts within radius
    func listBroadcasts(
        latitude: Double,
        longitude: Double,
        radiusMiles: Double = 10
    ) async throws -> [LiveBroadcast] {
        struct ListInput: Codable {
            let latitude: Double
            let longitude: Double
            let radiusMiles: Double
        }

        let broadcasts: [LiveBroadcast] = try await trpc.call(
            router: "live",
            procedure: "listBroadcasts",
            type: .query,
            input: ListInput(latitude: latitude, longitude: longitude, radiusMiles: radiusMiles)
        )

        self.broadcasts = broadcasts
        print("✅ LiveModeService: Found \(broadcasts.count) live broadcasts")
        return broadcasts
    }

    // MARK: - Polling

    /// Starts polling for live broadcasts (every 5 seconds when active)
    func startPolling() {
        stopPolling()
        pollTask = Task {
            while !Task.isCancelled {
                // Poll for status changes
                do {
                    _ = try await getStatus()
                } catch {
                    print("⚠️ LiveModeService: Poll failed - \(error.localizedDescription)")
                }
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            }
        }
    }

    /// Stops polling
    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    deinit {
        pollTask?.cancel()
    }
}

// MARK: - Instant Mode Service

/// Manages Instant Mode task operations via tRPC
@MainActor
final class InstantModeService: ObservableObject {
    static let shared = InstantModeService()

    private let trpc = TRPCClient.shared

    @Published var availableTasks: [InstantTask] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - List Available

    /// Lists instant tasks available for one-tap acceptance
    func listAvailable() async throws -> [InstantTask] {
        struct EmptyInput: Codable {}

        let tasks: [InstantTask] = try await trpc.call(
            router: "instant",
            procedure: "listAvailable",
            type: .query,
            input: EmptyInput()
        )

        self.availableTasks = tasks
        print("✅ InstantModeService: Found \(tasks.count) instant tasks")
        return tasks
    }

    // MARK: - Accept Task

    /// One-tap acceptance of an instant task
    func accept(taskId: String) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct AcceptInput: Codable {
            let taskId: String
        }

        let task: HXTask = try await trpc.call(
            router: "instant",
            procedure: "accept",
            input: AcceptInput(taskId: taskId)
        )

        // Remove from available list
        availableTasks.removeAll { $0.id == taskId }

        print("✅ InstantModeService: Accepted instant task - \(task.title)")
        return task
    }

    // MARK: - Dismiss

    /// Dismisses an instant task notification
    func dismiss(taskId: String) async throws {
        struct DismissInput: Codable {
            let taskId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "instant",
            procedure: "dismiss",
            input: DismissInput(taskId: taskId)
        )

        // Remove from available list
        availableTasks.removeAll { $0.id == taskId }

        print("✅ InstantModeService: Dismissed instant task \(taskId)")
    }

    // MARK: - Metrics (Debug/Testing)

    /// Gets instant mode metrics
    func getMetrics() async throws -> InstantModeMetrics {
        struct EmptyInput: Codable {}

        let metrics: InstantModeMetrics = try await trpc.call(
            router: "instant",
            procedure: "metrics",
            type: .query,
            input: EmptyInput()
        )

        return metrics
    }
}
