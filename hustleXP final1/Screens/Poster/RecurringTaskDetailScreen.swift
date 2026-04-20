//
//  RecurringTaskDetailScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle) — Detail view
//  v2.4.0: Recurring Task Series Detail (Poster-side)
//
//  Shows full detail of a recurring task series including schedule,
//  stats, preferred worker, and recent occurrences.
//

import SwiftUI

struct RecurringTaskDetailScreen: View {
    let seriesId: String

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    @State private var series: RecurringTaskSeries?
    @State private var occurrences: [RecurringOccurrence] = []
    @State private var isLoading = true
    @State private var showContent = false
    @State private var showCancelConfirmation = false
    @State private var showEditSheet = false

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(Color.recurringBlue)
            } else if let series {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: Header
                        headerSection(series)

                        // MARK: Stats Grid
                        statsGrid(series)

                        // MARK: Schedule
                        scheduleSection(series)

                        // MARK: Preferred Worker
                        if series.preferredWorkerName != nil {
                            preferredWorkerSection(series)
                        }

                        // MARK: Recent Occurrences
                        if !occurrences.isEmpty {
                            recentOccurrencesSection
                        }

                        // MARK: Actions
                        actionsSection(series)

                        Spacer().frame(height: 40)
                    }
                    .padding(16)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.textMuted)
                    Text("Series not found")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .navigationTitle("Series Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Cancel Series", isPresented: $showCancelConfirmation) {
            Button("Keep Active", role: .cancel) {}
            Button("Cancel Series", role: .destructive) {
                Task {
                    do {
                        try await RecurringTaskService.shared.cancelSeries(id: seriesId)
                        await loadFromAPI()
                        HXLogger.info("RecurringTaskDetail: Series cancelled", category: "Task")
                    } catch {
                        HXLogger.error("RecurringTaskDetail: Cancel failed - \(error.localizedDescription)", category: "Task")
                    }
                }
            }
        } message: {
            Text("This will stop all future occurrences. Any active occurrence will still complete. This cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            if let series {
                EditRecurringSeriesSheet(series: series) {
                    Task { await loadFromAPI() }
                }
            }
        }
        .task {
            await loadFromAPI()
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
    }

    // MARK: - Header Section

    private func headerSection(_ series: RecurringTaskSeries) -> some View {
        VStack(spacing: 16) {
            // Pattern icon
            ZStack {
                Circle()
                    .fill(series.pattern.color.opacity(0.2))
                    .frame(width: 72, height: 72)

                Image(systemName: series.pattern.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(series.pattern.color)
            }

            VStack(spacing: 6) {
                Text(series.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(series.patternDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(series.pattern.color)
            }

            // Status badge
            statusBadge(series.status)

            // Location
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
                Text(series.location)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(series.pattern.color.opacity(0.2), lineWidth: 1)
        )
    }

    private func statusBadge(_ status: RecurringSeriesStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .active: return ("ACTIVE", .successGreen)
            case .paused: return ("PAUSED", .warningOrange)
            case .completed: return ("COMPLETED", .infoBlue)
            case .cancelled: return ("CANCELLED", .errorRed)
            }
        }()

        return Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(color)
            .tracking(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    // MARK: - Stats Grid

    private func statsGrid(_ series: RecurringTaskSeries) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OVERVIEW")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(
                    value: series.formattedPayment,
                    label: "Per Occurrence",
                    icon: "dollarsign.circle.fill",
                    color: .moneyGreen
                )
                statCard(
                    value: series.formattedTotalSpent,
                    label: "Total Spent",
                    icon: "banknote.fill",
                    color: .moneyGreen
                )
                statCard(
                    value: "\(Int(series.completionRate * 100))%",
                    label: "Completion Rate",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .recurringBlue
                )
                statCard(
                    value: "\(series.occurrenceCount)",
                    label: "Occurrences",
                    icon: "arrow.trianglehead.2.clockwise.rotate.90",
                    color: .recurringBlue
                )
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
            }

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Schedule Section

    private func scheduleSection(_ series: RecurringTaskSeries) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCHEDULE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1)

            VStack(spacing: 0) {
                // Next occurrence
                scheduleRow(
                    icon: "calendar.badge.clock",
                    label: "Next Occurrence",
                    value: series.nextOccurrenceText,
                    color: .recurringBlue
                )

                Divider().background(Color.borderSubtle)

                // Pattern
                scheduleRow(
                    icon: series.pattern.icon,
                    label: "Pattern",
                    value: series.pattern.label,
                    color: series.pattern.color
                )

                Divider().background(Color.borderSubtle)

                // Time of day
                if let time = series.timeOfDay {
                    scheduleRow(
                        icon: "clock.fill",
                        label: "Time",
                        value: time,
                        color: .textSecondary
                    )

                    Divider().background(Color.borderSubtle)
                }

                // Start date
                scheduleRow(
                    icon: "play.circle.fill",
                    label: "Started",
                    value: series.startDate.formatted(date: .abbreviated, time: .omitted),
                    color: .successGreen
                )

                if let endDate = series.endDate {
                    Divider().background(Color.borderSubtle)

                    scheduleRow(
                        icon: "stop.circle.fill",
                        label: "Ends",
                        value: endDate.formatted(date: .abbreviated, time: .omitted),
                        color: .errorRed
                    )
                }

                // Duration
                Divider().background(Color.borderSubtle)

                scheduleRow(
                    icon: "timer",
                    label: "Est. Duration",
                    value: series.estimatedDuration,
                    color: .textSecondary
                )
            }
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func scheduleRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Preferred Worker Section

    private func preferredWorkerSection(_ series: RecurringTaskSeries) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREFERRED WORKER")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.errorRed.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.errorRed)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(series.preferredWorkerName ?? "")
                        .font(.system(size: 16, weight: .semibold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    Text("Gets first dibs on each occurrence")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(series.completedCount)")
                        .font(.system(size: 17, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.successGreen)
                    Text("completed")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.errorRed.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Recent Occurrences Section

    private var recentOccurrencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RECENT OCCURRENCES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(1)

                Spacer()

                Text("\(occurrences.count) total")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }

            VStack(spacing: 0) {
                ForEach(Array(occurrences.prefix(5).enumerated()), id: \.element.id) { index, occurrence in
                    occurrenceRow(occurrence)

                    if index < min(occurrences.count, 5) - 1 {
                        Divider().background(Color.borderSubtle)
                    }
                }
            }
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func occurrenceRow(_ occurrence: RecurringOccurrence) -> some View {
        HStack(spacing: 12) {
            // Occurrence number
            Text("#\(occurrence.occurrenceNumber)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.recurringBlue)
                .frame(width: 32)

            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(occurrence.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textPrimary)

                if let worker = occurrence.workerName {
                    Text(worker)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textMuted)
                }
            }

            Spacer()

            // View Task button for posted/completed/in-progress occurrences
            if occurrence.hasSpawnedTask, let taskId = occurrence.taskId {
                Button {
                    router.navigateToPoster(.taskDetail(taskId: taskId))
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                        Text("View Task")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Color.recurringBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.recurringBlue.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Status badge
            occurrenceStatusBadge(occurrence.status)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func occurrenceStatusBadge(_ status: OccurrenceStatus) -> some View {
        let (text, color, icon): (String, Color, String) = {
            switch status {
            case .completed: return ("Completed", .successGreen, "checkmark.circle.fill")
            case .skipped: return ("Skipped", .warningOrange, "forward.fill")
            case .cancelled: return ("Cancelled", .errorRed, "xmark.circle.fill")
            case .scheduled: return ("Scheduled", .infoBlue, "clock.fill")
            case .posted: return ("Posted", .brandPurple, "arrow.up.circle.fill")
            case .inProgress: return ("In Progress", .warningOrange, "figure.walk")
            }
        }()

        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Actions Section

    private func actionsSection(_ series: RecurringTaskSeries) -> some View {
        VStack(spacing: 12) {
            // Pause / Resume
            if series.isActive {
                actionButton(
                    title: "Pause Series",
                    icon: "pause.circle.fill",
                    color: .warningOrange,
                    variant: .secondary
                ) {
                    Task {
                        do {
                            try await RecurringTaskService.shared.pauseSeries(id: seriesId)
                            await loadFromAPI()
                        } catch {
                            HXLogger.error("RecurringTaskDetail: Pause failed - \(error.localizedDescription)", category: "Task")
                        }
                    }
                }
            } else if series.isPaused {
                actionButton(
                    title: "Resume Series",
                    icon: "play.circle.fill",
                    color: .successGreen,
                    variant: .secondary
                ) {
                    Task {
                        do {
                            try await RecurringTaskService.shared.resumeSeries(id: seriesId)
                            await loadFromAPI()
                        } catch {
                            HXLogger.error("RecurringTaskDetail: Resume failed - \(error.localizedDescription)", category: "Task")
                        }
                    }
                }
            }

            // Edit series
            actionButton(
                title: "Edit Series",
                icon: "pencil.circle.fill",
                color: .recurringBlue,
                variant: .secondary
            ) {
                showEditSheet = true
            }

            // Cancel series
            if series.status != .cancelled && series.status != .completed {
                actionButton(
                    title: "Cancel Series",
                    icon: "xmark.circle.fill",
                    color: .errorRed,
                    variant: .danger
                ) {
                    showCancelConfirmation = true
                }
            }
        }
    }

    private func actionButton(title: String, icon: String, color: Color, variant: ActionVariant, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .minimumScaleFactor(0.7)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            .foregroundStyle(variant == .danger ? Color.errorRed : color)
            .padding(16)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        variant == .danger
                            ? Color.errorRed.opacity(0.2)
                            : Color.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    // MARK: - API Data Loading

    private func loadFromAPI() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let seriesResult = RecurringTaskService.shared.getSeries(id: seriesId)
            async let occurrencesResult = RecurringTaskService.shared.getOccurrences(seriesId: seriesId)

            let (fetchedSeries, fetchedOccurrences) = try await (seriesResult, occurrencesResult)
            self.series = fetchedSeries
            self.occurrences = fetchedOccurrences.sorted { $0.occurrenceNumber > $1.occurrenceNumber }
            HXLogger.info("RecurringTaskDetail: Loaded series '\(fetchedSeries.title)' with \(fetchedOccurrences.count) occurrences", category: "Task")
        } catch {
            HXLogger.error("RecurringTaskDetail: API load failed - \(error.localizedDescription)", category: "Task")
            self.series = nil
            self.occurrences = []
        }
    }
}

// MARK: - Action Variant

private enum ActionVariant {
    case secondary
    case danger
}

// MARK: - Edit Recurring Series Sheet

private struct EditRecurringSeriesSheet: View {
    let series: RecurringTaskSeries
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var payment: String
    @State private var location: String
    @State private var estimatedDuration: String
    @State private var pattern: RecurrencePattern
    @State private var dayOfWeek: Int
    @State private var dayOfMonth: Int
    @State private var endDate: Date?
    @State private var hasEndDate: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(series: RecurringTaskSeries, onSave: @escaping () -> Void) {
        self.series = series
        self.onSave = onSave
        _title = State(initialValue: series.title)
        _description = State(initialValue: series.description ?? "")
        _payment = State(initialValue: String(format: "%.0f", series.payment))
        _location = State(initialValue: series.location)
        _estimatedDuration = State(initialValue: series.estimatedDuration)
        _pattern = State(initialValue: series.pattern)
        _dayOfWeek = State(initialValue: series.dayOfWeek ?? 1)
        _dayOfMonth = State(initialValue: series.dayOfMonth ?? 1)
        _endDate = State(initialValue: series.endDate)
        _hasEndDate = State(initialValue: series.endDate != nil)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && (Double(payment) ?? 0) >= 5
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    fieldSection(label: "Title") {
                        TextField("Series title", text: $title)
                    }

                    // Description
                    fieldSection(label: "Description") {
                        TextField("Describe the task", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    // Payment
                    fieldSection(label: "Payment ($)") {
                        TextField("Amount", text: $payment)
                            .keyboardType(.numberPad)
                    }

                    // Location
                    fieldSection(label: "Location") {
                        TextField("Location", text: $location)
                    }

                    // Duration
                    fieldSection(label: "Estimated Duration") {
                        TextField("e.g. 2 hrs", text: $estimatedDuration)
                    }

                    // Schedule
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Schedule")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        // Pattern picker
                        HStack(spacing: 0) {
                            ForEach(RecurrencePattern.allCases, id: \.self) { p in
                                Button {
                                    pattern = p
                                } label: {
                                    Text(p.label)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(pattern == p ? .white : Color.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(pattern == p ? Color.recurringBlue : Color.surfaceElevated)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderSubtle, lineWidth: 1))

                        // Day picker for weekly/biweekly
                        if pattern == .weekly || pattern == .biweekly {
                            HStack(spacing: 6) {
                                ForEach(1...7, id: \.self) { day in
                                    let names = ["M", "T", "W", "T", "F", "S", "S"]
                                    Button {
                                        dayOfWeek = day
                                    } label: {
                                        Text(names[day - 1])
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(dayOfWeek == day ? .white : Color.textPrimary)
                                            .frame(width: 36, height: 36)
                                            .background(dayOfWeek == day ? Color.recurringBlue : Color.surfaceElevated)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 8)
                        }

                        // Day of month for monthly
                        if pattern == .monthly {
                            HStack {
                                Text("Day of month:")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textSecondary)
                                Picker("", selection: $dayOfMonth) {
                                    ForEach(1...28, id: \.self) { d in
                                        Text("\(d)").tag(d)
                                    }
                                }
                                .tint(.recurringBlue)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // End date
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Set end date", isOn: $hasEndDate)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                            .tint(.recurringBlue)

                        if hasEndDate {
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { endDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date())! },
                                    set: { endDate = $0 }
                                ),
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                            .tint(.recurringBlue)
                        }
                    }

                    // Propagation info
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.infoBlue)
                        Text("Budget changes apply to future occurrences only. Schedule changes regenerate upcoming occurrences.")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(10)
                    .background(Color.infoBlue.opacity(0.1))
                    .cornerRadius(8)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }

                    // Save button
                    Button(action: save) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isValid && !isSaving ? Color.recurringBlue : Color.textMuted.opacity(0.5))
                        )
                    }
                    .disabled(!isValid || isSaving)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBlack)
            .navigationTitle("Edit Series")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            content()
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .padding(14)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderSubtle, lineWidth: 1)
                )
        }
    }

    private func save() {
        guard isValid else { return }
        isSaving = true
        errorMessage = nil

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        Task {
            do {
                _ = try await RecurringTaskService.shared.updateSeries(
                    id: series.id,
                    title: title.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
                    payment: Double(payment),
                    location: location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location,
                    estimatedDuration: estimatedDuration.isEmpty ? nil : estimatedDuration,
                    pattern: pattern != series.pattern ? pattern : nil,
                    dayOfWeek: (pattern == .weekly || pattern == .biweekly) ? dayOfWeek : nil,
                    dayOfMonth: pattern == .monthly ? dayOfMonth : nil,
                    endDate: hasEndDate ? (endDate.map { formatter.string(from: $0) }) : nil
                )
                isSaving = false
                onSave()
                dismiss()
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecurringTaskDetailScreen(seriesId: "test-series-1")
    }
    .environment(Router())
    .environment(AppState())
}
