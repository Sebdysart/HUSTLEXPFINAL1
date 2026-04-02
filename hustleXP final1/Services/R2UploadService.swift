//
//  R2UploadService.swift
//  hustleXP final1
//
//  Central service for uploading photos to Cloudflare R2 via presigned URLs.
//  Used by proof submission, photo messaging, and profile/license uploads.
//

import Foundation
import UIKit
import Combine

// MARK: - R2 Upload Errors

enum R2UploadError: Error, LocalizedError {
    case imageConversionFailed
    case fileTooLarge(bytes: Int)
    case presignedUrlFailed(Error)
    case uploadFailed(statusCode: Int)
    case uploadNetworkError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to JPEG data"
        case .fileTooLarge(let bytes):
            let mb = Double(bytes) / 1_048_576.0
            return String(format: "File too large (%.1fMB). Maximum is 10MB.", mb)
        case .presignedUrlFailed(let error):
            return "Failed to get upload URL: \(error.localizedDescription)"
        case .uploadFailed(let statusCode):
            return "Upload failed (HTTP \(statusCode))"
        case .uploadNetworkError(let error):
            return "Upload network error: \(error.localizedDescription)"
        case .noData:
            return "No image data to upload"
        }
    }
}

// MARK: - Presigned URL Models (matches backend upload.getPresignedUrl schema)

/// Input for `upload.getPresignedUrl` mutation.
/// Field names match the backend Zod schema exactly.
private struct PresignedURLInput: Encodable {
    let taskId: String?
    let filename: String
    let contentType: String
    let fileSize: Int?
    let purpose: String?
}

/// Response from `upload.getPresignedUrl` mutation.
/// Field names match the backend response exactly.
private struct PresignedURLResponse: Decodable {
    let uploadUrl: String
    let publicUrl: String
    let key: String
    let expiresAt: String
}

// MARK: - R2 Upload Service

/// Uploads photos to Cloudflare R2 via backend-issued presigned URLs.
///
/// Usage:
/// ```swift
/// let url = try await R2UploadService.shared.uploadPhoto(image, purpose: .proof, taskId: taskId)
/// ```
@MainActor
final class R2UploadService: ObservableObject {
    static let shared = R2UploadService(client: TRPCClient.shared)

    private let trpc: TRPCClientProtocol

    /// Current upload progress (0.0 to 1.0). Resets at the start of each upload call.
    @Published var uploadProgress: Double = 0.0

    /// Whether an upload is currently in progress.
    @Published var isUploading = false

    init(client: TRPCClientProtocol) {
        self.trpc = client
    }

    // MARK: - Constants

    private static let maxFileSize = 10 * 1024 * 1024 // 10 MB
    private static let jpegQuality: CGFloat = 0.8

    // MARK: - Single Photo Upload

    /// Uploads a single photo to R2 and returns its public URL.
    ///
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - purpose: The upload purpose (proof, message, license)
    ///   - taskId: The associated task ID (required by backend)
    /// - Returns: The public URL of the uploaded photo
    func uploadPhoto(
        _ image: UIImage,
        purpose: UploadPurpose,
        taskId: String? = nil
    ) async throws -> String {
        isUploading = true
        uploadProgress = 0.0
        defer {
            isUploading = false
            uploadProgress = 1.0
        }

        // 1. Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: Self.jpegQuality) else {
            throw R2UploadError.imageConversionFailed
        }

        guard imageData.count <= Self.maxFileSize else {
            throw R2UploadError.fileTooLarge(bytes: imageData.count)
        }

        uploadProgress = 0.1

        // 2. Generate a unique filename
        let filename = "\(UUID().uuidString).jpg"

        // 3. Request presigned URL from backend
        let presignedResponse: PresignedURLResponse
        do {
            presignedResponse = try await trpc.call(
                router: "upload",
                procedure: "getPresignedUrl",
                type: .mutation,
                input: PresignedURLInput(
                    taskId: taskId,
                    filename: filename,
                    contentType: "image/jpeg",
                    fileSize: imageData.count,
                    purpose: purpose.rawValue
                )
            )
        } catch {
            throw R2UploadError.presignedUrlFailed(error)
        }

