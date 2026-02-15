//
//  BiometricService.swift
//  hustleXP final1
//
//  Real tRPC service for biometric proof verification
//  Maps to backend biometric.ts router
//

import Foundation
import Combine

// MARK: - Biometric Types

struct BiometricProofInput: Codable {
    let proofId: String
    let taskId: String
    let photoUrl: String
    let gpsCoordinates: GPSPoint
    let gpsAccuracyMeters: Double
    let gpsTimestamp: String
    let taskLocation: GPSPoint
    let lidarDepthMapUrl: String?
    let timeLockHash: String
    let submissionTimestamp: String

    struct GPSPoint: Codable {
        let latitude: Double
        let longitude: Double
    }

    // Map to snake_case for backend
    enum CodingKeys: String, CodingKey {
        case proofId = "proof_id"
        case taskId = "task_id"
        case photoUrl = "photo_url"
        case gpsCoordinates = "gps_coordinates"
        case gpsAccuracyMeters = "gps_accuracy_meters"
        case gpsTimestamp = "gps_timestamp"
        case taskLocation = "task_location"
        case lidarDepthMapUrl = "lidar_depth_map_url"
        case timeLockHash = "time_lock_hash"
        case submissionTimestamp = "submission_timestamp"
    }
}

struct BiometricVerificationResult: Codable {
    let success: Bool
    let recommendation: String // "approve", "manual_review", "reject"
    let flags: [String]
    let biometricScores: BiometricScores?
    let gpsValidation: GPSValidation?
    let impossibleTravel: ImpossibleTravel?
    let timeLock: TimeLockResult?
    let reasoning: String?

    struct BiometricScores: Codable {
        let livenessScore: Double?
        let deepfakeScore: Double?
    }

    struct GPSValidation: Codable {
        let passed: Bool
        let distanceMeters: Double?
        let riskLevel: String?

        enum CodingKeys: String, CodingKey {
            case passed
            case distanceMeters = "distance_meters"
            case riskLevel = "risk_level"
        }
    }

    struct ImpossibleTravel: Codable {
        let flagged: Bool
        let speedKmh: Double?

        enum CodingKeys: String, CodingKey {
            case flagged
            case speedKmh = "speed_kmh"
        }
    }

    struct TimeLockResult: Codable {
        let passed: Bool
        let timeDeltaSeconds: Double?

        enum CodingKeys: String, CodingKey {
            case passed
            case timeDeltaSeconds = "time_delta_seconds"
        }
    }

    enum CodingKeys: String, CodingKey {
        case success, recommendation, flags, reasoning
        case biometricScores = "biometric_scores"
        case gpsValidation = "gps_validation"
        case impossibleTravel = "impossible_travel"
        case timeLock = "time_lock"
    }
}

struct FaceAnalysisResult: Codable {
    let livenessScore: Double
    let deepfakeScore: Double
    let recommendation: String
    let flags: [String]
}

// MARK: - Biometric Service

/// Handles biometric proof verification via tRPC
@MainActor
final class BiometricService: ObservableObject {
    static let shared = BiometricService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Submit biometric proof for full validation (liveness, GPS, time-lock)
    func submitBiometricProof(_ input: BiometricProofInput) async throws -> BiometricVerificationResult {
        isLoading = true
        defer { isLoading = false }

        let result: BiometricVerificationResult = try await trpc.call(
            router: "biometric",
            procedure: "submitBiometricProof",
            input: input
        )

        print("✅ BiometricService: Verification result: \(result.recommendation), flags: \(result.flags)")
        return result
    }

    /// Analyze a face photo only (for profile verification)
    func analyzeFacePhoto(photoUrl: String) async throws -> FaceAnalysisResult {
        isLoading = true
        defer { isLoading = false }

        struct PhotoInput: Codable {
            let photoUrl: String

            enum CodingKeys: String, CodingKey {
                case photoUrl = "photo_url"
            }
        }

        let result: FaceAnalysisResult = try await trpc.call(
            router: "biometric",
            procedure: "analyzeFacePhoto",
            input: PhotoInput(photoUrl: photoUrl)
        )

        print("✅ BiometricService: Face analysis - liveness: \(result.livenessScore)")
        return result
    }
}
