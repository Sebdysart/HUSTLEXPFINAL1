//
//  ProofService.swift
//  hustleXP final1
//
//  Handles proof photo uploads to Cloudflare R2
//  and proof submission workflow
//

import Foundation
import UIKit
import Combine

/// Proof submission record
struct ProofSubmission: Codable, Identifiable {
    let id: String
    let taskId: String
    let workerId: String
    let photoUrls: [String]
    let notes: String?
    let gpsLatitude: Double?
    let gpsLongitude: Double?
    let biometricHash: String?
    let submittedAt: Date
    let reviewedAt: Date?
    let approved: Bool?
    let reviewerFeedback: String?
}

/// Pre-signed URL response for R2 upload
struct PresignedUploadURL: Codable {
    let uploadUrl: String
    let publicUrl: String
    let key: String
    let expiresAt: Date
}

/// Manages proof photo uploads and submission
@MainActor
final class ProofService: ObservableObject {
    static let shared = ProofService()

    private let trpc = TRPCClient.shared

    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var error: Error?

    private init() {}

    // MARK: - Photo Upload to R2

    /// Gets a pre-signed URL for uploading a photo to Cloudflare R2
    func getUploadURL(
        taskId: String,
        filename: String,
        contentType: String = "image/jpeg"
    ) async throws -> PresignedUploadURL {
        struct GetURLInput: Codable {
            let taskId: String
            let filename: String
            let contentType: String
        }

        let response: PresignedUploadURL = try await trpc.call(
            router: "upload",
            procedure: "getPresignedUrl",
            input: GetURLInput(taskId: taskId, filename: filename, contentType: contentType)
        )

        HXLogger.info("ProofService: Got pre-signed URL for \(filename)", category: "Task")
        return response
    }

    /// Uploads an image to the pre-signed R2 URL
    func uploadImage(_ image: UIImage, to presignedURL: PresignedUploadURL) async throws -> String {
        isUploading = true
        uploadProgress = 0
        defer {
            isUploading = false
            uploadProgress = 1.0
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ProofError.imageCompressionFailed
        }

        guard let uploadURL = URL(string: presignedURL.uploadUrl) else {
            throw ProofError.uploadFailed
        }
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

        // Upload with progress tracking
        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProofError.uploadFailed
        }

        HXLogger.info("ProofService: Uploaded image to R2", category: "Task")
        return presignedURL.publicUrl
    }

    /// Convenience method: Gets URL and uploads image in one call
    func uploadProofPhoto(
        image: UIImage,
        taskId: String,
        photoIndex: Int
    ) async throws -> String {
        let filename = "proof_\(taskId)_\(photoIndex)_\(Int(Date().timeIntervalSince1970)).jpg"
        let presignedURL = try await getUploadURL(taskId: taskId, filename: filename)
        let publicUrl = try await uploadImage(image, to: presignedURL)
        return publicUrl
    }

    /// Uploads multiple proof photos
    func uploadProofPhotos(
        images: [UIImage],
        taskId: String
    ) async throws -> [String] {
        var uploadedUrls: [String] = []

        for (index, image) in images.enumerated() {
            uploadProgress = Double(index) / Double(images.count)
            let url = try await uploadProofPhoto(image: image, taskId: taskId, photoIndex: index)
            uploadedUrls.append(url)
        }

        uploadProgress = 1.0
        HXLogger.info("ProofService: Uploaded \(uploadedUrls.count) proof photos", category: "Task")
        return uploadedUrls
    }

    // MARK: - Proof Submission (routes to task.submitProof on backend)

    /// Submits proof with uploaded photo URLs
    func submitProof(
        taskId: String,
        photoUrls: [String],
        notes: String?,
        gpsLatitude: Double?,
        gpsLongitude: Double?,
        biometricHash: String?
    ) async throws -> ProofSubmission {
        struct SubmitInput: Codable {
            let taskId: String
            let photoUrls: [String]
            let notes: String?
            let gpsLatitude: Double?
            let gpsLongitude: Double?
            let biometricHash: String?
        }

        let input = SubmitInput(
            taskId: taskId,
            photoUrls: photoUrls,
            notes: notes,
            gpsLatitude: gpsLatitude,
            gpsLongitude: gpsLongitude,
            biometricHash: biometricHash
        )

        let proof: ProofSubmission = try await trpc.call(
            router: "task",
            procedure: "submitProof",
            input: input
        )

        HXLogger.info("ProofService: Submitted proof for task \(taskId)", category: "Task")
        return proof
    }

    /// Gets proof submission for a task
    func getProof(taskId: String) async throws -> ProofSubmission {
        struct GetInput: Codable {
            let taskId: String
        }

        let proof: ProofSubmission = try await trpc.call(
            router: "task",
            procedure: "getProof",
            type: .query,
            input: GetInput(taskId: taskId)
        )

        return proof
    }

    // MARK: - Proof Review (Poster) (routes to task.reviewProof on backend)

    /// Poster reviews submitted proof
    func reviewProof(
        taskId: String,
        approved: Bool,
        feedback: String?
    ) async throws -> ProofSubmission {
        struct ReviewInput: Codable {
            let taskId: String
            let approved: Bool
            let feedback: String?
        }

        let proof: ProofSubmission = try await trpc.call(
            router: "task",
            procedure: "reviewProof",
            input: ReviewInput(taskId: taskId, approved: approved, feedback: feedback)
        )

        HXLogger.info("ProofService: Reviewed proof for task \(taskId), approved: \(approved)", category: "Task")
        return proof
    }
}

// MARK: - Proof Errors

enum ProofError: Error, LocalizedError {
    case imageCompressionFailed
    case uploadFailed
    case noPhotosProvided

    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image for upload"
        case .uploadFailed:
            return "Failed to upload photo"
        case .noPhotosProvided:
            return "At least one photo is required"
        }
    }
}

// MARK: - Biometric Proof Helper

/// Generates biometric proof hash for verification
struct BiometricProofGenerator {
    /// Generates a hash combining device ID, timestamp, and location
    static func generateHash(
        latitude: Double?,
        longitude: Double?,
        timestamp: Date = Date()
    ) -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let timestampStr = ISO8601DateFormatter().string(from: timestamp)
        let locationStr = "\(latitude ?? 0),\(longitude ?? 0)"

        let combined = "\(deviceId)|\(timestampStr)|\(locationStr)"

        // Simple hash (in production, use proper cryptographic hash)
        guard let data = combined.data(using: .utf8) else {
            return "unknown_hash"
        }
        let hash = data.base64EncodedString()
        return hash
    }
}
