//
//  PushNotificationManager.swift
//  hustleXP final1
//
//  Created by Sebastian Dysart on 2/11/26.
//

import Foundation
import UIKit
import Combine
import FirebaseMessaging
import UserNotifications

/// Manages push notification authorization, FCM token registration, and notification handling.
///
/// Integrates with Firebase Cloud Messaging for token management and the tRPC backend
/// for device token registration. Handles both foreground presentation and notification tap responses.
@MainActor
final class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()

    // MARK: - Published State

    /// Whether the user has granted notification authorization
    @Published var isAuthorized: Bool = false

    /// The current Firebase Cloud Messaging token for this device
    @Published var fcmToken: String?

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Diagnostics

    /// Call this after app launch to print the full push notification setup status to Xcode console.
    func logDiagnostics() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let authStatus: String
        switch settings.authorizationStatus {
        case .authorized:    authStatus = "authorized"
        case .denied:        authStatus = "DENIED — user blocked notifications"
        case .notDetermined: authStatus = "notDetermined — never asked yet"
        case .provisional:   authStatus = "provisional"
        case .ephemeral:     authStatus = "ephemeral"
        @unknown default:    authStatus = "unknown(\(settings.authorizationStatus.rawValue))"
        }

        let currentFCMToken = try? await Messaging.messaging().token()
        let dbToken = fcmToken

        HXLogger.info("========== PUSH NOTIFICATION DIAGNOSTICS ==========", category: "Push")
        HXLogger.info("[Diag] Authorization status : \(authStatus)", category: "Push")
        HXLogger.info("[Diag] Alert setting        : \(settings.alertSetting == .enabled ? "enabled" : "DISABLED")", category: "Push")
        HXLogger.info("[Diag] Sound setting        : \(settings.soundSetting == .enabled ? "enabled" : "DISABLED")", category: "Push")
        HXLogger.info("[Diag] FCM token (memory)   : \(dbToken ?? "NIL — not yet received")", category: "Push")
        HXLogger.info("[Diag] FCM token (Firebase) : \(currentFCMToken ?? "NIL — Firebase returned nil")", category: "Push")
        HXLogger.info("[Diag] Tokens match         : \(dbToken == currentFCMToken ? "YES" : "NO — mismatch!")", category: "Push")
        HXLogger.info("====================================================", category: "Push")
    }

    // MARK: - Authorization

    /// Requests notification authorization from the user.
    /// - Returns: `true` if authorization was granted, `false` otherwise.
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            isAuthorized = granted

            if granted {
                HXLogger.info("[PushNotificationManager] Notification authorization granted", category: "Push")
            } else {
                HXLogger.info("[PushNotificationManager] Notification authorization denied", category: "Push")
            }

            return granted
        } catch {
            HXLogger.error("[PushNotificationManager] Authorization request failed: \(error.localizedDescription)", category: "Push")
            isAuthorized = false
            return false
        }
    }

    /// Registers the app for remote notifications on the main thread.
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - FCM Token Management

    private static let pendingTokenKey = "hx.pendingFCMToken"

    /// Handles a new FCM token: tries to register immediately, falls back to UserDefaults on failure.
    func handleFCMToken(_ token: String) async {
        self.fcmToken = token
        HXLogger.info("[PushNotificationManager] FCM token received: \(token.prefix(20))...", category: "Push")

        do {
            try await registerToken(token)
            // Success: clear any previously stored pending token
            UserDefaults.standard.removeObject(forKey: Self.pendingTokenKey)
            HXLogger.info("[PushNotificationManager] Device token registered with backend", category: "Push")
        } catch {
            // Pre-auth or network failure: persist for retry after login
            UserDefaults.standard.set(token, forKey: Self.pendingTokenKey)
            HXLogger.info("[PushNotificationManager] Token stored as pending (will retry after login): \(error.localizedDescription)", category: "Push")
        }
    }

    /// Called after every successful login (and when Go Mode is enabled).
    /// Flushes the FCM token to the backend, asking Firebase directly as a last resort
    /// so we never end up with 0 active tokens in device_tokens.
    func flushPendingToken() async {
        // 1. Use in-memory token if available
        // 2. Fall back to UserDefaults pending token
        // 3. Last resort: ask Firebase for the current token directly
        var token = fcmToken ?? UserDefaults.standard.string(forKey: Self.pendingTokenKey)
        if token == nil {
            token = try? await Messaging.messaging().token()
            if let t = token {
                self.fcmToken = t
                HXLogger.info("[PushNotificationManager] FCM token retrieved from Firebase directly: \(t.prefix(20))...", category: "Push")
            }
        }
        guard let token else {
            HXLogger.error("[PushNotificationManager] No FCM token available — cannot register device", category: "Push")
            return
        }

        do {
            try await registerToken(token)
            UserDefaults.standard.removeObject(forKey: Self.pendingTokenKey)
            HXLogger.info("[PushNotificationManager] FCM token registered with backend", category: "Push")
        } catch {
            HXLogger.error("[PushNotificationManager] Token flush failed: \(error.localizedDescription)", category: "Push")
        }
    }

    /// Called on logout. Deregisters the current token from the backend and clears local state.
    func deregisterCurrentToken() async {
        let token = fcmToken ?? UserDefaults.standard.string(forKey: Self.pendingTokenKey)
        guard let token else { return }

        do {
            let _: EmptyResponse = try await TRPCClient.shared.call(
                router: "notification",
                procedure: "unregisterDeviceToken",
                type: .mutation,
                input: ["fcmToken": token]
            )
            HXLogger.info("[PushNotificationManager] Device token deregistered", category: "Push")
            UserDefaults.standard.removeObject(forKey: Self.pendingTokenKey)
            self.fcmToken = nil
        } catch {
            HXLogger.error("[PushNotificationManager] Token deregistration failed: \(error.localizedDescription)", category: "Push")
        }
    }

    // Private helper: raw backend registration call
    private func registerToken(_ token: String) async throws {
        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "notification",
            procedure: "registerDeviceToken",
            type: .mutation,
            input: [
                "fcmToken": token,
                "deviceType": "ios"
            ]
        )
    }

    // MARK: - Notification Handling

    /// Processes an incoming notification payload for deep linking or data updates.
    /// - Parameter userInfo: The notification payload dictionary.
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        // Step 1: log raw payload so we can see exactly what FCM delivered
        HXLogger.info("[Push][1] Raw userInfo keys: \(userInfo.keys.map { "\($0)" }.sorted())", category: "Push")
        HXLogger.info("[Push][1] Raw userInfo: \(userInfo)", category: "Push")

        // Step 2: extract the data dict — FCM puts payload fields either under "data" key or flat.
        // NOTE: [AnyHashable: Any] cannot be cast to [String: Any] in Swift even when all keys are
        // strings — the cast silently fails. We always extract key-by-key using AnyHashable lookup.
        let data: [String: Any]
        if let nested = userInfo["data"] as? [String: Any] {
            HXLogger.info("[Push][2] Found nested 'data' dict with keys: \(nested.keys.sorted())", category: "Push")
            data = nested
        } else {
            // Flatten AnyHashable-keyed dict into [String: Any] safely
            let flat = Dictionary(uniqueKeysWithValues: userInfo.compactMap { key, value -> (String, Any)? in
                if let stringKey = key as? String { return (stringKey, value) }
                if let stringKey = key.base as? String { return (stringKey, value) }
                return nil
            })
            guard !flat.isEmpty else {
                HXLogger.error("[Push][2] Cannot extract data dict from userInfo — dropping notification", category: "Push")
                return
            }
            HXLogger.info("[Push][2] Flat userInfo extracted, keys: \(flat.keys.sorted())", category: "Push")
            data = flat
        }

        // Step 3: check notification type
        guard let type = data["type"] as? String else {
            HXLogger.error("[Push][3] No 'type' field in data dict — dropping. data=\(data)", category: "Push")
            return
        }
        HXLogger.info("[Push][3] Notification type='\(type)'", category: "Push")

        switch type {
        case "task_assigned":
            if let taskId = data["taskId"] as? String {
                HXLogger.info("[Push] Deep link -> task: \(taskId)", category: "Push")
                NotificationCenter.default.post(
                    name: .pushNotificationDeepLink,
                    object: nil,
                    userInfo: ["type": type, "taskId": taskId]
                )
            }

        case "escrow_released":
            if let escrowId = data["escrowId"] as? String {
                HXLogger.info("[Push] Deep link -> escrow: \(escrowId)", category: "Push")
                NotificationCenter.default.post(
                    name: .pushNotificationDeepLink,
                    object: nil,
                    userInfo: ["type": type, "escrowId": escrowId]
                )
            }

        case "dispute_update":
            if let disputeId = data["disputeId"] as? String {
                HXLogger.info("[Push] Deep link -> dispute: \(disputeId)", category: "Push")
                NotificationCenter.default.post(
                    name: .pushNotificationDeepLink,
                    object: nil,
                    userInfo: ["type": type, "disputeId": disputeId]
                )
            }

        case "xp_earned":
            let amount = data["amount"] as? Int ?? Int(data["amount"] as? String ?? "") ?? 0
            HXLogger.info("[Push] XP earned: \(amount)", category: "Push")
            NotificationCenter.default.post(
                name: .pushNotificationDeepLink,
                object: nil,
                userInfo: ["type": type, "amount": amount]
            )

        case "dispatch_ping":
            // Step 4: parse dispatch ping fields
            // FCM data messages deliver ALL values as strings — must parse Int from String
            HXLogger.info("[Push][4] Parsing dispatch_ping fields. Raw data=\(data)", category: "Push")

            guard let taskId = data["taskId"] as? String, !taskId.isEmpty else {
                HXLogger.error("[Push][4] dispatch_ping missing taskId — dropping. data=\(data)", category: "Push")
                return
            }

            let taskTitle = data["taskTitle"] as? String ?? "New task available"

            // paymentCents comes as String from FCM data messages
            let paymentCents: Int
            if let intVal = data["paymentCents"] as? Int {
                paymentCents = intVal
            } else if let strVal = data["paymentCents"] as? String, let parsed = Int(strVal) {
                paymentCents = parsed
            } else {
                paymentCents = 0
                HXLogger.error("[Push][4] paymentCents missing or unparseable: \(data["paymentCents"] as Any)", category: "Push")
            }

            // waveNumber comes as String from FCM data messages
            let waveNumber: Int
            if let intVal = data["waveNumber"] as? Int {
                waveNumber = intVal
            } else if let strVal = data["waveNumber"] as? String, let parsed = Int(strVal) {
                waveNumber = parsed
            } else {
                waveNumber = 1
                HXLogger.error("[Push][4] waveNumber missing or unparseable: \(data["waveNumber"] as Any) — defaulting to 1", category: "Push")
            }

            // location is "" (empty string) when backend has no location — convert to nil
            let rawLocation = data["location"] as? String
            let location: String? = (rawLocation?.isEmpty == false) ? rawLocation : nil

            HXLogger.info(
                "[Push][4] dispatch_ping parsed — taskId=\(taskId) title='\(taskTitle)' paymentCents=\(paymentCents) wave=\(waveNumber) location=\(location ?? "<none>")",
                category: "Push"
            )

            // Step 5: post to NotificationCenter → GoModeManager picks it up
            HXLogger.info("[Push][5] Posting .dispatchPingReceived to NotificationCenter", category: "Push")
            NotificationCenter.default.post(
                name: .dispatchPingReceived,
                object: nil,
                userInfo: [
                    "taskId": taskId,
                    "taskTitle": taskTitle,
                    "paymentCents": paymentCents,
                    "location": location as Any,
                    "waveNumber": waveNumber,
                ]
            )

        default:
            HXLogger.info("[Push] Unhandled notification type: '\(type)'", category: "Push")
            NotificationCenter.default.post(
                name: .pushNotificationDeepLink,
                object: nil,
                userInfo: ["type": type]
            )
        }
    }
}

