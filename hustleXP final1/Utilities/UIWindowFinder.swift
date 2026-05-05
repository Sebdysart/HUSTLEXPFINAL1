//
//  UIWindowFinder.swift
//  hustleXP final1
//
//  Reliable window/view-controller lookup for OAuth flows (Google/Apple Sign-In).
//
//  iOS 13+ scene-based apps can have multiple connected scenes, and the
//  "first" scene/window isn't always the active one — leading to OAuth sheets
//  being presented on hidden windows and silently failing with "cancelled".
//

import UIKit
import AuthenticationServices

enum UIWindowFinder {
    /// Returns the topmost active key window across all foreground scenes.
    /// Filters by `activationState == .foregroundActive` to skip background scenes.
    @MainActor
    static var keyWindow: UIWindow? {
        let activeScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        // Prefer the keyWindow from an active scene
        if let keyWindow = activeScenes
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return keyWindow
        }

        // Fall back to the first window of any active scene
        if let firstActiveWindow = activeScenes.flatMap({ $0.windows }).first {
            return firstActiveWindow
        }

        // Last resort — any connected scene's first window
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first
    }

    /// Returns the topmost view controller for presenting modals (OAuth, payment sheets, etc.)
    /// Walks the presentation chain to find the highest-level controller currently visible.
    @MainActor
    static var topViewController: UIViewController? {
        guard let root = keyWindow?.rootViewController else { return nil }
        return topMostController(from: root)
    }

    @MainActor
    private static func topMostController(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController {
            return topMostController(from: presented)
        }
        if let nav = controller as? UINavigationController, let visible = nav.visibleViewController {
            return topMostController(from: visible)
        }
        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topMostController(from: selected)
        }
        return controller
    }

    /// Returns an `ASPresentationAnchor` for Apple Sign-In flows.
    /// Always returns a usable anchor (never nil) — Apple's API expects this.
    @MainActor
    static var presentationAnchor: ASPresentationAnchor {
        if let window = keyWindow { return window }
        // keyWindow already walks all connected scenes; reaching here means the app
        // has no UIWindowScene at all, which is a fatal configuration error.
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }.first!
        return UIWindow(windowScene: scene)
    }
}
