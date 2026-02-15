//
//  SkillService.swift
//  hustleXP final1
//
//  Real tRPC service for skills and licensing
//  Handles skill management, license verification, and task eligibility
//

import Foundation
import UIKit
import Combine

/// Skill from backend (API response type)
struct APISkill: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let requiresLicense: Bool
    let licenseType: String?
    let description: String?
    let iconName: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: APISkill, rhs: APISkill) -> Bool {
        lhs.id == rhs.id
    }
}

/// Skill category from backend (API response type)
struct APISkillCategory: Codable, Identifiable {
    let id: String
    let name: String
    let iconName: String?
    let skills: [APISkill]
}

/// Worker's skill with level (API response type)
struct WorkerSkillRecord: Codable, Identifiable {
    let id: String
    let skillId: String
    let skillName: String
    let level: Int
    let xp: Int
    let tasksCompleted: Int
    let licenseVerified: Bool
    let licenseVerifiedAt: Date?
}

/// License submission status (API response type)
enum APILicenseVerificationStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case expired = "expired"
}

/// License submission record (API response type)
struct APILicenseSubmission: Codable, Identifiable {
    let id: String
    let skillId: String
    let skillName: String
    let licenseType: String
    let licenseNumber: String?
    let photoUrl: String
    let status: APILicenseVerificationStatus
    let submittedAt: Date
    let reviewedAt: Date?
    let rejectionReason: String?
    let expiresAt: Date?
}

/// Task eligibility check result
struct TaskEligibility: Codable {
    let isEligible: Bool
    let reason: String?
    let requiredSkill: String?
    let requiredLevel: Int?
    let currentLevel: Int?
    let requiresLicense: Bool
    let licenseVerified: Bool
}

/// Manages skills and licensing via tRPC
@MainActor
final class SkillService: ObservableObject {
    static let shared = SkillService()

    private let trpc = TRPCClient.shared

    @Published var mySkills: [WorkerSkillRecord] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Skill Catalog

    /// Gets all skill categories with skills
    func getCategories() async throws -> [APISkillCategory] {
        struct EmptyInput: Codable {}

        let categories: [APISkillCategory] = try await trpc.call(
            router: "skills",
            procedure: "getCategories",
            type: .query,
            input: EmptyInput()
        )

        print("✅ SkillService: Fetched \(categories.count) skill categories")
        return categories
    }

    /// Gets skills in a category
    func getSkills(categoryId: String) async throws -> [APISkill] {
        struct GetSkillsInput: Codable {
            let categoryId: String
        }

        let skills: [APISkill] = try await trpc.call(
            router: "skills",
            procedure: "getSkills",
            type: .query,
            input: GetSkillsInput(categoryId: categoryId)
        )

        return skills
    }

    // MARK: - My Skills

    /// Gets current user's skills
    func getMySkills() async throws -> [WorkerSkillRecord] {
        struct EmptyInput: Codable {}

        let skills: [WorkerSkillRecord] = try await trpc.call(
            router: "skills",
            procedure: "getMySkills",
            type: .query,
            input: EmptyInput()
        )

        self.mySkills = skills
        print("✅ SkillService: User has \(skills.count) skills")
        return skills
    }

    /// Adds skills to user's profile
    func addSkills(skillIds: [String]) async throws -> [WorkerSkillRecord] {
        isLoading = true
        defer { isLoading = false }

        struct AddSkillsInput: Codable {
            let skillIds: [String]
        }

        let skills: [WorkerSkillRecord] = try await trpc.call(
            router: "skills",
            procedure: "addSkills",
            input: AddSkillsInput(skillIds: skillIds)
        )

        self.mySkills = skills
        print("✅ SkillService: Added \(skillIds.count) skills")
        return skills
    }

    /// Removes a skill from user's profile
    func removeSkill(skillId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct RemoveSkillInput: Codable {
            let skillId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "skills",
            procedure: "removeSkill",
            input: RemoveSkillInput(skillId: skillId)
        )

        // Refresh skills
        _ = try? await getMySkills()

        print("✅ SkillService: Removed skill \(skillId)")
    }

    // MARK: - License Verification

    /// Submits a license for verification
    func submitLicense(
        skillId: String,
        licenseType: String,
        licenseNumber: String?,
        photoUrl: String
    ) async throws -> APILicenseSubmission {
        isLoading = true
        defer { isLoading = false }

        struct SubmitLicenseInput: Codable {
            let skillId: String
            let licenseType: String
            let licenseNumber: String?
            let photoUrl: String
        }

        let submission: APILicenseSubmission = try await trpc.call(
            router: "skills",
            procedure: "submitLicense",
            input: SubmitLicenseInput(
                skillId: skillId,
                licenseType: licenseType,
                licenseNumber: licenseNumber,
                photoUrl: photoUrl
            )
        )

        print("✅ SkillService: Submitted license for verification")
        return submission
    }

    /// Gets license submission status
    func getLicenseSubmissions() async throws -> [APILicenseSubmission] {
        struct EmptyInput: Codable {}

        let submissions: [APILicenseSubmission] = try await trpc.call(
            router: "skills",
            procedure: "getLicenseSubmissions",
            type: .query,
            input: EmptyInput()
        )

        return submissions
    }

    // MARK: - Task Eligibility

    /// Checks if user is eligible for a task
    func checkTaskEligibility(taskId: String) async throws -> TaskEligibility {
        struct CheckInput: Codable {
            let taskId: String
        }

        let eligibility: TaskEligibility = try await trpc.call(
            router: "skills",
            procedure: "checkTaskEligibility",
            type: .query,
            input: CheckInput(taskId: taskId)
        )

        return eligibility
    }

    /// Gets tasks user is eligible for
    /// Note: Backend doesn't have skills.getEligibleTasks; use TaskDiscoveryService.getFeed() instead
    /// which filters by user's skills automatically
    func getEligibleTasks(
        latitude: Double?,
        longitude: Double?,
        radiusMeters: Double?
    ) async throws -> [HXTask] {
        // Delegate to TaskDiscovery which handles skill-based filtering server-side
        let mySkills = self.mySkills.map { $0.skillId }
        let response = try await TaskDiscoveryService.shared.getFeed(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0,
            radiusMeters: radiusMeters ?? 16093,
            skills: mySkills.isEmpty ? nil : mySkills
        )

        print("✅ SkillService: Found \(response.tasks.count) eligible tasks via discovery")
        return response.tasks
    }
}

// MARK: - License Photo Upload Helper

extension SkillService {
    /// Uploads license photo and submits for verification
    func uploadAndSubmitLicense(
        image: UIImage,
        skillId: String,
        licenseType: String,
        licenseNumber: String?
    ) async throws -> APILicenseSubmission {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ProofError.imageCompressionFailed
        }

        // Get pre-signed URL for license upload
        let filename = "license_\(skillId)_\(Int(Date().timeIntervalSince1970)).jpg"

        struct GetURLInput: Codable {
            let filename: String
            let contentType: String
            let purpose: String
        }

        let presignedURL: PresignedUploadURL = try await trpc.call(
            router: "upload",
            procedure: "getPresignedUrl",
            input: GetURLInput(filename: filename, contentType: "image/jpeg", purpose: "license")
        )

        // Upload to R2
        var request = URLRequest(url: URL(string: presignedURL.uploadUrl)!)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProofError.uploadFailed
        }

        // Submit license with uploaded URL
        return try await submitLicense(
            skillId: skillId,
            licenseType: licenseType,
            licenseNumber: licenseNumber,
            photoUrl: presignedURL.publicUrl
        )
    }
}