// MARK: - Notification Categories

extension PushNotificationManager {
    /// Registers the DISPATCH_PING notification category with Accept / Decline action buttons.
    /// Must be called once at app launch before the first notification is delivered.
    static func registerNotificationCategories() {
        let acceptAction = UNNotificationAction(
            identifier: "DISPATCH_PING_ACCEPT",
            title: "Accept",
            options: [.foreground]
        )
        let declineAction = UNNotificationAction(
            identifier: "DISPATCH_PING_DECLINE",
            title: "Decline",
            options: [.destructive]
        )
        let pingCategory = UNNotificationCategory(
            identifier: "DISPATCH_PING",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([pingCategory])
        HXLogger.info("[Push] Registered DISPATCH_PING notification category with Accept/Decline actions", category: "Push")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationManager: UNUserNotificationCenterDelegate {

    /// Called when a notification is delivered while the app is in the foreground.
    /// Displays the notification as a banner even when the app is active.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let category = notification.request.content.categoryIdentifier
        let title = notification.request.content.title
        let body = notification.request.content.body
        // Convert [AnyHashable: Any] → [String: Any] for Sendable crossing into Task
        let sendableUserInfo = Dictionary(uniqueKeysWithValues:
            notification.request.content.userInfo.compactMap { key, value -> (String, Any)? in
                guard let stringKey = key as? String else { return nil }
                return (stringKey, value)
            }
        )
        let notifType = sendableUserInfo["type"] as? String
        Task { @MainActor in
            HXLogger.info("[Push][FG] ✅ Foreground notification arrived — title='\(title)' body='\(body)' category='\(category)' keys=\(sendableUserInfo.keys.sorted())", category: "Push")
            self.handleNotificationFromSendable(sendableUserInfo)
        }

        if notifType == "dispatch_ping" {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.banner, .sound, .badge])
        }
    }

