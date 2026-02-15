//
//  SquadDetailScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status) — Detail view
//  v2.4.0: Squad Detail (Hustler-side)
//
//  Shows full detail of a squad including members, stats,
//  active tasks, and management actions.
//

import SwiftUI

struct SquadDetailScreen: View {
    let squadId: String

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    @State private var squad: HXSquad?
    @State private var activeTasks: [MockSquadTask] = []
    @State private var isLoading = true
    @State private var showContent = false
    @State private var showLeaveConfirmation = false
    @State private var showInviteSheet = false

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(Color.squadGold)
            } else if let squad {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: Header
                        headerSection(squad)

                        // MARK: Stats Grid
                        statsGrid(squad)

                        // MARK: Members
                        membersSection(squad)

                        // MARK: Active Tasks
                        if !activeTasks.isEmpty {
                            activeTasksSection
                        }

                        // MARK: Actions
                        actionsSection(squad)

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
                    Text("Squad not found")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .navigationTitle("Squad Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Leave Squad", isPresented: $showLeaveConfirmation) {
            Button("Stay", role: .cancel) {}
            Button("Leave", role: .destructive) {
                // Mock: would call SquadService.shared.leaveSquad
            }
        } message: {
            Text("Are you sure you want to leave this squad? You can rejoin later if invited.")
        }
        .sheet(isPresented: $showInviteSheet) {
            inviteSheet
        }
        .task {
            loadMockData()
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
    }

    // MARK: - Header Section

    private func headerSection(_ squad: HXSquad) -> some View {
        VStack(spacing: 16) {
            // Emoji + name
            Text(squad.emoji)
                .font(.system(size: 56))

            VStack(spacing: 6) {
                Text(squad.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)

                if let tagline = squad.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .italic()
                }
            }

            // Level bar
            VStack(spacing: 8) {
                HStack {
                    Text("Level \(squad.squadLevel)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.squadGold)

                    Spacer()

                    Text("\(squad.squadXP) XP")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.squadGold, Color.squadGoldLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * squad.levelProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 4)

            // Member count
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("\(squad.memberCount)/\(squad.maxMembers) members")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color.textMuted)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.successGreen)
                        .frame(width: 8, height: 8)
                    Text("\(squad.members.filter { $0.isOnline }.count) online")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.squadGold.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Stats Grid

    private func statsGrid(_ squad: HXSquad) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SQUAD STATS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(
                    value: "\(squad.totalTasksCompleted)",
                    label: "Tasks Done",
                    icon: "checkmark.circle.fill",
                    color: .successGreen
                )
                statCard(
                    value: squad.formattedEarnings,
                    label: "Total Earned",
                    icon: "dollarsign.circle.fill",
                    color: .moneyGreen
                )
                statCard(
                    value: String(format: "%.1f", squad.averageRating),
                    label: "Avg Rating",
                    icon: "star.fill",
                    color: .warningOrange
                )
                statCard(
                    value: "Lvl \(squad.squadLevel)",
                    label: "Squad Level",
                    icon: "bolt.fill",
                    color: .squadGold
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

    // MARK: - Members Section

    private func membersSection(_ squad: HXSquad) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MEMBERS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(1)

                Spacer()

                Text("\(squad.memberCount)/\(squad.maxMembers)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }

            VStack(spacing: 0) {
                ForEach(Array(squad.members.enumerated()), id: \.element.id) { index, member in
                    memberRow(member)

                    if index < squad.members.count - 1 {
                        Divider().background(Color.borderSubtle)
                    }
                }
            }
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func memberRow(_ member: SquadMember) -> some View {
        HStack(spacing: 12) {
            // Avatar with tier color
            ZStack {
                Circle()
                    .fill(member.tierColor)
                    .frame(width: 44, height: 44)

                Text(member.userInitials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)

                // Online status dot
                if member.isOnline {
                    Circle()
                        .fill(Color.successGreen)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.surfaceElevated, lineWidth: 2)
                        )
                        .offset(x: 15, y: 15)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(member.userName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)

                    // Captain crown
                    if member.role == .organizer {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.squadGold)
                    }
                }

                HStack(spacing: 8) {
                    // Trust tier badge
                    Text(member.trustTier.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(member.tierColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(member.tierColor.opacity(0.15))
                        .clipShape(Capsule())

                    // Rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.warningOrange)
                        Text(String(format: "%.1f", member.rating))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }

            Spacer()

            // Tasks completed
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(member.completedTasks)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("tasks")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Active Tasks Section

    private var activeTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVE TASKS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1)

            ForEach(activeTasks) { task in
                activeTaskCard(task)
            }
        }
    }

    private func activeTaskCard(_ task: MockSquadTask) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.squadGold.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.squadGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(task.statusLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(task.statusColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(task.formattedPerWorkerPay)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                    Text("per worker")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                }
            }

            // Spots bar
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 11))
                    Text("\(task.acceptedCount)/\(task.requiredWorkers) spots filled")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color.textSecondary)

                Spacer()

                if task.spotsRemaining > 0 {
                    Text("\(task.spotsRemaining) open")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.squadGold)
                } else {
                    Text("Full")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.successGreen)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(task.spotsRemaining > 0 ? Color.squadGold : Color.successGreen)
                        .frame(
                            width: geo.size.width * (Double(task.acceptedCount) / Double(task.requiredWorkers)),
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.squadGold.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Actions Section

    private func actionsSection(_ squad: HXSquad) -> some View {
        VStack(spacing: 12) {
            // Invite member (visible to organizer)
            let isOrganizer = squad.members.first(where: { $0.role == .organizer })?.userId == appState.userId

            if isOrganizer || true /* demo mode */ {
                actionButton(
                    title: "Invite Member",
                    icon: "person.badge.plus",
                    color: .squadGold,
                    isDanger: false
                ) {
                    showInviteSheet = true
                }
            }

            // Manage squad (visible to organizer)
            if isOrganizer || true /* demo mode */ {
                actionButton(
                    title: "Manage Squad",
                    icon: "gearshape.fill",
                    color: .textSecondary,
                    isDanger: false
                ) {
                    // Mock: would navigate to squad management
                }
            }

            // Leave squad
            actionButton(
                title: "Leave Squad",
                icon: "rectangle.portrait.and.arrow.right",
                color: .errorRed,
                isDanger: true
            ) {
                showLeaveConfirmation = true
            }
        }
    }

    private func actionButton(title: String, icon: String, color: Color, isDanger: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            .foregroundStyle(color)
            .padding(16)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isDanger ? Color.errorRed.opacity(0.2) : Color.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Invite Sheet

    private var inviteSheet: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    ZStack {
                        Circle()
                            .fill(Color.squadGold.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.squadGold)
                    }

                    VStack(spacing: 8) {
                        Text("Invite to Squad")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)

                        Text("Only Elite+ hustlers can join squads.\nShare your invite link or search by username.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    // Placeholder search field
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.textMuted)

                        Text("Search hustlers...")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textMuted)

                        Spacer()
                    }
                    .padding(14)
                    .background(Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationTitle("Invite Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showInviteSheet = false }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    // MARK: - Mock Data

    private func loadMockData() {
        isLoading = true

        let now = Date()
        let calendar = Calendar.current

        squad = HXSquad(
            id: squadId,
            name: "Thunder Squad",
            organizerId: "hustler-001",
            organizerName: "Alex R.",
            members: [
                SquadMember(
                    id: "member-1",
                    userId: "hustler-001",
                    userName: "Alex R.",
                    userInitials: "AR",
                    role: .organizer,
                    trustTier: .elite,
                    rating: 4.9,
                    completedTasks: 142,
                    joinedAt: calendar.date(byAdding: .day, value: -60, to: now) ?? now,
                    lastActiveAt: now,
                    isOnline: true
                ),
                SquadMember(
                    id: "member-2",
                    userId: "hustler-002",
                    userName: "Jordan K.",
                    userInitials: "JK",
                    role: .member,
                    trustTier: .elite,
                    rating: 4.8,
                    completedTasks: 118,
                    joinedAt: calendar.date(byAdding: .day, value: -45, to: now) ?? now,
                    lastActiveAt: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                    isOnline: true
                ),
                SquadMember(
                    id: "member-3",
                    userId: "hustler-003",
                    userName: "Sam W.",
                    userInitials: "SW",
                    role: .member,
                    trustTier: .master,
                    rating: 4.95,
                    completedTasks: 203,
                    joinedAt: calendar.date(byAdding: .day, value: -30, to: now) ?? now,
                    lastActiveAt: calendar.date(byAdding: .hour, value: -8, to: now) ?? now,
                    isOnline: false
                ),
            ],
            status: .active,
            maxMembers: 5,
            createdAt: calendar.date(byAdding: .day, value: -60, to: now) ?? now,
            lastActiveAt: now,
            totalTasksCompleted: 37,
            totalEarnings: 2850,
            averageRating: 4.88,
            squadXP: 4200,
            squadLevel: 3,
            emoji: "\u{26A1}\u{FE0F}",
            tagline: "Speed. Precision. Results."
        )

        activeTasks = [
            MockSquadTask(
                id: "st-1",
                title: "Move 3-Bedroom House",
                requiredWorkers: 4,
                acceptedCount: 2,
                perWorkerPayment: 120,
                statusLabel: "Recruiting",
                statusColor: .squadGold
            ),
            MockSquadTask(
                id: "st-2",
                title: "Deep Clean Office Suite",
                requiredWorkers: 3,
                acceptedCount: 3,
                perWorkerPayment: 85,
                statusLabel: "Ready",
                statusColor: .successGreen
            ),
        ]

        isLoading = false
    }
}

// MARK: - Mock Squad Task (simplified for detail screen)

private struct MockSquadTask: Identifiable {
    let id: String
    let title: String
    let requiredWorkers: Int
    let acceptedCount: Int
    let perWorkerPayment: Double
    let statusLabel: String
    let statusColor: Color

    var spotsRemaining: Int { requiredWorkers - acceptedCount }

    var formattedPerWorkerPay: String {
        "$\(String(format: "%.0f", perWorkerPayment))"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SquadDetailScreen(squadId: "test-squad-1")
    }
    .environment(Router())
    .environment(AppState())
}
