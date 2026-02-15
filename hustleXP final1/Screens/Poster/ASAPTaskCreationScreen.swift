//
//  ASAPTaskCreationScreen.swift
//  hustleXP final1
//
//  ASAP Task Creation - "I need help NOW" urgent task posting
//  Instant escrow, surge pricing, and live worker matching
//

import SwiftUI

struct ASAPTaskCreationScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(LiveDataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: LiveTaskCategory = .other
    @State private var basePayment: Double = 40
    @State private var location: String = ""
    @State private var currentStep: Int = 1
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    @State private var createdQuest: QuestAlert?
    @State private var userLocation: GPSCoordinates?
    @State private var nearbyWorkerCount: Int = 0
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case title, description, location
    }
    
    private let liveModeService = MockLiveModeService.shared
    
    @State private var apiPrice: PriceCalculation?

    // Pricing calculation
    private var urgencyPremium: Double {
        if let apiPrice = apiPrice {
            return Double(apiPrice.asapPremiumCents ?? 0) / 100.0
        }
        return basePayment * 0.25 // 25% surge fallback
    }

    private var totalPayment: Double {
        if let apiPrice = apiPrice {
            return Double(apiPrice.finalPriceCents) / 100.0
        }
        return basePayment + urgencyPremium
    }
    
    private var estimatedETA: String {
        if nearbyWorkerCount > 3 {
            return "~3-5 min"
        } else if nearbyWorkerCount > 0 {
            return "~5-10 min"
        } else {
            return "~10-15 min"
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && title.count >= 5 &&
        !description.isEmpty && description.count >= 10 &&
        !location.isEmpty &&
        basePayment >= 20
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundLayer
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Progress indicator
                    progressIndicator
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case 1:
                                categoryStep
                            case 2:
                                detailsStep
                            case 3:
                                pricingStep
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                
                // Bottom action bar
                VStack {
                    Spacer()
                    bottomActionBar
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showConfirmation) {
            if let quest = createdQuest {
                QuestCreatedConfirmation(quest: quest) {
                    dismiss()
                    router.navigateToHustler(.onTheWayTracking(trackingId: quest.id))
                }
            }
        }
        .task {
            await loadLocation()
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            // Urgent red glow
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.errorRed.opacity(0.2), Color.errorRed.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: -100)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Button(action: handleBack) {
                Image(systemName: currentStep == 1 ? "xmark" : "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surfaceElevated))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 8, height: 8)
                    Text("ASAP REQUEST")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.errorRed)
                }
                
                Text("Step \(currentStep) of 3")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textMuted)
            }
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.errorRed : Color.surfaceSecondary)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Step 1: Category
    
    private var categoryStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What do you need help with?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Select the category that best fits your urgent need")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Category grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(LiveTaskCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    )
                }
            }
            
            // Nearby workers info
            if nearbyWorkerCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.successGreen)
                    
                    Text("\(nearbyWorkerCount) workers nearby ready to help")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.successGreen.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - Step 2: Details
    
    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tell us more")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Be specific so workers know exactly what you need")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("What's the issue?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("", text: $title, prompt: Text(titlePlaceholder).foregroundColor(.textMuted))
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .title ? Color.errorRed : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .title)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional details")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("", text: $description, prompt: Text("What should the helper know?").foregroundColor(.textMuted), axis: .vertical)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(3...6)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .description ? Color.errorRed : Color.borderSubtle, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .description)
            }
            
            // Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Where are you?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.errorRed)
                    
                    TextField("", text: $location, prompt: Text("Address or landmark").foregroundColor(.textMuted))
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textPrimary)
                        .focused($focusedField, equals: .location)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .location ? Color.errorRed : Color.borderSubtle, lineWidth: 1)
                )
                
                Button(action: useCurrentLocation) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 14))
                        Text("Use current location")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
        }
    }
    
    private var titlePlaceholder: String {
        switch selectedCategory {
        case .lockout: return "e.g., Locked out of my apartment"
        case .jumpstart: return "e.g., Car battery dead, need jump"
        case .lifting: return "e.g., Need help moving heavy furniture"
        case .delivery: return "e.g., Urgent pickup needed"
        default: return "Briefly describe your urgent need"
        }
    }
    
    // MARK: - Step 3: Pricing
    
    private var pricingStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Set your price")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Higher pay = faster response time")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Price selector
            VStack(spacing: 16) {
                // Total with breakdown
                VStack(spacing: 8) {
                    Text("$\(Int(totalPayment))")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(Color.moneyGreen)
                    
                    HStack(spacing: 4) {
                        Text("Base: $\(Int(basePayment))")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textSecondary)
                        
                        Text("+")
                            .foregroundStyle(Color.textMuted)
                        
                        Text("Surge: $\(Int(urgencyPremium))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.warningOrange)
                    }
                }
                
                // Slider
                Slider(value: $basePayment, in: 20...150, step: 5)
                    .tint(Color.moneyGreen)
                    .onChange(of: basePayment) { _, newValue in
                        // v2.2.0: Recalculate price via API
                        Task {
                            do {
                                apiPrice = try await PricingService.shared.calculatePrice(
                                    basePriceCents: Int(newValue * 100),
                                    mode: "LIVE",
                                    category: selectedCategory.rawValue,
                                    isASAP: true
                                )
                            } catch {
                                apiPrice = nil
                            }
                        }
                    }
                
                // Quick amounts
                HStack(spacing: 10) {
                    ForEach([25, 40, 60, 80, 100], id: \.self) { amount in
                        Button(action: {
                            withAnimation {
                                basePayment = Double(amount)
                            }
                        }) {
                            Text("$\(amount)")
                                .font(.system(size: 14, weight: basePayment == Double(amount) ? .bold : .medium))
                                .foregroundStyle(basePayment == Double(amount) ? .white : Color.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(basePayment == Double(amount) ? Color.moneyGreen : Color.surfaceElevated)
                                )
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
            )
            
            // ETA estimate
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated arrival")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textMuted)
                    
                    Text(estimatedETA)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.brandPurple)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandPurple.opacity(0.1))
            )
            
            // Escrow notice
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.successGreen)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Instant Escrow")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Your payment will be held securely until the task is complete")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.successGreen.opacity(0.1))
            )
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            HStack(spacing: 12) {
                if currentStep < 3 {
                    Button(action: nextStep) {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.headline.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.errorRed)
                        )
                    }
                    .disabled(!canProceed)
                    .opacity(canProceed ? 1 : 0.5)
                } else {
                    Button(action: submitQuest) {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("BROADCAST QUEST")
                                    .font(.headline.weight(.bold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.errorRed, Color.errorRed.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.errorRed.opacity(0.4), radius: 12, y: 4)
                    }
                    .disabled(!isValid || isSubmitting)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .colorScheme(.dark)
            )
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 1: return true // Category always selected
        case 2: return !title.isEmpty && !description.isEmpty && !location.isEmpty
        case 3: return isValid
        default: return false
        }
    }
    
    // MARK: - Actions
    
    private func handleBack() {
        if currentStep > 1 {
            withAnimation {
                currentStep -= 1
            }
        } else {
            dismiss()
        }
    }
    
    private func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }
    
    private func useCurrentLocation() {
        location = "Current Location (GPS)"
    }
    
    private func submitQuest() {
        guard isValid, let coords = userLocation else { return }
        
        isSubmitting = true
        
        // Create the task
        let task = HXTask(
            id: UUID().uuidString,
            title: title,
            description: description,
            payment: basePayment,
            location: location,
            latitude: coords.latitude,
            longitude: coords.longitude,
            estimatedDuration: "15-30 min",
            posterId: appState.userId ?? "poster-asap",
            posterName: "You",
            posterRating: 5.0,
            hustlerId: nil,
            hustlerName: nil,
            state: .posted,
            requiredTier: .elite,
            createdAt: Date(),
            claimedAt: nil,
            completedAt: nil
        )
        
        // Create quest alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let quest = liveModeService.createQuestAlert(
                task: task,
                posterLocation: coords,
                category: selectedCategory
            )
            
            createdQuest = quest
            isSubmitting = false
            showConfirmation = true
            
            // Haptic
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.success)
        }
    }
    
    private func loadLocation() async {
        let (coords, _) = await LocationService.current.captureLocation()
        userLocation = coords
        nearbyWorkerCount = Int.random(in: 2...6)
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let category: LiveTaskCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color.opacity(0.2) : Color.surfaceSecondary)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? category.color : Color.textMuted)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? category.color.opacity(0.1) : Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? category.color : Color.borderSubtle, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Quest Created Confirmation

private struct QuestCreatedConfirmation: View {
    let quest: QuestAlert
    let onDismiss: () -> Void
    
    @State private var pulseGlow = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.errorRed.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseGlow ? 1.2 : 1.0)
                    .opacity(pulseGlow ? 0 : 1)
                
                Circle()
                    .fill(Color.errorRed.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.errorRed)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    pulseGlow = true
                }
            }
            
            VStack(spacing: 8) {
                Text("Quest Broadcasting!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Your request is now visible to \nelite workers nearby")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Quest summary
            VStack(spacing: 12) {
                HStack {
                    Text(quest.task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                }
                
                HStack {
                    Label("Expires in \(quest.decisionWindowSeconds)s", systemImage: "timer")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.errorRed)
                    
                    Spacer()
                    
                    Text("$\(Int(quest.totalPayment))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Track Worker")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.brandPurple)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.brandBlack.ignoresSafeArea())
    }
}

// MARK: - Preview

#Preview {
    ASAPTaskCreationScreen()
        .environment(Router())
        .environment(LiveDataService.shared)
}
