//
//  ReferralService.swift
//  hustleXP final1
//
//  Manages referral code generation, sharing, and redemption
//

import SwiftUI
import Combine

class ReferralService: ObservableObject {
    @Published var referralCode: String?
    @Published var referralCount: Int = 0
    @Published var totalEarned: Int = 0 // cents
    @Published var isLoading = false
    @Published var error: String?

    private let trpc = TRPCClient.shared

    // MARK: - Codable models

    private struct EmptyInput: Codable {}

    private struct ReferralCodeResponse: Codable {
        let code: String
        let usesCount: Int?
        let totalEarnedCents: Int?
    }

    private struct RedeemInput: Codable {
        let code: String
    }

    private struct EmptyResponse: Codable {}

    func getOrCreateReferralCode() async {
        await MainActor.run { isLoading = true }

        do {
            let result: ReferralCodeResponse = try await trpc.call(
                router: "referral",
                procedure: "getOrCreateCode",
                input: EmptyInput()
            )

            await MainActor.run {
                self.referralCode = result.code
                self.referralCount = result.usesCount ?? 0
                self.totalEarned = result.totalEarnedCents ?? 0
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func redeemCode(_ code: String) async -> Bool {
        do {
            let _: EmptyResponse = try await trpc.call(
                router: "referral",
                procedure: "redeemCode",
                input: RedeemInput(code: code)
            )
            return true
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            return false
        }
    }

    func shareReferralCode() -> String {
        let code = referralCode ?? "HUSTLEXP"
        return "Join me on HustleXP! Use my referral code \(code) to get $5 off your first task. Download: https://hustlexp.app/ref/\(code)"
    }
}
