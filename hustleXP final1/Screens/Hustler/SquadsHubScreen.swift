//
//  SquadsHubScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity) + E (Progress/Status)
//  v2.4.0: Squads Mode — Gold-tier unlockable
//
//  Premium team-based task mode. Hustlers form squads of up to 5
//  to tackle larger tasks together. Requires Elite trust tier.
//

import SwiftUI

struct SquadsHubScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    @State private var mySquads: [HXSquad] = []
    @State private var pendingInvites: [SquadInvite] = []
    @State private var selectedTab: SquadsTab = .mySquads
    @State private var showCreateSheet = false
    @State private var isLoading = true
    @State private var showContent = false

    private var isUnlocked: Bool {
        SquadTierGate.isUnlocked(tier: appState.trustTier)
    }

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if !isUnlocked {
                // TIER-GATE: Show locked splash
                SquadsLockedView(currentTier: appState.trustTier)
            } else {
                VStack(spacing: 0) {
                    // Tab selector
                    squadTabBar

                    // Content
                    switch selectedTab {
                    case .mySquads:
                        mySquadsView
                    case .invites:
                        invitesView
                    case .leaderboard:
                        leaderboardView
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .navigationTitle("Squads")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if isUnlocked {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.squadGold)
                    }
                    .accessibilityLabel("Create new squad")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateSquadSheet()
        }
        .task {
            await loadData()
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
    }

    // MARK: - Tab Bar

    private var squadTabBar: some View {
        HStack(spacing: 0) {
            ForEach(SquadsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 13))
                            Text(tab.label)
                                .font(.system(size: 14, weight: .semibold))
                                .minimumScaleFactor(0.7)

                            if tab == .invites && !pendingInvites.isEmpty {
                                Text("\(pendingInvites.count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.errorRed)
                                    .clipShape(Capsule())
                            }
                        }
                        .foregroundStyle(selectedTab == tab ? Color.squadGold : Color.textMuted)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.squadGold : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(Color.surfaceSecondary)
    }

    // MARK: - My Squads

    private var mySquadsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if mySquads.isEmpty && !isLoading {
                    emptySquadsState
                } else {
                    ForEach(mySquads) { squad in
                        SquadCard(squad: squad)
                            .onTapGesture {
                                router.navigateToHustler(.squadDetail(squadId: squad.id))
                            }
                    }
                }
            }
            .padding(16)
        }
    }

    private var emptySquadsState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)

            ZStack {
                Circle()
                    .fill(Color.squadGold.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.squadGold)
            }

            VStack(spacing: 8) {
                Text("No Squads Yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)

                Text("Create a squad to team up with other Elite hustlers and tackle bigger, higher-paying tasks together.")
                    .font(.system(size: 15))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            HXButton("Create Your First Squad", icon: "plus.circle.fill", variant: .primary) {
                showCreateSheet = true
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Invites

    private var invitesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if pendingInvites.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 60)

                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.textMuted)

                        Text("No Pending Invites")
                            .font(.system(size: 17, weight: .semibold))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(pendingInvites) { invite in
                        InviteCard(invite: invite) { accepted in
                            Task {
                                try? await SquadService.shared.respondToInvite(
                                    inviteId: invite.id,
                                    accept: accepted
                                )
                                await loadData()
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Leaderboard

    private var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Coming soon placeholder
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)

                    ZStack {
                        Circle()
                            .fill(Color.squadGold.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.squadGold)
                    }

                    Text("Squad Leaderboard")
                        .font(.system(size: 20, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    Text("Compete with other squads in your area.\nRankings update weekly.")
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)

                    // Sample leaderboard entries
                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { rank in
                            leaderboardRow(rank: rank + 1)
                            if rank < 4 {
                                Divider().background(Color.borderSubtle)
                            }
                        }
                    }
                    .background(Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 8)
                }
            }
            .padding(16)
        }
    }

    private func leaderboardRow(rank: Int) -> some View {
        let names = ["Thunder Squad", "Night Owls", "Quick Crew", "Elite Force", "Task Masters"]
        let emojis = ["⚡️", "🦉", "🚀", "💪", "🎯"]
        let xps = [12500, 9800, 7200, 5100, 3400]

        return HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(rank <= 3 ? Color.squadGold : Color.textMuted)
                .frame(width: 36)

            Text(emojis[rank - 1])
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(names[rank - 1])
                    .font(.system(size: 15, weight: .semibold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)

                Text("\(xps[rank - 1]) Squad XP")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            if rank <= 3 {
                Image(systemName: rank == 1 ? "crown.fill" : "medal.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        rank == 1 ? Color.squadGold :
                        rank == 2 ? Color.textSecondary :
                        Color(hex: "CD7F32")
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        do {
            async let squadsTask = SquadService.shared.getMySquads()
            async let invitesTask = SquadService.shared.getPendingInvites()

            let (squads, invites) = try await (squadsTask, invitesTask)
            mySquads = squads
            pendingInvites = invites
        } catch {
            print("⚠️ SquadsHub: Load failed - \(error.localizedDescription)")
            // Use mock data for demo
            mySquads = []
            pendingInvites = []
        }
        isLoading = false
    }
}

// MARK: - Squads Tab Enum

enum SquadsTab: String, CaseIterable {
    case mySquads
    case invites
    case leaderboard

    var label: String {
        switch self {
        case .mySquads: return "My Squads"
        case .invites: return "Invites"
        case .leaderboard: return "Rankings"
        }
    }

    var icon: String {
        switch self {
        case .mySquads: return "person.3.fill"
        case .invites: return "envelope.fill"
        case .leaderboard: return "trophy.fill"
        }
    }
}

// MARK: - Squad Card

private struct SquadCard: View {
    let squad: HXSquad

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Text(squad.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(squad.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 11))
                            Text("\(squad.memberCount)/\(squad.maxMembers)")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(Color.textMuted)

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                            Text(String(format: "%.1f", squad.averageRating))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(Color.warningOrange)

                        Text("Lvl \(squad.squadLevel)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.squadGold)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(16)

            // Stats row
            HStack(spacing: 0) {
                squadStat(value: "\(squad.totalTasksCompleted)", label: "Tasks", icon: "checkmark.circle.fill", color: .successGreen)

                Divider()
                    .frame(height: 28)
                    .background(Color.borderSubtle)

                squadStat(value: squad.formattedEarnings, label: "Earned", icon: "dollarsign.circle.fill", color: .moneyGreen)

                Divider()
                    .frame(height: 28)
                    .background(Color.borderSubtle)

                squadStat(value: "\(squad.squadXP)", label: "XP", icon: "bolt.fill", color: .squadGold)
            }
            .padding(.vertical, 12)
            .background(Color.surfaceSecondary.opacity(0.5))

            // Member avatars
            HStack(spacing: -8) {
                ForEach(squad.members.prefix(5)) { member in
                    ZStack {
                        Circle()
                            .fill(member.tierColor)
                            .frame(width: 32, height: 32)

                        Text(member.userInitials)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.surfaceElevated, lineWidth: 2)
                    )
                }

                Spacer()

                if let tagline = squad.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                        .italic()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.squadGold.opacity(0.2), lineWidth: 1)
        )
    }

    private func squadStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Invite Card

private struct InviteCard: View {
    let invite: SquadInvite
    let onRespond: (Bool) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text(invite.squadEmoji)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text(invite.squadName)
                        .font(.system(size: 16, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    Text("Invited by \(invite.inviterName)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if !invite.isExpired {
                    Text(timeRemaining)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.warningOrange)
                } else {
                    Text("Expired")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.errorRed)
                }
            }

            if !invite.isExpired {
                HStack(spacing: 12) {
                    Button {
                        onRespond(false)
                    } label: {
                        Text("Decline")
                            .font(.system(size: 14, weight: .semibold))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(Color.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityLabel("Decline squad invite")

                    Button {
                        onRespond(true)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Join Squad")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.brandBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.squadGold)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityLabel("Accept and join squad")
                }
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.squadGold.opacity(0.2), lineWidth: 1)
        )
    }

    private var timeRemaining: String {
        let remaining = invite.expiresAt.timeIntervalSince(Date())
        let hours = Int(remaining / 3600)
        if hours > 24 {
            return "\(hours / 24)d left"
        } else if hours > 0 {
            return "\(hours)h left"
        } else {
            return "< 1h left"
        }
    }
}

// MARK: - Squads Locked View (Tier Gate)

struct SquadsLockedView: View {
    let currentTier: TrustTier

    @State private var showPulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)

                // Locked emblem
                ZStack {
                    // Pulse rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.squadGold.opacity(0.1), lineWidth: 1)
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
                                colors: [Color.squadGold.opacity(0.3), Color.clear],
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
                                .stroke(Color.squadGold.opacity(0.5), lineWidth: 2)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.squadGold)

                        Text("GOLD")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(Color.squadGold)
                            .tracking(2)
                    }
                }

                // Title
                VStack(spacing: 12) {
                    Text("Squads Mode")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textPrimary)

                    Text("Team up with trusted hustlers to tackle\nbigger tasks and earn more together.")
                        .font(.system(size: 16))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Requirements
                VStack(spacing: 12) {
                    Text("UNLOCK REQUIREMENTS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.squadGold)
                        .tracking(1.5)

                    VStack(spacing: 10) {
                        ForEach(SquadTierGate.unlockRequirements) { req in
                            requirementRow(req)
                        }
                    }
                }
                .padding(20)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.squadGold.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Benefits
                VStack(spacing: 16) {
                    benefitRow(icon: "person.3.fill", title: "Team Up", description: "Form squads of up to 5 Elite hustlers")
                    benefitRow(icon: "dollarsign.arrow.circlepath", title: "Higher Payouts", description: "Access multi-worker tasks worth 2-5x more")
                    benefitRow(icon: "trophy.fill", title: "Squad Rankings", description: "Compete on the leaderboard for bonus XP")
                    benefitRow(icon: "bolt.shield.fill", title: "Trust Bonus", description: "Squad completion boosts all members' trust")
                }
                .padding(.horizontal, 24)

                // Current progress
                VStack(spacing: 8) {
                    Text("Your Current Tier")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textMuted)

                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .foregroundStyle(tierColor(for: currentTier))
                        Text(currentTier.name)
                            .font(.system(size: 17, weight: .bold))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(tierColor(for: currentTier))
                    }

                    let tiersToGo = max(0, TrustTier.elite.rawValue - currentTier.rawValue)
                    if tiersToGo > 0 {
                        Text("\(tiersToGo) tier\(tiersToGo == 1 ? "" : "s") to unlock")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            showPulse = true
        }
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
                    .minimumScaleFactor(0.7)
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
                    .fill(Color.squadGold.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.squadGold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }

    private func tierColor(for tier: TrustTier) -> Color {
        switch tier {
        case .unranked, .rookie: return .tierRookie
        case .verified: return .tierVerified
        case .trusted: return .tierTrusted
        case .elite: return .tierElite
        case .master: return .tierMaster
        }
    }
}

