//
//  HustlerProfileScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct HustlerProfileScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    ProfileHeaderSection(
                        userName: appState.userName ?? "Hustler",
                        trustTier: appState.trustTier,
                        rating: dataService.currentUser.rating,
                        totalRatings: dataService.currentUser.totalRatings
                    )
                    
                    // v1.8.0: Tax Balance Card (if blocked)
                    if dataService.taxStatus.blocked {
                        TaxBalanceCard(
                            taxStatus: dataService.taxStatus,
                            onPayNow: {
                                router.navigateToHustler(.taxPayment)
                            }
                        )
                    }
                    
                    // v1.8.0: Verification Unlock Card
                    VerificationUnlockCard(
                        status: dataService.verificationUnlockStatus,
                        onUnlockTap: {
                            router.navigateToSettings(.verification)
                        }
                    )
                    
                    // Stats grid
                    StatsGridSection(user: dataService.currentUser)
                    
                    // v1.8.0: Insurance Pool Card
                    InsurancePoolCard(
                        poolStatus: dataService.insurancePoolStatus,
                        onFileClaimTap: {
                            router.navigateToHustler(.fileClaim)
                        },
                        onViewClaimsTap: {
                            router.navigateToHustler(.claimsHistory)
                        }
                    )
                    
                    // Quick actions
                    QuickActionsSection(router: router)
                    
                    // Recent activity
                    RecentActivitySection()
                    
                    // Achievements preview
                    AchievementsPreviewSection()
                }
                .padding(24)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

// MARK: - Profile Header Section
private struct ProfileHeaderSection: View {
    let userName: String
    let trustTier: TrustTier
    let rating: Double
    let totalRatings: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple.opacity(0.3), Color.brandPurple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                HXText(
                    String(userName.prefix(2)).uppercased(),
                    style: .largeTitle,
                    color: .brandPurple
                )
                
                // Verified badge
                Circle()
                    .fill(Color.brandBlack)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.brandPurple)
                    )
                    .offset(x: 35, y: 35)
            }
            
            VStack(spacing: 8) {
                HXText(userName, style: .title2)
                
                HStack(spacing: 12) {
                    HXBadge(variant: .tier(trustTier))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.warningOrange)
                        
                        HXText(String(format: "%.1f", rating), style: .subheadline)
                        
                        HXText("(\(totalRatings))", style: .caption, color: .textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.surfaceElevated)
        .cornerRadius(20)
    }
}

// MARK: - Stats Grid Section
private struct StatsGridSection: View {
    let user: HXUser
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ProfileStatCard(
                icon: "checkmark.circle.fill",
                iconColor: .successGreen,
                title: "Tasks Completed",
                value: "\(user.tasksCompleted)"
            )
            
            ProfileStatCard(
                icon: "dollarsign.circle.fill",
                iconColor: .moneyGreen,
                title: "Total Earnings",
                value: "$\(Int(user.totalEarnings))"
            )
            
            ProfileStatCard(
                icon: "star.fill",
                iconColor: .warningOrange,
                title: "Avg Rating",
                value: String(format: "%.1f", user.rating)
            )
            
            ProfileStatCard(
                icon: "bolt.fill",
                iconColor: .brandPurple,
                title: "XP Earned",
                value: "\(user.xp)"
            )
        }
    }
}

// MARK: - Profile Stat Card
private struct ProfileStatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HXText(value, style: .title2)
                HXText(title, style: .caption, color: .textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Quick Actions Section
private struct QuickActionsSection: View {
    let router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Quick Actions", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ProfileActionRow(
                    icon: "bolt.fill",
                    iconColor: .brandPurple,
                    title: "XP Breakdown",
                    subtitle: "View your progress"
                ) {
                    router.navigateToHustler(.xpBreakdown)
                }
                
                HXDivider()
                    .padding(.leading, 56)
                
                ProfileActionRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: .moneyGreen,
                    title: "Earnings",
                    subtitle: "View payment history"
                ) {
                    router.navigateToHustler(.earnings)
                }
                
                HXDivider()
                    .padding(.leading, 56)
                
                ProfileActionRow(
                    icon: "clock.fill",
                    iconColor: .textSecondary,
                    title: "Task History",
                    subtitle: "All completed tasks"
                ) {
                    router.navigateToHustler(.history)
                }
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Profile Action Row
private struct ProfileActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText(title, style: .body)
                    HXText(subtitle, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Activity Section
private struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Recent Activity", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ActivityRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .successGreen,
                    title: "Completed: Deliver Package",
                    time: "2 hours ago",
                    amount: "+$25"
                )
                
                ActivityRow(
                    icon: "star.fill",
                    iconColor: .warningOrange,
                    title: "Received 5-star rating",
                    time: "2 hours ago",
                    amount: nil
                )
                
                ActivityRow(
                    icon: "bolt.fill",
                    iconColor: .brandPurple,
                    title: "Earned 50 XP",
                    time: "2 hours ago",
                    amount: nil
                )
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Activity Row
private struct ActivityRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let time: String
    let amount: String?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                HXText(title, style: .subheadline)
                HXText(time, style: .caption, color: .textTertiary)
            }
            
            Spacer()
            
            if let amount = amount {
                HXText(amount, style: .subheadline, color: .moneyGreen)
            }
        }
    }
}

// MARK: - Achievements Preview Section
private struct AchievementsPreviewSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Achievements", style: .caption, color: .textSecondary)
                Spacer()
                Button(action: {}) {
                    HXText("See All", style: .caption, color: .brandPurple)
                }
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 16) {
                AchievementBadge(icon: "flame.fill", title: "First Task", isUnlocked: true)
                AchievementBadge(icon: "bolt.fill", title: "Speed Demon", isUnlocked: true)
                AchievementBadge(icon: "star.fill", title: "5-Star", isUnlocked: false)
                AchievementBadge(icon: "crown.fill", title: "Top Rated", isUnlocked: false)
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Achievement Badge
private struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.brandPurple.opacity(0.15) : Color.surfaceSecondary)
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isUnlocked ? Color.brandPurple : Color.textTertiary)
            }
            
            HXText(title, style: .caption, color: isUnlocked ? .textPrimary : .textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        HustlerProfileScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(MockDataService.shared)
}
