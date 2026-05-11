//
//  DispatchModels.swift
//  hustleXP final1
//
//  Data models for the Smart Dispatch / Ping System (Phase 2).
//

import Foundation

// MARK: - Go Mode Status

struct GoModeStatus: Codable {
    let goMode: Bool
    let isOnline: Bool
    let lastLocationLat: Double?
    let lastLocationLng: Double?
    let locationUpdatedAt: Date?

    private enum CodingKeys: String, CodingKey {
        case goMode, isOnline, lastLocationLat, lastLocationLng, locationUpdatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        goMode = try c.decode(Bool.self, forKey: .goMode)
        isOnline = try c.decode(Bool.self, forKey: .isOnline)
        locationUpdatedAt = try c.decodeIfPresent(Date.self, forKey: .locationUpdatedAt)
        // PostgreSQL NUMERIC columns arrive as strings — accept both
        if let d = try? c.decodeIfPresent(Double.self, forKey: .lastLocationLat) {
            lastLocationLat = d
        } else {
            lastLocationLat = (try? c.decodeIfPresent(String.self, forKey: .lastLocationLat)).flatMap(Double.init)
        }
        if let d = try? c.decodeIfPresent(Double.self, forKey: .lastLocationLng) {
            lastLocationLng = d
        } else {
            lastLocationLng = (try? c.decodeIfPresent(String.self, forKey: .lastLocationLng)).flatMap(Double.init)
        }
    }
}

// MARK: - Dispatch Prefs

struct DispatchPrefs: Codable {
    var maxDistanceMiles: Int
    var minPayoutCents: Int
    var preferredCategories: [String]
    var autoAccept: Bool
    var pingSoundEnabled: Bool

    static let defaults = DispatchPrefs(
        maxDistanceMiles: 10,
        minPayoutCents: 0,
        preferredCategories: [],
        autoAccept: false,
        pingSoundEnabled: true
    )

    var minPayoutDollars: Double { Double(minPayoutCents) / 100.0 }
}

// MARK: - Soft Hold Result

struct SoftHoldAcquireResult: Codable {
    let acquired: Bool
    let expiresAt: Date?
}

// MARK: - Poster Dispatch Status

struct PosterDispatchEvent: Codable {
    let eventType: String
    let waveNumber: Int
    let createdAt: Date
}

struct PosterDispatchStatus: Codable {
    let dispatchState: String
    let waveNumber: Int
    let fulfillmentMode: String
    let softHoldExpiresAt: Date?
    let estimatedArrivalMinutes: Int?
    let estimatedArrivalAt: Date?
    let events: [PosterDispatchEvent]

    var isSearching: Bool {
        dispatchState == "broadcasting" || dispatchState == "soft_hold_active"
    }

    var isClaimed: Bool {
        dispatchState == "claimed" || dispatchState == "in_progress"
    }

    var stateLabel: String {
        switch dispatchState {
        case "idle":              return "Queued"
        case "broadcasting":     return "Finding Hustler"
        case "soft_hold_active": return "Hustler Considering"
        case "claimed":          return "On the Way"
        case "in_progress":      return "In Progress"
        case "completed":        return "Completed"
        case "expired":          return "No Match Found"
        case "cancelled":        return "Cancelled"
        default:                 return dispatchState.capitalized
        }
    }

    var etaLabel: String? {
        guard let mins = estimatedArrivalMinutes else { return nil }
        return mins <= 1 ? "Arriving now" : "~\(mins) min away"
    }
}

// MARK: - Confirm Claim Result

struct ConfirmClaimResult: Codable {
    let taskId: String
    let estimatedArrivalMinutes: Int?
    let estimatedArrivalAt: Date?
}

// MARK: - Incoming Ping (from push notification)

struct IncomingPing: Identifiable {
    let id: String          // taskId
    let taskId: String
    let taskTitle: String
    let paymentCents: Int
    let location: String?
    let waveNumber: Int
    let receivedAt: Date
    let expiresAt: Date     // receivedAt + 30s — countdown target

    var paymentFormatted: String {
        let dollars = Double(paymentCents) / 100.0
        return String(format: "$%.0f", dollars)
    }

    var secondsRemaining: Int {
        max(0, Int(expiresAt.timeIntervalSinceNow))
    }
}

// MARK: - Active Ping Poll Response

struct ActivePingResponse: Codable {
    let taskId: String
    let taskTitle: String
    let paymentCents: Int
    let location: String?
    let waveNumber: Int
    let expiresAt: String
}

// MARK: - Ping Debug State

struct PingDebugState: Codable {
    struct HustlerInfo: Codable {
        let goMode: Bool
        let trustHold: Bool
        let trustTier: Int
        let defaultMode: String
        let accountStatus: String
        let hasLocation: Bool
        let locationAgeSeconds: Int?
    }
    struct TaskInfo: Codable {
        let id: String
        let title: String
        let state: String
        let fulfillmentMode: String
        let dispatchState: String
        let ageSeconds: Int
    }
    struct OutboxEventInfo: Codable {
        let eventType: String
        let taskId: String
        let status: String
        let attempts: Int
        let error: String?
        let ageSeconds: Int
    }
    struct DispatchEventInfo: Codable {
        let taskId: String
        let eventType: String
        let waveNumber: Int
        let ageSeconds: Int
    }

    let hustler: HustlerInfo?
    let recentSmartDispatchTasks: [TaskInfo]
    let outboxEvents: [OutboxEventInfo]
    let myDispatchEvents: [DispatchEventInfo]
}
