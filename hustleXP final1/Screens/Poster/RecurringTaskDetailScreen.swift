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
                // Mock: would call RecurringTaskService.shared.cancelSeries
            }
        } message: {
            Text("This will stop all future occurrences. Any active occurrence will still complete. This cannot be undone.")
        }
        .task {
            loadMockData()
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
                    // Mock: would call RecurringTaskService.shared.pauseSeries
                }
            } else if series.isPaused {
                actionButton(
                    title: "Resume Series",
                    icon: "play.circle.fill",
                    color: .successGreen,
                    variant: .secondary
                ) {
                    // Mock: would call RecurringTaskService.shared.resumeSeries
                }
            }

            // Edit schedule
            actionButton(
                title: "Edit Schedule",
                icon: "pencil.circle.fill",
                color: .recurringBlue,
                variant: .secondary
            ) {
                // Mock: would present edit sheet
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

    // MARK: - Mock Data

    private func loadMockData() {
        isLoading = true

        let now = Date()
        let calendar = Calendar.current

        series = RecurringTaskSeries(
            id: seriesId,
            posterId: "poster-001",
            templateTaskId: "task-template-001",
            pattern: .weekly,
            dayOfWeek: 2,
            dayOfMonth: nil,
            timeOfDay: "09:00",
            startDate: calendar.date(byAdding: .day, value: -42, to: now) ?? now,
            endDate: nil,
            title: "Mow the Front & Back Lawn",
            description: "Full mow of front and back yard, edge along walkways, bag clippings.",
            payment: 45,
            location: "742 Evergreen Terrace",
            category: .yardWork,
            estimatedDuration: "1.5 hours",
            requiredTier: .rookie,
            status: .active,
            occurrenceCount: 6,
            completedCount: 5,
            preferredWorkerId: "hustler-007",
            preferredWorkerName: "Marcus T.",
            createdAt: calendar.date(byAdding: .day, value: -42, to: now) ?? now,
            updatedAt: now,
            nextOccurrence: calendar.date(byAdding: .day, value: 3, to: now)
        )

        occurrences = [
            RecurringOccurrence(
                id: "occ-6",
                seriesId: seriesId,
                taskId: "task-gen-6",
                occurrenceNumber: 6,
                scheduledDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                status: .completed,
                workerId: "hustler-007",
                workerName: "Marcus T.",
                completedAt: calendar.date(byAdding: .day, value: -1, to: now),
                rating: 5
            ),
            RecurringOccurrence(
                id: "occ-5",
                seriesId: seriesId,
                taskId: "task-gen-5",
                occurrenceNumber: 5,
                scheduledDate: calendar.date(byAdding: .day, value: -8, to: now) ?? now,
                status: .completed,
                workerId: "hustler-007",
                workerName: "Marcus T.",
                completedAt: calendar.date(byAdding: .day, value: -8, to: now),
                rating: 5
            ),
            RecurringOccurrence(
                id: "occ-4",
                seriesId: seriesId,
                taskId: "task-gen-4",
                occurrenceNumber: 4,
                scheduledDate: calendar.date(byAdding: .day, value: -15, to: now) ?? now,
                status: .skipped,
                workerId: nil,
                workerName: nil,
                completedAt: nil,
                rating: nil
            ),
            RecurringOccurrence(
                id: "occ-3",
                seriesId: seriesId,
                taskId: "task-gen-3",
                occurrenceNumber: 3,
                scheduledDate: calendar.date(byAdding: .day, value: -22, to: now) ?? now,
                status: .completed,
                workerId: "hustler-007",
                workerName: "Marcus T.",
                completedAt: calendar.date(byAdding: .day, value: -22, to: now),
                rating: 4
            ),
            RecurringOccurrence(
                id: "occ-2",
                seriesId: seriesId,
                taskId: "task-gen-2",
                occurrenceNumber: 2,
                scheduledDate: calendar.date(byAdding: .day, value: -29, to: now) ?? now,
                status: .completed,
                workerId: "hustler-007",
                workerName: "Marcus T.",
                completedAt: calendar.date(byAdding: .day, value: -29, to: now),
                rating: 5
            ),
        ]

        isLoading = false
    }
}

// MARK: - Action Variant

private enum ActionVariant {
    case secondary
    case danger
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecurringTaskDetailScreen(seriesId: "test-series-1")
    }
    .environment(Router())
    .environment(AppState())
}
