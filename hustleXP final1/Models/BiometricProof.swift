//
//  BiometricProof.swift
//  hustleXP final1
//
//  Biometric Proof Submission models for v1.8.0
//

import Foundation
import CoreLocation

// MARK: - GPS Coordinates

struct GPSCoordinates: Codable {
    let latitude: Double
    let longitude: Double
    let accuracyMeters: Double
    let timestamp: Date
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, accuracyMeters: Double = 10.0, timestamp: Date = Date()) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracyMeters = accuracyMeters
        self.timestamp = timestamp
    }
    
    init(coordinate: CLLocationCoordinate2D, accuracyMeters: Double = 10.0, timestamp: Date = Date()) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.accuracyMeters = accuracyMeters
        self.timestamp = timestamp
    }
}

// MARK: - Biometric Proof Submission

struct BiometricProofSubmission: Codable {
    let proofId: String
    let photoURL: URL?
    let gpsCoordinates: GPSCoordinates
    let gpsAccuracyMeters: Double
    let gpsTimestamp: Date
    let deviceModel: String
    let osVersion: String
    
    /// Formatted GPS accuracy
    var formattedAccuracy: String {
        String(format: "±%.1fm", gpsAccuracyMeters)
    }
}

// MARK: - Validation Scores

struct ValidationScores: Codable {
    let liveness: Int       // 0-100 (>70 = pass)
    let deepfake: Int       // 0-100 (<80 = pass, inverted)
    let gpsProximity: Int   // 0-100 (distance-based)
    
    var livenessPass: Bool { liveness > 70 }
    var deepfakePass: Bool { deepfake < 80 }
    var gpsProximityPass: Bool { gpsProximity > 60 }
}

// MARK: - Validation Recommendation

enum ValidationRecommendation: String, Codable {
    case approve
    case manualReview = "manual_review"
    case reject
    
    var displayName: String {
        switch self {
        case .approve: return "Approved"
        case .manualReview: return "Under Review"
        case .reject: return "Rejected"
        }
    }
    
    var icon: String {
        switch self {
        case .approve: return "checkmark.circle.fill"
        case .manualReview: return "clock.fill"
        case .reject: return "xmark.circle.fill"
        }
    }
}

// MARK: - Risk Level

enum RiskLevel: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }
}

// MARK: - Biometric Validation Result

struct BiometricValidationResult: Codable {
    let recommendation: ValidationRecommendation
    let reasoning: String
    let flags: [String]
    let scores: ValidationScores
    let riskLevel: RiskLevel
    
    /// Whether the proof passed all validation checks
    var isApproved: Bool {
        recommendation == .approve
    }
    
    /// Whether manual review is required
    var needsReview: Bool {
        recommendation == .manualReview
    }
    
    /// Whether the proof was rejected
    var isRejected: Bool {
        recommendation == .reject
    }
}

// MARK: - Validation Flag

struct ValidationFlag: Identifiable {
    let id = UUID()
    let code: String
    let displayName: String
    
    static func fromCode(_ code: String) -> ValidationFlag {
        let displayName: String
        switch code {
        case "low_accuracy":
            displayName = "Low GPS Accuracy"
        case "impossible_travel":
            displayName = "Impossible Travel"
        case "weak_liveness":
            displayName = "Weak Liveness"
        case "potential_deepfake":
            displayName = "Potential Deepfake"
        case "gps_mismatch":
            displayName = "GPS Mismatch"
        case "timestamp_mismatch":
            displayName = "Time Mismatch"
        default:
            displayName = code.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return ValidationFlag(code: code, displayName: displayName)
    }
}
