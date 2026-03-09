//
//  TaskBatchingService.swift
//  hustleXP final1
//
//  Local heuristic service for task batching and route optimization
//  Replaces the removed batching API contract with deterministic client-side behavior
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

    // MARK: - State

    private(set) var currentRecommendation: BatchRecommendation?
    private(set) var isLoading = false
    private(set) var error: Error?

    private init() {}

    // MARK: - Generate Recommendation

    /// Generates a recommendation using the local batching heuristic.
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

        let available = availableTasks.filter(\.isAvailable)
        guard let primaryTask = selectPrimaryTask(from: available, currentLocation: currentLocation) else {
            currentRecommendation = nil
            return nil
        }

        let fallbackLocation = currentLocation ?? primaryTask.gpsCoordinates ?? GPSCoordinates(
            latitude: primaryTask.latitude ?? 0,
            longitude: primaryTask.longitude ?? 0,
            accuracyMeters: 0,
            timestamp: Date()
        )

        let recommendation = generateRecommendation(
            for: primaryTask,
            availableTasks: available,
            userLocation: fallbackLocation
        )

        if let recommendation {
            HXLogger.info("TaskBatchingService: Generated local recommendation for \(recommendation.taskCount) tasks", category: "Batching")
        }

        return recommendation
    }

    // MARK: - Calculate Savings

    /// Calculates batch savings using the same local heuristic as the UI.
    func calculateBatchSavingsFromAPI(tasks: [HXTask]) async throws -> BatchSavings {
        calculateBatchSavingsLocal(tasks: tasks)
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

    private func selectPrimaryTask(
        from availableTasks: [HXTask],
        currentLocation: GPSCoordinates?
    ) -> HXTask? {
        let candidates = availableTasks.filter { $0.gpsCoordinates != nil || ($0.latitude != nil && $0.longitude != nil) }
        guard !candidates.isEmpty else {
            return availableTasks.first
        }

        guard let currentLocation else {
            return candidates.max(by: { $0.payment < $1.payment })
        }

        return candidates.min { lhs, rhs in
            let lhsDistance = distance(from: currentLocation, to: lhs)
            let rhsDistance = distance(from: currentLocation, to: rhs)
            if lhsDistance == rhsDistance {
                return lhs.payment > rhs.payment
            }
            return lhsDistance < rhsDistance
        }
    }

    private func distance(from origin: GPSCoordinates, to task: HXTask) -> Double {
        guard let taskCoordinates = task.gpsCoordinates ?? {
            guard let latitude = task.latitude, let longitude = task.longitude else { return nil }
            return GPSCoordinates(latitude: latitude, longitude: longitude, accuracyMeters: 0, timestamp: Date())
        }() else {
            return .greatestFiniteMagnitude
        }

        return LocationService.current.calculateDistance(from: origin, to: taskCoordinates)
    }

    func clearRecommendation() {
        currentRecommendation = nil
    }
}
