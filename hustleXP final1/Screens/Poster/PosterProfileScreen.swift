//
//  PosterProfileScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//

import SwiftUI

struct PosterProfileScreen: View {
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
                    PosterHeaderSection(
                        userName: appState.userName ?? "Poster",
                        user: dataService.currentUser
                    )
                    
                    // Stats grid
                    PosterStatsSection(user: dataService.currentUser)
                    
                    // Quick actions
                    PosterActionsSection(router: router)
                    
                    // Posting tips
                    PostingTipsSection()
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

// MARK: - Poster Header Section
private struct PosterHeaderSection: View {
    let userName: String
    let user: HXUser
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPurple.opacity(0.3), Color.accentPurple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                HXText(
                    String(userName.prefix(2)).uppercased(),
                    style: .largeTitle,
                    color: .accentPurple
                )
            }
            
            VStack(spacing: 8) {
                HXText(userName, style: .title2)
                
                HStack(spacing: 8) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.accentPurple)
                    
                    HXText("Task Poster", style: .subheadline, color: .accentPurple)
                }
            }
            
            // Member since
            HXText(
                "Member since \(formatDate(user.createdAt))",
                style: .caption,
                color: .textTertiary
            )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.surfaceElevated)
        .cornerRadius(20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Poster Stats Section
private struct PosterStatsSection: View {
    let user: HXUser
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            PosterStatCard(
                icon: "list.bullet.clipboard.fill",
                iconColor: .accentPurple,
                title: "Tasks Posted",
                value: "\(user.tasksPosted)"
            )
            
            PosterStatCard(
                icon: "dollarsign.circle.fill",
                iconColor: .moneyGreen,
                title: "Total Spent",
                value: "$\(Int(user.totalSpent))"
            )
            
            PosterStatCard(
                icon: "checkmark.circle.fill",
                iconColor: .successGreen,
                title: "Completed",
                value: "0"
            )
            
            PosterStatCard(
                icon: "person.2.fill",
                iconColor: .infoBlue,
                title: "Hustlers Hired",
                value: "0"
            )
        }
    }
}

// MARK: - Poster Stat Card
private struct PosterStatCard: View {
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

// MARK: - Poster Actions Section
private struct PosterActionsSection: View {
    let router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Quick Actions", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                PosterActionRow(
                    icon: "plus.circle.fill",
                    iconColor: .brandPurple,
                    title: "Post New Task",
                    subtitle: "Create a new task"
                ) {
                    router.navigateToPoster(.createTask)
                }
                
                HXDivider()
                    .padding(.leading, 56)
                
                PosterActionRow(
                    icon: "list.bullet",
                    iconColor: .infoBlue,
                    title: "Active Tasks",
                    subtitle: "Manage your tasks"
                ) {
                    router.navigateToPoster(.activeTasks)
                }
                
                HXDivider()
                    .padding(.leading, 56)
                
                PosterActionRow(
                    icon: "clock.fill",
                    iconColor: .textSecondary,
                    title: "Task History",
                    subtitle: "All completed tasks"
                ) {
                    router.navigateToPoster(.history)
                }
            }
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Poster Action Row
private struct PosterActionRow: View {
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

// MARK: - Posting Tips Section
private struct PostingTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Tips for Great Tasks", style: .caption, color: .textSecondary)
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 16) {
                TipRow(
                    icon: "text.alignleft",
                    text: "Write clear, detailed descriptions"
                )
                TipRow(
                    icon: "dollarsign.circle",
                    text: "Set fair, competitive prices"
                )
                TipRow(
                    icon: "clock",
                    text: "Give realistic time estimates"
                )
                TipRow(
                    icon: "star",
                    text: "Leave ratings to help the community"
                )
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(16)
        }
    }
}

// MARK: - Tip Row
private struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.brandPurple)
                .frame(width: 20)
            
            HXText(text, style: .subheadline, color: .textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        PosterProfileScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(MockDataService.shared)
}
