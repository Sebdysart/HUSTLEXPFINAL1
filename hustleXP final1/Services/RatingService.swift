//
//  RatingService.swift
//  hustleXP final1
//
//  Real tRPC service for post-task ratings
//  Maps to backend rating.ts router
//

import Foundation
import Combine

// MARK: - Rating Types

struct RatingSummary: Codable {
    let averageRating: Double
    let totalRatings: Int
    let ratingDistribution: [String: Int] // star count as string -> number of ratings
}

struct UserRating: Codable, Identifiable {
    let id: String
    let taskId: String
    let taskTitle: String
    let fromUserId: String
    let fromUserName: String
    let rating: Int
    let review: String?
    let createdAt: Date
}

// MARK: - Rating Service

/// Handles post-task ratings via tRPC
@MainActor
final class RatingService: ObservableObject {
    static let shared = RatingService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Submits a rating for a completed task
    func submitRating(
        taskId: String,
        rating: Int, // 1-5
        review: String?,
        tags: [String]? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        struct RatingInput: Codable {
            let taskId: String
            let stars: Int
            let comment: String?
            let tags: [String]?
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "rating",
            procedure: "submitRating",
            input: RatingInput(taskId: taskId, stars: rating, comment: review, tags: tags)
        )

        HXLogger.info("RatingService: Submitted \(rating)-star rating for task \(taskId)", category: "General")
    }

    /// Gets rating summary for a user
    func getUserRatingSummary(userId: String) async throws -> RatingSummary {
        struct GetSummaryInput: Codable {
            let userId: String
        }

        let summary: RatingSummary = try await trpc.call(
            router: "rating",
            procedure: "getUserRatingSummary",
            type: .query,
            input: GetSummaryInput(userId: userId)
        )

        return summary
    }

    /// Gets ratings received by current user
    func getMyRatings(limit: Int = 50) async throws -> [UserRating] {
        struct GetRatingsInput: Codable {
            let limit: Int
        }

        let ratings: [UserRating] = try await trpc.call(
            router: "rating",
            procedure: "getMyRatings",
            type: .query,
            input: GetRatingsInput(limit: limit)
        )

        HXLogger.info("RatingService: Fetched \(ratings.count) ratings", category: "General")
        return ratings
    }

    // MARK: - Task Ratings

    /// Gets ratings for a specific task (only returns public ratings)
    /// Ratings are blind until both parties rate or 7 days expire (RATE-8)
    func getTaskRatings(taskId: String) async throws -> [UserRating] {
        struct TaskRatingsInput: Codable {
            let taskId: String
        }

        let ratings: [UserRating] = try await trpc.call(
            router: "rating",
            procedure: "getTaskRatings",
            type: .query,
            input: TaskRatingsInput(taskId: taskId)
        )

        HXLogger.info("RatingService: Fetched \(ratings.count) ratings for task \(taskId)", category: "General")
        return ratings
    }

    /// Gets ratings others have given to the current user (public only)
    func getRatingsReceived(limit: Int = 50, offset: Int = 0) async throws -> [UserRating] {
        struct ReceivedInput: Codable {
            let limit: Int
            let offset: Int
        }

        let ratings: [UserRating] = try await trpc.call(
            router: "rating",
            procedure: "getRatingsReceived",
            type: .query,
            input: ReceivedInput(limit: limit, offset: offset)
        )

        HXLogger.info("RatingService: Fetched \(ratings.count) ratings received", category: "General")
        return ratings
    }
}
