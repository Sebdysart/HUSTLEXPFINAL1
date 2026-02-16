//
//  BatchQuestService.swift
//  hustleXP final1
//
//  Real tRPC service for batch questing and route optimization
//  Maps to backend batchQuest.ts router
//

import Foundation
import Combine

// MARK: - Batch Quest Types

struct BatchSuggestion: Codable, Identifiable {
    let id: String
    let taskId: String
    let title: String
    let distanceMeters: Double
    let estimatedEarnings: Double?
    let category: String?
}

struct BatchRoute: Codable {
    let taskIds: [String]
    let totalDistanceMeters: Double
    let estimatedDurationMinutes: Int
    let optimizedOrder: [String]
}

// MARK: - Batch Quest Service

/// Handles batch task suggestions and route optimization via tRPC
@MainActor
final class BatchQuestService: ObservableObject {
    static let shared = BatchQuestService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Get batch quest suggestions near a current task
    func getSuggestions(
        currentTaskId: String,
        maxResults: Int? = nil,
        maxDistanceMeters: Int? = nil
    ) async throws -> [BatchSuggestion] {
        isLoading = true
        defer { isLoading = false }

        struct SuggestionsInput: Codable {
            let currentTaskId: String
            let maxResults: Int?
            let maxDistanceMeters: Int?
        }

        let suggestions: [BatchSuggestion] = try await trpc.call(
            router: "batchQuest",
            procedure: "getSuggestions",
            type: .query,
            input: SuggestionsInput(
                currentTaskId: currentTaskId,
                maxResults: maxResults,
                maxDistanceMeters: maxDistanceMeters
            )
        )

        HXLogger.info("BatchQuestService: Found \(suggestions.count) batch suggestions", category: "Task")
        return suggestions
    }

    /// Build an optimized route for a set of tasks
    func buildRoute(taskIds: [String]) async throws -> BatchRoute {
        isLoading = true
        defer { isLoading = false }

        struct RouteInput: Codable {
            let taskIds: [String]
        }

        let route: BatchRoute = try await trpc.call(
            router: "batchQuest",
            procedure: "buildRoute",
            type: .query,
            input: RouteInput(taskIds: taskIds)
        )

        HXLogger.info("BatchQuestService: Built route for \(taskIds.count) tasks", category: "Task")
        return route
    }
}
