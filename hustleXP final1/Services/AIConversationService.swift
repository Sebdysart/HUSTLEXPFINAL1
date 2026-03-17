//
//  AIConversationService.swift
//  hustleXP final1
//
//  Client-side conversational UX for AI-powered task creation
//  Handles keyword extraction, category detection, and field parsing offline.
//  Real AI pricing/XP happens on backend via TaskService.createTask() -> ScoperAIService
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
    var wildcardFollowUpStep: Int = 0

    var hasBasicInfo: Bool {
        !title.isEmpty && !description.isEmpty
    }

    var isReadyToPost: Bool {
        !title.isEmpty && !description.isEmpty && payment != nil && !location.isEmpty
    }

    var completionPercentage: Double {
        var completed = 0.0
        if !title.isEmpty { completed += 0.25 }
        if !description.isEmpty { completed += 0.25 }
        if payment != nil { completed += 0.25 }
        if !location.isEmpty { completed += 0.25 }
        return completed
    }

    var missingFields: [String] {
        var missing: [String] = []
        if payment == nil { missing.append("payment") }
        if location.isEmpty { missing.append("location") }
        if duration.isEmpty { missing.append("duration") }
        return missing
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
}

// MARK: - AI Conversation Service

/// Client-side conversational task creation with keyword extraction and field parsing.
/// Lightweight NLP for responsive UX; server-side AI handles pricing and validation.
@MainActor
@Observable
final class AIConversationService {
    static let shared = AIConversationService()

    // MARK: - Initial Message

    func getInitialMessage() -> AIConversationMessage {
        AIConversationMessage(
            content: "What do you need done?",
            isFromAI: true,
            isBold: true
        )
    }

    // MARK: - Process User Input

    func processUserInput(_ input: String, currentDraft: AITaskDraft) -> (updatedDraft: AITaskDraft, response: AIConversationMessage) {
        let updatedDraft = currentDraft

        // First message - extract initial task info
        if currentDraft.title.isEmpty {
            return processInitialDescription(input, draft: updatedDraft)
        }

        // Subsequent messages - look for specific details or refinements
        return processRefinement(input, draft: updatedDraft)
    }

    // MARK: - Process Initial Description

    private func processInitialDescription(_ input: String, draft: AITaskDraft) -> (AITaskDraft, AIConversationMessage) {
        let lowercased = input.lowercased()

        // Extract category and generate title
        let category = detectCategory(from: lowercased)
        draft.category = category
        draft.title = generateTitle(from: input, category: category)
        draft.description = input

        // Try to extract location if mentioned
        if let location = extractLocation(from: input) {
            draft.location = location
        }

        // Try to extract payment if mentioned
        if let payment = extractPayment(from: input) {
            draft.payment = payment
        }

        // Try to extract duration if mentioned
        if let duration = extractDuration(from: input) {
            draft.duration = duration
        }

        // Generate follow-up response
        let response: AIConversationMessage
        if category == .wildcardBizarre {
            response = AIConversationMessage(
                content: "Interesting! This sounds like a one-of-a-kind task. What's the most unusual or performance-based part of it? (This helps us price it correctly)",
                isFromAI: true
            )
            draft.wildcardFollowUpStep = 1
        } else {
            response = generateFollowUpResponse(draft: draft, category: category)
        }

        return (draft, response)
    }

    // MARK: - Process Refinement

    private func processRefinement(_ input: String, draft: AITaskDraft) -> (AITaskDraft, AIConversationMessage) {
        let lowercased = input.lowercased()

        // Wildcard multi-step follow-up
        if draft.category == .wildcardBizarre && draft.wildcardFollowUpStep == 1 {
            draft.description += " | Unique aspect: \(input)"
            draft.wildcardFollowUpStep = 2
            return (draft, AIConversationMessage(
                content: "Got it. What proof would make you 100% confident this task was completed correctly?",
                isFromAI: true
            ))
        }
        if draft.category == .wildcardBizarre && draft.wildcardFollowUpStep == 2 {
            draft.description += " | Completion proof: \(input)"
            draft.wildcardFollowUpStep = 3
            return (draft, AIConversationMessage(
                content: "Perfect — I have what I need to price this. Does this look good, or would you like to adjust anything?",
                isFromAI: true
            ))
        }

        // Check for confirmation
        if isConfirmation(lowercased) {
            let response = AIConversationMessage(
                content: "Your task is ready to post! Tap the button below when you're ready.",
                isFromAI: true
            )
            return (draft, response)
        }

        // Check for title change request
        if lowercased.contains("title") || lowercased.contains("catchy") || lowercased.contains("rename") {
            draft.title = generateCatchyTitle(for: draft)
            let response = AIConversationMessage(
                content: "How about this title?\n\n\"\(draft.title)\"\n\nAnything else you'd like to change?",
                isFromAI: true
            )
            return (draft, response)
        }

        // Try to extract any missing fields from the input
        if let payment = extractPayment(from: input) {
            draft.payment = payment
        }

        if let location = extractLocation(from: input) {
            draft.location = location
        }

        if let duration = extractDuration(from: input) {
            draft.duration = duration
        }

        // Check if description should be updated
        if lowercased.contains("add") || lowercased.contains("include") || lowercased.contains("mention") {
            draft.description = "\(draft.description). Additional details: \(input)"
        }

        // Generate appropriate response based on what was updated
        let response: AIConversationMessage
        if draft.isReadyToPost {
            response = AIConversationMessage(
                content: "Perfect! Your task is ready to post.\n\nDoes this look good, or would you like to change anything?",
                isFromAI: true
            )
        } else {
            response = generateMissingFieldsResponse(draft: draft)
        }

        return (draft, response)
    }

