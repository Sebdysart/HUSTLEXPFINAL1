//
//  RealLocationService.swift
//  hustleXP final1
//
//  Real GPS location service using CoreLocation for production builds
//

import Foundation
import CoreLocation

@MainActor
@Observable
final class RealLocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    static let shared = RealLocationService()

    private let locationManager = CLLocationManager()
    var currentLocation: GPSCoordinates?
    var currentAccuracy: Double = 0
    var isCapturing: Bool = false
    var captureTimestamp: Date?

    private var locationContinuation: CheckedContinuation<(coordinates: GPSCoordinates, accuracy: Double), Never>?

    // MARK: - Fallback Mock Locations (for getMockTaskLocation)

    private let fallbackLocations: [(name: String, coords: GPSCoordinates)] = [
        ("Downtown SF", GPSCoordinates(latitude: 37.7749, longitude: -122.4194)),
        ("Mission District", GPSCoordinates(latitude: 37.7599, longitude: -122.4148)),
        ("Castro", GPSCoordinates(latitude: 37.7609, longitude: -122.4350)),
        ("SOMA", GPSCoordinates(latitude: 37.7785, longitude: -122.3950)),
        ("Marina", GPSCoordinates(latitude: 37.8015, longitude: -122.4367)),
        ("Noe Valley", GPSCoordinates(latitude: 37.7502, longitude: -122.4337)),
        ("Pacific Heights", GPSCoordinates(latitude: 37.7925, longitude: -122.4382)),
        ("Haight-Ashbury", GPSCoordinates(latitude: 37.7692, longitude: -122.4481))
    ]

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }

    // MARK: - Permission

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Capture Location (Async)

    func captureLocation() async -> (coordinates: GPSCoordinates, accuracy: Double) {
        isCapturing = true

        // If we already have a recent location (within 5 seconds), return it immediately
        if let current = currentLocation,
           let timestamp = captureTimestamp,
           Date().timeIntervalSince(timestamp) < 5.0 {
            isCapturing = false
            print("[RealLocation] Using cached location (age: \(String(format: "%.1f", Date().timeIntervalSince(timestamp)))s)")
            return (coordinates: current, accuracy: currentAccuracy)
        }

        // Request a fresh location update
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Use continuation to bridge delegate callback to async/await
        let result = await withCheckedContinuation { (continuation: CheckedContinuation<(coordinates: GPSCoordinates, accuracy: Double), Never>) in
            self.locationContinuation = continuation
        }

        isCapturing = false
        locationManager.stopUpdatingLocation()

        print("[RealLocation] Captured: (\(String(format: "%.4f", result.coordinates.latitude)), \(String(format: "%.4f", result.coordinates.longitude))) (+-\(String(format: "%.1f", result.accuracy))m)")

        return result
    }

    // MARK: - Synchronous Location

    func getCurrentLocation() -> Result<GPSCoordinates, LocationError> {
        // Check authorization status
        let status = locationManager.authorizationStatus
        switch status {
        case .denied, .restricted:
            return .failure(.permissionDenied)
        case .notDetermined:
            requestPermission()
            return .failure(.locationUnavailable)
        default:
            break
        }

        // Return cached location if available
        if let current = currentLocation {
            print("[RealLocation] Returning cached location (+-\(String(format: "%.1f", currentAccuracy))m)")
            return .success(current)
        }

        // No cached location available - start updates and return error
        locationManager.startUpdatingLocation()
        return .failure(.locationUnavailable)
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            let coords = GPSCoordinates(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                accuracyMeters: location.horizontalAccuracy,
                timestamp: location.timestamp
            )

            currentLocation = coords
            currentAccuracy = location.horizontalAccuracy
            captureTimestamp = location.timestamp

            // Resolve any pending continuation
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(returning: (coordinates: coords, accuracy: location.horizontalAccuracy))
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[RealLocation] Location error: \(error.localizedDescription)")

        Task { @MainActor in
            isCapturing = false

            // If there's a pending continuation, provide a fallback
            if let continuation = locationContinuation {
                locationContinuation = nil
                // Use last known location or a default
                let fallback = currentLocation ?? GPSCoordinates(
                    latitude: 37.7749,
                    longitude: -122.4194,
                    accuracyMeters: 1000,
                    timestamp: Date()
                )
                continuation.resume(returning: (coordinates: fallback, accuracy: fallback.accuracyMeters))
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                print("[RealLocation] Location permission denied")
            default:
                break
            }
        }
    }

    // MARK: - Mock Task Location (Fallback)

    func getMockTaskLocation(for taskId: String) -> CLLocationCoordinate2D {
        // Use task ID hash to consistently return same location for same task
        let hash = abs(taskId.hashValue)
        let index = hash % fallbackLocations.count
        return fallbackLocations[index].coords.clLocationCoordinate
    }

    // MARK: - SF Neighborhoods

    var sfNeighborhoods: [(name: String, coords: GPSCoordinates)] {
        fallbackLocations
    }

    // MARK: - Walking ETA & Distance

    func calculateWalkingETA(from: GPSCoordinates, to: GPSCoordinates) -> WalkingETA {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distance = fromLocation.distance(from: toLocation)

        // Walking speed: 5 km/h = 1.39 m/s
        let walkingSpeed = 1.39
        let duration = Int(distance / walkingSpeed)

        return WalkingETA(
            distanceMeters: distance,
            durationSeconds: duration,
            route: generateRoute(from: from, to: to),
            calculatedAt: Date()
        )
    }

    /// Generate walking route points between two locations
    private func generateRoute(from: GPSCoordinates, to: GPSCoordinates, steps: Int = 10) -> WalkingRoute {
        var points: [GPSCoordinates] = []
        let latStep = (to.latitude - from.latitude) / Double(steps)
        let lonStep = (to.longitude - from.longitude) / Double(steps)

        for i in 0...steps {
            let jitter = Double.random(in: -0.0001...0.0001)
            let point = GPSCoordinates(
                latitude: from.latitude + (latStep * Double(i)) + jitter,
                longitude: from.longitude + (lonStep * Double(i)) + jitter
            )
            points.append(point)
        }

        return WalkingRoute(polylinePoints: points, instructions: nil)
    }

    func sortTasksByDistance(tasks: [HXTask], from location: GPSCoordinates) -> [HXTask] {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return tasks
            .filter { $0.hasCoordinates }
            .sorted { task1, task2 in
                let dist1 = task1.distance(from: userLocation) ?? Double.infinity
                let dist2 = task2.distance(from: userLocation) ?? Double.infinity
                return dist1 < dist2
            }
    }

    func getTasksWithinRadius(tasks: [HXTask], from location: GPSCoordinates, radiusMeters: Double) -> [HXTask] {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return tasks.filter { task in
            guard let distance = task.distance(from: userLocation) else { return false }
            return distance <= radiusMeters
        }
    }

    func calculateDistance(from: GPSCoordinates, to: GPSCoordinates) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    // MARK: - Validation

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
