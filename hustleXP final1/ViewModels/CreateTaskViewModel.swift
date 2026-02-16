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
    var location: String = ""
    var duration: String = ""
    var requiredTier: TrustTier = .rookie
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
            !description.isEmpty &&
            !location.isEmpty &&
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
        guard let dataService else { return }

        isSubmitting = true

        let category = determineCategory()

        let request = AIPricingRequest(
            title: title,
            description: description,
            category: category,
            estimatedDuration: duration.isEmpty ? nil : duration,
            location: location.isEmpty ? nil : location
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            let suggestion = dataService.getAIPriceSuggestion(for: request)
            self.aiSuggestion = suggestion
            self.isSubmitting = false
            self.showAIPricingModal = true
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
                    location: location,
                    latitude: nil,
                    longitude: nil,
                    estimatedDuration: duration.isEmpty ? "1 hr" : duration,
                    category: determineCategory(),
                    requiredTier: requiredTier,
                    requiredSkills: nil
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

                    let mockTask = HXTask(
                        id: newTask.id,
                        title: title,
                        description: description,
                        payment: paymentAmount,
                        location: location,
                        latitude: nil,
                        longitude: nil,
                        estimatedDuration: duration.isEmpty ? "1 hr" : duration,
                        posterId: dataService.currentUser.id,
                        posterName: dataService.currentUser.name,
                        posterRating: dataService.currentUser.rating,
                        hustlerId: nil,
                        hustlerName: nil,
                        state: .posted,
                        requiredTier: requiredTier,
                        createdAt: Date(),
                        claimedAt: nil,
                        completedAt: nil,
                        aiSuggestedPrice: taskWasAIPriced
                    )
                    dataService.postTask(mockTask)

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
                HXLogger.error("CreateTask: API failed, using mock - \(error.localizedDescription)", category: "Task")

                let mockTask = HXTask(
                    id: "task-\(UUID().uuidString.prefix(8))",
                    title: title,
                    description: description,
                    payment: paymentAmount,
                    location: location,
                    latitude: nil,
                    longitude: nil,
                    estimatedDuration: duration.isEmpty ? "1 hr" : duration,
                    posterId: dataService.currentUser.id,
                    posterName: dataService.currentUser.name,
                    posterRating: dataService.currentUser.rating,
                    hustlerId: nil,
                    hustlerName: nil,
                    state: .posted,
                    requiredTier: requiredTier,
                    createdAt: Date(),
                    claimedAt: nil,
                    completedAt: nil,
                    aiSuggestedPrice: taskWasAIPriced
                )
                dataService.postTask(mockTask)

                isSubmitting = false
                router.popPoster()
            }
        }
    }
}
