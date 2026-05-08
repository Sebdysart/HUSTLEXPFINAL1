//
//  GoModeManager.swift
//  hustleXP final1
//
//  Central manager for the Smart Dispatch / Ping System (iOS side).
//
//  Responsibilities:
//    - Persist and sync Go Mode on/off state with backend
//    - Upload GPS position every LOCATION_UPDATE_INTERVAL seconds while online
//    - Request "always" location permission when Go Mode first enabled
//    - Receive incoming dispatch pings and expose them for LivePingView
//    - Manage ping countdown and auto-dismiss on expiry
//

import Foundation
import CoreLocation
import Combine

@MainActor
@Observable
final class GoModeManager {
    static let shared = GoModeManager()

    // MARK: - State

    var isGoModeEnabled: Bool = false
    var isOnline: Bool = false
    var locationUpdatedAt: Date? = nil
    var activePing: IncomingPing? = nil
    var dispatchPrefs: DispatchPrefs = .defaults
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Private

    private let service = DispatchServiceClient.shared
    private var locationTimer: Timer?
    private var pingExpiryTimer: Timer?
    private var notificationObserver: NSObjectProtocol?

    /// How often to push location to the backend (seconds) while Go Mode is on
    private let locationUpdateInterval: TimeInterval = 30

    private init() {
        subscribeToDispatchPingNotifications()
    }

    // MARK: - Go Mode Toggle

    func setGoMode(enabled: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if enabled {
            // Ensure we have location permission before enabling
            requestAlwaysLocationIfNeeded()
        }

        do {
            let status = try await service.setGoMode(enabled: enabled)
            isGoModeEnabled = status.goMode
            isOnline = status.isOnline
            locationUpdatedAt = status.locationUpdatedAt

            if enabled {
                startLocationUpdates()
            } else {
                stopLocationUpdates()
            }

            HXLogger.info("[GoModeManager] Go Mode \(enabled ? "enabled" : "disabled"), online=\(isOnline)", category: "Dispatch")
        } catch {
            errorMessage = "Couldn't update Go Mode. Check your connection."
            HXLogger.error("[GoModeManager] setGoMode failed: \(error.localizedDescription)", category: "Dispatch")
        }
    }

    // MARK: - Location Updates

