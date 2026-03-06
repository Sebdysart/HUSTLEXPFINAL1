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

    private let trpc: TRPCClientProtocol

    @Published var status: LiveModeStatus?
    @Published var broadcasts: [LiveBroadcast] = []
    @Published var isLoading = false
    @Published var error: Error?

    /// Polling timer for live broadcasts
    private var pollTask: Task<Void, Never>?

    init(client: TRPCClientProtocol = TRPCClient.shared) {
        self.trpc = client
    }

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
            HXLogger.info("LiveModeService: Live mode ACTIVATED", category: "LiveMode")
        } else {
            stopPolling()
            self.broadcasts = []
            HXLogger.info("LiveModeService: Live mode DEACTIVATED", category: "LiveMode")
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
        HXLogger.info("LiveModeService: Found \(broadcasts.count) live broadcasts", category: "LiveMode")
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
                    HXLogger.error("LiveModeService: Poll failed - \(error.localizedDescription)", category: "LiveMode")
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

    // MARK: - Local Session Management

    /// Local session state — no mock dependency.
    /// Real data comes from tRPC toggle/listBroadcasts above.
    /// Quest-level tracking (accept, navigate, arrive) awaits backend endpoints.
    private var currentSession: LiveModeSession?

    /// Worker stats derived from real API status when available.
    /// Returns defaults that allow live mode access — real gating happens via trust tier + backend status.
    var workerStats: LiveModeStats {
        LiveModeStats(
            totalSessions: 0,
            totalTimeActive: 0,
            questsReceived: status?.totalTasks ?? 0,
            questsAccepted: status?.totalTasks ?? 0,
            questsCompleted: Int(Double(status?.totalTasks ?? 0) * (status?.completionRate ?? 0)),
            totalEarnings: 0,
            averageResponseTime: 0,
            averageArrivalTime: 0,
            ghostingStrikes: 0,
            reliabilityScore: 100
        )
    }

    /// Standard 2-mile radius
    var maxRadiusMeters: Double { 3218 }

    /// Creates a local session for tracking worker state during live mode.
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
            batteryLevel: 1.0,
            signalStrength: .excellent,
            availableFor: categories,
            maxDistance: maxDistance
        )
        currentSession = session
        HXLogger.info("LiveModeService: Session started for \(workerId)", category: "LiveMode")
        return session
    }

    /// Real quests come from the listBroadcasts tRPC endpoint — no local fabrication.
    func getVisibleQuests(at location: GPSCoordinates, isLiveMode: Bool) -> [QuestAlert] {
        []
    }

    /// Pure data transformation: wraps a real API-created task into a QuestAlert for UI display.
    func createQuestAlert(
        task: HXTask,
        posterLocation: GPSCoordinates,
        category: LiveTaskCategory
    ) -> QuestAlert {
        QuestAlert(
            id: UUID().uuidString,
            task: task,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(300),
            initialPayment: task.payment,
            currentPayment: task.payment,
            surgeMultiplier: 1.0,
            urgencyPremium: task.payment * 0.2,
            decisionWindowSeconds: 60,
            priceBoosts: 0,
            maxRadius: 3218,
            posterLocation: posterLocation,
            status: .broadcasting
        )
    }

    /// Clears the local session.
    func endLiveMode() {
        currentSession = nil
        HXLogger.info("LiveModeService: Local session ended", category: "LiveMode")
    }

    /// Quest acceptance requires a backend quest.accept endpoint — not yet available.
    func acceptQuest(_ questId: String, workerId: String, workerLocation: GPSCoordinates) -> OnTheWaySession? {
        HXLogger.info("LiveModeService: Quest accept awaits backend endpoint", category: "LiveMode")
        return nil
    }

    /// Logs navigation start. Real tracking handled by GeofenceService.
    func startNavigation(trackingId: String) {
        HXLogger.info("LiveModeService: Navigation started for \(trackingId)", category: "LiveMode")
    }

    /// Logs arrival. Real verification handled by GeofenceService.checkProximity().
    func markArrived(trackingId: String) {
        HXLogger.info("LiveModeService: Arrival marked for \(trackingId)", category: "LiveMode")
    }

    /// Updates the local session with fresh location data.
    func updateLocation(_ location: GPSCoordinates, heading: Double, speed: Double) {
        if var session = currentSession {
            session.location = location
            session.heading = heading
            session.speed = speed
            session.isMoving = speed > 0.5
            session.lastPingAt = Date()
            currentSession = session
        }
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

    private let trpc: TRPCClientProtocol

    @Published var availableTasks: [InstantTask] = []
    @Published var isLoading = false
    @Published var error: Error?

    init(client: TRPCClientProtocol = TRPCClient.shared) {
        self.trpc = client
    }

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
        HXLogger.info("InstantModeService: Found \(tasks.count) instant tasks", category: "LiveMode")
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

        HXLogger.info("InstantModeService: Accepted instant task - \(task.title)", category: "LiveMode")
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

        HXLogger.info("InstantModeService: Dismissed instant task \(taskId)", category: "LiveMode")
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
