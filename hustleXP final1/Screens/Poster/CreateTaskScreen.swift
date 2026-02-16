//
//  CreateTaskScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Premium task creation with elegant form and animations
//

import SwiftUI
import StripePaymentSheet

struct CreateTaskScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    // v2.2.0: Real API services
    @StateObject private var taskService = TaskService.shared
    @StateObject private var escrowService = EscrowService.shared
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var payment: String = ""
    @State private var location: String = ""
    @State private var duration: String = ""
    @State private var requiredTier: TrustTier = .rookie
    @State private var isSubmitting: Bool = false
    @State private var errors: [String: String] = [:]
    @State private var showContent = false
    @State private var showPaymentSheet: Bool = false
    @State private var pendingTaskId: String?
    @FocusState private var focusedField: Field?
    
    // v1.8.0 AI Pricing
    @State private var useAIPricing: Bool = false
    @State private var showAIPricingModal: Bool = false
    @State private var aiSuggestion: AIPriceSuggestion?
    @State private var taskWasAIPriced: Bool = false
    
    private enum Field {
        case title, description, payment, location
    }
    
    private var isValid: Bool {
        let baseValid = !title.isEmpty && 
            !description.isEmpty && 
            !location.isEmpty &&
            errors.isEmpty
        
        // If AI pricing is enabled, payment is optional until AI suggests
        if useAIPricing {
            return baseValid
        } else {
            return baseValid && !payment.isEmpty && Double(payment) != nil
        }
    }
    
    private var paymentAmount: Double {
        Double(payment) ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                // Background
                backgroundLayer
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: isCompact ? 18 : 24) {
                        // Title field
                        titleField(isCompact: isCompact)
                        
                        // Description field
                        descriptionField(isCompact: isCompact)
                        
                        // AI Pricing toggle (v1.8.0)
                        aiPricingSection(isCompact: isCompact)
                        
                        // Payment section (hidden when AI pricing enabled)
                        if !useAIPricing {
                            paymentSection(isCompact: isCompact)
                        }
                        
                        // Location field
                        locationField(isCompact: isCompact)
                        
                        // Duration section
                        durationSection(isCompact: isCompact)
                        
                        // Tier section
                        tierSection(isCompact: isCompact)
                        
                        // Summary
                        if isValid {
                            summarySection(isCompact: isCompact)
                        }
                        
                        Spacer(minLength: isCompact ? 100 : 120)
                    }
                    .padding(.horizontal, isCompact ? 16 : 20)
                    .padding(.top, isCompact ? 4 : 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationTitle("Post a Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showAIPricingModal) {
            if let suggestion = aiSuggestion {
                AIPricingSuggestionModal(
                    suggestion: suggestion,
                    onAccept: acceptAISuggestion,
                    onEdit: editAISuggestion
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width

            ZStack {
                Color.brandBlack.ignoresSafeArea()

                VStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.brandPurple.opacity(0.15),
                                    Color.brandPurple.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: screenWidth * 0.46
                            )
                        )
                        .frame(width: screenWidth * 0.92, height: screenWidth * 0.92)
                        .offset(y: -100)

                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Title Field
    
    private func titleField(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack {
                Text("Task Title")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            HStack(spacing: isCompact ? 10 : 12) {
                Image(systemName: "pencil.line")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(focusedField == .title ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                
                TextField("", text: $title, prompt: Text("What needs to be done?").foregroundColor(.textMuted))
                    .font(isCompact ? .subheadline : .body)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: .title)
                    .onChange(of: title) { _, newValue in
                        if newValue.isEmpty {
                            errors["title"] = "Title is required"
                        } else if newValue.count < 5 {
                            errors["title"] = "Title must be at least 5 characters"
                        } else {
                            errors.removeValue(forKey: "title")
                        }
                    }
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .stroke(
                        focusedField == .title ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .title ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            if let error = errors["title"] {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: showContent)
    }
    
    // MARK: - Description Field
    
    private func descriptionField(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack {
                Text("Description")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            HStack(alignment: .top, spacing: isCompact ? 10 : 12) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(focusedField == .description ? Color.brandPurple : Color.textMuted)
                    .frame(width: 20)
                    .padding(.top, 2)
                
                TextField("", text: $description, prompt: Text("Describe the task in detail").foregroundColor(.textMuted), axis: .vertical)
                    .font(isCompact ? .subheadline : .body)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(isCompact ? 2...4 : 3...6)
                    .focused($focusedField, equals: .description)
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .stroke(
                        focusedField == .description ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .description ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
            
            Text("Be specific about what you need done")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.05), value: showContent)
    }
    
    // MARK: - Payment Section
    
    private func paymentSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack {
                Text("Payment")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            HStack(spacing: isCompact ? 10 : 12) {
                // Dollar sign with circle
                ZStack {
                    Circle()
                        .fill(Color.moneyGreen.opacity(0.15))
                        .frame(width: isCompact ? 34 : 40, height: isCompact ? 34 : 40)
                    
                    Text("$")
                        .font(.system(size: isCompact ? 17 : 20, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                }
                
                TextField("0", text: $payment)
                    .keyboardType(.decimalPad)
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: isCompact ? 60 : 80)
                    .focused($focusedField, equals: .payment)
                
                Spacer()
                
                // Quick amount buttons
                HStack(spacing: isCompact ? 6 : 8) {
                    PremiumQuickAmountButton(amount: 25, currentAmount: $payment, isCompact: isCompact)
                    PremiumQuickAmountButton(amount: 50, currentAmount: $payment, isCompact: isCompact)
                    PremiumQuickAmountButton(amount: 100, currentAmount: $payment, isCompact: isCompact)
                }
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .stroke(
                        focusedField == .payment ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .payment ? 2 : 1
                    )
            )
            
            if let error = errors["payment"] {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
    }
    
    // MARK: - Location Field
    
    private func locationField(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack {
                Text("Location")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            HStack(spacing: isCompact ? 10 : 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundStyle(focusedField == .location ? Color.errorRed : Color.textMuted)
                    .frame(width: 20)
                
                TextField("", text: $location, prompt: Text("Where is this task?").foregroundColor(.textMuted))
                    .font(isCompact ? .subheadline : .body)
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: .location)
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 12 : 14)
                    .stroke(
                        focusedField == .location ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .location ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: showContent)
    }
    
    // MARK: - Duration Section
    
    private func durationSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            Text("Estimated Duration")
                .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            
            HStack(spacing: isCompact ? 6 : 10) {
                PremiumDurationChip(title: "30 min", icon: "clock", isSelected: duration == "30 min", isCompact: isCompact) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        duration = "30 min"
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                PremiumDurationChip(title: "1 hr", icon: "clock.fill", isSelected: duration == "1 hr", isCompact: isCompact) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        duration = "1 hr"
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                PremiumDurationChip(title: "2 hrs", icon: "clock.badge.checkmark", isSelected: duration == "2 hrs", isCompact: isCompact) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        duration = "2 hrs"
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                PremiumDurationChip(title: "3+ hrs", icon: "hourglass", isSelected: duration == "3+ hrs", isCompact: isCompact) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        duration = "3+ hrs"
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
    }
    
    // MARK: - Tier Section
    
    private func tierSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            VStack(alignment: .leading, spacing: isCompact ? 3 : 4) {
                Text("Minimum Hustler Tier")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("Higher tiers have more verified hustlers")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            
            HStack(spacing: isCompact ? 6 : 10) {
                ForEach([TrustTier.rookie, .verified, .trusted], id: \.self) { tier in
                    PremiumTierChip(tier: tier, isSelected: requiredTier == tier, isCompact: isCompact) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            requiredTier = tier
                        }
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: showContent)
    }
    
    // MARK: - AI Pricing Section (v1.8.0)
    
    private func aiPricingSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            AIPricingToggle(isEnabled: $useAIPricing, isCompact: isCompact)
                .onChange(of: useAIPricing) { _, newValue in
                    if newValue {
                        // Clear manual price when enabling AI
                        payment = ""
                        taskWasAIPriced = false
                    }
                }
            
            if useAIPricing {
                // AI pricing hint
                HStack(spacing: isCompact ? 6 : 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.aiPurple)
                    
                    Text("Scoper AI will suggest an optimal price based on your task details")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(isCompact ? 10 : 12)
                .background(Color.aiPurple.opacity(0.1))
                .cornerRadius(isCompact ? 8 : 10)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.08), value: showContent)
    }
    
    // MARK: - Summary Section
    
    private func summarySection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    .foregroundStyle(Color.successGreen)
                Text("Task Summary")
                    .font(isCompact ? .subheadline.weight(.semibold) : .headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            VStack(spacing: isCompact ? 10 : 12) {
                PremiumSummaryRow(icon: "briefcase.fill", label: "Task", value: title, color: .brandPurple, isCompact: isCompact)
                
                // Payment row with AI badge if applicable
                HStack {
                    PremiumSummaryRow(
                        icon: "dollarsign.circle.fill",
                        label: "Payment",
                        value: useAIPricing ? "AI will suggest" : "$\(payment)",
                        color: useAIPricing ? .aiPurple : .moneyGreen,
                        isCompact: isCompact
                    )
                    
                    if taskWasAIPriced {
                        AIPricedBadge()
                    }
                }
                
                PremiumSummaryRow(icon: "mappin.circle.fill", label: "Location", value: location, color: .errorRed, isCompact: isCompact)
                PremiumSummaryRow(icon: "clock.fill", label: "Duration", value: duration.isEmpty ? "Not set" : duration, color: .brandPurple, isCompact: isCompact)
                PremiumSummaryRow(icon: "shield.checkered", label: "Min. Tier", value: requiredTier.name, color: .infoBlue, isCompact: isCompact)
            }
            .padding(isCompact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                    .fill(Color.brandPurple.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                            .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
            
            Button(action: postTask) {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Post Task")
                            .font(.headline.weight(.semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isValid
                                ? LinearGradient(
                                    colors: [Color.brandPurple, Color.brandPurpleLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [Color.textMuted, Color.textMuted],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                )
                .shadow(color: isValid ? Color.brandPurple.opacity(0.3) : .clear, radius: 12, y: 4)
            }
            .accessibilityLabel("Post task")
            .disabled(!isValid || isSubmitting)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .colorScheme(.dark)
            )
        }
    }
    
    // MARK: - Actions
    
    private func postTask() {
        guard isValid else { return }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        focusedField = nil
        
        // If AI pricing is enabled, get suggestion first
        if useAIPricing && aiSuggestion == nil {
            requestAIPricing()
            return
        }
        
        // Proceed with posting
        submitTask()
    }
    
    private func requestAIPricing() {
        isSubmitting = true
        
        // Determine category from task details
        let category = determineCategory()
        
        // Create AI pricing request
        let request = AIPricingRequest(
            title: title,
            description: description,
            category: category,
            estimatedDuration: duration.isEmpty ? nil : duration,
            location: location.isEmpty ? nil : location
        )
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let suggestion = dataService.getAIPriceSuggestion(for: request)
            aiSuggestion = suggestion
            isSubmitting = false
            showAIPricingModal = true
        }
    }
    
    private func determineCategory() -> TaskCategory {
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
    
    private func acceptAISuggestion() {
        guard let suggestion = aiSuggestion else { return }
        payment = String(format: "%.2f", suggestion.suggestedPriceDollars)
        taskWasAIPriced = true
        submitTask()
    }
    
    private func editAISuggestion() {
        // Switch to manual pricing mode with AI suggestion as starting point
        guard let suggestion = aiSuggestion else { return }
        payment = String(format: "%.0f", suggestion.suggestedPriceDollars)
        useAIPricing = false
        taskWasAIPriced = true
    }
    
    private func submitTask() {
        isSubmitting = true

        // v2.2.0: Use real API to create task, then present Stripe PaymentSheet
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

                // Store task ID for payment
                pendingTaskId = newTask.id

                // Create payment intent for escrow
                let paymentIntent = try await escrowService.createPaymentIntent(taskId: newTask.id)
                HXLogger.info("CreateTask: Payment intent created - \(paymentIntent.paymentIntentId)", category: "Task")

                // Prepare and present real Stripe PaymentSheet
                let stripeManager = StripePaymentManager.shared
                stripeManager.preparePaymentSheet(clientSecret: paymentIntent.clientSecret)

                let result = await stripeManager.presentPaymentSheet()

                switch result {
                case .completed:
                    // Payment succeeded - confirm escrow funding on backend
                    HXLogger.info("CreateTask: Stripe payment completed", category: "Task")

                    do {
                        _ = try await escrowService.confirmFunding(
                            escrowId: paymentIntent.escrowId,
                            stripePaymentIntentId: paymentIntent.paymentIntentId
                        )
                        HXLogger.info("CreateTask: Escrow funded successfully", category: "Task")
                    } catch {
                        HXLogger.error("CreateTask: Escrow confirm failed - \(error.localizedDescription)", category: "Task")
                        // Payment went through but confirm failed - backend webhook will reconcile
                    }

                    // Also update mock data for consistency
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
                    // Task created but not funded - user can retry from task detail

                case .failed(error: let error):
                    HXLogger.error("CreateTask: Stripe payment failed - \(error.localizedDescription)", category: "Task")
                    stripeManager.reset()
                    isSubmitting = false
                    // Task created but not funded - user can retry from task detail
                }

            } catch {
                HXLogger.error("CreateTask: API failed, using mock - \(error.localizedDescription)", category: "Task")

                // Fall back to mock data
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

// MARK: - Premium Supporting Views

struct PremiumQuickAmountButton: View {
    let amount: Int
    @Binding var currentAmount: String
    var isCompact: Bool = false
    
    private var isSelected: Bool {
        currentAmount == "\(amount)"
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            currentAmount = "\(amount)"
        }) {
            Text("$\(amount)")
                .font(isCompact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .padding(.horizontal, isCompact ? 10 : 14)
                .padding(.vertical, isCompact ? 6 : 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.brandPurple : Color.surfaceSecondary)
                )
        }
    }
}

struct PremiumDurationChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isCompact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .padding(.horizontal, isCompact ? 10 : 14)
                .padding(.vertical, isCompact ? 8 : 10)
                .background(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                        .fill(isSelected ? Color.brandPurple : Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

struct PremiumTierChip: View {
    let tier: TrustTier
    let isSelected: Bool
    var isCompact: Bool = false
    let action: () -> Void
    
    private var tierColor: Color {
        switch tier {
        case .unranked, .rookie: return Color.textSecondary
        case .verified: return Color.brandPurple
        case .trusted: return Color.infoBlue
        case .elite: return Color.moneyGreen
        case .master: return Color.yellow
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 4 : 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundStyle(isSelected ? tierColor : Color.textMuted)
                
                Text(tier.name)
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
            }
            .padding(.horizontal, isCompact ? 10 : 14)
            .padding(.vertical, isCompact ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                    .fill(isSelected ? tierColor.opacity(0.15) : Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                    .stroke(isSelected ? tierColor.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

struct PremiumSummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text(label)
                .font(isCompact ? .footnote : .subheadline)
                .foregroundStyle(Color.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Legacy Supporting Views (kept for compatibility)

struct QuickAmountButton: View {
    let amount: Int
    @Binding var currentAmount: String
    
    var body: some View {
        Button(action: { currentAmount = "\(amount)" }) {
            Text("$\(amount)")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(currentAmount == "\(amount)" ? Color.brandPurple : Color.surfaceSecondary)
                .foregroundStyle(currentAmount == "\(amount)" ? .white : Color.textPrimary)
                .cornerRadius(16)
        }
    }
}

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HXText(title, style: .subheadline, color: isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.brandPurple : Color.surfaceElevated)
                .cornerRadius(20)
        }
    }
}

struct TierChip: View {
    let tier: TrustTier
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                Text(tier.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandPurple.opacity(0.1) : Color.surfaceElevated)
            .foregroundStyle(isSelected ? Color.brandPurple : Color.textPrimary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.brandPurple : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HXText(label, style: .subheadline, color: .textSecondary)
            Spacer()
            HXText(value, style: .subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        CreateTaskScreen()
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
