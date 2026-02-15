//
//  DailyChallengeService.swift
//  hustleXP final1
//
//  Manages daily challenges for engagement
//

import SwiftUI
import Combine

class DailyChallengeService: ObservableObject {
    @Published var challenges: [DailyChallenge] = []
    @Published var isLoading = false
    @Published var error: String?

    private let trpc = TRPCClient.shared

    // MARK: - Models

    struct DailyChallenge: Identifiable {
        let id: String
        let title: String
        let description: String
        let challengeType: String
        let targetValue: Int
        let currentProgress: Int
        let xpReward: Int
        let completed: Bool
        let icon: String

        var progressPercent: Double {
            guard targetValue > 0 else { return 0 }
            return min(Double(currentProgress) / Double(targetValue), 1.0)
        }
    }

    private struct DailyChallengeResponse: Codable {
        let id: String?
        let title: String?
        let description: String?
        let challengeType: String?
        let targetValue: Int?
        let progress: Int?
        let xpReward: Int?
        let completed: Bool?
    }

    private struct EmptyInput: Codable {}

    func loadTodaysChallenges() async {
        await MainActor.run { isLoading = true }

        do {
            let result: [DailyChallengeResponse] = try await trpc.call(
                router: "challenges",
                procedure: "getTodaysChallenges",
                type: .query,
                input: EmptyInput()
            )

            let parsed = result.map { item -> DailyChallenge in
                let type = item.challengeType ?? "complete_task"
                return DailyChallenge(
                    id: item.id ?? UUID().uuidString,
                    title: item.title ?? "Challenge",
                    description: item.description ?? "",
                    challengeType: type,
                    targetValue: item.targetValue ?? 1,
                    currentProgress: item.progress ?? 0,
                    xpReward: item.xpReward ?? 10,
                    completed: item.completed ?? false,
                    icon: Self.iconFor(type)
                )
            }

            await MainActor.run {
                self.challenges = parsed
                self.isLoading = false
            }
        } catch {
            // Default challenges if API fails
            await MainActor.run {
                self.challenges = Self.defaultChallenges()
                self.isLoading = false
            }
        }
    }

    static func iconFor(_ type: String) -> String {
        switch type {
        case "complete_task": return "checkmark.circle.fill"
        case "earn_rating": return "star.fill"
        case "fast_completion": return "bolt.fill"
        case "specific_category": return "tag.fill"
        case "streak_maintain": return "flame.fill"
        default: return "target"
        }
    }

    static func defaultChallenges() -> [DailyChallenge] {
        [
            DailyChallenge(id: "dc1", title: "Complete a Task", description: "Finish any task today", challengeType: "complete_task", targetValue: 1, currentProgress: 0, xpReward: 10, completed: false, icon: "checkmark.circle.fill"),
            DailyChallenge(id: "dc2", title: "Speed Run", description: "Complete a task in under 30 minutes", challengeType: "fast_completion", targetValue: 1, currentProgress: 0, xpReward: 15, completed: false, icon: "bolt.fill"),
            DailyChallenge(id: "dc3", title: "Keep the Streak", description: "Maintain your daily streak", challengeType: "streak_maintain", targetValue: 1, currentProgress: 0, xpReward: 5, completed: false, icon: "flame.fill"),
        ]
    }
}
