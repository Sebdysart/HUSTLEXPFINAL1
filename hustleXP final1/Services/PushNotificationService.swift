//
//  PushNotificationService.swift
//  hustleXP final1
//
//  Manages push notification registration, handling, and FCM token sync
//

import SwiftUI
import UserNotifications
import Combine

class PushNotificationService: NSObject, ObservableObject {
    static let shared = PushNotificationService()

    @Published var fcmToken: String?
    @Published var permissionGranted = false
    @Published var unreadCount: Int = 0

    private let trpc = TRPCClient.shared

    // MARK: - Codable models for tRPC calls

    private struct RegisterDeviceInput: Codable {
        let token: String
        let platform: String
        let deviceId: String
    }

    private struct EmptyResponse: Codable {}

    override init() {
        super.init()
    }

    // MARK: - Request Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.permissionGranted = granted
            }
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            HXLogger.error("[PushNotificationService] Permission request failed: \(error)", category: "Push")
            return false
        }
    }

    // MARK: - Sync FCM Token with Backend
    func syncTokenWithBackend() {
        guard let token = fcmToken else { return }

        Task {
            do {
                let input = RegisterDeviceInput(
                    token: token,
                    platform: "ios",
                    deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                )
                let _: EmptyResponse = try await trpc.call(
                    router: "notification",
                    procedure: "registerDeviceToken",
                    input: input
                )
                HXLogger.info("[PushNotificationService] FCM token synced with backend", category: "Push")
            } catch {
                HXLogger.error("[PushNotificationService] Token sync failed: \(error)", category: "Push")
            }
        }
    }

    // MARK: - Update FCM Token
    func updateFCMToken(_ token: String) {
        HXLogger.info("[PushNotificationService] FCM Token: \(token)", category: "Push")
        DispatchQueue.main.async {
            self.fcmToken = token
        }
        syncTokenWithBackend()
    }

    // MARK: - Handle Notification
    func handleNotification(userInfo: [AnyHashable: Any]) {
        // Parse notification data
        guard let type = userInfo["type"] as? String else { return }

        HXLogger.info("[PushNotificationService] Received notification type: \(type)", category: "Push")

        // Update unread count
        DispatchQueue.main.async {
            self.unreadCount += 1
        }

        // Post local notification for in-app handling
        NotificationCenter.default.post(
            name: .hustleXPNotificationReceived,
            object: nil,
            userInfo: userInfo as? [String: Any]
        )
    }

    // MARK: - Clear Badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error {
                HXLogger.error("[PushNotificationService] Clear badge failed: \(error)", category: "Push")
            }
        }
        unreadCount = 0
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    static let hustleXPNotificationReceived = Notification.Name("hustleXPNotificationReceived")
}
