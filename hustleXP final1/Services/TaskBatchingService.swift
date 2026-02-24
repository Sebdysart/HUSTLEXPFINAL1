//
//  TaskBatchingService.swift
//  hustleXP final1
//
//  Real tRPC service for AI-powered task batching and route optimization
//  Maps to backend batching.ts router
//  Replaces MockTaskBatchingService
//

import Foundation
import SwiftUI

// MARK: - Types

struct BatchRecommendation: Codable, Identifiable {
    var id: String { primaryTask.id }

    let primaryTask: HXTask
    let additionalTasks: [HXTask]
    let totalEarnings: Int // cents
    let totalDuration: Int // minutes
    let earningsPerHour: Double // $/hr
    let routeDistance: Double // meters
    let estimatedTravelTime: Int // minutes
    let savingsVsIndividual: Int // cents
    let confidence: Double // 0-1
    let reasoning: String
}

struct BatchSavings: Codable {
    let totalEarnings: Int
    let combinedDuration: Int
    let individualDuration: Int
    let timeSaved: Int
    let earningsBoost: Int
}

// MARK: - Task Batching Service

@MainActor
@Observable
final class TaskBatchingService {
    static let shared = TaskBatchingService()

    private let trpc = TRPCClient.shared

    // MARK: - State

    private(set) var currentRecommendation: BatchRecommendation?
    private(set) var isLoading = false
    private(set) var error: Error?

    private init() {}

    // MARK: - Generate Recommendation

    /// Generate batch recommendation from available tasks
    func generateRecommendation(
        availableTasks: [HXTask],
        currentLocation: GPSCoordinates? = nil
    ) async throws -> BatchRecommendation? {
        guard availableTasks.count >= 2 else {
            return nil // Need at least 2 tasks to batch
        }

        isLoading = true
        error = nil
        defer { isLoading = false }

        struct GenerateInput: Codable {
            let availableTasks: [TaskInput]
            let currentLocation: LocationInput?
        }

        struct TaskInput: Codable {
            let id: String
            let title: String
            let price: Int
            let location: String
            let latitude: Double?
            let longitude: Double?
            let estimatedDuration: Int?
        }

        struct LocationInput: Codable {
            let lat: Double
            let lng: Double
        }

        let taskInputs = availableTasks.map { task in
            TaskInput(
                id: task.id,
                title: task.title,
                price: Int(task.payment * 100), // Convert to cents
                location: task.location,
                latitude: task.latitude,
                longitude: task.longitude,
                estimatedDuration: parseDuration(task.estimatedDuration)
            )
        }

        let locationInput = currentLocation.map { loc in
            LocationInput(lat: loc.latitude, lng: loc.longitude)
        }

        let input = GenerateInput(
            availableTasks: taskInputs,
            currentLocation: locationInput
        )

        do {
            let recommendation: BatchRecommendation? = try await trpc.call(
                router: "batching",
                procedure: "generateRecommendation",
                type: .query,
                input: input
            )

            self.currentRecommendation = recommendation

            if let rec = recommendation {
                HXLogger.info("Batch recommendation: \(rec.additionalTasks.count + 1) tasks, $\(String(format: "%.0f", rec.earningsPerHour))/hr", category: "Batching")
            }

            return recommendation
        } catch {
            self.error = error
            HXLogger.error("Failed to generate batch recommendation: \(error.localizedDescription)", category: "Batching")
            throw error
        }
    }

    // MARK: - Calculate Savings

    /// Calculate savings for specific tasks
    func calculateBatchSavings(tasks: [HXTask]) async throws -> BatchSavings {
        struct CalculateInput: Codable {
            let tasks: [TaskInput]
        }

        struct TaskInput: Codable {
            let id: String
            let title: String
            let price: Int
            let location: String
            let latitude: Double?
            let longitude: Double?
            let estimatedDuration: Int?
        }

        let taskInputs = tasks.map { task in
            TaskInput(
                id: task.id,
                title: task.title,
                price: Int(task.payment * 100),
                location: task.location,
                latitude: task.latitude,
                longitude: task.longitude,
                estimatedDuration: parseDuration(task.estimatedDuration)
            )
        }

        let input = CalculateInput(tasks: taskInputs)

        let savings: BatchSavings = try await trpc.call(
            router: "batching",
            procedure: "calculateSavings",
            type: .query,
            input: input
        )

        return savings
    }

    // MARK: - Helpers

    private func parseDuration(_ durationString: String?) -> Int? {
        guard let str = durationString else { return nil }

        // Parse strings like "1 hr", "30 min", "2 hrs"
        let components = str.lowercased().components(separatedBy: " ")
        guard let number = components.first, let value = Int(number) else {
            return nil
        }

        if str.contains("hr") {
            return value * 60
        } else if str.contains("min") {
            return value
        }

        return nil
    }

    func clearRecommendation() {
        currentRecommendation = nil
    }
}
