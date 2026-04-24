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
    static let shared = TaskService(client: TRPCClient.shared)

    private let trpc: TRPCClientProtocol

    @Published var isLoading = false
    @Published var error: Error?

    init(client: TRPCClientProtocol) {
        self.trpc = client
    }

    // MARK: - Task CRUD Operations

    /// Creates a new task
    func createTask(
        title: String,
        description: String,
        payment: Double,
        location: String,
        locationCity: String? = nil,
        locationState: String? = nil,
        locationRadiusMiles: Int? = nil,
        latitude: Double?,
        longitude: Double?,
        estimatedDuration: String,
        category: TaskCategory?,
        templateSlug: String? = nil,
        requiredTier: TrustTier = .rookie,
        requiredSkills: [String]? = nil,
        deadline: Date? = nil
    ) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct CreateTaskInput: Codable {
            let title: String
            let description: String?
            let price: Int
            let location: String?
            let locationCity: String?
            let locationState: String?
            let locationRadiusMiles: Int?
            let latitude: Double?
            let longitude: Double?
            let category: String?
            let estimatedDuration: String?
            let templateSlug: String?
            let deadline: String?
            let mode: String
            let requiresProof: Bool
            let instantMode: Bool
        }

        let input = CreateTaskInput(
            title: title,
            description: description,
            price: Int(payment * 100),
            location: location,
            locationCity: locationCity,
            locationState: locationState,
            locationRadiusMiles: locationRadiusMiles,
            latitude: latitude,
            longitude: longitude,
            category: category?.rawValue,
            estimatedDuration: estimatedDuration,
            templateSlug: templateSlug,
            deadline: deadline.map { ISO8601DateFormatter().string(from: $0) },
            mode: "STANDARD",
            requiresProof: true,
            instantMode: false
        )

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "create",
            input: input
        )

        HXLogger.info("TaskService: Created task - \(task.title)", category: "Task")
        AnalyticsService.shared.trackTaskEvent(.taskCreated, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Updates a task (poster only, OPEN state only)
    func updateTask(
        taskId: String,
        title: String? = nil,
        description: String? = nil,
        price: Int? = nil,
        location: String? = nil,
        category: String? = nil,
        estimatedDuration: String? = nil,
        requirements: String? = nil,
        deadline: Date? = nil,
        templateSlug: String? = nil
    ) async throws -> HXTask {
        struct UpdateTaskInput: Codable {
            let taskId: String
            let title: String?
            let description: String?
            let price: Int?
            let location: String?
            let category: String?
            let estimatedDuration: String?
            let requirements: String?
            let deadline: String?
            let templateSlug: String?
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "update",
            input: UpdateTaskInput(
                taskId: taskId,
                title: title,
                description: description,
                price: price,
                location: location,
                category: category,
                estimatedDuration: estimatedDuration,
                requirements: requirements,
                deadline: deadline.map { ISO8601DateFormatter().string(from: $0) },
                templateSlug: templateSlug
            )
        )

        HXLogger.info("TaskService: Updated task - \(task.title)", category: "Task")
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

        HXLogger.info("TaskService: Accepted task - \(task.title)", category: "Task")
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

        HXLogger.info("TaskService: Started task - \(task.title)", category: "Task")
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

        HXLogger.info("TaskService: Submitted proof for task - \(task.title)", category: "Task")
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

        HXLogger.info("TaskService: Abandoned task - \(task.title)", category: "Task")
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

        HXLogger.info("TaskService: Reviewed proof for task - \(task.title), approved: \(approved)", category: "Task")
        AnalyticsService.shared.trackTaskEvent(approved ? .proofApproved : .proofRejected, taskId: task.id, taskTitle: task.title)
        return task
    }

    /// Poster marks task as complete (after proof approved)
    func completeTask(taskId: String) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct CompleteInput: Codable {
            let taskId: String
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "complete",
            input: CompleteInput(taskId: taskId)
        )

        HXLogger.info("TaskService: Completed task - \(task.title)", category: "Task")
        AnalyticsService.shared.trackTaskEvent(.taskCompleted, taskId: task.id, taskTitle: task.title)
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

        HXLogger.info("TaskService: Cancelled task - \(task.title)", category: "Task")
        AnalyticsService.shared.trackTaskEvent(.taskCancelled, taskId: task.id, taskTitle: task.title)
        return task
    }

    // MARK: - Applicant Management (Poster)

    /// Lists applicants for a posted task
    func listApplicants(taskId: String) async throws -> [TaskApplicant] {
        HXLogger.info("TaskService: Applicant listing is not exposed by the live backend contract for task \(taskId)", category: "Task")
        return []
    }

    /// Poster assigns a specific applicant as the worker for their task
    func assignWorker(taskId: String, workerId: String) async throws -> HXTask {
        throw unsupportedTaskWorkflow(
            "Assigning applicants is not available in the live backend contract for task \(taskId)."
        )
    }

    /// Poster rejects an applicant for their task
    func rejectApplicant(taskId: String, workerId: String) async throws {
        throw unsupportedTaskWorkflow(
            "Rejecting applicants is not available in the live backend contract for task \(taskId)."
        )
    }

    // MARK: - Application (Hustler)

    /// Hustler applies for a task with optional message
    func applyForTask(taskId: String, message: String? = nil) async throws -> ApplicationResponse {
        isLoading = true
        defer { isLoading = false }

        struct ApplyInput: Codable {
            let taskId: String
            let message: String?
        }

        let response: ApplicationResponse = try await trpc.call(
            router: "task",
            procedure: "applyForTask",
            input: ApplyInput(taskId: taskId, message: message)
        )

        HXLogger.info("TaskService: Applied for task \(taskId)", category: "Task")
        return response
    }

    /// Hustler withdraws their application
    func withdrawApplication(taskId: String) async throws {
        throw unsupportedTaskWorkflow(
            "Application withdrawal is not available in the live backend contract for task \(taskId)."
        )
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

        HXLogger.info("TaskService: Fetched \(tasks.count) open tasks", category: "Task")
        return tasks
    }

    /// Gets tasks created by the current user (poster)
    func listMyPostedTasks(state: TaskState? = nil) async throws -> [HXTask] {
        struct ListByPosterInput: Codable {
            let limit: Int
        }
        struct PaginatedResponse: Codable {
            let tasks: [HXTask]
            let nextCursor: String?
        }

        let response: PaginatedResponse = try await trpc.call(
            router: "task",
            procedure: "listByPoster",
            type: .query,
            input: ListByPosterInput(limit: 50)
        )

        var tasks = response.tasks
        if let state {
            tasks = tasks.filter { $0.state == state }
        }

        HXLogger.info("TaskService: Fetched \(tasks.count) posted tasks", category: "Task")
        return tasks
    }

    /// Gets tasks claimed by the current user (worker)
    func listMyClaimedTasks(state: TaskState? = nil) async throws -> [HXTask] {
        struct ListByWorkerInput: Codable {
            let limit: Int
        }
        struct PaginatedResponse: Codable {
            let tasks: [HXTask]
            let nextCursor: String?
        }

        let response: PaginatedResponse = try await trpc.call(
            router: "task",
            procedure: "listByWorker",
            type: .query,
            input: ListByWorkerInput(limit: 50)
        )

        var tasks = response.tasks
        if let state {
            tasks = tasks.filter { $0.state == state }
        }

        HXLogger.info("TaskService: Fetched \(tasks.count) claimed tasks", category: "Task")
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

        HXLogger.info("TaskService: Fetched \(tasks.count) history tasks", category: "Task")
        return tasks
    }

    private func unsupportedTaskWorkflow(_ message: String) -> NSError {
        NSError(
            domain: "HustleXP",
            code: 501,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
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
        limit: Int = 50,
        filters: FeedFilterParams? = nil
    ) async throws -> TaskFeedResponse {
        struct FeedFiltersInput: Codable {
            let category: String?
            let min_price: Int?
            let max_price: Int?
            let max_distance_miles: Double?
            let sort_by: String?
        }

        struct FeedInput: Codable {
            let latitude: Double
            let longitude: Double
            let radiusMeters: Double
            let skills: [String]?
            let limit: Int
            let filters: FeedFiltersInput?
        }

        let filtersInput: FeedFiltersInput? = filters.map { f in
            FeedFiltersInput(
                category: f.category?.rawValue,
                min_price: f.minPriceCents,
                max_price: f.maxPriceCents,
                max_distance_miles: f.maxDistanceMiles,
                sort_by: f.sortBy?.rawValue
            )
        }

        let input = FeedInput(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            skills: skills,
            limit: limit,
            filters: filtersInput
        )

        let response: TaskFeedResponse = try await trpc.call(
            router: "taskDiscovery",
            procedure: "getFeed",
            type: .query,
            input: input
        )

        HXLogger.info("TaskDiscovery: Fetched feed with \(response.tasks.count) tasks", category: "Task")
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
            minPaymentCents: minPayment.map { Int($0 * 100) },
            maxPaymentCents: maxPayment.map { Int($0 * 100) }
        )

        let tasks: [HXTask] = try await trpc.call(
            router: "taskDiscovery",
            procedure: "search",
            type: .query,
            input: input
        )

        HXLogger.info("TaskDiscovery: Search returned \(tasks.count) tasks", category: "Task")
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

        HXLogger.info("TaskDiscovery: Calculated feed scores", category: "Task")
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

        HXLogger.info("TaskDiscovery: Matching score for task \(taskId) = \(result.score)", category: "Task")
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

        HXLogger.info("TaskDiscovery: Saved search '\(name)'", category: "Task")
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

        HXLogger.info("TaskDiscovery: Fetched \(searches.count) saved searches", category: "Task")
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

        HXLogger.info("TaskDiscovery: Deleted saved search \(searchId)", category: "Task")
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

        HXLogger.info("TaskDiscovery: Executed saved search, returned \(tasks.count) tasks", category: "Task")
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

// MARK: - Feed Filter Types

enum FeedSortOption: String, CaseIterable, Identifiable {
    case relevance = "relevance"
    case price = "price"
    case distance = "distance"
    case deadline = "deadline"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .relevance: return "Best Match"
        case .price: return "Highest Pay"
        case .distance: return "Nearest"
        case .deadline: return "Ending Soon"
        }
    }

    var icon: String {
        switch self {
        case .relevance: return "sparkles"
        case .price: return "dollarsign"
        case .distance: return "location"
        case .deadline: return "clock"
        }
    }
}

struct FeedFilterParams {
    var category: TaskCategory? = nil
    var minPriceCents: Int? = nil   // USD cents
    var maxPriceCents: Int? = nil   // USD cents
    var maxDistanceMiles: Double? = nil
    var sortBy: FeedSortOption? = nil

    var isActive: Bool {
        category != nil || minPriceCents != nil || maxPriceCents != nil
            || maxDistanceMiles != nil || (sortBy != nil && sortBy != .relevance)
    }
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

// MARK: - Application Response

struct ApplicationResponse: Codable, Identifiable {
    let id: String
    let taskId: String
    let status: String
    let message: String?
    let appliedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case status
        case message
        case appliedAt = "applied_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        taskId = (try? container.decode(String.self, forKey: .taskId)) ?? ""
        status = (try? container.decode(String.self, forKey: .status)) ?? "pending"
        message = try? container.decode(String.self, forKey: .message)
        appliedAt = try? container.decode(Date.self, forKey: .appliedAt)
    }
}
