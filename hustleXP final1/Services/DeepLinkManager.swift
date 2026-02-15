//
//  DeepLinkManager.swift
//  hustleXP final1
//
//  Deep link handler for custom URL scheme (hustlexp://) and
//  universal links (https://hustlexp.app/).
//
//  Parses incoming URLs into typed DeepLink destinations and
//  coordinates with Router to navigate the user to the correct screen.
//

import SwiftUI
import Combine

// MARK: - Deep Link Destination

/// Typed destinations that can be reached via deep link.
enum DeepLinkDestination: Equatable {
    /// Navigate to a specific task detail screen
    case task(taskId: String)
    /// Navigate to a user profile
    case profile(userId: String)
    /// Apply a referral code
    case referral(code: String)

    /// Human-readable label for analytics / logging
    var analyticsName: String {
        switch self {
        case .task:     return "task_detail"
        case .profile:  return "profile"
        case .referral: return "referral"
        }
    }
}

// MARK: - DeepLinkManager

/// Parses and manages deep links for HustleXP.
///
/// Supports two URL formats:
///  - Custom scheme:   `hustlexp://task/{taskId}`
///  - Universal links: `https://hustlexp.app/task/{taskId}`
///
/// Paths handled:
///  - `/task/{taskId}`    -> task detail
///  - `/profile/{userId}` -> user profile
///  - `/ref/{code}`       -> referral code application
@MainActor
@Observable
final class DeepLinkManager {

    // MARK: - Singleton

    static let shared = DeepLinkManager()

    // MARK: - State

    /// The most recent deep link that has not yet been consumed by the Router.
    /// Set by `handleURL(_:)`, cleared by `consumePendingDeepLink()`.
    var pendingDeepLink: DeepLinkDestination?

    /// History of all deep links received during the current session (useful for debugging).
    private(set) var deepLinkHistory: [DeepLinkDestination] = []

    // MARK: - Constants

    /// Custom URL scheme registered in Info.plist
    private let customScheme = "hustlexp"

    /// Universal link host
    private let universalLinkHost = "hustlexp.app"

    // MARK: - URL Handling

    /// Primary entry point. Call this from `.onOpenURL` in the App struct.
    /// Returns `true` if the URL was recognised as a valid deep link.
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        print("[DeepLinkManager] Received URL: \(url.absoluteString)")

        guard let destination = parseURL(url) else {
            print("[DeepLinkManager] URL not recognised as deep link")
            return false
        }

        print("[DeepLinkManager] Parsed destination: \(destination.analyticsName)")
        pendingDeepLink = destination
        deepLinkHistory.append(destination)
        return true
    }

    /// Consume (and clear) the pending deep link. Typically called by
    /// the navigation layer after it has navigated to the destination.
    func consumePendingDeepLink() -> DeepLinkDestination? {
        let link = pendingDeepLink
        pendingDeepLink = nil
        return link
    }

    // MARK: - URL Generation

    /// Build a shareable universal link for a task.
    static func taskURL(taskId: String) -> URL {
        URL(string: "https://hustlexp.app/task/\(taskId)")!
    }

    /// Build a shareable universal link for a user profile.
    static func profileURL(userId: String) -> URL {
        URL(string: "https://hustlexp.app/profile/\(userId)")!
    }

    /// Build a shareable universal link for a referral code.
    static func referralURL(code: String) -> URL {
        URL(string: "https://hustlexp.app/ref/\(code)")!
    }

    // MARK: - Parsing

    /// Parses a URL (custom scheme or universal link) into a typed destination.
    private func parseURL(_ url: URL) -> DeepLinkDestination? {
        // Determine path components depending on scheme type
        let pathComponents: [String]

        if url.scheme == customScheme {
            // hustlexp://task/abc-123
            // url.host == "task", url.pathComponents == ["/", "abc-123"]
            // OR hustlexp://task/abc-123 where host is "task" and path is "/abc-123"
            var components: [String] = []
            if let host = url.host {
                components.append(host)
            }
            components.append(contentsOf: url.pathComponents.filter { $0 != "/" })
            pathComponents = components
        } else if url.scheme == "https" || url.scheme == "http" {
            // Universal link: https://hustlexp.app/task/abc-123
            guard url.host == universalLinkHost || url.host == "www.\(universalLinkHost)" else {
                return nil
            }
            pathComponents = url.pathComponents.filter { $0 != "/" }
        } else {
            return nil
        }

        return matchPath(pathComponents)
    }

    /// Match an array of path segments to a DeepLinkDestination.
    ///
    /// Expected patterns:
    ///  - ["task", "{taskId}"]
    ///  - ["profile", "{userId}"]
    ///  - ["ref", "{code}"]
    private func matchPath(_ segments: [String]) -> DeepLinkDestination? {
        guard segments.count >= 2 else { return nil }

        let resource = segments[0].lowercased()
        let identifier = segments[1]

        // Reject empty identifiers
        guard !identifier.isEmpty else { return nil }

        switch resource {
        case "task":
            return .task(taskId: identifier)
        case "profile":
            return .profile(userId: identifier)
        case "ref":
            return .referral(code: identifier)
        default:
            return nil
        }
    }
}

// MARK: - Router Deep Link Integration

extension Router {

    /// Navigate the user to the screen that corresponds to a deep link destination.
    ///
    /// The method inspects the current user role to decide which navigation
    /// stack to push onto (hustler vs poster). Shared routes (like task detail)
    /// exist in both stacks so the correct one is chosen automatically.
    func navigate(to destination: DeepLinkDestination, appState: AppState) {
        print("[Router] Navigating to deep link: \(destination.analyticsName)")

        switch destination {
        case .task(let taskId):
            // Both roles have a taskDetail route — push onto the active role stack
            if appState.userRole == .poster {
                navigateToPoster(.taskDetail(taskId: taskId))
            } else {
                navigateToHustler(.taskDetail(taskId: taskId))
            }

        case .profile(let userId):
            // If the deep link targets the current user, go to the own profile
            if userId == appState.userId {
                if appState.userRole == .poster {
                    navigateToPoster(.profile)
                } else {
                    navigateToHustler(.profile)
                }
            } else {
                // For other users, navigate via task detail with userId context
                // (profile viewing of others would be handled by a future route)
                if appState.userRole == .poster {
                    navigateToPoster(.profile)
                } else {
                    navigateToHustler(.profile)
                }
            }

        case .referral(let code):
            // Navigate to the referrals settings screen
            navigateToSettings(.referrals)
            print("[Router] Referral code received: \(code)")
        }
    }
}
