//
//  SpatialIntelligence.swift
//  hustleXP final1
//
//  Spatial Intelligence models for v1.9.0 - Heat Maps, Geofencing, Task Batching, Movement Tracking
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Heat Zone

/// Represents a geographic zone with task density information
struct HeatZone: Identifiable, Codable {
    let id: String
    let name: String
    let centerLatitude: Double
    let centerLongitude: Double
    let radiusMeters: Double
    let intensity: HeatIntensity
    let taskCount: Int
    let averagePayment: Double
    let lastUpdated: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }
    
    var formattedAveragePayment: String {
        "$\(String(format: "%.0f", averagePayment))"
    }
}

/// Heat intensity levels based on task density
enum HeatIntensity: String, Codable, CaseIterable {
    case low = "LOW"           // 1-2 tasks
    case medium = "MEDIUM"     // 3-4 tasks
    case high = "HIGH"         // 5-7 tasks
    case hot = "HOT"           // 8+ tasks
    
    var color: Color {
        switch self {
        case .low: return Color.heatLow
        case .medium: return Color.heatMedium
        case .high: return Color.heatHigh
        case .hot: return Color.heatHot
        }
    }
    
    var glowOpacity: Double {
        switch self {
        case .low: return 0.2
        case .medium: return 0.35
        case .high: return 0.5
        case .hot: return 0.7
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low Activity"
        case .medium: return "Moderate"
        case .high: return "Busy"
        case .hot: return "Hot Zone"
        }
    }
    
    static func from(taskCount: Int) -> HeatIntensity {
        switch taskCount {
        case 0...2: return .low
        case 3...4: return .medium
        case 5...7: return .high
        default: return .hot
        }
    }
}

// MARK: - Geofence Region

/// Represents a geofenced area for Smart Start functionality
struct GeofenceRegion: Identifiable, Codable, Hashable {
    let id: String
    let taskId: String
    let centerLatitude: Double
    let centerLongitude: Double
    let radiusMeters: Double
    let isActive: Bool
    let createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }
    
    var region: CLCircularRegion {
        CLCircularRegion(
            center: coordinate,
            radius: radiusMeters,
            identifier: id
        )
    }
    
    static func forTask(_ task: HXTask, radius: Double = 50) -> GeofenceRegion? {
        guard let lat = task.latitude, let lon = task.longitude else { return nil }
        return GeofenceRegion(
            id: "geofence_\(task.id)",
            taskId: task.id,
            centerLatitude: lat,
            centerLongitude: lon,
            radiusMeters: radius,
            isActive: true,
            createdAt: Date()
        )
    }
}

/// Geofence crossing events
enum GeofenceEvent: String, Codable {
    case entered = "ENTERED"
    case exited = "EXITED"
    case dwelling = "DWELLING"   // Inside for > 30 seconds
}

// MARK: - Task Cluster

/// A group of nearby tasks for batching recommendations
struct TaskCluster: Identifiable {
    let id: String
    let tasks: [HXTask]
    let centerLatitude: Double
    let centerLongitude: Double
    let totalPayment: Double
    let estimatedTotalDuration: String
    let walkingDistanceBetween: Double  // meters
    let walkingTimeBetween: Int          // minutes
    
    var taskCount: Int { tasks.count }
    
    var formattedPayment: String {
        "$\(String(format: "%.0f", totalPayment))"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }
}

// MARK: - Movement Tracking

/// A session tracking GPS movement during task execution
struct MovementTrackingSession: Identifiable, Codable {
    let id: String
    let taskId: String
    let hustlerId: String
    let startedAt: Date
    var locations: [TrackedLocation]
    var status: MovementStatus
    var flags: [MovementFlag]
    
    var totalDistanceMeters: Double {
        guard locations.count > 1 else { return 0 }
        var total: Double = 0
        for i in 1..<locations.count {
            let prev = CLLocation(latitude: locations[i-1].latitude, longitude: locations[i-1].longitude)
            let curr = CLLocation(latitude: locations[i].latitude, longitude: locations[i].longitude)
            total += curr.distance(from: prev)
        }
        return total
    }
    
    var averageSpeed: Double {  // m/s
        guard locations.count > 1,
              let first = locations.first,
              let last = locations.last else { return 0 }
        let timeElapsed = last.timestamp.timeIntervalSince(first.timestamp)
        guard timeElapsed > 0 else { return 0 }
        return totalDistanceMeters / timeElapsed
    }
    
    var isStationary: Bool {
        // Check if no significant movement in last 10 minutes
        guard locations.count > 2 else { return false }
        let recentLocations = locations.suffix(20) // Last ~10 min at 30s intervals
        var maxDistance: Double = 0
        let firstRecent = recentLocations.first!
        let firstLoc = CLLocation(latitude: firstRecent.latitude, longitude: firstRecent.longitude)
        
        for loc in recentLocations {
            let curr = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            maxDistance = max(maxDistance, curr.distance(from: firstLoc))
        }
        return maxDistance < 20 // Less than 20m movement
    }
    
