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
    @State private var activeTasks: [SquadTask] = []
    @State private var isLoading = true
    @State private var showContent = false
    @State private var showLeaveConfirmation = false
    @State private var showDisbandConfirmation = false
    @State private var showInviteSheet = false
    @State private var actionError: String? = nil
    @State private var acceptingTaskId: String? = nil

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
                        .minimumScaleFactor(0.7)
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
                Task {
                    if let squad {
                        do {
                            try await SquadService.shared.leaveSquad(squadId: squad.id)
                            router.navigateToHustler()
                        } catch {
                            actionError = error.localizedDescription
                        }
                    }
                }
            }
        } message: {
            Text("Are you sure you want to leave this squad? You can rejoin later if invited.")
        }
        .alert("Disband Squad", isPresented: $showDisbandConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Disband", role: .destructive) {
                Task {
                    if let squad {
                        do {
                            try await SquadService.shared.disbandSquad(id: squad.id)
                            router.navigateToHustler()
                        } catch {
                            actionError = error.localizedDescription
                        }
                    }
                }
            }
        } message: {
            Text("Are you sure you want to disband this squad? This action cannot be undone and all members will be removed.")
        }
        .alert("Action Failed", isPresented: Binding(
            get: { actionError != nil },
            set: { if !$0 { actionError = nil } }
        )) {
            Button("OK", role: .cancel) { actionError = nil }
        } message: {
            Text(actionError ?? "Something went wrong. Please try again.")
        }
        .sheet(isPresented: $showInviteSheet) {
            inviteSheet
        }
        .task {
            await loadFromAPI()
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
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)

                if let tagline = squad.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.system(size: 15, weight: .medium))
                        .minimumScaleFactor(0.7)
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
                        .minimumScaleFactor(0.7)
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
                    .minimumScaleFactor(0.7)
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

    private func activeTaskCard(_ task: SquadTask) -> some View {
        let statusLabel: String = {
            switch task.status {
            case .recruiting: return "Recruiting"
            case .ready: return "Ready"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }()

        let statusColor: Color = {
            switch task.status {
            case .recruiting: return .squadGold
            case .ready: return .successGreen
            case .inProgress: return .infoBlue
            case .completed: return .successGreen
            case .cancelled: return .errorRed
            }
        }()

        return VStack(spacing: 12) {
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
                    Text(task.task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(statusLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(statusColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(task.formattedPerWorkerPay)
                        .font(.system(size: 17, weight: .bold))
                        .minimumScaleFactor(0.7)
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
                    Text("\(task.acceptedWorkers.count)/\(task.requiredWorkers) spots filled")
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
                            width: geo.size.width * (Double(task.acceptedWorkers.count) / Double(max(task.requiredWorkers, 1))),
                            height: 6
                        )
                }
            }
            .frame(height: 6)

            // Accept button — only shown when task is recruiting and has open spots
            if task.status == .recruiting && task.spotsRemaining > 0 {
                let isAccepting = acceptingTaskId == task.id

                Button {
                    acceptSquadTask(task)
                } label: {
                    HStack(spacing: 6) {
                        if isAccepting {
                            ProgressView()
                                .tint(Color.brandBlack)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text(isAccepting ? "Joining..." : "Accept Task")
                            .font(.system(size: 14, weight: .semibold))
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Color.brandBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.squadGold)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(isAccepting)
                .accessibilityLabel("Accept squad task")
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.squadGold.opacity(0.15), lineWidth: 1)
        )
    }

    private func acceptSquadTask(_ task: SquadTask) {
        guard acceptingTaskId == nil else { return }
        HapticFeedback.confirmation()
        acceptingTaskId = task.id
        Task {
            do {
                try await SquadService.shared.acceptSquadTask(squadTaskId: task.id)
                // Reload tasks to reflect accepted state
                let refreshed = try await SquadService.shared.getSquadTasks(squadId: squadId)
                activeTasks = refreshed.filter { $0.status != .completed && $0.status != .cancelled }
                HXLogger.info("SquadDetail: Accepted squad task \(task.id)", category: "Squad")
            } catch {
                actionError = error.localizedDescription
                HXLogger.error("SquadDetail: Accept task failed - \(error.localizedDescription)", category: "Squad")
            }
            acceptingTaskId = nil
        }
    }

    // MARK: - Actions Section

    private func actionsSection(_ squad: HXSquad) -> some View {
        VStack(spacing: 12) {
            // Invite member (visible to organizer)
            let isOrganizer = squad.members.first(where: { $0.role == .organizer })?.userId == appState.userId

            if isOrganizer {
                actionButton(
                    title: "Invite Member",
                    icon: "person.badge.plus",
                    color: .squadGold,
                    isDanger: false
                ) {
                    showInviteSheet = true
                }
            }

            // Disband squad (organizer only)
            if isOrganizer {
                actionButton(
                    title: "Disband Squad",
                    icon: "trash.fill",
                    color: .errorRed,
                    isDanger: true
                ) {
                    HapticFeedback.warning()
                    showDisbandConfirmation = true
                }
            }

            // Leave squad (non-organizer members)
            if !isOrganizer {
                actionButton(
                    title: "Leave Squad",
                    icon: "rectangle.portrait.and.arrow.right",
                    color: .errorRed,
                    isDanger: true
                ) {
                    HapticFeedback.warning()
                    showLeaveConfirmation = true
                }
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
                    .minimumScaleFactor(0.7)

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
        .accessibilityLabel(title)
    }

    // MARK: - Invite Sheet

    private var inviteSheet: some View {
        InviteMemberSheet(squadId: squadId) {
            showInviteSheet = false
        }
    }

    // MARK: - API Data Loading

    private func loadFromAPI() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let squadResult = SquadService.shared.getSquad(id: squadId)
            async let tasksResult = SquadService.shared.getSquadTasks(squadId: squadId)

            let (fetchedSquad, fetchedTasks) = try await (squadResult, tasksResult)
            self.squad = fetchedSquad
            self.activeTasks = fetchedTasks.filter { $0.status != .completed && $0.status != .cancelled }
            HXLogger.info("SquadDetail: Loaded squad '\(fetchedSquad.name)' with \(fetchedTasks.count) tasks", category: "Squad")
        } catch {
            HXLogger.error("SquadDetail: API load failed - \(error.localizedDescription)", category: "Squad")
            self.squad = nil
            self.activeTasks = []
        }
    }
}

// MARK: - Invite Member Sheet

private struct InviteMemberSheet: View {
    let squadId: String
    let onDismiss: () -> Void

    @State private var userId = ""
    @State private var isSending = false
    @State private var successMessage: String? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
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
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.textPrimary)

                        Text("Only Elite+ hustlers can join squads.\nEnter the hustler's user ID or username.")
                            .font(.system(size: 15))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HXText("User ID or Username", style: .subheadline, color: .textSecondary)

                        TextField("", text: $userId, prompt: Text("e.g., user_abc123").foregroundColor(.textTertiary))
                            .font(.system(size: 17))
                            .foregroundStyle(Color.textPrimary)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding(16)
                            .background(Color.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    if let successMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.successGreen)
                            Text(successMessage)
                                .font(.system(size: 14, weight: .medium))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.successGreen)
                        }
                        .padding(12)
                        .background(Color.successGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    }

                    if let errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.errorRed)
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.errorRed)
                        }
                        .padding(12)
                        .background(Color.errorRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    }

                    HXButton(
                        isSending ? "Sending..." : "Send Invite",
                        icon: "paperplane.fill",
                        variant: .primary,
                        isLoading: isSending
                    ) {
                        sendInvite()
                    }
                    .disabled(userId.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
                    .opacity(userId.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
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
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func sendInvite() {
        let trimmed = userId.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSending = true
        errorMessage = nil
        successMessage = nil
        Task {
            do {
                _ = try await SquadService.shared.inviteMember(squadId: squadId, userId: trimmed)
                successMessage = "Invite sent to \(trimmed)"
                userId = ""
                HXLogger.info("InviteMemberSheet: Sent invite to \(trimmed)", category: "Squad")
            } catch {
                errorMessage = error.localizedDescription
                HXLogger.error("InviteMemberSheet: Invite failed - \(error.localizedDescription)", category: "Squad")
            }
            isSending = false
        }
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
