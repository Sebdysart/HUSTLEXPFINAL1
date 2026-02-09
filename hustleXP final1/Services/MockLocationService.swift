//
//  MockLocationService.swift
//  hustleXP final1
//
//  Mock GPS location service for v1.8.0 prototyping
//

import Foundation
import CoreLocation

@MainActor
@Observable
final class MockLocationService {
    static let shared = MockLocationService()
    
    // MARK: - Mock State
    
    var currentLocation: GPSCoordinates?
    var currentAccuracy: Double = 0
    var isCapturing: Bool = false
    var captureTimestamp: Date?
    
    // MARK: - San Francisco Area Mock Locations
    
    private let mockLocations: [(name: String, coords: GPSCoordinates)] = [
        ("Downtown SF", GPSCoordinates(latitude: 37.7749, longitude: -122.4194)),
        ("Mission District", GPSCoordinates(latitude: 37.7599, longitude: -122.4148)),
        ("Castro", GPSCoordinates(latitude: 37.7609, longitude: -122.4350)),
        ("SOMA", GPSCoordinates(latitude: 37.7785, longitude: -122.3950)),
        ("Marina", GPSCoordinates(latitude: 37.8015, longitude: -122.4367)),
        ("Noe Valley", GPSCoordinates(latitude: 37.7502, longitude: -122.4337)),
        ("Pacific Heights", GPSCoordinates(latitude: 37.7925, longitude: -122.4382)),
        ("Haight-Ashbury", GPSCoordinates(latitude: 37.7692, longitude: -122.4481))
    ]
    
    // MARK: - Mock Accuracy Ranges
    
    private let accuracyRanges: [(range: ClosedRange<Double>, weight: Double)] = [
        (5.0...10.0, 0.4),   // Good accuracy (40% of the time)
        (10.0...25.0, 0.35), // Medium accuracy (35% of the time)
        (25.0...50.0, 0.15), // Poor accuracy (15% of the time)
        (50.0...100.0, 0.1)  // Very poor accuracy (10% of the time)
    ]
    
    // MARK: - Public Methods
    
    /// Simulate capturing current GPS location
    func captureLocation() async -> (coordinates: GPSCoordinates, accuracy: Double) {
        isCapturing = true
        
        // Simulate GPS acquisition delay (0.5-2 seconds)
        let delay = Double.random(in: 0.5...2.0)
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Pick a random mock location
        let location = mockLocations.randomElement()!
        
        // Add slight random offset to coordinates (within ~100m)
        let latOffset = Double.random(in: -0.001...0.001)
        let lonOffset = Double.random(in: -0.001...0.001)
        let coordinates = GPSCoordinates(
            latitude: location.coords.latitude + latOffset,
            longitude: location.coords.longitude + lonOffset
        )
        
        // Generate random accuracy
        let accuracy = generateRandomAccuracy()
        
        // Update state
        currentLocation = coordinates
        currentAccuracy = accuracy
        captureTimestamp = Date()
        isCapturing = false
        
        print("[MockLocation] Captured: \(location.name) (±\(String(format: "%.1f", accuracy))m)")
        
        return (coordinates, accuracy)
    }
    
    /// Get a specific mock location by index (for testing)
    func getMockLocation(index: Int) -> GPSCoordinates {
        let safeIndex = index % mockLocations.count
        return mockLocations[safeIndex].coords
    }
    
    /// Reset the service state
    func reset() {
        currentLocation = nil
        currentAccuracy = 0
        captureTimestamp = nil
        isCapturing = false
    }
    
    // MARK: - Private Methods
    
    private func generateRandomAccuracy() -> Double {
        let random = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for (range, weight) in accuracyRanges {
            cumulative += weight
            if random <= cumulative {
                return Double.random(in: range)
            }
        }
        
        return Double.random(in: accuracyRanges[0].range)
    }
}

// MARK: - Mock Validation

extension MockLocationService {
    
    /// Validate GPS coordinates against task location
    func validateProximity(
        proofCoords: GPSCoordinates,
        taskCoords: GPSCoordinates,
        maxDistanceMeters: Double = 500
    ) -> (isValid: Bool, distanceMeters: Double) {
        let proofLocation = CLLocation(
            latitude: proofCoords.latitude,
            longitude: proofCoords.longitude
        )
        let taskLocation = CLLocation(
            latitude: taskCoords.latitude,
            longitude: taskCoords.longitude
        )
        
        let distance = proofLocation.distance(from: taskLocation)
        return (distance <= maxDistanceMeters, distance)
    }
    
    /// Generate a mock validation result for a proof submission
    func generateMockValidation(
        proofCoords: GPSCoordinates,
        taskCoords: GPSCoordinates?,
        accuracy: Double
    ) -> BiometricValidationResult {
        var flags: [String] = []
        var riskLevel: RiskLevel = .low
        var recommendation: ValidationRecommendation = .approve
        
        // Check accuracy
        if accuracy > 50 {
            flags.append("low_accuracy")
            riskLevel = .medium
        }
        
        // Check proximity if task has coordinates
        if let taskCoords = taskCoords {
            let (isNear, distance) = validateProximity(
                proofCoords: proofCoords,
                taskCoords: taskCoords
            )
            
            if !isNear {
                flags.append("gps_mismatch")
                riskLevel = .high
                recommendation = .manualReview
            } else if distance > 200 {
                flags.append("gps_mismatch")
                riskLevel = .medium
            }
        }
        
        // Generate scores
        let livenessScore = Int.random(in: 75...95)
        let deepfakeScore = Int.random(in: 10...40)
        let gpsScore = accuracy < 20 ? Int.random(in: 85...100) :
                       accuracy < 50 ? Int.random(in: 65...85) :
                       Int.random(in: 40...65)
        
        if livenessScore < 70 {
            flags.append("weak_liveness")
            recommendation = .manualReview
        }
        
        if deepfakeScore > 80 {
            flags.append("potential_deepfake")
            riskLevel = .critical
            recommendation = .reject
        }
        
        let scores = ValidationScores(
            liveness: livenessScore,
            deepfake: deepfakeScore,
            gpsProximity: gpsScore
        )
        
        let reasoning: String
        switch recommendation {
        case .approve:
            reasoning = "All validation checks passed. Proof looks authentic."
        case .manualReview:
            reasoning = "Some validation flags raised. Manual review required."
        case .reject:
            reasoning = "Validation failed. Please retake the proof photo at the task location."
        }
        
        return BiometricValidationResult(
            recommendation: recommendation,
            reasoning: reasoning,
            flags: flags,
            scores: scores,
            riskLevel: riskLevel
        )
    }
}
