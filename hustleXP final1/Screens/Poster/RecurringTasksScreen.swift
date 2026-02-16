//
//  RecurringTasksScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity) + C (Task Lifecycle)
//  v2.4.0: Recurring Tasks — Silver-tier unlockable
//
//  Posters can schedule tasks that repeat on a cadence.
//  Requires Trust Tier 3 (Trusted) — "Silver Tier"
//
//  v3.0.0: Refactored — logic extracted to RecurringTasksViewModel
//

import SwiftUI

struct RecurringTasksScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    @State private var viewModel = RecurringTasksViewModel()

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if !viewModel.isUnlocked {
                RecurringLockedView(currentTier: appState.trustTier)
            } else {
                VStack(spacing: 0) {
                    // Filter pills
                    filterBar

                    // Content
                    if viewModel.filteredSeries.isEmpty && !viewModel.isLoading {
                        emptyState
                    } else {
                        seriesList
                    }
                }
                .opacity(viewModel.showContent ? 1 : 0)
                .offset(y: viewModel.showContent ? 0 : 20)
            }
        }
        .navigationTitle("Recurring Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if viewModel.isUnlocked {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.recurringBlue)
                    }
                    .accessibilityLabel("Create recurring task")
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showCreateSheet },
            set: { viewModel.showCreateSheet = $0 }
        )) {
            CreateRecurringTaskSheet()
        }
        .task {
            viewModel.appState = appState
            await viewModel.loadData()
            viewModel.animateContentIn()
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 10) {
            ForEach(RecurringFilter.allCases, id: \.self) { filter in
                Button {
                    viewModel.selectFilter(filter)
                } label: {
                    HStack(spacing: 6) {
                        Text(filter.label)
                            .font(.system(size: 13, weight: .semibold))

                        let count = viewModel.countForFilter(filter)
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    viewModel.selectedFilter == filter
                                        ? Color.white.opacity(0.2)
                                        : Color.textMuted.opacity(0.2)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .foregroundStyle(viewModel.selectedFilter == filter ? .white : Color.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        viewModel.selectedFilter == filter
                            ? Color.recurringBlue
                            : Color.surfaceSecondary
                    )
                    .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Series List

    private var seriesList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(viewModel.filteredSeries) { item in
                    RecurringSeriesCard(series: item) { action in
                        viewModel.handleAction(action, for: item)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            ZStack {
                Circle()
                    .fill(Color.recurringBlue.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.recurringBlue)
            }

            VStack(spacing: 8) {
                Text(viewModel.selectedFilter == .active ? "No Active Recurring Tasks" : "No Recurring Tasks")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)

                Text("Schedule tasks that repeat automatically.\nPerfect for lawn care, cleaning, dog walking, and more.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            // Suggested categories
            VStack(alignment: .leading, spacing: 12) {
                Text("POPULAR FOR RECURRING")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(1)
                    .padding(.horizontal, 4)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(RecurringCategory.suggested.prefix(4)) { cat in
                        suggestedCategoryCard(cat)
                    }
                }
            }
            .padding(.horizontal, 24)

            HXButton("Create Recurring Task", icon: "plus.circle.fill", variant: .primary) {
                viewModel.showCreateSheet = true
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func suggestedCategoryCard(_ cat: RecurringCategory) -> some View {
        Button {
            viewModel.showCreateSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: cat.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(cat.color)

                Text(cat.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Enum

enum RecurringFilter: String, CaseIterable {
    case active, paused, all

    var label: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .all: return "All"
        }
    }
}

enum SeriesAction {
    case pause, resume, cancel
}

// MARK: - Recurring Series Card

private struct RecurringSeriesCard: View {
    let series: RecurringTaskSeries
    let onAction: (SeriesAction) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Pattern icon
                    ZStack {
                        Circle()
                            .fill(series.pattern.color.opacity(0.2))
                            .frame(width: 48, height: 48)

                        Image(systemName: series.pattern.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(series.pattern.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(series.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        HStack(spacing: 8) {
                            Text(series.patternDescription)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(series.pattern.color)

                            if series.isPaused {
                                Text("PAUSED")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.warningOrange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.warningOrange.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(series.formattedPayment)
                            .font(.system(size: 17, weight: .bold))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.moneyGreen)

                        Text("each")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            // Expanded details
            if isExpanded {
                VStack(spacing: 0) {
                    Divider().background(Color.borderSubtle)

                    // Stats
                    HStack(spacing: 0) {
                        seriesStat(value: "\(series.completedCount)", label: "Completed", icon: "checkmark.circle", color: .successGreen)

                        Divider().frame(height: 28).background(Color.borderSubtle)

                        seriesStat(value: series.formattedTotalSpent, label: "Total Spent", icon: "dollarsign.circle", color: .moneyGreen)

                        Divider().frame(height: 28).background(Color.borderSubtle)

                        seriesStat(
                            value: series.nextOccurrenceText,
                            label: "Next",
                            icon: "calendar.badge.clock",
                            color: .recurringBlue
                        )
                    }
                    .padding(.vertical, 14)

                    // Preferred worker
                    if let worker = series.preferredWorkerName {
                        HStack(spacing: 10) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.errorRed)

                            Text("Preferred: \(worker)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.textSecondary)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }

                    // Location
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textMuted)

                        Text(series.location)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    Divider().background(Color.borderSubtle)

                    // Actions
                    HStack(spacing: 12) {
                        if series.isActive {
                            Button {
                                onAction(.pause)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "pause.circle.fill")
                                    Text("Pause")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.warningOrange)
                            }
                        } else if series.isPaused {
                            Button {
                                onAction(.resume)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.circle.fill")
                                    Text("Resume")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.successGreen)
                            }
                        }

                        Spacer()

                        Button {
                            onAction(.cancel)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle")
                                Text("Cancel Series")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.errorRed.opacity(0.7))
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    series.isPaused
                        ? Color.warningOrange.opacity(0.2)
                        : Color.recurringBlue.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    private func seriesStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Recurring Locked View (Tier Gate)

struct RecurringLockedView: View {
    let currentTier: TrustTier

    @State private var showPulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)

                // Locked emblem
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.recurringBlue.opacity(0.1), lineWidth: 1)
                            .frame(width: CGFloat(160 + i * 40), height: CGFloat(160 + i * 40))
                            .scaleEffect(showPulse ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 2).repeatForever().delay(Double(i) * 0.3),
                                value: showPulse
                            )
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.recurringBlue.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 140, height: 140)

                    Circle()
                        .fill(Color.surfaceElevated)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color.recurringBlue.opacity(0.5), lineWidth: 2)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.recurringBlue)

                        Text("SILVER")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(Color.recurringBlue)
                            .tracking(2)
                    }
                }

                VStack(spacing: 12) {
                    Text("Recurring Tasks")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    Text("Schedule tasks that repeat automatically.\nPerfect for regular help you need on a cadence.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Requirements
                VStack(spacing: 12) {
                    Text("UNLOCK REQUIREMENTS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.recurringBlue)
                        .tracking(1.5)

                    VStack(spacing: 10) {
                        ForEach(RecurringTaskTierGate.unlockRequirements) { req in
                            requirementRow(req)
                        }
                    }
                }
                .padding(20)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.recurringBlue.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Benefits
                VStack(spacing: 16) {
                    benefitRow(icon: "arrow.trianglehead.2.clockwise.rotate.90", title: "Auto-Schedule", description: "Tasks repeat daily, weekly, or monthly")
                    benefitRow(icon: "heart.fill", title: "Preferred Workers", description: "Your favorite hustler gets first dibs")
                    benefitRow(icon: "clock.badge.checkmark", title: "Never Forget", description: "Automatic posting — no manual work")
                    benefitRow(icon: "chart.line.uptrend.xyaxis", title: "Track History", description: "See completion rates and spending over time")
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
        .onAppear { showPulse = true }
    }

    private func requirementRow(_ req: UnlockRequirement) -> some View {
        HStack(spacing: 14) {
            Image(systemName: req.icon)
                .font(.system(size: 18))
                .foregroundStyle(req.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(req.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(req.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color.textMuted.opacity(0.5))
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.recurringBlue.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.recurringBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Create Recurring Task Sheet

private struct CreateRecurringTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var payment: Double = 40
    @State private var location = ""
    @State private var pattern: RecurrencePattern = .weekly
    @State private var selectedDayOfWeek: Int = 2  // Tuesday
    @State private var selectedDayOfMonth: Int = 1
    @State private var selectedCategory: RecurringCategory?
    @State private var isCreating = false

    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Category suggestions
                        VStack(alignment: .leading, spacing: 12) {
                            HXText("What type of task?", style: .headline)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(RecurringCategory.suggested) { cat in
                                    Button {
                                        selectedCategory = cat
                                        if title.isEmpty {
                                            title = cat.examples.first ?? cat.name
                                        }
                                        pattern = cat.suggestedPattern
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 16))
                                                .foregroundStyle(cat.color)

                                            Text(cat.name)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(Color.textPrimary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)

                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            selectedCategory?.name == cat.name
                                                ? cat.color.opacity(0.15)
                                                : Color.surfaceElevated
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    selectedCategory?.name == cat.name
                                                        ? cat.color.opacity(0.5)
                                                        : Color.clear,
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Task Title", style: .subheadline, color: .textSecondary)

                            TextField("", text: $title, prompt: Text("e.g., Mow the lawn").foregroundColor(.textTertiary))
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textPrimary)
                                .padding(14)
                                .background(Color.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Details", style: .subheadline, color: .textSecondary)

                            TextField("", text: $description, prompt: Text("Describe the task...").foregroundColor(.textTertiary), axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(3...5)
                                .padding(14)
                                .background(Color.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Location", style: .subheadline, color: .textSecondary)

                            HStack(spacing: 10) {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(Color.brandPurple)

                                TextField("", text: $location, prompt: Text("Address or area").foregroundColor(.textTertiary))
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .padding(14)
                            .background(Color.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Payment
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HXText("Payment per Occurrence", style: .subheadline, color: .textSecondary)
                                Spacer()
                                Text("$\(Int(payment))")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(Color.moneyGreen)
                            }

                            Slider(value: $payment, in: 10...300, step: 5)
                                .tint(Color.brandPurple)
                        }

                        // Recurrence pattern
                        VStack(alignment: .leading, spacing: 12) {
                            HXText("Repeat Schedule", style: .headline)

                            HStack(spacing: 8) {
                                ForEach(RecurrencePattern.allCases, id: \.self) { pat in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            pattern = pat
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: pat.icon)
                                                .font(.system(size: 18))
                                            Text(pat.label)
                                                .font(.system(size: 11, weight: .semibold))
                                        }
                                        .foregroundStyle(pattern == pat ? .white : Color.textMuted)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(pattern == pat ? pat.color : Color.surfaceSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Day selector for weekly
                            if pattern == .weekly || pattern == .biweekly {
                                HStack(spacing: 6) {
                                    ForEach(1...7, id: \.self) { day in
                                        Button {
                                            selectedDayOfWeek = day
                                        } label: {
                                            Text(dayNames[day - 1])
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(selectedDayOfWeek == day ? .white : Color.textMuted)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(selectedDayOfWeek == day ? Color.recurringBlue : Color.surfaceElevated)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Summary
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.recurringBlue)

                            Text("Each occurrence will be posted automatically and charged via your saved payment method.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(14)
                        .background(Color.recurringBlue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Create button
                        HXButton(
                            isCreating ? "Setting Up..." : "Create Recurring Task",
                            icon: "arrow.trianglehead.2.clockwise.rotate.90",
                            variant: .primary,
                            isLoading: isCreating
                        ) {
                            createSeries()
                        }
                        .disabled(title.count < 3 || location.isEmpty || isCreating)
                        .opacity(title.count >= 3 && !location.isEmpty ? 1 : 0.5)

                        Spacer().frame(height: 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Recurring Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                        .accessibilityLabel("Cancel creating recurring task")
                }
            }
        }
    }

    private func createSeries() {
        isCreating = true
        Task {
            do {
                _ = try await RecurringTaskService.shared.createSeries(
                    title: title,
                    description: description,
                    payment: payment,
                    location: location,
                    category: nil,
                    estimatedDuration: "1 hour",
                    requiredTier: .rookie,
                    pattern: pattern,
                    dayOfWeek: (pattern == .weekly || pattern == .biweekly) ? selectedDayOfWeek : nil,
                    dayOfMonth: pattern == .monthly ? selectedDayOfMonth : nil,
                    timeOfDay: "09:00",
                    startDate: Date(),
                    endDate: nil
                )
                dismiss()
            } catch {
                HXLogger.error("CreateRecurring: Failed - \(error.localizedDescription)", category: "Task")
            }
            isCreating = false
        }
    }
}

// MARK: - Preview

#Preview("Recurring Tasks - Unlocked") {
    NavigationStack {
        RecurringTasksScreen()
    }
    .environment(Router())
    .environment({
        let state = AppState()
        state.trustTier = .trusted
        return state
    }())
}

#Preview("Recurring Tasks - Locked") {
    NavigationStack {
        RecurringTasksScreen()
    }
    .environment(Router())
    .environment({
        let state = AppState()
        state.trustTier = .verified
        return state
    }())
}
