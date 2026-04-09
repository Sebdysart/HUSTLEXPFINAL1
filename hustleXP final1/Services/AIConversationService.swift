//
//  AIConversationService.swift
//  hustleXP final1
//
//  Fully AI-powered task creation conversation.
//  Every message goes to backend task.aiConverse → GPT-4o.
//  No local keyword matching. No hardcoded responses.
//

import Foundation

// MARK: - AI Conversation Message

struct AIConversationMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromAI: Bool
    let isBold: Bool
    let timestamp: Date

    init(content: String, isFromAI: Bool, isBold: Bool = false) {
        self.content = content
        self.isFromAI = isFromAI
        self.isBold = isBold
        self.timestamp = Date()
    }
}

// MARK: - AI Task Draft

@Observable
class AITaskDraft {
    var title: String = ""
    var description: String = ""
    var payment: Double?
    var location: String = ""
    var duration: String = ""
    var category: TaskCategory?
    var requiredTier: TrustTier = .rookie
    var difficulty: String = ""
    var requirements: String = ""
    var deadline: String = ""
    var flags: [String] = []
    var isReadyToPost: Bool = false

    var hasBasicInfo: Bool {
        !title.isEmpty && !description.isEmpty
    }

    var completionPercentage: Double {
        var completed = 0.0
        if !title.isEmpty { completed += 0.2 }
        if !description.isEmpty { completed += 0.2 }
        if payment != nil { completed += 0.2 }
        if !location.isEmpty { completed += 0.2 }
        if !duration.isEmpty { completed += 0.2 }
        return completed
    }

    func toHXTask(posterId: String, posterName: String, posterRating: Double) -> HXTask {
        HXTask(
            id: "task-\(UUID().uuidString.prefix(8))",
            title: title,
            description: description,
            payment: payment ?? 0,
            location: location,
            latitude: nil,
            longitude: nil,
            estimatedDuration: duration.isEmpty ? "1 hr" : duration,
            posterId: posterId,
            posterName: posterName,
            posterRating: posterRating,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: requiredTier,
            createdAt: Date(),
            claimedAt: nil,
            completedAt: nil,
            aiSuggestedPrice: true
        )
    }

    /// Convert to the JSON shape the backend expects
    func toBackendDraft() -> [String: Any?] {
        return [
            "title": title.isEmpty ? nil : title,
            "description": description.isEmpty ? nil : description,
            "suggestedPriceCents": payment.map { Int($0 * 100) },
            "location": location.isEmpty ? nil : location,
            "estimatedDurationMinutes": durationToMinutes(),
            "difficulty": difficulty.isEmpty ? nil : difficulty,
            "category": category?.rawValue,
            "requirements": requirements.isEmpty ? nil : requirements,
            "deadline": deadline.isEmpty ? nil : deadline,
            "flags": flags.isEmpty ? nil : flags,
            "isReadyToPost": isReadyToPost,
        ]
    }

    func durationToMinutes() -> Int? {
        if duration.contains("min") {
            return Int(duration.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
        } else if duration.contains("hr") {
            if let hrs = Int(duration.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) {
                return hrs * 60
            }
        }
        return nil
    }

    /// Update from backend AI response
    func applyAIResponse(_ draft: AIConverseResponseDraft) {
        if let t = draft.title { title = t }
        if let d = draft.description { description = d }
        if let p = draft.suggestedPriceCents { payment = Double(p) / 100.0 }
        if let l = draft.location { location = l }
        if let dur = draft.estimatedDurationMinutes {
            if dur < 60 {
                duration = "\(dur) min"
            } else {
                let hrs = dur / 60
                duration = "\(hrs) hr\(hrs > 1 ? "s" : "")"
            }
        }
        if let diff = draft.difficulty { difficulty = diff }
        if let cat = draft.category {
            category = TaskCategory(rawValue: cat)
        }
        if let req = draft.requirements { requirements = req }
        if let dl = draft.deadline { deadline = dl }
        if let f = draft.flags { flags = f }
        if let ready = draft.isReadyToPost { isReadyToPost = ready }
    }
}

// MARK: - Backend Response Types

struct AIConverseInput: Codable {
    let message: String
    let conversationHistory: [ConversationEntry]
    let currentDraft: CurrentDraftInput?
}

struct ConversationEntry: Codable {
    let role: String
    let content: String
}

struct CurrentDraftInput: Codable {
    let title: String?
    let description: String?
    let suggestedPriceCents: Int?
    let location: String?
    let estimatedDurationMinutes: Int?
    let difficulty: String?
    let category: String?
    let requirements: String?
    let deadline: String?
    let flags: [String]?
    let isReadyToPost: Bool?
}

struct AIConverseResponse: Codable {
    let message: String
    let draft: AIConverseResponseDraft?
}

struct AIConverseResponseDraft: Codable {
    let title: String?
    let description: String?
    let suggestedPriceCents: Int?
    let location: String?
    let estimatedDurationMinutes: Int?
    let difficulty: String?
    let category: String?
    let requirements: String?
    let deadline: String?
    let flags: [String]?
    let isReadyToPost: Bool?
}

// MARK: - AI Conversation Service

@MainActor
@Observable
final class AIConversationService {
    static let shared = AIConversationService()

    /// Conversation history sent to the backend for context
    private var conversationHistory: [ConversationEntry] = []

    // MARK: - Initial Message

    func getInitialMessage() -> AIConversationMessage {
        conversationHistory = []
        return AIConversationMessage(
            content: "What do you need done?",
            isFromAI: true,
            isBold: true
        )
    }

    // MARK: - Process Message (All AI-Powered)

    func processMessage(_ input: String, draft: AITaskDraft) async -> (AITaskDraft, AIConversationMessage) {
        // Build the current draft input
        let draftInput = CurrentDraftInput(
            title: draft.title.isEmpty ? nil : draft.title,
            description: draft.description.isEmpty ? nil : draft.description,
            suggestedPriceCents: draft.payment.map { Int($0 * 100) },
            location: draft.location.isEmpty ? nil : draft.location,
            estimatedDurationMinutes: draft.durationToMinutes(),
            difficulty: draft.difficulty.isEmpty ? nil : draft.difficulty,
            category: draft.category?.rawValue,
            requirements: draft.requirements.isEmpty ? nil : draft.requirements,
            deadline: draft.deadline.isEmpty ? nil : draft.deadline,
            flags: draft.flags.isEmpty ? nil : draft.flags,
            isReadyToPost: draft.isReadyToPost
        )

        let apiInput = AIConverseInput(
            message: input,
            conversationHistory: conversationHistory,
            currentDraft: draftInput
        )

        do {
            let response: AIConverseResponse = try await TRPCClient.shared.call(
                router: "task",
                procedure: "aiConverse",
                input: apiInput
            )

            // Update conversation history
            conversationHistory.append(ConversationEntry(role: "user", content: input))
            conversationHistory.append(ConversationEntry(role: "assistant", content: response.message))

            // Apply draft updates from AI
            if let aiDraft = response.draft {
                draft.applyAIResponse(aiDraft)
            }

            return (draft, AIConversationMessage(content: response.message, isFromAI: true))

        } catch {
            HXLogger.error("AIConverse failed: \(error.localizedDescription)", category: "AI")

            // Fallback message
            return (draft, AIConversationMessage(
                content: "I'm having trouble right now. Could you describe your task again? Include what you need done, where, and your budget.",
                isFromAI: true
            ))
        }
    }

    // MARK: - Suggested Price

    func getSuggestedPrice(for draft: AITaskDraft) -> Double {
        return draft.payment ?? 25.0
    }
}