    var durationFormatted: String {
        guard let first = locations.first else { return "0 min" }
        let elapsed = Date().timeIntervalSince(first.timestamp)
        let minutes = Int(elapsed / 60)
        if minutes < 60 {
            return "\(minutes) min"
        }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

/// A single tracked GPS location point
struct TrackedLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracyMeters: Double
    let speedMps: Double?         // meters per second
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Movement tracking status
enum MovementStatus: String, Codable {
    case active = "ACTIVE"
    case stationary = "STATIONARY"
    case suspicious = "SUSPICIOUS"
    case completed = "COMPLETED"
    
    var color: Color {
        switch self {
        case .active: return .successGreen
        case .stationary: return .warningOrange
        case .suspicious: return .errorRed
        case .completed: return .textSecondary
        }
    }
}

/// Flags indicating potential fraud or anomalies
enum MovementFlag: String, Codable, CaseIterable {
    case stationaryTooLong = "STATIONARY_TOO_LONG"    // > 10 min no movement
    case impossibleSpeed = "IMPOSSIBLE_SPEED"          // > 100 km/h on foot
    case locationJump = "LOCATION_JUMP"                // Teleportation detected
    case lowAccuracy = "LOW_ACCURACY"                  // Consistent poor GPS
    
    var displayName: String {
        switch self {
        case .stationaryTooLong: return "No Movement"
        case .impossibleSpeed: return "Speed Anomaly"
        case .locationJump: return "Location Jump"
        case .lowAccuracy: return "Poor GPS"
        }
    }
    
    var icon: String {
        switch self {
        case .stationaryTooLong: return "pause.circle.fill"
        case .impossibleSpeed: return "speedometer"
        case .locationJump: return "arrow.triangle.swap"
        case .lowAccuracy: return "location.slash.fill"
        }
    }
}

// MARK: - Walking ETA

/// Walking distance and time estimate between two points
struct WalkingETA: Codable {
    let distanceMeters: Double
    let durationSeconds: Int
    let route: WalkingRoute?
    let calculatedAt: Date
    
    var formattedDistance: String {
        let miles = distanceMeters / 1609.34
        if miles < 0.1 {
            return "\(Int(distanceMeters))m"
        }
        return String(format: "%.1f mi", miles)
    }
    
    var formattedDuration: String {
        let minutes = durationSeconds / 60
        if minutes < 1 {
            return "<1 min"
        } else if minutes == 1 {
            return "1 min walk"
        }
        return "\(minutes) min walk"
    }
    
    var shortDuration: String {
        let minutes = durationSeconds / 60
        return minutes < 1 ? "<1m" : "\(minutes)m"
    }
}

/// A walking route with waypoints
struct WalkingRoute: Codable {
    let polylinePoints: [GPSCoordinates]
    let instructions: [String]?
}

// MARK: - Task Batching Recommendation

/// A recommendation to batch multiple nearby tasks
struct BatchRecommendation: Identifiable {
    let id: String
    let primaryTask: HXTask
    let nearbyTasks: [HXTask]
    let totalPayment: Double
    let totalEstimatedTime: String
    let savings: BatchSavings
    let expiresAt: Date?
    
    var allTasks: [HXTask] {
        [primaryTask] + nearbyTasks
    }
    
    var taskCount: Int {
        allTasks.count
    }
    
    var formattedTotalPayment: String {
        "$\(String(format: "%.0f", totalPayment))"
    }
}

/// Savings from batching tasks
struct BatchSavings: Codable {
    let timeSavedMinutes: Int
    let extraEarnings: Double
    let efficiencyBoost: Double  // percentage (e.g., 25.0 for 25%)
    
    var formattedTimeSaved: String {
        "\(timeSavedMinutes) min saved"
    }
    
    var formattedExtraEarnings: String {
        "+$\(String(format: "%.0f", extraEarnings))"
    }
    
    var formattedEfficiencyBoost: String {
        "+\(Int(efficiencyBoost))%"
    }
}

// MARK: - Movement Summary

/// Summary of a movement tracking session
struct MovementSummary {
    let totalDistance: Double
    let totalTime: TimeInterval
    let averageSpeed: Double
    let stationaryPeriods: Int
    let flags: [MovementFlag]
    let riskLevel: RiskLevel
    
    var formattedDistance: String {
        let miles = totalDistance / 1609.34
        if miles < 0.1 {
            return "\(Int(totalDistance))m"
        }
        return String(format: "%.1f mi", miles)
    }
    
    var formattedSpeed: String {
        // Convert m/s to mph
        let mph = averageSpeed * 2.237
        return String(format: "%.1f mph", mph)
    }
    
    var formattedTime: String {
        let minutes = Int(totalTime / 60)
        if minutes < 60 {
            return "\(minutes) min"
        }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

// MARK: - HXTask Spatial Extensions

extension HXTask {
    /// Whether this task has valid coordinates
    var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }
    
    /// Get CLLocationCoordinate2D if coordinates exist
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    /// Get GPSCoordinates if coordinates exist
    var gpsCoordinates: GPSCoordinates? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return GPSCoordinates(latitude: lat, longitude: lon)
    }
    
    /// Calculate distance from a location
    func distance(from location: CLLocation) -> Double? {
        guard let coord = coordinate else { return nil }
        let taskLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return location.distance(from: taskLocation)
    }
    
    /// Calculate distance from GPS coordinates
    func distance(from coords: GPSCoordinates) -> Double? {
        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        return distance(from: location)
    }
    
    /// Calculate walking ETA from a location
    func walkingETA(from location: CLLocation) -> WalkingETA? {
        guard let distance = distance(from: location) else { return nil }
        // Walking speed: ~5 km/h = ~1.39 m/s
        let walkingSpeed = 1.39
        let duration = Int(distance / walkingSpeed)
        return WalkingETA(
            distanceMeters: distance,
            durationSeconds: duration,
            route: nil,
            calculatedAt: Date()
        )
    }
}
