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

    /// Handles a new FCM token by storing it locally and sending it to the backend.
    /// - Parameter token: The Firebase Cloud Messaging device token.
    func handleFCMToken(_ token: String) async {
        self.fcmToken = token
        HXLogger.info("[PushNotificationManager] FCM token received: \(token.prefix(20))...", category: "Push")

        // Send token to backend for server-side push targeting
        do {
            let _: EmptyResponse = try await TRPCClient.shared.call(
                router: "notification",
                procedure: "registerDeviceToken",
                type: .mutation,
                input: [
                    "fcmToken": token,
                    "deviceType": "ios"
                ]
            )
            HXLogger.info("[PushNotificationManager] Device token registered with backend", category: "Push")
        } catch {
            HXLogger.error("[PushNotificationManager] Failed to register device token: \(error.localizedDescription)", category: "Push")
        }
    }

    // MARK: - Notification Handling

    /// Processes an incoming notification payload for deep linking or data updates.
    /// - Parameter userInfo: The notification payload dictionary.
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        HXLogger.info("[PushNotificationManager] Handling notification: \(userInfo)", category: "Push")

        // Parse the data payload for deep linking
        guard let data = userInfo["data"] as? [String: Any] ?? userInfo as? [String: Any] else {
            return
        }

        if let type = data["type"] as? String {
            switch type {
            case "task_assigned":
                if let taskId = data["taskId"] as? String {
                    HXLogger.info("[PushNotificationManager] Deep link -> task: \(taskId)", category: "Push")
                    // Post notification for navigation handling
                    NotificationCenter.default.post(
                        name: .pushNotificationDeepLink,
                        object: nil,
                        userInfo: ["type": type, "taskId": taskId]
                    )
                }

            case "escrow_released":
                if let escrowId = data["escrowId"] as? String {
                    HXLogger.info("[PushNotificationManager] Deep link -> escrow: \(escrowId)", category: "Push")
                    NotificationCenter.default.post(
                        name: .pushNotificationDeepLink,
                        object: nil,
                        userInfo: ["type": type, "escrowId": escrowId]
                    )
                }

            case "dispute_update":
                if let disputeId = data["disputeId"] as? String {
                    HXLogger.info("[PushNotificationManager] Deep link -> dispute: \(disputeId)", category: "Push")
                    NotificationCenter.default.post(
                        name: .pushNotificationDeepLink,
                        object: nil,
                        userInfo: ["type": type, "disputeId": disputeId]
                    )
                }

            case "xp_earned":
                if let amount = data["amount"] as? Int {
                    HXLogger.info("[PushNotificationManager] XP earned: \(amount)", category: "Push")
                    NotificationCenter.default.post(
                        name: .pushNotificationDeepLink,
                        object: nil,
                        userInfo: ["type": type, "amount": amount]
                    )
                }

            default:
                HXLogger.info("[PushNotificationManager] Unhandled notification type: \(type)", category: "Push")
                NotificationCenter.default.post(
                    name: .pushNotificationDeepLink,
                    object: nil,
                    userInfo: ["type": type]
                )
            }
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
        let userInfo = notification.request.content.userInfo
        HXLogger.info("[PushNotificationManager] Foreground notification received: \(userInfo)", category: "Push")

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
        HXLogger.info("[PushNotificationManager] Notification tapped: \(userInfo)", category: "Push")

        // Convert to sendable dictionary for async capture
        let sendableUserInfo = Dictionary(uniqueKeysWithValues: userInfo.compactMap { key, value -> (String, Any)? in
            guard let stringKey = key as? String else { return nil }
            return (stringKey, value)
        })
        Task { @MainActor in
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
            HXLogger.info("[PushNotificationManager] FCM token is nil", category: "Push")
            return
        }

        HXLogger.info("[PushNotificationManager] FCM token refreshed", category: "Push")

        Task { @MainActor in
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
