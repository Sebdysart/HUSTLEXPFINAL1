//
//  MockTaskBatchingService.swift
//  hustleXP final1
//
//  Mock Task Batching service for v1.9.0 - Nearby task recommendations
//

import Foundation
import CoreLocation

@MainActor
@Observable
final class MockTaskBatchingService {
    static let shared = MockTaskBatchingService()
    
    // MARK: - State
    
    var currentRecommendation: BatchRecommendation?
    var recentRecommendations: [BatchRecommendation] = []
    
    // MARK: - Configuration
    
    let maxBatchDistance: Double = 1000  // meters
    let maxBatchTasks: Int = 3
    let minTimeBetween: Int = 15         // minutes
    let maxTimeBetween: Int = 60         // minutes
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Recommendation Generation
    
    /// Generate a batch recommendation for a primary task
    func generateRecommendation(
        for task: HXTask,
        availableTasks: [HXTask],
        userLocation: GPSCoordinates
    ) -> BatchRecommendation? {
        // Find nearby tasks
        let nearbyTasks = findNearbyTasks(for: task, within: maxBatchDistance, from: availableTasks)
        
        guard !nearbyTasks.isEmpty else {
            return nil
        }
        
        // Take up to maxBatchTasks - 1 nearby tasks
        let batchTasks = Array(nearbyTasks.prefix(maxBatchTasks - 1))
        
        // Calculate totals
        let allTasks = [task] + batchTasks
        let totalPayment = allTasks.reduce(0) { $0 + $1.payment }
        
        // Estimate total time
        let estimatedTime = estimateTotalTime(tasks: allTasks, from: userLocation)
        
        // Calculate savings
        let savings = calculateBatchSavings(tasks: allTasks)
        
        let recommendation = BatchRecommendation(
            id: "batch_\(task.id)_\(UUID().uuidString.prefix(8))",
            primaryTask: task,
            nearbyTasks: batchTasks,
            totalPayment: totalPayment,
            totalEstimatedTime: estimatedTime,
            savings: savings,
            expiresAt: Date().addingTimeInterval(30 * 60) // 30 min expiry
        )
        
        currentRecommendation = recommendation
        recentRecommendations.append(recommendation)
        
        print("[TaskBatching] Generated recommendation: \(recommendation.taskCount) tasks, \(recommendation.formattedTotalPayment)")
        
        return recommendation
    }
    
    /// Find tasks within a certain radius of a primary task
    func findNearbyTasks(for task: HXTask, within radiusMeters: Double, from tasks: [HXTask]) -> [HXTask] {
        guard let taskLat = task.latitude, let taskLon = task.longitude else {
            return []
        }
        
        let taskLocation = CLLocation(latitude: taskLat, longitude: taskLon)
        
        return tasks
            .filter { otherTask in
                // Exclude the primary task
                guard otherTask.id != task.id else { return false }
                
                // Must be available
                guard otherTask.isAvailable else { return false }
                
                // Must have coordinates
                guard let lat = otherTask.latitude, let lon = otherTask.longitude else { return false }
                
                // Check distance
                let otherLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = taskLocation.distance(from: otherLocation)
                
                return distance <= radiusMeters
            }
            .sorted { task1, task2 in
                // Sort by distance
                let dist1 = task1.distance(from: taskLocation) ?? Double.infinity
                let dist2 = task2.distance(from: taskLocation) ?? Double.infinity
                return dist1 < dist2
            }
    }
    
    /// Calculate savings from batching tasks
    func calculateBatchSavings(tasks: [HXTask]) -> BatchSavings {
        guard tasks.count > 1 else {
            return BatchSavings(timeSavedMinutes: 0, extraEarnings: 0, efficiencyBoost: 0)
        }
        
        // Estimate time saved by not returning home between tasks
        // Assume 15 min travel home between separate tasks
        let tripsSaved = tasks.count - 1
        let timeSaved = tripsSaved * 15
        
        // Extra earnings from additional tasks
        let extraEarnings = tasks.dropFirst().reduce(0) { $0 + $1.payment }
        
        // Efficiency boost (percentage improvement)
        let baseTime = tasks.count * 30 // 30 min per task if done separately
        _ = baseTime - timeSaved // batchTime for potential future use
        let efficiencyBoost = Double(timeSaved) / Double(baseTime) * 100
        
        return BatchSavings(
            timeSavedMinutes: timeSaved,
            extraEarnings: extraEarnings,
            efficiencyBoost: efficiencyBoost
        )
    }
    
