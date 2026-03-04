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

private struct TaskBatchRecommendationResponse: Codable, Identifiable {
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

private struct TaskBatchSavingsResponse: Codable {
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
            let recommendation: TaskBatchRecommendationResponse? = try await trpc.call(
                router: "batching",
                procedure: "generateRecommendation",
                type: .query,
                input: input
            )

            let mapped = recommendation.map { rec in
                mapRecommendation(rec, fallbackTasks: availableTasks)
            }
            self.currentRecommendation = mapped

            if let rec = recommendation {
                HXLogger.info("Batch recommendation: \(rec.additionalTasks.count + 1) tasks, $\(String(format: "%.0f", rec.earningsPerHour))/hr", category: "Batching")
            }

            return mapped
        } catch {
            self.error = error
            HXLogger.error("Failed to generate batch recommendation: \(error.localizedDescription)", category: "Batching")
            throw error
        }
    }

    // MARK: - Calculate Savings

    /// Calculate savings for specific tasks
    func calculateBatchSavingsFromAPI(tasks: [HXTask]) async throws -> BatchSavings {
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

        let savings: TaskBatchSavingsResponse = try await trpc.call(
            router: "batching",
            procedure: "calculateSavings",
            type: .query,
            input: input
        )

        return mapSavingsResponse(savings)
    }

    // MARK: - Local Fallbacks

    /// Synchronous local recommendation used by existing UI callers.
    func generateRecommendation(
        for task: HXTask,
        availableTasks: [HXTask],
        userLocation: GPSCoordinates
    ) -> BatchRecommendation? {
        let nearbyTasks = availableTasks
            .filter { $0.id != task.id && $0.isAvailable }
            .filter { other in
                guard let from = task.gpsCoordinates, let to = other.gpsCoordinates else { return false }
                let distance = LocationService.current.calculateDistance(from: from, to: to)
                return distance <= 1000
            }
            .sorted { lhs, rhs in
                guard let from = task.gpsCoordinates, let lhsCoords = lhs.gpsCoordinates, let rhsCoords = rhs.gpsCoordinates else {
                    return false
                }
                let lhsDistance = LocationService.current.calculateDistance(from: from, to: lhsCoords)
                let rhsDistance = LocationService.current.calculateDistance(from: from, to: rhsCoords)
                return lhsDistance < rhsDistance
            }

        guard !nearbyTasks.isEmpty else { return nil }

        let selectedNearby = Array(nearbyTasks.prefix(2))
        let allTasks = [task] + selectedNearby
        let totalPayment = allTasks.reduce(0.0) { $0 + $1.payment }
        let savings = calculateBatchSavingsLocal(tasks: allTasks)

        let recommendation = BatchRecommendation(
            id: "batch_\(task.id)_\(UUID().uuidString.prefix(8))",
            primaryTask: task,
            nearbyTasks: selectedNearby,
            totalPayment: totalPayment,
            totalEstimatedTime: "\(allTasks.count * 30) min",
            savings: savings,
            expiresAt: Date().addingTimeInterval(30 * 60)
        )
        currentRecommendation = recommendation
        return recommendation
    }

    /// Synchronous local savings used by existing UI callers.
    func calculateBatchSavingsLocal(tasks: [HXTask]) -> BatchSavings {
        guard tasks.count > 1 else {
            return BatchSavings(timeSavedMinutes: 0, extraEarnings: 0, efficiencyBoost: 0)
        }

        let tripsSaved = tasks.count - 1
        let timeSaved = tripsSaved * 15
        let extraEarnings = tasks.dropFirst().reduce(0.0) { $0 + $1.payment }
        let baseTime = max(1, tasks.count * 30)
        let efficiencyBoost = Double(timeSaved) / Double(baseTime) * 100

        return BatchSavings(
            timeSavedMinutes: timeSaved,
            extraEarnings: extraEarnings,
            efficiencyBoost: efficiencyBoost
        )
    }

    // MARK: - Helpers

    private func mapRecommendation(
        _ response: TaskBatchRecommendationResponse,
        fallbackTasks: [HXTask]
    ) -> BatchRecommendation {
        let primaryTask = fallbackTasks.first(where: { $0.id == response.primaryTask.id }) ?? response.primaryTask
        let nearbyTasks = response.additionalTasks.map { additional in
            fallbackTasks.first(where: { $0.id == additional.id }) ?? additional
        }

        let timeSaved = max(0, response.totalDuration - response.estimatedTravelTime)
        let savings = BatchSavings(
            timeSavedMinutes: timeSaved,
            extraEarnings: Double(response.savingsVsIndividual) / 100.0,
            efficiencyBoost: response.confidence * 100
        )

        return BatchRecommendation(
            id: response.id,
            primaryTask: primaryTask,
            nearbyTasks: nearbyTasks,
            totalPayment: Double(response.totalEarnings) / 100.0,
            totalEstimatedTime: "\(response.totalDuration) min",
            savings: savings,
            expiresAt: Date().addingTimeInterval(30 * 60)
        )
    }

    private func mapSavingsResponse(_ response: TaskBatchSavingsResponse) -> BatchSavings {
        let efficiencyBoost: Double
        if response.individualDuration > 0 {
            efficiencyBoost = (Double(response.timeSaved) / Double(response.individualDuration)) * 100.0
        } else {
            efficiencyBoost = 0
        }

        return BatchSavings(
            timeSavedMinutes: max(0, response.timeSaved),
            extraEarnings: Double(response.earningsBoost) / 100.0,
            efficiencyBoost: efficiencyBoost
        )
    }

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
