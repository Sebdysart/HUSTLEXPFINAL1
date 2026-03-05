//
//  BetaDashboardScreen.swift
//  hustleXP final1
//
//  Beta admin dashboard — shows beta health: status banner with caps/guardrails,
//  metrics grid (8 key metrics), and kill signal monitoring.
//  Wired to betaDashboard tRPC procedures.
//

import SwiftUI

// MARK: - Response Models

struct BetaMetricsResponse: Decodable {
    let tasksCreated: Int
    let tasksCompleted: Int
    let gmvCents: Int
    let platformRevenueCents: Int
    let disputeRate: Double
    let conversionToPaid: Double
    let avgTaskPriceCents: Int
    let avgTimeToAcceptanceMinutes: Double
    let p50AcceptanceMinutes: Double
    let p95AcceptanceMinutes: Double
    let avgTimeToCompletionMinutes: Double
    let repeatPosterRate: Double
    let repeatHustlerRate: Double
    let totalUsers: Int
    let activeUsers7d: Int
}

struct BetaStatusResponse: Decodable {
    let enabled: Bool
    let region: String
    let bounds: BetaBounds?
    let startDate: String
    let endDate: String
    let daysRemaining: Int
    let users: BetaCap
    let tasks: BetaCap
    let gmvCents: BetaCap
    // Guardrail booleans are flat at top level (not nested)
    let canCreateUser: Bool
    let canCreateTask: Bool
    let withinGmvCap: Bool
    let withinDateWindow: Bool

    struct BetaBounds: Decodable {
        let north: Double?
        let south: Double?
        let east: Double?
        let west: Double?
    }
}

struct BetaCap: Decodable {
    let current: Int
    let max: Int
    let pct: Double
}

/// Wrapper for getKillSignals response: { signals: [...], shouldKill: bool }
struct BetaKillSignalsResponse: Decodable {
    let signals: [BetaKillSignal]
    let shouldKill: Bool
}

struct BetaKillSignal: Decodable, Identifiable {
    let name: String
    let triggered: Bool
    let detail: String

    var id: String { name }
}

// MARK: - Input Models

struct BetaMetricsInput: Encodable {
    let windowDays: Int
}

/// Placeholder for procedures that take no input.
/// Encodes to `{}` which TRPCClient treats as empty.
private struct EmptyInput: Encodable {}

// MARK: - View

