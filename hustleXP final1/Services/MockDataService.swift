//
//  MockDataService.swift
//  hustleXP final1
//
//  Mock data service for development
//

import Foundation

@MainActor
@Observable
final class MockDataService {
    static let shared = MockDataService()
    
    // MARK: - Current User
    var currentUser: HXUser = HXUser(
        id: "user-001",
        name: "Demo User",
        email: "demo@hustlexp.com",
        phone: "+1 (555) 123-4567",
        bio: "Ready to hustle!",
        avatarURL: nil,
        role: .hustler,
        trustTier: .rookie,
        rating: 4.5,
        totalRatings: 12,
        xp: 45,
        tasksCompleted: 8,
        tasksPosted: 3,
        totalEarnings: 325.00,
        totalSpent: 150.00,
        isVerified: false,
        createdAt: Date().addingTimeInterval(-86400 * 30)
    )
    
    // MARK: - Mock Tasks
    var availableTasks: [HXTask] = [
        HXTask(
            id: "task-001",
            title: "Deliver Package Downtown",
            description: "Need someone to pick up a package from my office and deliver it to a client downtown. Package is small (under 5 lbs).",
            payment: 25.00,
            location: "Downtown",
            latitude: 37.7749,
            longitude: -122.4194,
            estimatedDuration: "30 min",
            posterId: "poster-001",
            posterName: "John D.",
            posterRating: 4.8,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-3600),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-002",
            title: "Help Moving Furniture",
            description: "Moving a couch and dining table from apartment to storage unit. Need someone with a vehicle or willing to help load.",
            payment: 75.00,
            location: "Westside",
            latitude: 37.7849,
            longitude: -122.4294,
            estimatedDuration: "2 hrs",
            posterId: "poster-002",
            posterName: "Sarah M.",
            posterRating: 4.9,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .verified,
            createdAt: Date().addingTimeInterval(-7200),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-003",
            title: "Grocery Shopping & Delivery",
            description: "Need groceries picked up from Whole Foods and delivered. List will be provided. About 15 items.",
            payment: 35.00,
            location: "Midtown",
            latitude: 37.7649,
            longitude: -122.4094,
            estimatedDuration: "1 hr",
            posterId: "poster-003",
            posterName: "Mike R.",
            posterRating: 4.7,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-1800),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-004",
            title: "Dog Walking",
            description: "Need someone to walk my golden retriever for 45 minutes. He's friendly and well-trained.",
            payment: 20.00,
            location: "Park District",
            latitude: 37.7549,
            longitude: -122.4394,
            estimatedDuration: "45 min",
            posterId: "poster-004",
            posterName: "Lisa K.",
            posterRating: 5.0,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .rookie,
            createdAt: Date().addingTimeInterval(-900),
            claimedAt: nil,
            completedAt: nil
        ),
        HXTask(
            id: "task-005",
            title: "Assemble IKEA Furniture",
            description: "Need help assembling a KALLAX shelf unit and a desk. Tools provided.",
            payment: 50.00,
            location: "Eastside",
            latitude: 37.7949,
            longitude: -122.3994,
            estimatedDuration: "1.5 hrs",
            posterId: "poster-005",
            posterName: "Tom B.",
            posterRating: 4.6,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .trusted,
            createdAt: Date().addingTimeInterval(-5400),
            claimedAt: nil,
            completedAt: nil
        )
    ]
    
    var activeTask: HXTask? = nil
    
    var completedTasks: [HXTask] = []
    
    // MARK: - Mock Conversations
    var conversations: [HXConversation] = []
    
    // MARK: - Actions
    
    func claimTask(_ taskId: String) {
        guard let index = availableTasks.firstIndex(where: { $0.id == taskId }) else { return }
        var task = availableTasks[index]
        task.state = .claimed
        task.hustlerId = currentUser.id
        task.hustlerName = currentUser.name
        task.claimedAt = Date()
        
        availableTasks.remove(at: index)
        activeTask = task
        
        print("[MockData] Task claimed: \(task.title)")
    }
    
    func updateTaskState(_ taskId: String, to state: TaskState) {
        if var task = activeTask, task.id == taskId {
            task.state = state
            if state == .completed {
                task.completedAt = Date()
                completedTasks.append(task)
                activeTask = nil
                currentUser.tasksCompleted += 1
                currentUser.totalEarnings += task.payment
                currentUser.xp += Int(task.payment / 2)
            } else {
                activeTask = task
            }
            print("[MockData] Task state updated: \(state.rawValue)")
        }
    }
    
    func postTask(_ task: HXTask) {
        var newTask = task
        newTask.state = .posted
        availableTasks.insert(newTask, at: 0)
        currentUser.tasksPosted += 1
        print("[MockData] Task posted: \(task.title)")
    }
}