    func startLocationUpdates() {
        stopLocationUpdates()
        // Send location immediately, then on interval
        Task { await pushCurrentLocation() }
        locationTimer = Timer.scheduledTimer(
            withTimeInterval: locationUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.pushCurrentLocation()
            }
        }
        HXLogger.debug("[GoModeManager] Location update timer started (\(Int(locationUpdateInterval))s interval)", category: "Dispatch")
    }

    func stopLocationUpdates() {
        locationTimer?.invalidate()
        locationTimer = nil
    }

    private func pushCurrentLocation() async {
        guard isGoModeEnabled else { return }

        let (coords, accuracy) = await LocationService.current.captureLocation()
        guard accuracy >= 0 else { return }  // accuracy == -1 means cancelled/unavailable

        do {
            let status = try await service.updateLocation(lat: coords.latitude, lng: coords.longitude)
            isOnline = status.isOnline
            locationUpdatedAt = status.locationUpdatedAt
            HXLogger.debug("[GoModeManager] Location pushed: (\(String(format: "%.4f", coords.latitude)), \(String(format: "%.4f", coords.longitude)))", category: "Dispatch")
        } catch {
            HXLogger.error("[GoModeManager] Location push failed: \(error.localizedDescription)", category: "Dispatch")
        }
    }

    // MARK: - Load Status on App Launch

    func loadStatus() async {
        do {
            let status = try await service.getStatus()
            isGoModeEnabled = status.goMode
            isOnline = status.isOnline
            locationUpdatedAt = status.locationUpdatedAt

            if isGoModeEnabled {
                startLocationUpdates()
            }

            dispatchPrefs = try await service.getPrefs()
            HXLogger.info("[GoModeManager] Status loaded — goMode=\(isGoModeEnabled), online=\(isOnline)", category: "Dispatch")
        } catch {
            HXLogger.debug("[GoModeManager] Status load skipped: \(error.localizedDescription)", category: "Dispatch")
        }
    }

    // MARK: - Incoming Pings

    func handleIncomingPing(
        taskId: String,
        taskTitle: String,
        paymentCents: Int,
        location: String?,
        waveNumber: Int
    ) {
        let now = Date()
        let ping = IncomingPing(
            id: taskId,
            taskId: taskId,
            taskTitle: taskTitle,
            paymentCents: paymentCents,
            location: location,
            waveNumber: waveNumber,
            receivedAt: now,
            expiresAt: now.addingTimeInterval(30)
        )
        activePing = ping

        // Record ping_viewed immediately
        Task {
            try? await service.recordPingEvent(taskId: taskId, eventType: "ping_viewed", waveNumber: waveNumber)
        }

        // Auto-dismiss + record expired after countdown
        schedulePingExpiry(for: ping)
        HXLogger.info("[GoModeManager] Incoming ping for task \(taskId) wave \(waveNumber)", category: "Dispatch")
    }

    /// Accepts an incoming ping.
    /// Returns the `ConfirmClaimResult` on success (contains ETA), or nil if the task
    /// was already taken (race condition) or the soft hold expired.
    @discardableResult
    func acceptPing(_ ping: IncomingPing) async -> ConfirmClaimResult? {
        pingExpiryTimer?.invalidate()
        pingExpiryTimer = nil

        do {
            // Step 1: acquire the 30-second soft hold
            let holdResult = try await service.acquireSoftHold(taskId: ping.taskId)
            guard holdResult.acquired else {
                // Another hustler beat us — clear the ping silently
                activePing = nil
                HXLogger.info("[GoModeManager] Soft hold not acquired — task taken", category: "Dispatch")
                return nil
            }

            // Step 2: convert soft hold → real assignment + get ETA
            let claimResult = try await service.confirmClaim(taskId: ping.taskId)
            try? await service.recordPingEvent(
                taskId: ping.taskId,
                eventType: "ping_accepted",
                waveNumber: ping.waveNumber
            )
            activePing = nil
            HXLogger.info("[GoModeManager] Task \(ping.taskId) claimed — ETA \(claimResult.estimatedArrivalMinutes.map { "\($0) min" } ?? "unknown")", category: "Dispatch")
            return claimResult

        } catch {
            // CONFLICT means the task was claimed by someone else between soft hold and confirm
            HXLogger.error("[GoModeManager] acceptPing failed: \(error.localizedDescription)", category: "Dispatch")
            activePing = nil
            return nil
        }
    }

    func declinePing(_ ping: IncomingPing) {
        pingExpiryTimer?.invalidate()
        pingExpiryTimer = nil
        activePing = nil
        Task {
            try? await service.recordPingEvent(taskId: ping.taskId, eventType: "ping_declined", waveNumber: ping.waveNumber)
        }
        HXLogger.info("[GoModeManager] Ping declined for task \(ping.taskId)", category: "Dispatch")
    }

    // MARK: - Private Helpers

    private func schedulePingExpiry(for ping: IncomingPing) {
        pingExpiryTimer?.invalidate()
        let remaining = ping.expiresAt.timeIntervalSinceNow
        guard remaining > 0 else {
            handlePingExpired(ping)
            return
        }
        pingExpiryTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handlePingExpired(ping)
            }
        }
    }

    private func handlePingExpired(_ ping: IncomingPing) {
        guard activePing?.id == ping.id else { return }
        activePing = nil
        Task {
            try? await service.recordPingEvent(taskId: ping.taskId, eventType: "ping_expired", waveNumber: ping.waveNumber)
        }
        HXLogger.info("[GoModeManager] Ping expired for task \(ping.taskId)", category: "Dispatch")
    }

    private func subscribeToDispatchPingNotifications() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .dispatchPingReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let userInfo = notification.userInfo,
                  let taskId = userInfo["taskId"] as? String else { return }

            let taskTitle = userInfo["taskTitle"] as? String ?? "New task available"
            let paymentCents = userInfo["paymentCents"] as? Int ?? 0
            let location = userInfo["location"] as? String
            let waveNumber = userInfo["waveNumber"] as? Int ?? 1

            Task { @MainActor [weak self] in
                self?.handleIncomingPing(
                    taskId: taskId,
                    taskTitle: taskTitle,
                    paymentCents: paymentCents,
                    location: location,
                    waveNumber: waveNumber
                )
            }
        }
    }

    private func requestAlwaysLocationIfNeeded() {
        let locationManager = CLLocationManager()
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let dispatchPingReceived = Notification.Name("hx.dispatchPingReceived")
}