    /// Cluster tasks by proximity
    func clusterTasks(_ tasks: [HXTask]) -> [TaskCluster] {
        var clusters: [TaskCluster] = []
        var processed = Set<String>()
        
        for task in tasks where !processed.contains(task.id) {
            // Find all tasks within batch distance
            let nearbyTasks = findNearbyTasks(for: task, within: maxBatchDistance, from: tasks)
            let clusterTasks = [task] + nearbyTasks.filter { !processed.contains($0.id) }
            
            // Mark as processed
            clusterTasks.forEach { processed.insert($0.id) }
            
            // Calculate cluster center
            let validTasks = clusterTasks.filter { $0.hasCoordinates }
            guard !validTasks.isEmpty else { continue }
            
            let centerLat = validTasks.compactMap { $0.latitude }.reduce(0, +) / Double(validTasks.count)
            let centerLon = validTasks.compactMap { $0.longitude }.reduce(0, +) / Double(validTasks.count)
            
            // Calculate total payment
            let totalPayment = clusterTasks.reduce(0) { $0 + $1.payment }
            
            // Estimate walking distance and time between tasks
            let (walkingDistance, walkingTime) = estimateWalkingBetween(tasks: clusterTasks)
            
            let cluster = TaskCluster(
                id: "cluster_\(UUID().uuidString.prefix(8))",
                tasks: clusterTasks,
                centerLatitude: centerLat,
                centerLongitude: centerLon,
                totalPayment: totalPayment,
                estimatedTotalDuration: "\(clusterTasks.count * 30 + walkingTime) min",
                walkingDistanceBetween: walkingDistance,
                walkingTimeBetween: walkingTime
            )
            
            clusters.append(cluster)
        }
        
        return clusters.sorted { $0.taskCount > $1.taskCount }
    }
    
    /// Dismiss a recommendation
    func dismissRecommendation(_ id: String) {
        if currentRecommendation?.id == id {
            currentRecommendation = nil
        }
        recentRecommendations.removeAll { $0.id == id }
        
        print("[TaskBatching] Dismissed recommendation: \(id)")
    }
    
    /// Clear all recommendations
    func clearRecommendations() {
        currentRecommendation = nil
        recentRecommendations.removeAll()
    }
    
    // MARK: - Private Helpers
    
    private func estimateTotalTime(tasks: [HXTask], from userLocation: GPSCoordinates) -> String {
        // Base time for tasks (assume 30 min per task average)
        let taskTime = tasks.count * 30
        
        // Walking time between tasks (rough estimate)
        let walkingTime = (tasks.count - 1) * 10 // 10 min between each
        
        // Walking time to first task
        var toFirstTask = 0
        if let firstTask = tasks.first,
           let taskCoords = firstTask.gpsCoordinates {
            let distance = LocationService.current.calculateDistance(from: userLocation, to: taskCoords)
            toFirstTask = Int(distance / 1.39 / 60) // Walking at 1.39 m/s
        }
        
        let totalMinutes = taskTime + walkingTime + toFirstTask
        
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let mins = totalMinutes % 60
            return "\(hours)h \(mins)m"
        }
    }
    
    private func estimateWalkingBetween(tasks: [HXTask]) -> (distance: Double, time: Int) {
        guard tasks.count > 1 else { return (0, 0) }
        
        var totalDistance: Double = 0
        
        for i in 0..<(tasks.count - 1) {
            guard let from = tasks[i].gpsCoordinates,
                  let to = tasks[i + 1].gpsCoordinates else { continue }
            
            totalDistance += LocationService.current.calculateDistance(from: from, to: to)
        }
        
        // Walking speed: 1.39 m/s
        let timeSeconds = totalDistance / 1.39
        let timeMinutes = Int(timeSeconds / 60)
        
        return (totalDistance, timeMinutes)
    }
}
