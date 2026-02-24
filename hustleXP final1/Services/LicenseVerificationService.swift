//
//  LicenseVerificationService.swift
//  hustleXP final1
//
//  Real tRPC service for professional license verification
//  Maps to backend capability.ts router (license endpoints)
//  Replaces MockLicenseVerificationService
//

import Foundation
import SwiftUI

// MARK: - Types

enum LicenseVerificationStatus: String, Codable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case verified = "VERIFIED"
    case rejected = "REJECTED"
    case manualReview = "MANUAL_REVIEW"
    case expired = "EXPIRED"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .verified: return "Verified"
        case .rejected: return "Rejected"
        case .manualReview: return "Manual Review"
        case .expired: return "Expired"
        }
    }

    var isActive: Bool {
        self == .verified
    }
}

struct ProfessionalLicenseVerification: Codable, Identifiable {
    let id: String
    let userId: String
    let tradeType: String
    let issuingState: String
    let licenseNumber: String
    let expirationDate: String?
    let documentUrl: String?
    let status: LicenseVerificationStatus
    let submittedAt: Date
    let reviewedAt: Date?
    let reviewedBy: String?
    let rejectionReason: String?
    let notes: String?

    var isVerified: Bool {
        status == .verified
    }

    var isPending: Bool {
        status == .pending || status == .processing
    }
}

struct WorkerSkillProfile: Codable {
    let workerId: String
    var selectedSkills: Set<String>
    var unlockedSkills: Set<String>
    var licenses: [ProfessionalLicenseVerification]
    var skillLevels: [String: Int]
    var skillXP: [String: Int]
    var skillTasksCompleted: [String: Int]
    var generalLevel: Int
    var totalSkillXP: Int

    func hasSkill(_ skillId: String) -> Bool {
        selectedSkills.contains(skillId)
    }

    func isSkillUnlocked(_ skillId: String) -> Bool {
        unlockedSkills.contains(skillId)
    }
}

// MARK: - License Verification Service

@MainActor
@Observable
final class LicenseVerificationService {
    static let shared = LicenseVerificationService()

    private let trpc = TRPCClient.shared

    // MARK: - State

    private(set) var workerProfile: WorkerSkillProfile?
    private(set) var licenses: [ProfessionalLicenseVerification] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Profile Management

    func initializeProfile(for workerId: String) {
        if workerProfile == nil {
            workerProfile = WorkerSkillProfile(
                workerId: workerId,
                selectedSkills: Set(SkillCatalog.basicSkills().map { $0.id }),
                unlockedSkills: Set(SkillCatalog.basicSkills().map { $0.id }),
                licenses: [],
                skillLevels: [:],
                skillXP: [:],
                skillTasksCompleted: [:],
                generalLevel: 1,
                totalSkillXP: 0
            )
        }
    }

    func selectSkill(_ skillId: String) {
        guard var profile = workerProfile else { return }
        guard let skill = SkillCatalog.skill(byId: skillId) else { return }

        profile.selectedSkills.insert(skillId)

        // Basic skills are auto-unlocked
        if skill.type == .basic {
            profile.unlockedSkills.insert(skillId)
        }

        workerProfile = profile
        HXLogger.info("Selected skill: \(skill.name)", category: "Skill")
    }

    func deselectSkill(_ skillId: String) {
        guard var profile = workerProfile else { return }
        profile.selectedSkills.remove(skillId)
        workerProfile = profile
    }

    func isSkillSelected(_ skillId: String) -> Bool {
        workerProfile?.selectedSkills.contains(skillId) ?? false
    }

    func isSkillUnlocked(_ skillId: String) -> Bool {
        workerProfile?.unlockedSkills.contains(skillId) ?? false
    }

    // MARK: - License Submission

    /// Submit a professional license for verification
    func submitLicense(
        tradeType: String,
        issuingState: String,
        licenseNumber: String,
        expirationDate: String? = nil,
        documentUrl: String? = nil
    ) async throws -> ProfessionalLicenseVerification {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct SubmitLicenseInput: Codable {
            let tradeType: String
            let issuingState: String
            let licenseNumber: String
            let expirationDate: String?
            let documentUrl: String?
        }

        let input = SubmitLicenseInput(
            tradeType: tradeType,
            issuingState: issuingState,
            licenseNumber: licenseNumber,
            expirationDate: expirationDate,
            documentUrl: documentUrl
        )

        do {
            let verification: ProfessionalLicenseVerification = try await trpc.call(
                router: "capability",
                procedure: "submitLicense",
                input: input
            )

            // Refresh license list
            await fetchLicenses()

            HXLogger.info("License submitted: \(tradeType) - \(issuingState)", category: "License")
            return verification
        } catch {
            self.error = error
            HXLogger.error("Failed to submit license: \(error.localizedDescription)", category: "License")
            throw error
        }
    }

    // MARK: - Fetch Licenses

    /// Get all licenses for current user
    func fetchLicenses() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let fetchedLicenses: [ProfessionalLicenseVerification] = try await trpc.call(
                router: "capability",
                procedure: "getLicenses",
                type: .query
            )

            self.licenses = fetchedLicenses

            // Update worker profile with verified licenses
            if var profile = workerProfile {
                profile.licenses = fetchedLicenses.filter { $0.isVerified }

                // Unlock skills for verified licenses
                for license in fetchedLicenses where license.isVerified {
                    if let skill = SkillCatalog.licensedSkills().first(where: {
                        $0.licenseType?.rawValue == license.tradeType
                    }) {
                        profile.unlockedSkills.insert(skill.id)
                    }
                }

                workerProfile = profile
            }

            HXLogger.info("Fetched \(fetchedLicenses.count) licenses", category: "License")
        } catch {
            self.error = error
            HXLogger.error("Failed to fetch licenses: \(error.localizedDescription)", category: "License")
        }
    }

    // MARK: - License Upload Helper

    /// Upload license - convenience wrapper for UI compatibility
    func uploadLicense(
        type: LicenseType,
        licenseNumber: String,
        issuingState: String,
        documentURL: URL? = nil
    ) async throws -> ProfessionalLicenseVerification {
        return try await submitLicense(
            tradeType: type.rawValue,
            issuingState: issuingState,
            licenseNumber: licenseNumber,
            expirationDate: nil,
            documentUrl: documentURL?.absoluteString
        )
    }

    // MARK: - Status Helpers

    func hasVerifiedLicense(for tradeType: String) -> Bool {
        licenses.contains { $0.tradeType == tradeType && $0.isVerified }
    }

    func getPendingVerifications() -> [ProfessionalLicenseVerification] {
        licenses.filter { $0.isPending }
    }

    func getVerifiedLicenses() -> [ProfessionalLicenseVerification] {
        licenses.filter { $0.isVerified }
    }
}
