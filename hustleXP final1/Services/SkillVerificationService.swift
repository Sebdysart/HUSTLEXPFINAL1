//
//  SkillVerificationService.swift
//  hustleXP final1
//
//  Manages paid skill verification badges
//

import SwiftUI
import Combine

class SkillVerificationService: ObservableObject {
    @Published var verifiedSkills: [VerifiedSkill] = []
    @Published var isLoading = false
    @Published var error: String?

    private let trpc = TRPCClient.shared

    // MARK: - Models

    struct VerifiedSkill: Identifiable, Codable {
        let id: String
        let skillName: String
        let verificationType: String
        let verifiedAt: String
        let active: Bool
    }

    private struct EmptyInput: Codable {}

    private struct VerifyInput: Codable {
        let skillName: String
    }

    private struct VerifyResponse: Codable {
        let clientSecret: String
        let verificationId: String?
    }

    private struct ConfirmVerificationInput: Codable {
        let verificationId: String
        let stripePaymentIntentId: String
    }

    private struct ConfirmVerificationResponse: Codable {
        let success: Bool?
    }

    func loadVerifiedSkills() async {
        await MainActor.run { isLoading = true }

        do {
            let skills: [VerifiedSkill] = try await trpc.call(
                router: "skills",
                procedure: "getVerifiedSkills",
                type: .query,
                input: EmptyInput()
            )

            await MainActor.run {
                self.verifiedSkills = skills
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Requests paid verification for a skill. Returns a Stripe clientSecret for payment.
    func verifySkill(skillName: String) async -> String? {
        await MainActor.run { isLoading = true }

        do {
            let result: VerifyResponse = try await trpc.call(
                router: "skills",
                procedure: "requestVerification",
                input: VerifyInput(skillName: skillName)
            )
            await MainActor.run { isLoading = false }
            return result.clientSecret
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return nil
        }
    }

    /// Confirms a skill verification after Stripe payment succeeds.
    func confirmVerification(verificationId: String, stripePaymentIntentId: String) async -> Bool {
        await MainActor.run { isLoading = true }

        do {
            let _: ConfirmVerificationResponse = try await trpc.call(
                router: "skills",
                procedure: "confirmVerification",
                input: ConfirmVerificationInput(
                    verificationId: verificationId,
                    stripePaymentIntentId: stripePaymentIntentId
                )
            )
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        }
    }
}
