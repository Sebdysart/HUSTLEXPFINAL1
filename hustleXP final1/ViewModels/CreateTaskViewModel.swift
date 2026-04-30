//
//  CreateTaskViewModel.swift
//  hustleXP final1
//
//  Extracted from CreateTaskScreen.swift
//  Archetype: C (Task Lifecycle)
//
//  Contains all business logic, API calls, validation,
//  and state management for task creation flow.
//

import SwiftUI
import StripePaymentSheet

// MARK: - CreateTaskViewModel

@Observable
@MainActor
final class CreateTaskViewModel {

    // MARK: - Dependencies (injected after init)

    var router: Router?
    var dataService: LiveDataService?

    // MARK: - Services

    let taskService = TaskService.shared
    let escrowService = EscrowService.shared

    // MARK: - Form State

    var title: String = ""
    var description: String = ""
    var payment: String = ""
    var locationCity: String = ""
    var locationState: String = ""
    var locationRadiusMiles: Int = 25
    var durationValue: String = ""
    var durationUnit: DurationUnit = .hours
    var deadline: Date? = nil
    var requiredTier: TrustTier = .rookie
    var templateSlug: String = "standard_physical"
    var riskLevel: String = "LOW"

    var locationDisplay: String {
        if locationCity == "Anywhere" || locationCity.isEmpty { return "Anywhere" }
        if locationState.isEmpty { return locationCity }
        return "\(locationCity), \(locationState) (\(locationRadiusMiles) mi)"
    }

    var hasLocation: Bool {
        locationCity == "Anywhere" || (!locationCity.isEmpty && !locationState.isEmpty)
    }

    var formattedDuration: String {
        durationValue.isEmpty ? "" : durationUnit.format(value: durationValue)
    }

    // Keep legacy accessors for compatibility
    var location: String {
        get { locationDisplay }
        set { locationCity = newValue }
    }

    var duration: String {
        get { formattedDuration }
        set {
            let parsed = DurationUnit.parse(newValue)
            durationValue = parsed.value
            durationUnit = parsed.unit
        }
    }
    var isSubmitting: Bool = false
    var errors: [String: String] = [:]
    var showContent = false
    var showPaymentSheet: Bool = false
    var pendingTaskId: String?

    // MARK: - AI Pricing (v1.8.0)

    var useAIPricing: Bool = false
    var showAIPricingModal: Bool = false
    var aiSuggestion: AIPriceSuggestion?
    var taskWasAIPriced: Bool = false

    // MARK: - Computed Properties

    var isValid: Bool {
        let baseValid = !title.isEmpty &&
            description.count >= 10 &&
            hasLocation &&
            errors.isEmpty

        if useAIPricing {
            return baseValid
        } else {
            return baseValid && !payment.isEmpty && Double(payment) != nil
        }
    }

    var paymentAmount: Double {
        Double(payment) ?? 0
    }

    // MARK: - Validation

    func validateTitle(_ newValue: String) {
        if newValue.isEmpty {
            errors["title"] = "Title is required"
        } else if newValue.count < 5 {
            errors["title"] = "Title must be at least 5 characters"
        } else {
            errors.removeValue(forKey: "title")
        }
    }

    func handleAIPricingToggle(_ newValue: Bool) {
        if newValue {
            payment = ""
            taskWasAIPriced = false
        }
    }

    // MARK: - Duration Selection

