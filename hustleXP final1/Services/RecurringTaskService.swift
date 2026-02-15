//
//  RecurringTaskService.swift
//  hustleXP final1
//
//  v2.4.0: Recurring Tasks API Service
//  Handles series CRUD, occurrence management, and preferred worker assignment
//

import Foundation
import Combine

@MainActor
final class RecurringTaskService: ObservableObject {
    static let shared = RecurringTaskService()
    private let trpc = TRPCClient.shared

    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

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
        endDate: Date?
    ) async throws -> RecurringTaskSeries {
        isLoading = true
        defer { isLoading = false }

        struct CreateSeriesInput: Codable {
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
            let startDate: Date
            let endDate: Date?
        }

        let input = CreateSeriesInput(
            title: title,
            description: description,
            payment: payment,
            location: location,
            category: category?.rawValue,
            estimatedDuration: estimatedDuration,
            requiredTier: requiredTier.rawValue,
            pattern: pattern.rawValue,
            dayOfWeek: dayOfWeek,
            dayOfMonth: dayOfMonth,
            timeOfDay: timeOfDay,
            startDate: startDate,
            endDate: endDate
        )

        let series: RecurringTaskSeries = try await trpc.call(
            router: "recurringTask",
            procedure: "create",
            input: input
        )

        print("✅ RecurringTaskService: Created series '\(title)' (\(pattern.rawValue))")
        return series
    }

    func getMySeries() async throws -> [RecurringTaskSeries] {
        struct EmptyInput: Codable {}

        let series: [RecurringTaskSeries] = try await trpc.call(
            router: "recurringTask",
            procedure: "listMine",
            type: .query,
            input: EmptyInput()
        )

        print("✅ RecurringTaskService: Fetched \(series.count) series")
        return series
    }

    func getSeries(id: String) async throws -> RecurringTaskSeries {
        struct GetSeriesInput: Codable {
            let id: String
        }

        let series: RecurringTaskSeries = try await trpc.call(
            router: "recurringTask",
            procedure: "getById",
            type: .query,
            input: GetSeriesInput(id: id)
        )

        return series
    }

    func pauseSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct PauseInput: Codable {
            let id: String
        }

        struct SuccessResponse: Codable {
            let success: Bool?
        }

        let _: SuccessResponse = try await trpc.call(
            router: "recurringTask",
            procedure: "pause",
            input: PauseInput(id: id)
        )

        print("✅ RecurringTaskService: Paused series \(id)")
    }

    func resumeSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct ResumeInput: Codable {
            let id: String
        }

        struct SuccessResponse: Codable {
            let success: Bool?
        }

        let _: SuccessResponse = try await trpc.call(
            router: "recurringTask",
            procedure: "resume",
            input: ResumeInput(id: id)
        )

        print("✅ RecurringTaskService: Resumed series \(id)")
    }

    func cancelSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct CancelInput: Codable {
            let id: String
        }

        struct SuccessResponse: Codable {
            let success: Bool?
        }

        let _: SuccessResponse = try await trpc.call(
            router: "recurringTask",
            procedure: "cancel",
            input: CancelInput(id: id)
        )

        print("✅ RecurringTaskService: Cancelled series \(id)")
    }

    // MARK: - Occurrences

    func getOccurrences(seriesId: String) async throws -> [RecurringOccurrence] {
        struct GetOccurrencesInput: Codable {
            let seriesId: String
        }

        let occurrences: [RecurringOccurrence] = try await trpc.call(
            router: "recurringTask",
            procedure: "listOccurrences",
            type: .query,
            input: GetOccurrencesInput(seriesId: seriesId)
        )

        return occurrences
    }

    func skipOccurrence(occurrenceId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct SkipInput: Codable {
            let occurrenceId: String
        }

        struct SuccessResponse: Codable {
            let success: Bool?
        }

        let _: SuccessResponse = try await trpc.call(
            router: "recurringTask",
            procedure: "skipOccurrence",
            input: SkipInput(occurrenceId: occurrenceId)
        )

        print("✅ RecurringTaskService: Skipped occurrence")
    }

    // MARK: - Preferred Worker

    func setPreferredWorker(seriesId: String, workerId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct SetWorkerInput: Codable {
            let seriesId: String
            let workerId: String
        }

        struct SuccessResponse: Codable {
            let success: Bool?
        }

        let _: SuccessResponse = try await trpc.call(
            router: "recurringTask",
            procedure: "setPreferredWorker",
            input: SetWorkerInput(seriesId: seriesId, workerId: workerId)
        )

        print("✅ RecurringTaskService: Set preferred worker for series \(seriesId)")
    }
}
