//
//  EarningsScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct EarningsScreen: View {
    @Environment(MockDataService.self) private var dataService
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Total earnings hero
                    earningsHero
                    
                    // Period breakdown
                    periodBreakdown
                    
                    // Recent earnings
                    recentEarnings
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Earnings Hero
    
    private var earningsHero: some View {
        VStack(spacing: 8) {
            HXText("Total Earnings", style: .subheadline, color: .textSecondary)
            
            PriceDisplay(
                amount: dataService.currentUser.totalEarnings,
                label: "Lifetime",
                size: .large,
                color: .moneyGreen
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [Color.moneyGreen.opacity(0.1), Color.moneyGreen.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Period Breakdown
    
    private var periodBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Breakdown", style: .headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                EarningsPeriodRow(
                    period: "This Week",
                    amount: dataService.currentUser.totalEarnings * 0.3,
                    icon: "calendar"
                )
                EarningsPeriodRow(
                    period: "This Month",
                    amount: dataService.currentUser.totalEarnings * 0.7,
                    icon: "calendar.badge.clock"
                )
                EarningsPeriodRow(
                    period: "All Time",
                    amount: dataService.currentUser.totalEarnings,
                    icon: "clock.fill"
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Earnings
    
    private var recentEarnings: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Recent Earnings", style: .headline)
                .padding(.horizontal)
            
            if dataService.completedTasks.isEmpty {
                EmptyState(
                    icon: "banknote",
                    title: "No Earnings Yet",
                    message: "Complete tasks to start earning"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(dataService.completedTasks.prefix(5)) { task in
                        EarningsTransactionRow(task: task)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Earnings Period Row

struct EarningsPeriodRow: View {
    let period: String
    let amount: Double
    let icon: String
    
    var body: some View {
        HStack {
            HXIcon(icon, size: .small, color: .textSecondary)
            HXText(period, style: .body, color: .textSecondary)
            Spacer()
            HXText("$\(String(format: "%.2f", amount))", style: .headline, color: .moneyGreen)
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(8)
    }
}

// MARK: - Earnings Transaction Row

struct EarningsTransactionRow: View {
    let task: HXTask
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HXText(task.title, style: .subheadline)
                if let date = task.completedAt {
                    HXText(date.formatted(date: .abbreviated, time: .omitted), style: .caption, color: .textSecondary)
                }
            }
            
            Spacer()
            
            HXText("+$\(String(format: "%.0f", task.payment))", style: .headline, color: .successGreen)
        }
        .padding()
        .background(Color.surfaceElevated)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        EarningsScreen()
    }
    .environment(MockDataService.shared)
}
