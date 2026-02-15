//
//  TaskService.swift
//  hustleXP final1
//
//  Real tRPC service for task operations
//  Replaces MockDataService for all task-related API calls
//

import Foundation
import Combine

/// Manages all task-related API operations via tRPC
@MainActor
final class TaskService: ObservableObject {
    static let shared = TaskService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Task CRUD Operations

    /// Creates a new task
    func createTask(
        title: String,
        description: String,
        payment: Double,
        location: String,
        latitude: Double?,
        longitude: Double?,
        estimatedDuration: String,
        category: TaskCategory?,
        requiredTier: TrustTier = .rookie,
        requiredSkills: [String]? = nil
    ) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct CreateTaskInput: Codable {
            let title: String
            let description: String?
            let price: Int
            let location: String?
            let category: String?
            let mode: String
            let requiresProof: Bool
            let instantMode: Bool
        }

        let input = CreateTaskInput(
            title: title,
            description: description,
            price: Int(payment * 100), // Convert to cents
            location: location,
            category: category?.rawValue,
            mode: "STANDARD",
            requiresProof: true,
            instantMode: false
        )

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "create",
            input: input
        )

        print("✅ TaskService: Created task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.taskCreated, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Gets a task by ID
    func getTask(id: String) async throws -> HXTask {
        struct GetTaskInput: Codable {
            let taskId: String
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "getById",
            type: .query,
            input: GetTaskInput(taskId: id)
        )

        return task
    }

    /// Gets the current state of a task
    func getTaskState(id: String) async throws -> TaskState {
        struct GetStateInput: Codable {
            let taskId: String
        }

        struct StateResponse: Codable {
            let state: TaskState
        }

        let response: StateResponse = try await trpc.call(
            router: "task",
            procedure: "getState",
            type: .query,
            input: GetStateInput(taskId: id)
        )

        return response.state
    }

    // MARK: - Task Actions (Worker)

    /// Worker accepts/claims a task
    func acceptTask(taskId: String) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct AcceptInput: Codable {
            let taskId: String
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "accept",
            input: AcceptInput(taskId: taskId)
        )

        print("✅ TaskService: Accepted task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.taskAccepted, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Worker starts working on a task (transitions to in_progress)
    func startTask(taskId: String) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct StartInput: Codable {
            let taskId: String
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "start",
            input: StartInput(taskId: taskId)
        )

        print("✅ TaskService: Started task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.taskStarted, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Worker submits proof of completion
    func submitProof(
        taskId: String,
        photoUrls: [String],
        notes: String?,
        gpsLatitude: Double?,
        gpsLongitude: Double?,
        biometricHash: String?
    ) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct SubmitProofInput: Codable {
            let taskId: String
            let photoUrls: [String]
            let notes: String?
            let gpsLatitude: Double?
            let gpsLongitude: Double?
            let biometricHash: String?
        }

        let input = SubmitProofInput(
            taskId: taskId,
            photoUrls: photoUrls,
            notes: notes,
            gpsLatitude: gpsLatitude,
            gpsLongitude: gpsLongitude,
            biometricHash: biometricHash
        )

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "submitProof",
            input: input
        )

        print("✅ TaskService: Submitted proof for task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.proofSubmitted, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Worker cancels their acceptance of a task
    /// Note: Backend uses 'cancel' for both poster cancellation and worker abandonment
    func abandonTask(taskId: String, reason: String?) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct CancelInput: Codable {
            let taskId: String
            let reason: String?
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "cancel",
            input: CancelInput(taskId: taskId, reason: reason)
        )

        print("✅ TaskService: Abandoned task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.taskAbandoned, taskId: task.id, taskTitle: task.title)
        return task
    }

    // MARK: - Task Actions (Poster)

    /// Poster reviews and approves proof submission
    func reviewProof(taskId: String, approved: Bool, feedback: String?) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct ReviewInput: Codable {
            let taskId: String
            let approved: Bool
            let feedback: String?
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "reviewProof",
            input: ReviewInput(taskId: taskId, approved: approved, feedback: feedback)
        )

        print("✅ TaskService: Reviewed proof for task - \(task.title), approved: \(approved)")
        AnalyticsService.shared.trackTaskEvent(approved ? .proofApproved : .proofRejected, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Poster cancels their posted task
    func cancelTask(taskId: String, reason: String?) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct CancelInput: Codable {
            let taskId: String
            let reason: String?
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "cancel",
            input: CancelInput(taskId: taskId, reason: reason)
        )

        print("✅ TaskService: Cancelled task - \(task.title)")
        AnalyticsService.shared.trackTaskEvent(.taskCancelled, taskId: task.id, taskTitle: task.title)
        return task
    }

    // MARK: - Task Listings

    /// Gets all open tasks (available for workers)
    /// Note: For location-based filtering, use TaskDiscoveryService.getFeed() instead
    func listOpenTasks(
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [HXTask] {
        struct ListOpenInput: Codable {
            let limit: Int
            let offset: Int
        }

        let input = ListOpenInput(
            limit: min(limit, 100),
            offset: offset
        )

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: "listOpen",
            type: .query,
            input: input
        )

        print("✅ TaskService: Fetched \(tasks.count) open tasks")
        return tasks
    }

    /// Gets tasks created by the current user (poster)
    func listMyPostedTasks(state: TaskState? = nil) async throws -> [HXTask] {
        struct ListByPosterInput: Codable {
            let state: String?
        }

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: "listByPoster",
            type: .query,
            input: ListByPosterInput(state: state?.rawValue)
        )

        print("✅ TaskService: Fetched \(tasks.count) posted tasks")
        return tasks
    }

    /// Gets tasks claimed by the current user (worker)
    func listMyClaimedTasks(state: TaskState? = nil) async throws -> [HXTask] {
        struct ListByWorkerInput: Codable {
            let state: String?
        }

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: "listByWorker",
            type: .query,
            input: ListByWorkerInput(state: state?.rawValue)
        )

        print("✅ TaskService: Fetched \(tasks.count) claimed tasks")
        return tasks
    }

    /// Gets task history for the current user
    /// Note: Backend has no dedicated getHistory; uses listByWorker/listByPoster instead
    func getTaskHistory(role: UserRole, limit: Int = 50) async throws -> [HXTask] {
        let procedure = role == .poster ? "listByPoster" : "listByWorker"

        struct HistoryInput: Codable {
            let state: String?
        }

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: procedure,
            type: .query,
            input: HistoryInput(state: nil) // nil state returns all tasks including completed
        )

        print("✅ TaskService: Fetched \(tasks.count) history tasks")
        return tasks
    }
}

