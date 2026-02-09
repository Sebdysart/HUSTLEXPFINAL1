//
//  MockHeatMapService.swift
//  hustleXP final1
//
//  Mock Heat Map service for v1.9.0 - Generates task density heat zones
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
@Observable
final class MockHeatMapService {
    static let shared = MockHeatMapService()
    
    // MARK: - State
    
    var heatZones: [HeatZone] = []
    var isLoading: Bool = false
    var lastUpdated: Date?
    
    // MARK: - SF Neighborhood Data
    
    private let sfNeighborhoods: [(name: String, lat: Double, lon: Double)] = [
        ("Downtown", 37.7749, -122.4194),
        ("Mission", 37.7599, -122.4148),
        ("Castro", 37.7609, -122.4350),
        ("SOMA", 37.7785, -122.3950),
        ("Marina", 37.8015, -122.4367),
        ("Noe Valley", 37.7502, -122.4337),
        ("Pacific Heights", 37.7925, -122.4382),
        ("Haight", 37.7692, -122.4481)
    ]
    
    // MARK: - Initialization
    
    private init() {
        // Generate initial mock heat zones
        heatZones = generateMockHeatZones()
    }
    
    // MARK: - Public Methods
    
    /// Generate heat zones from task locations
    func generateHeatZones(from tasks: [HXTask]) -> [HeatZone] {
        var zones: [HeatZone] = []
        
        // Group tasks by neighborhood proximity
        for (index, neighborhood) in sfNeighborhoods.enumerated() {
            let center = CLLocation(latitude: neighborhood.lat, longitude: neighborhood.lon)
            
            // Count tasks within 500m of neighborhood center
            let nearbyTasks = tasks.filter { task in
                guard let lat = task.latitude, let lon = task.longitude else { return false }
                let taskLocation = CLLocation(latitude: lat, longitude: lon)
                return center.distance(from: taskLocation) < 500
            }
            
            if !nearbyTasks.isEmpty {
                let avgPayment = nearbyTasks.reduce(0) { $0 + $1.payment } / Double(nearbyTasks.count)
                let intensity = HeatIntensity.from(taskCount: nearbyTasks.count)
                
                let zone = HeatZone(
                    id: "heat_zone_\(index)",
                    name: neighborhood.name,
                    centerLatitude: neighborhood.lat,
                    centerLongitude: neighborhood.lon,
                    radiusMeters: 400,
                    intensity: intensity,
                    taskCount: nearbyTasks.count,
                    averagePayment: avgPayment,
                    lastUpdated: Date()
                )
                zones.append(zone)
            }
        }
        
        heatZones = zones
        lastUpdated = Date()
        return zones
    }
    
    /// Get heat zone at a specific coordinate
    func getHeatZone(at coordinate: CLLocationCoordinate2D) -> HeatZone? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return heatZones.first { zone in
            let zoneCenter = CLLocation(latitude: zone.centerLatitude, longitude: zone.centerLongitude)
            return location.distance(from: zoneCenter) <= zone.radiusMeters
        }
    }
    
    /// Refresh heat data from tasks
    func refreshHeatData(from tasks: [HXTask]) async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        _ = generateHeatZones(from: tasks)
        isLoading = false
    }
    
    /// Get color for a heat zone
    func getIntensityColor(for zone: HeatZone) -> Color {
        zone.intensity.color
    }
    
    /// Generate mock heat zones for demo purposes
    func generateMockHeatZones() -> [HeatZone] {
        // Create varied mock data for each neighborhood
        let mockTaskCounts = [3, 8, 2, 6, 1, 4, 5, 2]
        let mockAvgPayments = [25.0, 45.0, 30.0, 55.0, 20.0, 35.0, 40.0, 28.0]
        
        return sfNeighborhoods.enumerated().map { index, neighborhood in
            let taskCount = mockTaskCounts[index % mockTaskCounts.count]
            let avgPayment = mockAvgPayments[index % mockAvgPayments.count]
            let intensity = HeatIntensity.from(taskCount: taskCount)
            
            return HeatZone(
                id: "heat_zone_\(index)",
                name: neighborhood.name,
                centerLatitude: neighborhood.lat,
                centerLongitude: neighborhood.lon,
                radiusMeters: 400,
                intensity: intensity,
                taskCount: taskCount,
                averagePayment: avgPayment,
                lastUpdated: Date()
            )
        }
    }
    
    /// Get the hottest zones (sorted by task count)
    func getHottestZones(limit: Int = 3) -> [HeatZone] {
        return heatZones
            .sorted { $0.taskCount > $1.taskCount }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get zones with high-paying tasks
    func getHighPayingZones(minAveragePayment: Double = 40) -> [HeatZone] {
        return heatZones.filter { $0.averagePayment >= minAveragePayment }
    }
}
