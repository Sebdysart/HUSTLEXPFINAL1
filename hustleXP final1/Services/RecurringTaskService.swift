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

    @Published var isLoading = false
    @Published var error: Error?

    private var localSeries: [RecurringTaskSeries] = []
    private var localOccurrencesBySeriesId: [String: [RecurringOccurrence]] = [:]

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
        endDate: Date?
    ) async throws -> RecurringTaskSeries {
        isLoading = true
        defer { isLoading = false }
        let now = Date()
        let seriesId = "local-series-\(UUID().uuidString)"
        let nextOccurrence = computeNextOccurrence(
            pattern: pattern,
            dayOfWeek: dayOfWeek,
            dayOfMonth: dayOfMonth,
            timeOfDay: timeOfDay,
            startDate: startDate
        )

        let series = RecurringTaskSeries(
            id: seriesId,
            posterId: "local-poster",
            templateTaskId: "template-\(seriesId)",
            pattern: pattern,
            dayOfWeek: dayOfWeek,
            dayOfMonth: dayOfMonth,
            timeOfDay: timeOfDay,
            startDate: startDate,
            endDate: endDate,
            title: title,
            description: description,
            payment: payment,
            location: location,
            category: category,
            estimatedDuration: estimatedDuration,
            requiredTier: requiredTier,
            status: .active,
            occurrenceCount: 1,
            completedCount: 0,
            preferredWorkerId: nil,
            preferredWorkerName: nil,
            createdAt: now,
            updatedAt: now,
            nextOccurrence: nextOccurrence
        )

        localSeries.insert(series, at: 0)
        localOccurrencesBySeriesId[seriesId] = [makeOccurrence(for: series, number: 1, scheduledDate: nextOccurrence ?? startDate)]
        HXLogger.info("RecurringTaskService: Created local series '\(title)' (\(pattern.rawValue)) while backend support is pending", category: "Task")
        return series
    }

    func getMySeries() async throws -> [RecurringTaskSeries] {
        HXLogger.info("RecurringTaskService: Returning \(localSeries.count) local series", category: "Task")
        return localSeries
    }

    func getSeries(id: String) async throws -> RecurringTaskSeries {
        guard let series = localSeries.first(where: { $0.id == id }) else {
            throw NSError(
                domain: "HustleXP",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Recurring series not found: \(id)"]
            )
        }
        return series
    }

    func pauseSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try updateSeries(id: id) { series in
            series.status = .paused
            series.updatedAt = Date()
        }
        HXLogger.info("RecurringTaskService: Paused series \(id)", category: "Task")
    }

    func resumeSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try updateSeries(id: id) { series in
            series.status = .active
            series.updatedAt = Date()
        }
        HXLogger.info("RecurringTaskService: Resumed series \(id)", category: "Task")
    }

    func cancelSeries(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try updateSeries(id: id) { series in
            series.status = .cancelled
            series.updatedAt = Date()
        }
        HXLogger.info("RecurringTaskService: Cancelled series \(id)", category: "Task")
    }

    // MARK: - Occurrences

    func getOccurrences(seriesId: String) async throws -> [RecurringOccurrence] {
        localOccurrencesBySeriesId[seriesId] ?? []
    }

    func skipOccurrence(occurrenceId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        guard let seriesId = localOccurrencesBySeriesId.first(where: { _, occurrences in
            occurrences.contains(where: { $0.id == occurrenceId })
        })?.key else {
            throw NSError(
                domain: "HustleXP",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Recurring occurrence not found: \(occurrenceId)"]
            )
        }

        var occurrences = localOccurrencesBySeriesId[seriesId] ?? []
        guard let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) else {
            return
        }

        occurrences[index].status = .skipped
        localOccurrencesBySeriesId[seriesId] = occurrences
        HXLogger.info("RecurringTaskService: Skipped occurrence", category: "Task")
    }

    // MARK: - Preferred Worker

    func setPreferredWorker(seriesId: String, workerId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try updateSeries(id: seriesId) { series in
            series.preferredWorkerId = workerId
            series.preferredWorkerName = "Preferred Worker"
            series.updatedAt = Date()
        }
        HXLogger.info("RecurringTaskService: Set preferred worker for series \(seriesId)", category: "Task")
    }

    private func updateSeries(id: String, mutate: (inout RecurringTaskSeries) -> Void) throws {
        guard let index = localSeries.firstIndex(where: { $0.id == id }) else {
            throw NSError(
                domain: "HustleXP",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Recurring series not found: \(id)"]
            )
        }

        var series = localSeries[index]
        mutate(&series)
        localSeries[index] = series
    }

    private func makeOccurrence(for series: RecurringTaskSeries, number: Int, scheduledDate: Date) -> RecurringOccurrence {
        RecurringOccurrence(
            id: "local-occurrence-\(UUID().uuidString)",
            seriesId: series.id,
            taskId: "local-task-\(series.id)-\(number)",
            occurrenceNumber: number,
            scheduledDate: scheduledDate,
            status: .scheduled,
            workerId: nil,
            workerName: nil,
            completedAt: nil,
            rating: nil
        )
    }

    private func computeNextOccurrence(
        pattern: RecurrencePattern,
        dayOfWeek: Int?,
        dayOfMonth: Int?,
        timeOfDay: String?,
        startDate: Date
    ) -> Date? {
        let calendar = Calendar.current
        var date = startDate

        if let timeOfDay {
            let components = timeOfDay.split(separator: ":").compactMap { Int($0) }
            if components.count == 2,
               let adjusted = calendar.date(bySettingHour: components[0], minute: components[1], second: 0, of: date) {
                date = adjusted
            }
        }

        switch pattern {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return nextWeekday(from: date, weekday: dayOfWeek ?? 1, intervalWeeks: 1)
        case .biweekly:
            return nextWeekday(from: date, weekday: dayOfWeek ?? 1, intervalWeeks: 2)
        case .monthly:
            guard let dayOfMonth else {
                return calendar.date(byAdding: .month, value: 1, to: date)
            }
            var components = calendar.dateComponents([.year, .month], from: date)
            components.month = (components.month ?? 1) + 1
            components.day = min(dayOfMonth, 28)
            components.hour = calendar.component(.hour, from: date)
            components.minute = calendar.component(.minute, from: date)
            return calendar.date(from: components)
        }
    }

    private func nextWeekday(from date: Date, weekday: Int, intervalWeeks: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = min(max(weekday + 1, 1), 7)
        guard let nextDate = calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) else {
            return calendar.date(byAdding: .day, value: 7 * intervalWeeks, to: date)
        }
        if intervalWeeks == 1 {
            return nextDate
        }
        return calendar.date(byAdding: .day, value: 7 * (intervalWeeks - 1), to: nextDate)
    }
}