    // MARK: - Category Detection

    private func detectCategory(from text: String) -> TaskCategory {
        // Content creator signals
        if text.contains("stream") || text.contains("youtube") || text.contains("tiktok") ||
           text.contains("podcast") || text.contains("collab") || text.contains("gaming") ||
           text.contains("twitch") || text.contains("influencer") {
            return .contentCreator
        }
        // Creative production signals
        if text.contains("photo shoot") || text.contains("video shoot") || text.contains("model") ||
           text.contains("recording session") || text.contains("film") {
            return .creativeProduction
        }
        // Event signals
        if text.contains("event") || text.contains("party") || text.contains("ambassador") ||
           text.contains("promoter") || text.contains("mascot") || text.contains("appearance") {
            return .eventAppearance
        }
        // Licensed/specialized signals
        if text.contains("electrician") || text.contains("plumber") || text.contains("notary") ||
           text.contains("tutor") || text.contains("trainer") || text.contains("licensed") ||
           text.contains("therapist") || text.contains("hvac") {
            return .specializedLicensed
        }
        // Care signals
        if text.contains("babysit") || text.contains("childcare") || text.contains("child") {
            return .childcare
        }
        if text.contains("elder") || text.contains("senior") || text.contains("companion") {
            return .elderCare
        }
        if text.contains("dog walk") || text.contains("pet walk") || text.contains("dog") || text.contains("pet") || text.contains("cat") {
            return .petCare
        }
        // In-home signals
        if text.contains("handyman") || text.contains("repair") || text.contains("fix") || text.contains("paint") {
            return .handyman
        }
        if text.contains("clean") || text.contains("tidy") || text.contains("wash") {
            return .cleaning
        }
        // Standard physical
        if text.contains("deliver") || text.contains("pickup") || text.contains("drop off") || text.contains("package") {
            return .delivery
        }
        if text.contains("move") || text.contains("furniture") || text.contains("haul") || text.contains("lift") {
            return .moving
        }
        if text.contains("yard") || text.contains("lawn") || text.contains("garden") || text.contains("mow") || text.contains("rake") {
            return .yardWork
        }
        if text.contains("shop") || text.contains("grocery") || text.contains("store") || text.contains("buy") {
            return .shopping
        }
        if text.contains("assemble") || text.contains("build") || text.contains("ikea") {
            return .assembly
        }
        if text.contains("computer") || text.contains("tech") || text.contains("wifi") || text.contains("setup") {
            return .tech
        }
        // Wildcard — anything with enough detail that doesn't match standard categories
        let wordCount = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
        if wordCount > 4 {
            return .wildcardBizarre
        }
        return .other
    }

    // MARK: - Title Generation

    private func generateTitle(from input: String, category: TaskCategory) -> String {
        let keywords: [String: String] = [
            "grocery": "Grocery Pickup & Delivery",
            "groceries": "Grocery Pickup & Delivery",
            "deliver": "Quick Delivery Task",
            "package": "Package Delivery",
            "move": "Moving Help Needed",
            "furniture": "Furniture Moving",
            "clean": "Cleaning Help",
            "lawn": "Lawn Care",
            "mow": "Lawn Mowing",
            "dog": "Dog Walking",
            "walk": "Pet Walking",
            "assemble": "Furniture Assembly",
            "ikea": "IKEA Assembly",
            "computer": "Tech Support",
            "fix": "Repair Task"
        ]

        let lowercased = input.lowercased()
        for (keyword, title) in keywords {
            if lowercased.contains(keyword) {
                return title
            }
        }

        // Default based on category
        return "\(category.displayName) Task"
    }

    private func generateCatchyTitle(for draft: AITaskDraft) -> String {
        let catchyPrefixes = ["Quick", "Easy", "Help Needed:", "Looking for:", "Urgent:"]
        let prefix = catchyPrefixes.randomElement() ?? "Quick"

        if let category = draft.category {
            switch category {
            case .delivery:
                return "\(prefix) Delivery Run"
            case .shopping:
                return "\(prefix) Shopping Trip"
            case .cleaning:
                return "\(prefix) Clean-Up Help"
            case .moving:
                return "\(prefix) Moving Muscle"
            case .yardWork:
                return "\(prefix) Yard Work"
            case .petCare:
                return "\(prefix) Pet Care"
            case .assembly:
                return "\(prefix) Assembly Pro Needed"
            case .tech:
                return "\(prefix) Tech Wizard Wanted"
            case .contentCreator:
                return "\(prefix) Content Creator Collab"
            case .eventAppearance:
                return "\(prefix) Event Appearance"
            case .creativeProduction:
                return "\(prefix) Creative Production"
            case .specializedLicensed:
                return "\(prefix) Specialist Needed"
            case .childcare:
                return "\(prefix) Childcare Help"
            case .elderCare:
                return "\(prefix) Elder Care Support"
            case .handyman:
                return "\(prefix) Handyman Needed"
            case .wildcardBizarre:
                return "\(prefix) One-of-a-Kind Task"
            case .other:
                return "\(prefix) Task Help"
            }
        }

        return "\(prefix) \(draft.title)"
    }