// MARK: - Task Discovery Service

/// Handles AI-powered task discovery and matching
@MainActor
final class TaskDiscoveryService: ObservableObject {
    static let shared = TaskDiscoveryService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Gets personalized task feed for worker
    func getFeed(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 16093, // 10 miles
        skills: [String]? = nil,
        limit: Int = 20
    ) async throws -> TaskFeedResponse {
        struct FeedInput: Codable {
            let latitude: Double
            let longitude: Double
            let radiusMeters: Double
            let skills: [String]?
            let limit: Int
        }

        let input = FeedInput(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            skills: skills,
            limit: limit
        )

        let response: TaskFeedResponse = try await trpc.call(
            router: "taskDiscovery",
            procedure: "getFeed",
            type: .query,
            input: input
        )

        print("✅ TaskDiscovery: Fetched feed with \(response.tasks.count) tasks")
        return response
    }

    /// Searches tasks with filters
    func search(
        query: String?,
        latitude: Double?,
        longitude: Double?,
        category: TaskCategory?,
        minPayment: Double?,
        maxPayment: Double?
    ) async throws -> [HXTask] {
        struct SearchInput: Codable {
            let query: String?
            let latitude: Double?
            let longitude: Double?
            let category: String?
            let minPaymentCents: Int?
            let maxPaymentCents: Int?
        }

        let input = SearchInput(
            query: query,
            latitude: latitude,
            longitude: longitude,
            category: category?.rawValue,
            minPaymentCents: minPayment != nil ? Int(minPayment! * 100) : nil,
            maxPaymentCents: maxPayment != nil ? Int(maxPayment! * 100) : nil
        )

        let tasks: [HXTask] = try await trpc.call(
            router: "taskDiscovery",
            procedure: "search",
            type: .query,
            input: input
        )

        print("✅ TaskDiscovery: Search returned \(tasks.count) tasks")
        return tasks
    }

    /// Gets AI match score explanation for a task
    func getMatchExplanation(taskId: String) async throws -> MatchExplanation {
        struct ExplanationInput: Codable {
            let taskId: String
        }

        let explanation: MatchExplanation = try await trpc.call(
            router: "taskDiscovery",
            procedure: "getExplanation",
            type: .query,
            input: ExplanationInput(taskId: taskId)
        )

        return explanation
    }

