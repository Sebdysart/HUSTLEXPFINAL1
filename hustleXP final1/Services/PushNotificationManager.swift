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

    /// Called after every successful login. Flushes any pending FCM token to the backend.
    func flushPendingToken() async {
        guard let token = fcmToken ?? UserDefaults.standard.string(forKey: Self.pendingTokenKey)
        else { return }

        do {
            try await registerToken(token)
            UserDefaults.standard.removeObject(forKey: Self.pendingTokenKey)
            HXLogger.info("[PushNotificationManager] Pending FCM token flushed after login", category: "Push")
        } catch {
            HXLogger.error("[PushNotificationManager] Pending token flush failed: \(error.localizedDescription)", category: "Push")
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

        // Step 2: extract the data dict — FCM puts payload fields either under "data" key or flat
        let data: [String: Any]
        if let nested = userInfo["data"] as? [String: Any] {
            HXLogger.info("[Push][2] Found nested 'data' dict with keys: \(nested.keys.sorted())", category: "Push")
            data = nested
        } else if let flat = userInfo as? [String: Any] {
            HXLogger.info("[Push][2] No nested 'data' key — using flat userInfo, keys: \(flat.keys.sorted())", category: "Push")
            data = flat
        } else {
            HXLogger.error("[Push][2] Cannot extract data dict from userInfo — dropping notification", category: "Push")
            return
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
        // Convert [AnyHashable: Any] → [String: Any] for Sendable crossing into Task
        let sendableUserInfo = Dictionary(uniqueKeysWithValues:
            notification.request.content.userInfo.compactMap { key, value -> (String, Any)? in
                guard let stringKey = key as? String else { return nil }
                return (stringKey, value)
            }
        )
        Task { @MainActor in
            HXLogger.info("[Push][FG] Foreground notification — category='\(category)' keys=\(sendableUserInfo.keys.sorted())", category: "Push")
            // Run through handleNotification so dispatch_ping fires LivePingView in foreground
            self.handleNotificationFromSendable(sendableUserInfo)
        }

        // Show as banner, play sound, and update badge even in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Called when the user taps on a notification to open the app.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        HXLogger.info("[Push][TAP] Notification tapped — actionId='\(response.actionIdentifier)'", category: "Push")

        // Convert to sendable dictionary for async capture
        let sendableUserInfo = Dictionary(uniqueKeysWithValues: userInfo.compactMap { key, value -> (String, Any)? in
            guard let stringKey = key as? String else { return nil }
            return (stringKey, value)
        })
        Task { @MainActor in
            HXLogger.info("[Push][TAP] Handling tapped notification", category: "Push")
            self.handleNotificationFromSendable(sendableUserInfo)
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
            HXLogger.info("[PushNotificationManager] FCM token refreshed", category: "Push")
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