// MARK: - Create Squad Sheet

private struct CreateSquadSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var squadName = ""
    @State private var selectedEmoji = "⚡️"
    @State private var tagline = ""
    @State private var isCreating = false

    private let emojiOptions = ["⚡️", "🔥", "💪", "🚀", "🦅", "🎯", "⭐️", "🏆", "🦁", "🐺", "🦊", "🎪"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Emoji picker
                        VStack(spacing: 12) {
                            Text(selectedEmoji)
                                .font(.system(size: 64))

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 48, height: 48)
                                            .background(
                                                selectedEmoji == emoji
                                                    ? Color.squadGold.opacity(0.2)
                                                    : Color.surfaceSecondary
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        selectedEmoji == emoji ? Color.squadGold : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Squad name
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Squad Name", style: .subheadline, color: .textSecondary)

                            TextField("", text: $squadName, prompt: Text("e.g., Thunder Squad").foregroundColor(.textTertiary))
                                .font(.system(size: 17))
                                .foregroundStyle(Color.textPrimary)
                                .padding(16)
                                .background(Color.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Tagline
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HXText("Tagline", style: .subheadline, color: .textSecondary)
                                HXText("(optional)", style: .caption, color: .textTertiary)
                            }

                            TextField("", text: $tagline, prompt: Text("e.g., We get it done").foregroundColor(.textTertiary))
                                .font(.system(size: 15))
                                .foregroundStyle(Color.textPrimary)
                                .padding(16)
                                .background(Color.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Info
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.squadGold)

                            Text("Squads can have up to \(SquadTierGate.maxSquadSize) members. Only Elite+ hustlers can join.")
                                .font(.system(size: 13))
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(14)
                        .background(Color.squadGold.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Create button
                        HXButton(
                            isCreating ? "Creating..." : "Create Squad",
                            icon: "person.3.fill",
                            variant: .primary,
                            isLoading: isCreating
                        ) {
                            createSquad()
                        }
                        .disabled(squadName.count < 3 || isCreating)
                        .opacity(squadName.count >= 3 ? 1 : 0.5)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Create Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func createSquad() {
        isCreating = true
        Task {
            do {
                _ = try await SquadService.shared.createSquad(
                    name: squadName,
                    emoji: selectedEmoji,
                    tagline: tagline.isEmpty ? nil : tagline
                )
                dismiss()
            } catch {
                print("⚠️ CreateSquad: Failed - \(error.localizedDescription)")
            }
            isCreating = false
        }
    }
}

// MARK: - Preview

#Preview("Squads Hub - Unlocked") {
    NavigationStack {
        SquadsHubScreen()
    }
    .environment(Router())
    .environment({
        let state = AppState()
        state.trustTier = .elite
        return state
    }())
}

#Preview("Squads Hub - Locked") {
    NavigationStack {
        SquadsHubScreen()
    }
    .environment(Router())
    .environment({
        let state = AppState()
        state.trustTier = .verified
        return state
    }())
}
