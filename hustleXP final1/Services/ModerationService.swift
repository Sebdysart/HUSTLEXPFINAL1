//
//  ModerationService.swift
//  hustleXP final1
//
//  Real tRPC service for content moderation and user reporting
//  Maps to backend moderation.ts router
//  Handles: report creation, appeal submission, viewing reports/appeals
//

import Foundation
import Combine

// MARK: - Report Types

/// Content report from backend
struct ContentReport: Codable, Identifiable {
    let id: String
    let reporterId: String
    let reportedUserId: String?
    let reportedContentId: String?
    let reportedContentType: String
    let reason: ReportReason
    let description: String?
    let status: ReportStatus
    let createdAt: Date
    let reviewedAt: Date?
    let reviewerNotes: String?
}

/// Reasons for reporting content
enum ReportReason: String, Codable, CaseIterable {
    case spam = "SPAM"
    case harassment = "HARASSMENT"
    case inappropriateContent = "INAPPROPRIATE_CONTENT"
    case fraud = "FRAUD"
    case impersonation = "IMPERSONATION"
    case scam = "SCAM"
    case unsafe = "UNSAFE"
    case other = "OTHER"

    /// Safe decode — unknown values default to .other
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = ReportReason(rawValue: raw) ?? .other
    }

    var displayName: String {
        switch self {
        case .spam: return "Spam"
        case .harassment: return "Harassment"
        case .inappropriateContent: return "Inappropriate Content"
        case .fraud: return "Fraud"
        case .impersonation: return "Impersonation"
        case .scam: return "Scam"
        case .unsafe: return "Unsafe Behavior"
        case .other: return "Other"
        }
    }
}

/// Report status
enum ReportStatus: String, Codable {
    case pending = "PENDING"
    case reviewed = "REVIEWED"
    case actionTaken = "ACTION_TAKEN"
    case dismissed = "DISMISSED"

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = ReportStatus(rawValue: raw) ?? .pending
    }
}

// MARK: - Appeal Types

/// Content moderation appeal
struct ModerationAppeal: Codable, Identifiable {
    let id: String
    let userId: String
    let contentId: String
    let contentType: String
    let reason: String
    let status: AppealStatus
    let createdAt: Date
    let reviewedAt: Date?
    let reviewerNotes: String?
}

/// Appeal status
enum AppealStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"

    /// Safe decode — unknown values default to .pending
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = AppealStatus(rawValue: raw) ?? .pending
    }
}

// MARK: - Moderation Service

/// Manages content reporting and appeals via tRPC
@MainActor
final class ModerationService: ObservableObject {
    static let shared = ModerationService()

    private let trpc = TRPCClient.shared

    @Published var myAppeals: [ModerationAppeal] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Create Report

    /// Reports a user or content
    /// Backend expects: {contentType, contentId, reportedContentUserId, category, description}
    func createReport(
        reportedUserId: String? = nil,
        reportedContentId: String? = nil,
        reportedContentType: String,
        reason: ReportReason,
        description: String?
    ) async throws -> ContentReport {
        isLoading = true
        defer { isLoading = false }

        struct CreateReportInput: Codable {
            let contentType: String
            let contentId: String
            let reportedContentUserId: String
            let category: String
            let description: String?
        }

        // Map frontend fields to backend schema
        let contentId = reportedContentId ?? reportedUserId ?? ""
        let userId = reportedUserId ?? ""

        let report: ContentReport = try await trpc.call(
            router: "moderation",
            procedure: "createReport",
            input: CreateReportInput(
                contentType: reportedContentType.lowercased(),
                contentId: contentId,
                reportedContentUserId: userId,
                category: reason.rawValue,
                description: description
            )
        )

        print("✅ ModerationService: Created report \(report.id)")
        return report
    }

    /// Convenience: Report a task
    func reportTask(taskId: String, reason: ReportReason, description: String?) async throws -> ContentReport {
        return try await createReport(
            reportedContentId: taskId,
            reportedContentType: "TASK",
            reason: reason,
            description: description
        )
    }

    /// Convenience: Report a user
    func reportUser(userId: String, reason: ReportReason, description: String?) async throws -> ContentReport {
        return try await createReport(
            reportedUserId: userId,
            reportedContentType: "USER",
            reason: reason,
            description: description
        )
    }

    /// Convenience: Report a message
    func reportMessage(messageId: String, reason: ReportReason, description: String?) async throws -> ContentReport {
        return try await createReport(
            reportedContentId: messageId,
            reportedContentType: "MESSAGE",
            reason: reason,
            description: description
        )
    }

    // MARK: - Appeals

    /// Creates an appeal for moderated content
    /// Backend expects: {moderationQueueId, originalDecision, appealReason, deadline}
    func createAppeal(
        moderationQueueId: String,
        originalDecision: String,
        reason: String,
        deadline: Date? = nil
    ) async throws -> ModerationAppeal {
        isLoading = true
        defer { isLoading = false }

        struct CreateAppealInput: Codable {
            let moderationQueueId: String
            let originalDecision: String
            let appealReason: String
            let deadline: String
        }

        // Default deadline: 7 days from now
        let appealDeadline = deadline ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let formatter = ISO8601DateFormatter()

        let appeal: ModerationAppeal = try await trpc.call(
            router: "moderation",
            procedure: "createAppeal",
            input: CreateAppealInput(
                moderationQueueId: moderationQueueId,
                originalDecision: originalDecision,
                appealReason: reason,
                deadline: formatter.string(from: appealDeadline)
            )
        )

        print("✅ ModerationService: Created appeal \(appeal.id)")
        return appeal
    }

    /// Gets user's own appeals
    func getMyAppeals() async throws -> [ModerationAppeal] {
        struct EmptyInput: Codable {}

        let appeals: [ModerationAppeal] = try await trpc.call(
            router: "moderation",
            procedure: "getUserAppeals",
            type: .query,
            input: EmptyInput()
        )

        self.myAppeals = appeals
        print("✅ ModerationService: Fetched \(appeals.count) appeals")
        return appeals
    }
}
