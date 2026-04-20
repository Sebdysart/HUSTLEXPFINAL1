//
//  RecurringTaskService.swift
//  hustleXP final1
//
//  v2.4.0: Recurring Tasks API Service
//  Handles series CRUD, occurrence management, and preferred worker assignment
//  Connected to backend recurringTask.* tRPC endpoints
//

import Foundation
import Combine

@MainActor
final class RecurringTaskService: ObservableObject {
    static let shared = RecurringTaskService()

    @Published var isLoading = false
    @Published var error: Error?

    init() {}

    // MARK: - Series CRUD

    func createSeries(
        title: String,
        description: String,
        payment: Double,
        location: String,
        category: TaskCategory?,
        estimatedDuration: String,
        requiredTier: TrustTier,
        pattern: RecurrencePattern,
        dayOfWeek: Int?,
        dayOfMonth: Int?,
        timeOfDay: String?,
        startDate: Date,
        endDate: Date?,
        templateSlug: String? = nil,
        riskLevel: String = "LOW",
        requiresProof: Bool = true,
        requirements: String? = nil
    ) async throws -> RecurringTaskSeries {
        isLoading = true
        defer { isLoading = false }

        struct CreateInput: Codable {
            let title: String
            let description: String
            let payment: Double
            let location: String
            let category: String?
            let estimatedDuration: String
            let requiredTier: Int
            let pattern: String
            let dayOfWeek: Int?
            let dayOfMonth: Int?
            let timeOfDay: String?
            let startDate: String
            let endDate: String?
            let templateSlug: String?
            let riskLevel: String
            let requiresProof: Bool
            let requirements: String?
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let input = CreateInput(
            title: title,
            description: description,
            payment: payment,
            location: location,
            category: category?.rawValue,
            estimatedDuration: estimatedDuration,
            requiredTier: requiredTier.numericValue,
            pattern: pattern.rawValue,
            dayOfWeek: dayOfWeek,
            dayOfMonth: dayOfMonth,
            timeOfDay: timeOfDay,
            startDate: formatter.string(from: startDate),
            endDate: endDate.map { formatter.string(from: $0) },
            templateSlug: templateSlug,
            riskLevel: riskLevel,
            requiresProof: requiresProof,
            requirements: requirements
        )

        let series: RecurringTaskSeries = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "create",
            input: input
        )

        HXLogger.info("RecurringTaskService: Created series '\(title)' (\(pattern.rawValue))", category: "Task")
        return series
    }

    func getMySeries() async throws -> [RecurringTaskSeries] {
        isLoading = true
        defer { isLoading = false }

        struct ListInput: Codable {
            let limit: Int
            let offset: Int
        }

        let series: [RecurringTaskSeries] = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "listMine",
            type: .query,
            input: ListInput(limit: 50, offset: 0)
        )

        HXLogger.info("RecurringTaskService: Fetched \(series.count) series", category: "Task")
        return series
    }

    func getSeries(id: String) async throws -> RecurringTaskSeries {
        isLoading = true
        defer { isLoading = false }

        struct GetInput: Codable {
            let id: String
        }

        let series: RecurringTaskSeries = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "getById",
            type: .query,
            input: GetInput(id: id)
        )

        return series
    }

    func pauseSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct IdInput: Codable { let id: String }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "pause",
            input: IdInput(id: id)
        )

        HXLogger.info("RecurringTaskService: Paused series \(id)", category: "Task")
    }

    func resumeSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct IdInput: Codable { let id: String }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "resume",
            input: IdInput(id: id)
        )

        HXLogger.info("RecurringTaskService: Resumed series \(id)", category: "Task")
    }

    func cancelSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct IdInput: Codable { let id: String }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "cancel",
            input: IdInput(id: id)
        )

        HXLogger.info("RecurringTaskService: Cancelled series \(id)", category: "Task")
    }

    // MARK: - Occurrences

    func getOccurrences(seriesId: String) async throws -> [RecurringOccurrence] {
        struct OccInput: Codable {
            let seriesId: String
            let limit: Int
            let offset: Int
        }

        let occurrences: [RecurringOccurrence] = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "listOccurrences",
            type: .query,
            input: OccInput(seriesId: seriesId, limit: 50, offset: 0)
        )

        return occurrences
    }

    func skipOccurrence(occurrenceId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct SkipInput: Codable { let occurrenceId: String }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "skipOccurrence",
            input: SkipInput(occurrenceId: occurrenceId)
        )

        HXLogger.info("RecurringTaskService: Skipped occurrence \(occurrenceId)", category: "Task")
    }

    // MARK: - Spawning & Instance Tasks

    /// Manually spawn a task from a scheduled occurrence
    func spawnOccurrenceNow(occurrenceId: String) async throws -> SpawnResult {
        isLoading = true
        defer { isLoading = false }

        struct SpawnInput: Codable { let occurrenceId: String }

        let result: SpawnResult = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "spawnOccurrenceNow",
            input: SpawnInput(occurrenceId: occurrenceId)
        )

        HXLogger.info("RecurringTaskService: Spawned occurrence \(occurrenceId) -> task \(result.taskId)", category: "Task")
        return result
    }

    /// Get the spawned HXTask for an occurrence
    func getInstanceTask(occurrenceId: String) async throws -> HXTask {
        struct InstanceInput: Codable { let occurrenceId: String }

        let task: HXTask = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "getInstanceTask",
            type: .query,
            input: InstanceInput(occurrenceId: occurrenceId)
        )

        return task
    }

    // MARK: - Preferred Worker

    func setPreferredWorker(seriesId: String, workerId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct WorkerInput: Codable {
            let seriesId: String
            let workerId: String
        }
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await TRPCClient.shared.call(
            router: "recurringTask",
            procedure: "setPreferredWorker",
            input: WorkerInput(seriesId: seriesId, workerId: workerId)
        )

        HXLogger.info("RecurringTaskService: Set preferred worker for series \(seriesId)", category: "Task")
    }
}

// MARK: - Spawn Result

struct SpawnResult: Codable {
    let taskId: String
    let escrowId: String
}

// MARK: - TrustTier numeric helper

private extension TrustTier {
    var numericValue: Int {
        switch self {
        case .unranked: return 0
        case .rookie: return 1
        case .verified: return 2
        case .trusted: return 3
        case .elite: return 4
        case .master: return 5
        }
    }
}