    // MARK: - Feed Score Calculation

    /// Pre-calculates matching scores for better feed performance
    func calculateFeedScores(maxDistanceMiles: Double = 10.0) async throws -> [String: Any] {
        struct CalcInput: Codable {
            let maxDistanceMiles: Double
        }

        struct CalcResponse: Codable {
            let calculatedCount: Int?
            let success: Bool?
        }

        let response: CalcResponse = try await trpc.call(
            router: "taskDiscovery",
            procedure: "calculateFeedScores",
            input: CalcInput(maxDistanceMiles: maxDistanceMiles)
        )

        print("✅ TaskDiscovery: Calculated feed scores")
        return ["calculatedCount": response.calculatedCount ?? 0]
    }

    /// Calculates matching score for a specific task
    func calculateMatchingScore(taskId: String) async throws -> MatchExplanation {
        struct MatchInput: Codable {
            let taskId: String
        }

        let result: MatchExplanation = try await trpc.call(
            router: "taskDiscovery",
            procedure: "calculateMatchingScore",
            type: .query,
            input: MatchInput(taskId: taskId)
        )

        print("✅ TaskDiscovery: Matching score for task \(taskId) = \(result.score)")
        return result
    }

    // MARK: - Saved Searches

    /// Saves a search query for quick access
    func saveSearch(
        name: String,
        query: String? = nil,
        filters: [String: String]? = nil,
        sortBy: String = "relevance"
    ) async throws -> SavedSearch {
        struct SaveInput: Codable {
            let name: String
            let query: String?
            let filters: [String: String]?
            let sortBy: String
        }

        let saved: SavedSearch = try await trpc.call(
            router: "taskDiscovery",
            procedure: "saveSearch",
            input: SaveInput(name: name, query: query, filters: filters, sortBy: sortBy)
        )

        print("✅ TaskDiscovery: Saved search '\(name)'")
        return saved
    }

    /// Gets all saved searches for the current user
    func getSavedSearches() async throws -> [SavedSearch] {
        struct EmptyInput: Codable {}

        let searches: [SavedSearch] = try await trpc.call(
            router: "taskDiscovery",
            procedure: "getSavedSearches",
            type: .query,
            input: EmptyInput()
        )

        print("✅ TaskDiscovery: Fetched \(searches.count) saved searches")
        return searches
    }

    /// Deletes a saved search by ID
    func deleteSavedSearch(searchId: String) async throws {
        struct DeleteInput: Codable {
            let searchId: String
        }

        struct SuccessResponse: Codable {
            let success: Bool
        }

        let _: SuccessResponse = try await trpc.call(
            router: "taskDiscovery",
            procedure: "deleteSavedSearch",
            input: DeleteInput(searchId: searchId)
        )

        print("✅ TaskDiscovery: Deleted saved search \(searchId)")
    }

    /// Executes a saved search with its stored filters
    func executeSavedSearch(searchId: String, limit: Int = 20, offset: Int = 0) async throws -> [HXTask] {
        struct ExecuteInput: Codable {
            let searchId: String
            let limit: Int
            let offset: Int
        }

        let tasks: [HXTask] = try await trpc.call(
            router: "taskDiscovery",
            procedure: "executeSavedSearch",
            type: .query,
            input: ExecuteInput(searchId: searchId, limit: limit, offset: offset)
        )

        print("✅ TaskDiscovery: Executed saved search, returned \(tasks.count) tasks")
        return tasks
    }
}

// MARK: - Saved Search Model

struct SavedSearch: Codable, Identifiable {
    let id: String
    let name: String
    let query: String?
    let filters: [String: String]?
    let sortBy: String?
    let createdAt: Date?
}

// MARK: - Response Types

struct TaskFeedResponse: Codable {
    let tasks: [HXTask]
    let lockedQuests: [LockedQuestInfo]?
    let demandAlerts: [DemandAlert]?
    let matchScore: Double?
}

struct LockedQuestInfo: Codable, Identifiable {
    let id: String
    let task: HXTask
    let reason: String
    let requiredSkill: String?
    let requiredTier: String?
    let potentialEarnings: Double
}

struct DemandAlert: Codable, Identifiable {
    let id: String
    let category: String
    let location: String
    let multiplier: Double
    let message: String
}

struct MatchExplanation: Codable {
    let score: Double
    let factors: [MatchFactor]
    let summary: String
}

struct MatchFactor: Codable {
    let name: String
    let score: Double
    let description: String
}
