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
    private var pingPollTimer: Timer?
    private var notificationObserver: NSObjectProtocol?
    private var pollCount: Int = 0

    /// How often to push location to the backend (seconds) while Go Mode is on
    private let locationUpdateInterval: TimeInterval = 30
    /// How often to poll for pending pings (seconds) — covers Simulator + FCM fallback
    private let pingPollInterval: TimeInterval = 3

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
                // Ensure FCM token is registered every time Go Mode is enabled —
                // guards against the case where token registration failed at login.
                Task { await PushNotificationManager.shared.flushPendingToken() }
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
        startPingPolling()
    }

    func stopLocationUpdates() {
        locationTimer?.invalidate()
        locationTimer = nil
        stopPingPolling()
    }

    // MARK: - Ping Polling (Simulator + FCM fallback)

    private func startPingPolling() {
        stopPingPolling()
        HXLogger.info("[GoMode][POLL] Ping polling started (\(Int(pingPollInterval))s interval)", category: "Dispatch")
        // Poll immediately, then on interval
        Task { await pollForActivePing() }
        pingPollTimer = Timer.scheduledTimer(withTimeInterval: pingPollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.pollForActivePing()
            }
        }
    }

    private func stopPingPolling() {
        pingPollTimer?.invalidate()
        pingPollTimer = nil
    }

    private func pollForActivePing() async {
        pollCount += 1
        let cycle = pollCount

        // Skip if a ping is already showing
        if activePing != nil {
            HXLogger.info("[GoMode][POLL #\(cycle)] Skipping — ping already active for task \(activePing!.taskId)", category: "Dispatch")
            return
        }
        guard isGoModeEnabled else {
            HXLogger.info("[GoMode][POLL #\(cycle)] Skipping — isGoModeEnabled=false", category: "Dispatch")
            return
        }

        // Log debug state on first poll and every 5th poll
        if cycle == 1 || cycle % 5 == 0 {
            await logDebugState(cycle: cycle)
        }

        HXLogger.info("[GoMode][POLL #\(cycle)] Calling getActivePing... (isOnline=\(isOnline) isGoModeEnabled=\(isGoModeEnabled))", category: "Dispatch")

        do {
            let response = try await service.getActivePing()

            if let response {
                // Parse expiry to check it hasn't already expired
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let expiresAt = iso.date(from: response.expiresAt)
                    ?? ISO8601DateFormatter().date(from: response.expiresAt)
                    ?? Date().addingTimeInterval(90)

                let secsLeft = Int(expiresAt.timeIntervalSinceNow)
                HXLogger.info(
                    "[GoMode][POLL #\(cycle)] ✅ Active ping found — taskId=\(response.taskId) wave=\(response.waveNumber) paymentCents=\(response.paymentCents) expiresIn=\(secsLeft)s",
                    category: "Dispatch"
                )

                guard secsLeft > 0 else {
                    HXLogger.info("[GoMode][POLL #\(cycle)] Ping found but already expired (\(secsLeft)s) — skipping", category: "Dispatch")
                    return
                }

                handleIncomingPing(
                    taskId: response.taskId,
                    taskTitle: response.taskTitle,
                    paymentCents: response.paymentCents,
                    location: response.location,
                    waveNumber: response.waveNumber
                )
            } else {
                HXLogger.info("[GoMode][POLL #\(cycle)] No active ping returned from backend", category: "Dispatch")
            }

        } catch {
            HXLogger.error("[GoMode][POLL #\(cycle)] getActivePing error: \(error.localizedDescription)", category: "Dispatch")
        }
    }

    private func logDebugState(cycle: Int) async {
        do {
            let state = try await service.getPingDebugState()

            // Hustler eligibility
            if let h = state.hustler {
                HXLogger.info(
                    "[GoMode][DEBUG #\(cycle)] Hustler — goMode=\(h.goMode) trustTier=\(h.trustTier) trustHold=\(h.trustHold) defaultMode=\(h.defaultMode) status=\(h.accountStatus) hasLocation=\(h.hasLocation) locationAge=\(h.locationAgeSeconds.map { "\($0)s" } ?? "never")",
                    category: "Dispatch"
                )
            } else {
                HXLogger.error("[GoMode][DEBUG #\(cycle)] Hustler row not found!", category: "Dispatch")
            }

            // Recent tasks
            if state.recentSmartDispatchTasks.isEmpty {
                HXLogger.info("[GoMode][DEBUG #\(cycle)] No smart_dispatch tasks in DB", category: "Dispatch")
            } else {
                for t in state.recentSmartDispatchTasks {
                    HXLogger.info(
                        "[GoMode][DEBUG #\(cycle)] Task — id=\(t.id.prefix(8))... '\(t.title)' state=\(t.state) dispatch=\(t.dispatchState) mode=\(t.fulfillmentMode) age=\(t.ageSeconds)s",
                        category: "Dispatch"
                    )
                }
            }

            // Outbox events
            if state.outboxEvents.isEmpty {
                HXLogger.info("[GoMode][DEBUG #\(cycle)] No dispatch outbox events in last 10 min", category: "Dispatch")
            } else {
                for e in state.outboxEvents {
                    HXLogger.info(
                        "[GoMode][DEBUG #\(cycle)] Outbox — \(e.eventType) task=\(e.taskId.prefix(8))... status=\(e.status) attempts=\(e.attempts) age=\(e.ageSeconds)s error=\(e.error ?? "none")",
                        category: "Dispatch"
                    )
                }
            }

            // My dispatch events
            if state.myDispatchEvents.isEmpty {
                HXLogger.info("[GoMode][DEBUG #\(cycle)] No dispatch_events for ME in last 10 min — wave was never fired for this hustler", category: "Dispatch")
            } else {
                for e in state.myDispatchEvents {
                    HXLogger.info(
                        "[GoMode][DEBUG #\(cycle)] DispatchEvent — \(e.eventType) task=\(e.taskId.prefix(8))... wave=\(e.waveNumber ?? 0) age=\(e.ageSeconds)s",
                        category: "Dispatch"
                    )
                }
            }

            // FCM token status — CRITICAL: 0 tokens means push notifications can never deliver
            if let fcm = state.fcmTokens {
                if fcm.activeCount == 0 {
                    HXLogger.error("[GoMode][DEBUG #\(cycle)] FCM — NO active tokens! Push delivery impossible. Re-login or reinstall may fix.", category: "Dispatch")
                } else {
                    let regAge = fcm.lastRegisteredAgeSeconds.map { "\($0)s ago" } ?? "unknown"
                    HXLogger.info("[GoMode][DEBUG #\(cycle)] FCM — tokens=\(fcm.activeCount) lastRegistered=\(regAge)", category: "Dispatch")
                }
            }
        } catch {
            HXLogger.error("[GoMode][DEBUG #\(cycle)] getPingDebugState error: \(error.localizedDescription)", category: "Dispatch")
        }
    }

    private func pushCurrentLocation() async {
        guard isGoModeEnabled else { return }

        let (coords, accuracy) = await LocationService.current.captureLocation()

        // accuracy == -1 means GPS timed out (common on Simulator).
        // Still push the coords — they may be the Simulator's set location or last known fix.
        // Only skip if coords are exactly (0, 0) which means no location at all.
        if accuracy < 0 {
            HXLogger.info("[GoMode][LOC] GPS accuracy unavailable (accuracy=\(accuracy)) — using coords anyway if non-zero", category: "Dispatch")
        }
        guard coords.latitude != 0 || coords.longitude != 0 else {
            HXLogger.error("[GoMode][LOC] Coords are (0,0) — skipping location push. Set a Simulator location via Features > Location in the Simulator menu.", category: "Dispatch")
            return
        }

        HXLogger.info("[GoMode][LOC] Pushing location (\(String(format: "%.4f", coords.latitude)), \(String(format: "%.4f", coords.longitude))) accuracy=\(String(format: "%.1f", accuracy))m", category: "Dispatch")

        do {
            let status = try await service.updateLocation(lat: coords.latitude, lng: coords.longitude)
            isOnline = status.isOnline
            locationUpdatedAt = status.locationUpdatedAt
            HXLogger.info("[GoMode][LOC] Location pushed — isOnline=\(status.isOnline)", category: "Dispatch")
        } catch {
            HXLogger.error("[GoMode][LOC] Location push failed: \(error.localizedDescription)", category: "Dispatch")
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
            HXLogger.info("[GoMode][INIT] Status loaded — goMode=\(isGoModeEnabled) isOnline=\(isOnline) locationAge=\(locationUpdatedAt.map { "\(Int(-$0.timeIntervalSinceNow))s ago" } ?? "never")", category: "Dispatch")
        } catch {
            HXLogger.error("[GoMode][INIT] Status load failed: \(error.localizedDescription)", category: "Dispatch")
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
        HXLogger.info("[GoMode][7] handleIncomingPing — taskId=\(taskId) wave=\(waveNumber) isGoModeEnabled=\(isGoModeEnabled)", category: "Dispatch")

        // Guard: ignore duplicate delivery for the same task (willPresent + didReceiveRemoteNotification
        // can both fire when the app is in the foreground and content-available:1 is set).
        if let existing = activePing, existing.taskId == taskId {
            HXLogger.info("[GoMode][7] Duplicate ping for taskId=\(taskId) — already active, ignoring", category: "Dispatch")
            return
        }

        let now = Date()
        let ping = IncomingPing(
            id: taskId,
            taskId: taskId,
            taskTitle: taskTitle,
            paymentCents: paymentCents,
            location: location,
            waveNumber: waveNumber,
            receivedAt: now,
            expiresAt: now.addingTimeInterval(90)
        )

        HXLogger.info("[GoMode][7] Setting activePing — LivePingView should appear now", category: "Dispatch")
        activePing = ping

        // Record ping_viewed immediately
        Task {
            try? await service.recordPingEvent(taskId: taskId, eventType: "ping_viewed", waveNumber: waveNumber)
        }

        // Auto-dismiss + record expired after countdown
        schedulePingExpiry(for: ping)
        HXLogger.info("[GoMode][7] Ping scheduled for expiry in 90s — activePing=\(activePing?.taskId ?? "nil")", category: "Dispatch")
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
            // Pause polling for 60s so the hustler isn't interrupted with a new ping
            // while navigating to the task they just accepted.
            stopPingPolling()
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(60))
                guard let self, self.isGoModeEnabled else { return }
                self.startPingPolling()
            }
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
        HXLogger.info("[GoMode][SUB] Subscribing to .dispatchPingReceived notifications", category: "Dispatch")
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .dispatchPingReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            HXLogger.info("[GoMode][6] .dispatchPingReceived fired — userInfo=\(notification.userInfo as Any)", category: "Dispatch")

            guard let self else {
                HXLogger.error("[GoMode][6] self is nil — GoModeManager deallocated", category: "Dispatch")
                return
            }
            guard let userInfo = notification.userInfo else {
                HXLogger.error("[GoMode][6] userInfo is nil — dropping ping", category: "Dispatch")
                return
            }
            guard let taskId = userInfo["taskId"] as? String else {
                HXLogger.error("[GoMode][6] taskId missing from userInfo — dropping ping. userInfo=\(userInfo)", category: "Dispatch")
                return
            }

            let taskTitle = userInfo["taskTitle"] as? String ?? "New task available"
            let paymentCents = userInfo["paymentCents"] as? Int ?? 0
            let location = userInfo["location"] as? String
            let waveNumber = userInfo["waveNumber"] as? Int ?? 1

            HXLogger.info(
                "[GoMode][6] Ping fields — taskId=\(taskId) title='\(taskTitle)' paymentCents=\(paymentCents) wave=\(waveNumber) location=\(location ?? "<none>")",
                category: "Dispatch"
            )

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
        HXLogger.info("[GoMode][SUB] Observer registered for .dispatchPingReceived", category: "Dispatch")
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