        uploadProgress = 0.3

        // 4. Upload image data to presigned URL via PUT
        guard let uploadURL = URL(string: presignedResponse.uploadUrl) else {
            throw R2UploadError.presignedUrlFailed(
                NSError(domain: "R2UploadService", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid presigned URL returned by server"
                ])
            )
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
        } catch {
            throw R2UploadError.uploadNetworkError(error)
        }

        // 5. Validate upload response
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            HXLogger.error("R2UploadService: Upload failed with HTTP \(httpResponse.statusCode)", category: "Network")
            throw R2UploadError.uploadFailed(statusCode: httpResponse.statusCode)
        }

        uploadProgress = 1.0
        HXLogger.info("R2UploadService: Uploaded \(filename) (\(imageData.count) bytes) for \(purpose.rawValue)", category: "Network")

        return presignedResponse.publicUrl
    }

    // MARK: - Batch Photo Upload

    /// Uploads multiple photos to R2 and returns their public URLs.
    ///
    /// Progress is tracked across all images (e.g., 3 images = progress increments of ~0.33).
    ///
    /// - Parameters:
    ///   - images: Array of UIImages to upload
    ///   - purpose: The upload purpose (proof, message, license)
    ///   - taskId: The associated task ID (required by backend)
    /// - Returns: Array of public URLs in the same order as the input images
    func uploadPhotos(
        _ images: [UIImage],
        purpose: UploadPurpose,
        taskId: String? = nil
    ) async throws -> [String] {
        guard !images.isEmpty else { return [] }

        isUploading = true
        uploadProgress = 0.0
        defer {
            isUploading = false
            uploadProgress = 1.0
        }

        // Backend requires a UUID for taskId; use a placeholder for non-task uploads
        let resolvedTaskId = taskId ?? UUID().uuidString

        var urls: [String] = []
        let perImageWeight = 1.0 / Double(images.count)

        for (index, image) in images.enumerated() {
            // Convert to JPEG
            guard let imageData = image.jpegData(compressionQuality: Self.jpegQuality) else {
                throw R2UploadError.imageConversionFailed
            }

            guard imageData.count <= Self.maxFileSize else {
                throw R2UploadError.fileTooLarge(bytes: imageData.count)
            }

            let filename = "\(UUID().uuidString).jpg"

            // Get presigned URL
            let presignedResponse: PresignedURLResponse
            do {
                presignedResponse = try await trpc.call(
                    router: "upload",
                    procedure: "getPresignedUrl",
                    type: .mutation,
                    input: PresignedURLInput(
                        taskId: resolvedTaskId,
                        filename: filename,
                        contentType: "image/jpeg",
                        fileSize: imageData.count,
                        purpose: purpose.rawValue
                    )
                )
            } catch {
                throw R2UploadError.presignedUrlFailed(error)
            }

            uploadProgress = Double(index) * perImageWeight + perImageWeight * 0.3

            // Upload to presigned URL
            guard let uploadURL = URL(string: presignedResponse.uploadUrl) else {
                throw R2UploadError.presignedUrlFailed(
                    NSError(domain: "R2UploadService", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid presigned URL returned by server"
                    ])
                )
            }

            var request = URLRequest(url: uploadURL)
            request.httpMethod = "PUT"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

            let response: URLResponse
            do {
                (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
            } catch {
                throw R2UploadError.uploadNetworkError(error)
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                HXLogger.error("R2UploadService: Upload \(index + 1)/\(images.count) failed with HTTP \(httpResponse.statusCode)", category: "Network")
                throw R2UploadError.uploadFailed(statusCode: httpResponse.statusCode)
            }

            urls.append(presignedResponse.publicUrl)
            uploadProgress = Double(index + 1) * perImageWeight

            HXLogger.info("R2UploadService: Uploaded \(index + 1)/\(images.count) for \(purpose.rawValue)", category: "Network")
        }

        return urls
    }
}