    /// Called when the user taps a notification or taps an action button on a notification banner.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let title = response.notification.request.content.title
        let actionId = response.actionIdentifier

        // Convert to sendable dictionary for async capture
        let sendableUserInfo = Dictionary(uniqueKeysWithValues: userInfo.compactMap { key, value -> (String, Any)? in
            guard let stringKey = key as? String else { return nil }
            return (stringKey, value)
        })
        Task { @MainActor in
            HXLogger.info("[Push][TAP] Notification response — title='\(title)' actionId='\(actionId)'", category: "Push")

            if actionId == "DISPATCH_PING_DECLINE" {
                // Decline without opening the app.
                // Do NOT call handleNotificationFromSendable — that schedules a Task { @MainActor }
                // to set activePing, which would re-appear LivePingView after declinePing clears it.
                let data = (sendableUserInfo["data"] as? [String: Any]) ?? sendableUserInfo
                guard let taskId = data["taskId"] as? String, !taskId.isEmpty else { return }
                let waveNumber = (data["waveNumber"] as? Int) ?? Int(data["waveNumber"] as? String ?? "") ?? 1
                HXLogger.info("[Push][ACTION] DISPATCH_PING_DECLINE — taskId=\(taskId)", category: "Push")
                GoModeManager.shared.declinePingById(taskId: taskId, waveNumber: waveNumber)
            } else {
                // Regular tap or DISPATCH_PING_ACCEPT (.foreground opens app → LivePingView handles it)
                HXLogger.info("[Push][TAP] Routing to handler — keys=\(sendableUserInfo.keys.sorted())", category: "Push")
                self.handleNotificationFromSendable(sendableUserInfo)
            }
        }

        completionHandler()
    }
    
    /// Handles notification from sendable dictionary (called from nonisolated context)
    private func handleNotificationFromSendable(_ userInfo: [String: Any]) {
        // Convert back to AnyHashable dictionary for existing handler
        let anyHashableUserInfo = Dictionary(uniqueKeysWithValues: userInfo.map { (AnyHashable($0.key), $0.value) })
        handleNotification(anyHashableUserInfo)
    }
}

// MARK: - MessagingDelegate

extension PushNotificationManager: MessagingDelegate {

    /// Called when Firebase Cloud Messaging generates or refreshes the device token.
    nonisolated func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else {
            Task { @MainActor in
                HXLogger.info("[PushNotificationManager] FCM token is nil", category: "Push")
            }
            return
        }

        Task { @MainActor in
            HXLogger.info("[Push][FCM] Token refreshed — FULL TOKEN: \(token)", category: "Push")
            await handleFCMToken(token)
        }
    }
}

// MARK: - Supporting Types

/// Empty response type for backend calls that return no meaningful data.
private struct EmptyResponse: Decodable {}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when a push notification requires deep linking into the app.
    static let pushNotificationDeepLink = Notification.Name("pushNotificationDeepLink")
}
