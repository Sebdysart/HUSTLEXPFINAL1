//
//  GDPRService.swift
//  hustleXP final1
//
//  Real tRPC service for GDPR/privacy compliance
//  Maps to backend gdpr.ts router
//  Handles: data export, deletion requests, consent management
//

import Foundation
import Combine

// MARK: - GDPR Request Types

/// GDPR request type
enum GDPRRequestType: String, Codable, CaseIterable {
    case export = "EXPORT"
    case deletion = "DELETION"
    case rectification = "RECTIFICATION"
    case restriction = "RESTRICTION"

    /// Safe decode — unknown values default to .export
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = GDPRRequestType(rawValue: raw) ?? .export
    }

    var displayName: String {
        switch self {
        case .export: return "Export My Data"
        case .deletion: return "Delete My Data"
        case .rectification: return "Correct My Data"
        case .restriction: return "Restrict Processing"
        }
    }

    var description: String {
        switch self {
        case .export: return "Download a copy of all your personal data"
        case .deletion: return "Permanently delete your account and all associated data"
        case .rectification: return "Request correction of inaccurate personal data"
        case .restriction: return "Restrict how your data is processed"
        }
    }
}

/// GDPR request status
enum GDPRRequestStatus: String, Codable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case failed = "FAILED"

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = GDPRRequestStatus(rawValue: raw) ?? .pending
    }

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .failed: return "Failed"
        }
    }
}

/// GDPR request record
struct GDPRRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let type: GDPRRequestType
    let status: GDPRRequestStatus
    let reason: String?
    let createdAt: Date
    let completedAt: Date?
    let downloadUrl: String?
    let expiresAt: Date?
}

// MARK: - Consent Types

/// Consent type
enum ConsentType: String, Codable, CaseIterable {
    case analytics = "ANALYTICS"
    case marketing = "MARKETING"
    case thirdParty = "THIRD_PARTY"
    case locationTracking = "LOCATION_TRACKING"
    case pushNotifications = "PUSH_NOTIFICATIONS"

    /// Safe decode — unknown values default to .analytics
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = ConsentType(rawValue: raw) ?? .analytics
    }

    var displayName: String {
        switch self {
        case .analytics: return "Analytics"
        case .marketing: return "Marketing Communications"
        case .thirdParty: return "Third-Party Sharing"
        case .locationTracking: return "Location Tracking"
        case .pushNotifications: return "Push Notifications"
        }
    }

    var description: String {
        switch self {
        case .analytics: return "Help us improve the app by sharing usage data"
        case .marketing: return "Receive promotional emails and offers"
        case .thirdParty: return "Allow sharing data with trusted partners"
        case .locationTracking: return "Track location for task matching"
        case .pushNotifications: return "Receive push notifications about tasks and updates"
        }
    }
}

/// Consent status for a single type
struct ConsentStatus: Codable, Identifiable {
    let id: String
    let type: ConsentType
    let granted: Bool
    let updatedAt: Date
}

// MARK: - GDPR Service

/// Manages GDPR/privacy operations via tRPC
@MainActor
final class GDPRService: ObservableObject {
    static let shared = GDPRService()

    private let trpc = TRPCClient.shared

    @Published var requests: [GDPRRequest] = []
    @Published var consents: [ConsentStatus] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - GDPR Requests

    /// Creates a GDPR request (export, deletion, rectification, restriction)
    func createRequest(type: GDPRRequestType, reason: String? = nil) async throws -> GDPRRequest {
        isLoading = true
        defer { isLoading = false }

        struct CreateRequestInput: Codable {
            let type: String
            let reason: String?
        }

        let request: GDPRRequest = try await trpc.call(
            router: "gdpr",
            procedure: "createRequest",
            input: CreateRequestInput(type: type.rawValue, reason: reason)
        )

        // Refresh requests list
        _ = try? await getMyRequests()

        HXLogger.info("GDPRService: Created \(type.rawValue) request", category: "General")
        return request
    }

    /// Gets status of a specific GDPR request
    func getRequestStatus(requestId: String) async throws -> GDPRRequest {
        struct GetStatusInput: Codable {
            let requestId: String
        }

        let request: GDPRRequest = try await trpc.call(
            router: "gdpr",
            procedure: "getRequestStatus",
            type: .query,
            input: GetStatusInput(requestId: requestId)
        )

        return request
    }

    /// Gets all GDPR requests for user
    func getMyRequests() async throws -> [GDPRRequest] {
        struct EmptyInput: Codable {}

        let requests: [GDPRRequest] = try await trpc.call(
            router: "gdpr",
            procedure: "getMyRequests",
            type: .query,
            input: EmptyInput()
        )

        self.requests = requests
        HXLogger.info("GDPRService: Fetched \(requests.count) GDPR requests", category: "General")
        return requests
    }

    /// Cancels a pending GDPR request (within grace period)
    func cancelRequest(requestId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct CancelInput: Codable {
            let requestId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "gdpr",
            procedure: "cancelRequest",
            input: CancelInput(requestId: requestId)
        )

        // Refresh requests list
        _ = try? await getMyRequests()

        HXLogger.info("GDPRService: Cancelled request \(requestId)", category: "General")
    }

    // MARK: - Consent Management

    /// Gets all consent statuses for user
    func getConsentStatus() async throws -> [ConsentStatus] {
        struct EmptyInput: Codable {}

        let consents: [ConsentStatus] = try await trpc.call(
            router: "gdpr",
            procedure: "getConsentStatus",
            type: .query,
            input: EmptyInput()
        )

        self.consents = consents
        HXLogger.info("GDPRService: Fetched \(consents.count) consent statuses", category: "General")
        return consents
    }

    /// Updates consent for a specific type
    func updateConsent(type: ConsentType, granted: Bool) async throws {
        isLoading = true
        defer { isLoading = false }

        struct UpdateConsentInput: Codable {
            let type: String
            let granted: Bool
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "gdpr",
            procedure: "updateConsent",
            input: UpdateConsentInput(type: type.rawValue, granted: granted)
        )

        // Refresh consents
        _ = try? await getConsentStatus()

        HXLogger.info("GDPRService: Updated consent \(type.rawValue) = \(granted)", category: "General")
    }

    // MARK: - Convenience Methods

    /// Requests a data export
    func requestDataExport() async throws -> GDPRRequest {
        return try await createRequest(type: .export)
    }

    /// Requests account deletion
    func requestAccountDeletion(reason: String?) async throws -> GDPRRequest {
        return try await createRequest(type: .deletion, reason: reason)
    }
}