    func selectDuration(_ value: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            duration = value
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    // MARK: - Tier Selection

    func selectTier(_ tier: TrustTier) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            requiredTier = tier
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    // MARK: - Category Detection

    func determineCategory() -> TaskCategory {
        let lowercaseDesc = description.lowercased()
        let lowercaseTitle = title.lowercased()

        if lowercaseDesc.contains("deliver") || lowercaseTitle.contains("deliver") {
            return .delivery
        } else if lowercaseDesc.contains("clean") || lowercaseTitle.contains("clean") {
            return .cleaning
        } else if lowercaseDesc.contains("move") || lowercaseDesc.contains("furniture") {
            return .moving
        } else if lowercaseDesc.contains("yard") || lowercaseDesc.contains("lawn") || lowercaseDesc.contains("garden") {
            return .yardWork
        } else if lowercaseDesc.contains("dog") || lowercaseDesc.contains("pet") || lowercaseDesc.contains("walk") {
            return .petCare
        } else if lowercaseDesc.contains("shop") || lowercaseDesc.contains("grocery") || lowercaseDesc.contains("errand") {
            return .shopping
        } else if lowercaseDesc.contains("assemble") || lowercaseDesc.contains("repair") || lowercaseDesc.contains("fix") {
            return .assembly
        }
        return .other
    }

    /// Auto-assign template and risk based on category
    func updateTemplateFromCategory() {
        let cat = determineCategory()
        templateSlug = cat.templateSlug
        switch cat {
        case .cleaning, .handyman:
            riskLevel = "MEDIUM"
        case .childcare, .elderCare:
            riskLevel = "HIGH"
        case .petCare:
            riskLevel = "MEDIUM"
        case .contentCreator, .creativeProduction, .eventAppearance:
            riskLevel = "MEDIUM"
        case .specializedLicensed:
            riskLevel = "MEDIUM"
        case .wildcardBizarre:
            riskLevel = "MEDIUM"
        default:
            riskLevel = "LOW"
        }
    }

    // MARK: - Actions

    func postTask() {
        guard isValid else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // If AI pricing is enabled, get suggestion first
        if useAIPricing && aiSuggestion == nil {
            requestAIPricing()
            return
        }

        // Proceed with posting
        submitTask()
    }

    func requestAIPricing() {
        isSubmitting = true

        Task {
            do {
                struct EvalInput: Codable {
                    let description: String
                }
                struct ScopeProposal: Codable {
                    let suggested_price_cents: Int?
                    let price_reasoning: String?
                    let suggested_xp: Int?
                    let difficulty: String?
                    let estimated_duration_minutes: Int?
                    let confidence_score: Double?
                }
                struct EvalResponse: Codable {
                    let scopeProposal: ScopeProposal?
                }

                let response: EvalResponse = try await TRPCClient.shared.call(
                    router: "task",
                    procedure: "evaluateDraft",
                    input: EvalInput(description: description)
                )

                if let proposal = response.scopeProposal,
                   let priceCents = proposal.suggested_price_cents {
                    let category = determineCategory()
                    let range = category.basePriceRange

                    aiSuggestion = AIPriceSuggestion(
                        suggestedPriceCents: priceCents,
                        xpReward: proposal.suggested_xp ?? (priceCents / 10),
                        rationale: proposal.price_reasoning ?? "AI-suggested price based on task analysis",
                        priceRangeLowCents: range.lowerBound,
                        priceRangeHighCents: range.upperBound,
                        confidence: (proposal.confidence_score ?? 0.5) > 0.7 ? .high : .medium,
                        factors: [
                            PricingFactor(name: "Difficulty", impact: proposal.difficulty == "hard" ? .positive : .neutral, description: (proposal.difficulty ?? "medium").capitalized),
                            PricingFactor(name: "AI Analysis", impact: .neutral, description: proposal.price_reasoning ?? "Based on similar tasks"),
                        ]
                    )

                    // Also update duration if AI provided it
                    if let durMins = proposal.estimated_duration_minutes, durationValue.isEmpty {
                        if durMins < 60 {
                            durationValue = "\(durMins)"
                            durationUnit = .hours
                        } else if durMins < 1440 {
                            durationValue = "\(durMins / 60)"
                            durationUnit = .hours
                        } else {
                            durationValue = "\(durMins / 1440)"
                            durationUnit = .days
                        }
                    }

                    isSubmitting = false
                    showAIPricingModal = true
                } else {
                    // Fallback to local heuristic
                    let category = determineCategory()
                    let request = AIPricingRequest(title: title, description: description, category: category, estimatedDuration: formattedDuration, location: locationDisplay)
                    aiSuggestion = request.generateMockSuggestion()
                    isSubmitting = false
                    showAIPricingModal = true
                }
            } catch {
                HXLogger.error("AI Pricing failed: \(error.localizedDescription) — using local fallback", category: "AI")
                let category = determineCategory()
                let request = AIPricingRequest(title: title, description: description, category: category, estimatedDuration: formattedDuration, location: locationDisplay)
                aiSuggestion = request.generateMockSuggestion()
                isSubmitting = false
                showAIPricingModal = true
            }
        }
    }

    func acceptAISuggestion() {
        guard let suggestion = aiSuggestion else { return }
        payment = String(format: "%.2f", suggestion.suggestedPriceDollars)
        taskWasAIPriced = true
        submitTask()
    }

    func editAISuggestion() {
        guard let suggestion = aiSuggestion else { return }
        payment = String(format: "%.0f", suggestion.suggestedPriceDollars)
        useAIPricing = false
        taskWasAIPriced = true
    }

    func submitTask() {
        guard let dataService, let router else { return }

        isSubmitting = true

        Task {
            do {
                let newTask = try await taskService.createTask(
                    title: title,
                    description: description,
                    payment: paymentAmount,
                    location: locationDisplay,
                    locationCity: locationCity,
                    locationState: locationState,
                    locationRadiusMiles: locationRadiusMiles,
                    latitude: nil,
                    longitude: nil,
                    estimatedDuration: formattedDuration.isEmpty ? "1 hr" : formattedDuration,
                    category: determineCategory(),
                    templateSlug: templateSlug,
                    requiredTier: requiredTier,
                    requiredSkills: nil,
                    deadline: deadline
                )

                HXLogger.info("CreateTask: Task created via API - \(newTask.id)", category: "Task")

                pendingTaskId = newTask.id

                let paymentIntent = try await escrowService.createPaymentIntent(taskId: newTask.id)
                HXLogger.info("CreateTask: Payment intent created - \(paymentIntent.paymentIntentId)", category: "Task")

                let stripeManager = StripePaymentManager.shared
                stripeManager.preparePaymentSheet(clientSecret: paymentIntent.clientSecret)

                let result = await stripeManager.presentPaymentSheet()

                switch result {
                case .completed:
                    HXLogger.info("CreateTask: Stripe payment completed", category: "Task")

                    do {
                        _ = try await escrowService.confirmFunding(
                            escrowId: paymentIntent.escrowId,
                            stripePaymentIntentId: paymentIntent.paymentIntentId
                        )
                        HXLogger.info("CreateTask: Escrow funded successfully", category: "Task")
                    } catch {
                        HXLogger.error("CreateTask: Escrow confirm failed - \(error.localizedDescription)", category: "Task")
                    }

                    // Update local cache directly using the task we already created above —
                    // do NOT call dataService.postTask() because that would create another
                    // task on the backend (it makes its own createTask API call).
                    dataService.availableTasks.insert(newTask, at: 0)
                    dataService.postedTasks.insert(newTask, at: 0)

                    stripeManager.reset()
                    isSubmitting = false
                    router.popPoster()

                case .canceled:
                    HXLogger.error("CreateTask: Payment canceled by user", category: "Task")
                    stripeManager.reset()
                    isSubmitting = false

                case .failed(error: let error):
                    HXLogger.error("CreateTask: Stripe payment failed - \(error.localizedDescription)", category: "Task")
                    stripeManager.reset()
                    isSubmitting = false
                }

            } catch {
                HXLogger.error("CreateTask: API failed - \(error.localizedDescription)", category: "Task")
                // Surface the error — don't silently fall back to creating a duplicate task.
                ErrorToastManager.shared.show("Couldn't post task: \(error.localizedDescription)")
                isSubmitting = false
            }
        }
    }
}
