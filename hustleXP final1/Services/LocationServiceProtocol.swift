//
//  LocationServiceProtocol.swift
//  hustleXP final1
//
//  Protocol for GPS location services - enables switching between mock and real implementations
//

import Foundation
import CoreLocation

// MARK: - Location Service Protocol

@MainActor
protocol LocationServiceProtocol: AnyObject {
    var currentLocation: GPSCoordinates? { get }
    var currentAccuracy: Double { get }
    var isCapturing: Bool { get }
    var captureTimestamp: Date? { get }

    /// Capture current GPS location asynchronously
    func captureLocation() async -> (coordinates: GPSCoordinates, accuracy: Double)

    /// Synchronous location fetch returning Result
    func getCurrentLocation() -> Result<GPSCoordinates, LocationError>

    /// Get a fallback/mock task location for a given task ID
    func getMockTaskLocation(for taskId: String) -> CLLocationCoordinate2D

    /// Calculate walking ETA between two points
    func calculateWalkingETA(from: GPSCoordinates, to: GPSCoordinates) -> WalkingETA

    /// Calculate distance between two coordinates in meters
    func calculateDistance(from: GPSCoordinates, to: GPSCoordinates) -> Double

    /// Sort tasks by proximity to a location
    func sortTasksByDistance(tasks: [HXTask], from: GPSCoordinates) -> [HXTask]

    /// Filter tasks within a radius
    func getTasksWithinRadius(tasks: [HXTask], from: GPSCoordinates, radiusMeters: Double) -> [HXTask]

    /// Validate proximity between proof and task coordinates
    func validateProximity(proofCoords: GPSCoordinates, taskCoords: GPSCoordinates, maxDistanceMeters: Double) -> (isValid: Bool, distanceMeters: Double)

    /// Generate a validation result for a proof submission
    func generateMockValidation(proofCoords: GPSCoordinates, taskCoords: GPSCoordinates?, accuracy: Double) -> BiometricValidationResult

    /// SF neighborhoods data for heat map / live mode
    var sfNeighborhoods: [(name: String, coords: GPSCoordinates)] { get }
}
