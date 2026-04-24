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

/// Proof submission record — mirrors the `proofs` DB table (columns snake_case → camelCase via decoder).
/// `submitterId` is the worker who submitted the proof (DB: submitter_id).
/// `reviewedBy` is the poster who reviewed it (DB: reviewed_by), populated after review.
/// Proof record returned by backend — mirrors the `proofs` DB table.
/// Photos are stored separately in `proof_photos`; use `ProofDetail` for full data with photos.
struct ProofSubmission: Codable, Identifiable {
    let id: String
    let taskId: String
    let submitterId: String
    let state: String
    let description: String?
    let submittedAt: Date?
    let reviewedAt: Date?
    let reviewedBy: String?
    let rejectionReason: String?
}

/// Wraps the nested { task, proof } response from task.submitProof.
/// Backend returns both so the caller can update task state and display the proof record.
private struct SubmitProofWrapper: Codable {
    let task: HXTask
    let proof: ProofSubmission
}

/// Photo attached to a proof — mirrors `proof_photos` DB table.
/// TRPCClient uses `.convertFromSnakeCase` so no explicit CodingKeys needed.
struct ProofPhoto: Codable, Identifiable {
    let id: String
    let proofId: String
    let storageKey: String   // The actual URL or R2 key
    let contentType: String
    let sequenceNumber: Int
}

/// Full proof detail returned by `task.getProof` — includes photos and videos.
/// TRPCClient uses `.convertFromSnakeCase` so no explicit CodingKeys needed.
struct ProofDetail: Codable {
    let id: String
    let taskId: String
    let submitterId: String
    let state: String
    let description: String?
    let submittedAt: Date?
    let reviewedAt: Date?
    let reviewedBy: String?
    let photos: [ProofPhoto]

    /// Convenience: extract photo URLs from attached photos
    var photoUrls: [String] {
        photos.map { $0.storageKey }
    }
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
        contentType: String = "image/jpeg",
        fileSize: Int,
        purpose: UploadPurpose = .proof
    ) async throws -> PresignedUploadURL {
        struct GetURLInput: Codable {
            let taskId: String
            let filename: String
            let contentType: String
            let fileSize: Int
            let purpose: UploadPurpose
        }

        let response: PresignedUploadURL = try await trpc.call(
            router: "upload",
            procedure: "getPresignedUrl",
            input: GetURLInput(taskId: taskId, filename: filename, contentType: contentType, fileSize: fileSize, purpose: purpose)
        )

        HXLogger.info("ProofService: Got pre-signed URL for \(filename) (\(fileSize) bytes)", category: "Task")
        return response
    }

    /// Uploads raw image data to the pre-signed R2 URL
    func uploadImageData(_ imageData: Data, to presignedURL: PresignedUploadURL) async throws -> String {
        isUploading = true
        uploadProgress = 0
        defer {
            isUploading = false
            uploadProgress = 1.0
        }

        guard let uploadURL = URL(string: presignedURL.uploadUrl) else {
            throw ProofError.uploadFailed
        }
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProofError.uploadFailed
        }

        HXLogger.info("ProofService: Uploaded image to R2 (\(imageData.count) bytes)", category: "Task")
        return presignedURL.publicUrl
    }

    /// Uploads a UIImage to the pre-signed R2 URL (convenience wrapper)
    func uploadImage(_ image: UIImage, to presignedURL: PresignedUploadURL) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ProofError.imageCompressionFailed
        }
        return try await uploadImageData(imageData, to: presignedURL)
    }

    /// Convenience method: Gets URL and uploads image in one call
    func uploadProofPhoto(
        image: UIImage,
        taskId: String,
        photoIndex: Int
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ProofError.imageCompressionFailed
        }
        let filename = "proof_\(taskId)_\(photoIndex)_\(Int(Date().timeIntervalSince1970)).jpg"
        let presignedURL = try await getUploadURL(
            taskId: taskId,
            filename: filename,
            fileSize: imageData.count
        )
        let publicUrl = try await uploadImageData(imageData, to: presignedURL)
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

        // Backend returns { task: HXTask, proof: ProofRecord } — unwrap via SubmitProofWrapper
        let response: SubmitProofWrapper = try await trpc.call(
            router: "task",
            procedure: "submitProof",
            input: input
        )

        HXLogger.info("ProofService: Submitted proof for task \(taskId)", category: "Task")
        return response.proof
    }

    /// Gets proof detail (with photos) for a task
    func getProof(taskId: String) async throws -> ProofDetail {
        struct GetInput: Codable {
            let taskId: String
        }

        let proof: ProofDetail = try await trpc.call(
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