    // MARK: - Field Extraction

    private func extractPayment(from text: String) -> Double? {
        // Look for dollar amounts like "$35", "35 dollars", "$35.00"
        let patterns = [
            "\\$([0-9]+\\.?[0-9]*)",
            "([0-9]+)\\s*(?:dollars|bucks)",
            "pay\\s*([0-9]+)",
            "offer\\s*([0-9]+)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let valueRange = Range(match.range(at: 1), in: text) {
                        let valueString = String(text[valueRange])
                        return Double(valueString)
                    }
                }
            }
        }
        return nil
    }

    private func extractLocation(from text: String) -> String? {
        // Common location patterns
        let locationKeywords = ["from", "at", "to", "near", "in"]
        let knownPlaces = ["whole foods", "target", "walmart", "costco", "safeway", "cvs", "walgreens", "home depot", "lowes", "apartment", "house", "office", "downtown", "midtown"]

        let lowercased = text.lowercased()

        // Check for known places first
        for place in knownPlaces {
            if lowercased.contains(place) {
                return place.capitalized
            }
        }

        // Try to extract location after keywords
        for keyword in locationKeywords {
            if let range = lowercased.range(of: "\(keyword) ") {
                let afterKeyword = String(lowercased[range.upperBound...])
                let words = afterKeyword.split(separator: " ").prefix(3)
                if !words.isEmpty {
                    return words.joined(separator: " ").capitalized
                }
            }
        }

        return nil
    }

    private func extractDuration(from text: String) -> String? {
        let lowercased = text.lowercased()

        // Check for time mentions
        if lowercased.contains("30 min") || lowercased.contains("half hour") {
            return "30 min"
        } else if lowercased.contains("1 hour") || lowercased.contains("one hour") || lowercased.contains("an hour") {
            return "1 hr"
        } else if lowercased.contains("2 hour") || lowercased.contains("two hour") || lowercased.contains("couple hour") {
            return "2 hrs"
        } else if lowercased.contains("3 hour") || lowercased.contains("three hour") || lowercased.contains("few hour") {
            return "3+ hrs"
        } else if lowercased.contains("quick") || lowercased.contains("fast") || lowercased.contains("short") {
            return "30 min"
        } else if lowercased.contains("long") || lowercased.contains("big") {
            return "2 hrs"
        }

        return nil
    }

    // MARK: - Response Generation

    private func generateFollowUpResponse(draft: AITaskDraft, category: TaskCategory) -> AIConversationMessage {
        var response = "Got it! \(category.displayName)."

        if !draft.missingFields.isEmpty {
            response += "\n\nA few quick questions to finalize:"

            if draft.payment == nil {
                let range = category.basePriceRange
                let low = Double(range.lowerBound) / 100.0
                let high = Double(range.upperBound) / 100.0
                response += "\n• How much are you looking to pay? (Similar tasks: $\(Int(low))-$\(Int(high)))"
            }

            if draft.location.isEmpty {
                response += "\n• Where should the hustler go?"
            }

            if draft.duration.isEmpty {
                response += "\n• How long do you think this will take?"
            }
        } else {
            response += "\n\nYour task looks complete! Does everything look good?"
        }

        return AIConversationMessage(content: response, isFromAI: true)
    }

    private func generateMissingFieldsResponse(draft: AITaskDraft) -> AIConversationMessage {
        var response = "Got it!"

        let missing = draft.missingFields
        if !missing.isEmpty {
            response += " I still need:"

            if missing.contains("payment") {
                response += "\n• How much will you pay?"
            }
            if missing.contains("location") {
                response += "\n• Where is this task?"
            }
        }

        return AIConversationMessage(content: response, isFromAI: true)
    }

    private func isConfirmation(_ text: String) -> Bool {
        let confirmations = ["looks good", "perfect", "great", "yes", "yep", "correct", "that's right", "post it", "ready", "good to go", "let's do it", "confirm"]
        return confirmations.contains { text.contains($0) }
    }

    // MARK: - Suggested Price

    func getSuggestedPrice(for draft: AITaskDraft) -> Double {
        guard let category = draft.category else { return 25.0 }

        let range = category.basePriceRange
        let midpoint = (range.lowerBound + range.upperBound) / 2

        // Add complexity bonus based on description length
        let complexityBonus = min(draft.description.count / 50, 3) * 500

        return Double(midpoint + complexityBonus) / 100.0
    }
}