struct BetaDashboardScreen: View {
    @State private var metrics: BetaMetricsResponse?
    @State private var status: BetaStatusResponse?
    @State private var killSignals: [BetaKillSignal] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(Color.brandPurple)
                    .scaleEffect(1.2)
            } else if let errorMessage {
                errorStateView(message: errorMessage)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        if let status {
                            betaStatusSection(status)
                        }

                        if let metrics {
                            metricsGridSection(metrics)
                        }

                        if !killSignals.isEmpty {
                            killSignalsSection(killSignals)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Beta Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { await loadDashboard() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color.brandPurple)
                }
                .accessibilityLabel("Refresh dashboard")
            }
        }
        .task { await loadDashboard() }
    }

    // MARK: - Data Loading

    private func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        do {
            async let metricsCall: BetaMetricsResponse = TRPCClient.shared.call(
                router: "betaDashboard",
                procedure: "getMetrics",
                type: .query,
                input: BetaMetricsInput(windowDays: 30)
            )
            async let statusCall: BetaStatusResponse = TRPCClient.shared.call(
                router: "betaDashboard",
                procedure: "getStatus",
                type: .query,
                input: EmptyInput()
            )
            async let killCall: BetaKillSignalsResponse = TRPCClient.shared.call(
                router: "betaDashboard",
                procedure: "getKillSignals",
                type: .query,
                input: EmptyInput()
            )

            let (m, s, k) = try await (metricsCall, statusCall, killCall)
            metrics = m
            status = s
            killSignals = k.signals
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Section 1: Beta Status Banner

    @ViewBuilder
    private func betaStatusSection(_ status: BetaStatusResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header row: enabled badge + days remaining
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(status.enabled ? Color.successGreen : Color.errorRed)
                        .frame(width: 8, height: 8)
                    HXText(
                        status.enabled ? "Beta Active" : "Beta Disabled",
                        style: .headline,
                        color: status.enabled ? .successGreen : .errorRed
                    )
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                    HXText(
                        "\(status.daysRemaining) days left",
                        style: .subheadline,
                        color: status.daysRemaining <= 7 ? .warningOrange : .textSecondary
                    )
                }
            }

            // Progress bars: Users, Tasks, GMV
            VStack(spacing: 12) {
                capProgressBar(label: "Users", cap: status.users)
                capProgressBar(label: "Tasks", cap: status.tasks)
                capProgressBar(
                    label: "GMV",
                    cap: status.gmvCents,
                    formatter: { formatCents($0) }
                )
            }

            // Guardrails
            VStack(alignment: .leading, spacing: 8) {
                HXText("Guardrails", style: .caption, color: .textSecondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    guardrailIndicator(label: "Create User", ok: status.canCreateUser)
                    guardrailIndicator(label: "Create Task", ok: status.canCreateTask)
                    guardrailIndicator(label: "GMV Cap", ok: status.withinGmvCap)
                    guardrailIndicator(label: "Date Window", ok: status.withinDateWindow)
                }
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }

    @ViewBuilder
    private func capProgressBar(
        label: String,
        cap: BetaCap,
        formatter: ((Int) -> String)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HXText(label, style: .caption, color: .textSecondary)
                Spacer()
                HXText(
                    "\(formatter?(cap.current) ?? "\(cap.current)") / \(formatter?(cap.max) ?? "\(cap.max)")",
                    style: .caption,
                    color: .textSecondary
                )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor(for: cap.pct))
                        .frame(width: max(0, geo.size.width * min(CGFloat(cap.pct) / 100.0, 1.0)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private func guardrailIndicator(label: String, ok: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(ok ? Color.successGreen : Color.errorRed)
            HXText(label, style: .caption)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background((ok ? Color.successGreen : Color.errorRed).opacity(0.08))
        .cornerRadius(8)
    }

    // MARK: - Section 2: Metrics Grid

    @ViewBuilder
    private func metricsGridSection(_ metrics: BetaMetricsResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Key Metrics (30d)", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricCard(
                    icon: "plus.circle.fill",
                    iconColor: .brandPurple,
                    label: "Tasks Created",
                    value: "\(metrics.tasksCreated)"
                )
                metricCard(
                    icon: "checkmark.circle.fill",
                    iconColor: .successGreen,
                    label: "Tasks Completed",
                    value: "\(metrics.tasksCompleted)"
                )
                metricCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: .warningOrange,
                    label: "GMV",
                    value: formatCents(metrics.gmvCents)
                )
                metricCard(
                    icon: "banknote.fill",
                    iconColor: .successGreen,
                    label: "Revenue",
                    value: formatCents(metrics.platformRevenueCents)
                )
                metricCard(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .errorRed,
                    label: "Dispute Rate",
                    value: formatPercent(metrics.disputeRate)
                )
                metricCard(
                    icon: "person.2.fill",
                    iconColor: .infoBlue,
                    label: "Active Users 7d",
                    value: "\(metrics.activeUsers7d)"
                )
                metricCard(
                    icon: "tag.fill",
                    iconColor: .brandPurple,
                    label: "Avg Task Price",
                    value: formatCents(metrics.avgTaskPriceCents)
                )
                metricCard(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .infoBlue,
                    label: "Repeat Poster Rate",
                    value: formatPercent(metrics.repeatPosterRate)
                )
            }
        }
    }

    @ViewBuilder
    private func metricCard(icon: String, iconColor: Color, label: String, value: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                HXText(value, style: .title2)
                HXText(label, style: .caption, color: .textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }

    // MARK: - Section 3: Kill Signals

    @ViewBuilder
    private func killSignalsSection(_ signals: [BetaKillSignal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Kill Signals", style: .caption, color: .textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 10) {
                ForEach(signals) { signal in
                    killSignalCard(signal)
                }
            }
        }
    }

    @ViewBuilder
    private func killSignalCard(_ signal: BetaKillSignal) -> some View {
        HStack(spacing: 12) {
            Image(systemName: signal.triggered ? "exclamationmark.octagon.fill" : "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(signal.triggered ? Color.errorRed : Color.successGreen)

            VStack(alignment: .leading, spacing: 4) {
                HXText(humanizeSignal(signal.name), style: .subheadline)
                HXText(signal.detail, style: .caption, color: .textSecondary)
            }

            Spacer()

            HXText(
                signal.triggered ? "ALERT" : "OK",
                style: .caption,
                color: signal.triggered ? .errorRed : .successGreen
            )
        }
        .padding(14)
        .background(
            signal.triggered
                ? Color.errorRed.opacity(0.08)
                : Color.surfaceElevated
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    signal.triggered ? Color.errorRed.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }

    // MARK: - Error State

    @ViewBuilder
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.textTertiary)

            HXText("Failed to load dashboard", style: .headline)

            HXText(message, style: .caption, color: .textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                Task { await loadDashboard() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .foregroundStyle(Color.brandPurple)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.brandPurple.opacity(0.12))
                .cornerRadius(12)
            }
            .accessibilityLabel("Retry loading dashboard")
        }
    }

    // MARK: - Formatting Helpers

    private func formatCents(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
    }

    private func formatPercent(_ value: Double) -> String {
        return String(format: "%.1f%%", value * 100)
    }

    private func humanizeSignal(_ signal: String) -> String {
        signal
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { word in
                let lower = word.lowercased()
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }
            .joined(separator: " ")
    }

    private func progressColor(for percentage: Double) -> Color {
        if percentage >= 90 { return .errorRed }
        if percentage >= 70 { return .warningOrange }
        return .brandPurple
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BetaDashboardScreen()
    }
}
