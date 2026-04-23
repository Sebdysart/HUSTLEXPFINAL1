//
//  EarningsScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct EarningsScreen: View {
    @Environment(LiveDataService.self) private var dataService

    // Live earnings animation state
    @State private var earningsBurst: EarningsEvent?
    @State private var showBurst = false
    @State private var lastHandledEvent: EarningsEvent?

    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: isCompact ? 18 : 24) {
                        // Total earnings hero
                        earningsHero(isCompact: isCompact)

                        // Period breakdown
                        periodBreakdown(isCompact: isCompact)

                        // Recent earnings
                        recentEarnings(isCompact: isCompact)
                    }
                    .padding(.vertical, isCompact ? 12 : 16)
                    .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                }

                // Inline "+$X earned" toast
                if showBurst, let burst = earningsBurst {
                    VStack {
                        earningsBurstBanner(burst)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Spacer()
                    }
                    .padding(.top, 8)
                    .zIndex(10)
                }
            }
        }
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            // Refresh user to get latest earnings on appear
            await dataService.refreshAll()
        }
        .onChange(of: dataService.latestEarningsEvent) { _, newEvent in
            guard let event = newEvent, event != lastHandledEvent else { return }
            lastHandledEvent = event
            earningsBurst = event

            withAnimation(.spring(response: 0.4)) {
                showBurst = true
            }
            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showBurst = false
                }
            }
        }
    }

    // MARK: - Earnings Burst Banner

    private func earningsBurstBanner(_ event: EarningsEvent) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.title2)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("+\(event.formattedPayout) earned")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(event.taskTitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.successGreen, Color.successGreen.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .successGreen.opacity(0.4), radius: 12, y: 4)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Earnings Hero
    
    private func earningsHero(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 8) {
            HXText("Total Earnings", style: .subheadline, color: .textSecondary)
            
            PriceDisplay(
                amount: dataService.currentUser.totalEarnings,
                label: "Lifetime",
                size: .large,
                color: .moneyGreen
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 24 : 32)
        .background(
            LinearGradient(
                colors: [Color.moneyGreen.opacity(0.1), Color.moneyGreen.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(isCompact ? 12 : 16)
        .padding(.horizontal, isCompact ? 16 : 20)
    }
    
    // MARK: - Period Breakdown
    
    private func periodBreakdown(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            HXText("Breakdown", style: .headline)
                .padding(.horizontal, isCompact ? 16 : 20)
            
            VStack(spacing: isCompact ? 8 : 12) {
                EarningsPeriodRow(
                    period: "This Week",
                    amount: dataService.currentUser.totalEarnings * 0.3,
                    icon: "calendar",
                    isCompact: isCompact
                )
                EarningsPeriodRow(
                    period: "This Month",
                    amount: dataService.currentUser.totalEarnings * 0.7,
                    icon: "calendar.badge.clock",
                    isCompact: isCompact
                )
                EarningsPeriodRow(
                    period: "All Time",
                    amount: dataService.currentUser.totalEarnings,
                    icon: "clock.fill",
                    isCompact: isCompact
                )
            }
            .padding(.horizontal, isCompact ? 16 : 20)
        }
    }
    
    // MARK: - Recent Earnings
    
    private func recentEarnings(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            HXText("Recent Earnings", style: .headline)
                .padding(.horizontal, isCompact ? 16 : 20)
            
            if dataService.completedTasks.isEmpty {
                EmptyState(
                    icon: "banknote",
                    title: "No Earnings Yet",
                    message: "Complete tasks to start earning"
                )
            } else {
                VStack(spacing: isCompact ? 6 : 8) {
                    ForEach(dataService.completedTasks.prefix(5)) { task in
                        EarningsTransactionRow(task: task, isCompact: isCompact)
                    }
                }
                .padding(.horizontal, isCompact ? 16 : 20)
            }
        }
    }
}

// MARK: - Earnings Period Row

struct EarningsPeriodRow: View {
    let period: String
    let amount: Double
    let icon: String
    var isCompact: Bool = false
    
    var body: some View {
        HStack {
            HXIcon(icon, size: .small, color: .textSecondary)
            HXText(period, style: .body, color: .textSecondary)
            Spacer()
            HXText("$\(String(format: "%.2f", amount))", style: .headline, color: .moneyGreen)
        }
        .padding(isCompact ? 12 : 16)
        .background(Color.surfaceElevated)
        .cornerRadius(isCompact ? 8 : 10)
    }
}

// MARK: - Earnings Transaction Row

struct EarningsTransactionRow: View {
    let task: HXTask
    var isCompact: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HXText(task.title, style: .subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let date = task.completedAt {
                    HXText(date.formatted(date: .abbreviated, time: .omitted), style: .caption, color: .textSecondary)
                }
            }
            
            Spacer()
            
            HXText("+$\(String(format: "%.0f", task.payment))", style: .headline, color: .successGreen)
        }
        .padding(isCompact ? 12 : 16)
        .background(Color.surfaceElevated)
        .cornerRadius(isCompact ? 8 : 10)
    }
}

#Preview {
    NavigationStack {
        EarningsScreen()
    }
    .environment(LiveDataService.shared)
}
