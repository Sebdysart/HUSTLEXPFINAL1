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
            let description: String
            let paymentCents: Int
            let location: String
            let latitude: Double?
            let longitude: Double?
            let estimatedDuration: String
            let category: String?
            let requiredTier: String
            let requiredSkills: [String]?
        }

        let input = CreateTaskInput(
            title: title,
            description: description,
            paymentCents: Int(payment * 100), // Convert to cents
            location: location,
            latitude: latitude,
            longitude: longitude,
            estimatedDuration: estimatedDuration,
            category: category?.rawValue,
            requiredTier: String(requiredTier.rawValue),
            requiredSkills: requiredSkills
        )

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "create",
            input: input
        )

        print("✅ TaskService: Created task - \(task.title)")
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
        return task
    }

    /// Worker cancels their acceptance of a task
    func abandonTask(taskId: String, reason: String?) async throws -> HXTask {
        isLoading = true
        defer { isLoading = false }

        struct AbandonInput: Codable {
            let taskId: String
            let reason: String?
        }

        let task: HXTask = try await trpc.call(
            router: "task",
            procedure: "abandon",
            input: AbandonInput(taskId: taskId, reason: reason)
        )

        print("✅ TaskService: Abandoned task - \(task.title)")
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
        return task
    }

    // MARK: - Task Listings

    /// Gets all open tasks (available for workers)
    func listOpenTasks(
        latitude: Double? = nil,
        longitude: Double? = nil,
        radiusMeters: Double? = nil,
        category: TaskCategory? = nil,
        limit: Int = 50
    ) async throws -> [HXTask] {
        struct ListOpenInput: Codable {
            let latitude: Double?
            let longitude: Double?
            let radiusMeters: Double?
            let category: String?
            let limit: Int
        }

        let input = ListOpenInput(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            category: category?.rawValue,
            limit: limit
        )

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: "listOpen",
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
            input: ListByWorkerInput(state: state?.rawValue)
        )

        print("✅ TaskService: Fetched \(tasks.count) claimed tasks")
        return tasks
    }

    /// Gets task history for the current user
    func getTaskHistory(role: UserRole, limit: Int = 50) async throws -> [HXTask] {
        struct HistoryInput: Codable {
            let role: String
            let limit: Int
        }

        let tasks: [HXTask] = try await trpc.call(
            router: "task",
            procedure: "getHistory",
            input: HistoryInput(role: role.rawValue, limit: limit)
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
            input: ExplanationInput(taskId: taskId)
        )

        return explanation
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
