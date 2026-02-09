//
//  LockedQuestsTab.swift
//  hustleXP final1
//
//  "Locked Quests" Tab - Shows high-paying tasks the worker is nearly eligible for
//  - Creates FOMO and gamification loop
//  - Clear unlock path for each task
//  - Drives upgrades and skill progression
//

import SwiftUI

// MARK: - Locked Quests Tab View

struct LockedQuestsTab: View {
    let lockedQuests: [LockedQuest]
    let onUnlockAction: (LockedQuest) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            if lockedQuests.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(lockedQuests, id: \.id) { quest in
                            LockedQuestCard(
                                quest: quest,
                                onUnlock: { onUnlockAction(quest) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.instantYellow)
            
            Text("Locked Quests")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            
            Text("(\(lockedQuests.count))")
                .font(.system(size: 13))
                .foregroundStyle(Color.textMuted)
            
            Spacer()
            
            Text("Upgrade to unlock")
                .font(.system(size: 12))
                .foregroundStyle(Color.textMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surfaceSecondary)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.successGreen)
            
            Text("You're eligible for all nearby quests!")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.textPrimary)
            
            Text("Keep building your skills to unlock more")
                .font(.system(size: 13))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Locked Quest Card

struct LockedQuestCard: View {
    let quest: LockedQuest
    let onUnlock: () -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card
            mainContent
            
            // Expanded details
            if isExpanded {
                expandedContent
            }
        }
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lockColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var mainContent: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                // Lock badge with skill icon
                ZStack {
                    Circle()
                        .fill(lockColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: quest.requiredSkill.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(lockColor)
                    
                    // Lock overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.white)
                                .padding(3)
                                .background(lockColor)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 48, height: 48)
                }
                
                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Distance
                        if let distance = quest.distanceMeters {
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                Text(formatDistance(distance))
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(Color.textMuted)
                        }
                        
                        // Block reason
                        blockReasonBadge
                    }
                }
                
                Spacer()
                
                // Payment
                VStack(alignment: .trailing, spacing: 2) {
                    Text(quest.task.formattedPayment)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.successGreen)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(16)
        }
    }
    
    private var expandedContent: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.borderSubtle)
            
            // Hook message
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.instantYellow)
                
                Text(quest.hookMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            
            // Unlock button
            Button {
                onUnlock()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: unlockButtonIcon)
                    Text(unlockButtonText)
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(lockColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private var blockReasonBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: blockReasonIcon)
                .font(.system(size: 10))
            Text(quest.blockReason.rawValue)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(lockColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(lockColor.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var lockColor: Color {
        switch quest.blockReason {
        case .licenseRequired:
            return .instantYellow
        case .levelTooLow:
            return .warningOrange
        case .skillNotSelected:
            return .infoBlue
        case .verificationPending:
            return .textMuted
        default:
            return .textMuted
        }
    }
    
    private var blockReasonIcon: String {
        switch quest.blockReason {
        case .licenseRequired: return "checkmark.seal"
        case .levelTooLow: return "arrow.up.circle"
        case .skillNotSelected: return "plus.circle"
        case .verificationPending: return "clock"
        default: return "lock"
        }
    }
    
    private var unlockButtonIcon: String {
        switch quest.blockReason {
        case .licenseRequired: return "checkmark.seal.fill"
        case .levelTooLow: return "arrow.up.circle.fill"
        case .skillNotSelected: return "plus.circle.fill"
        default: return "lock.open.fill"
        }
    }
    
    private var unlockButtonText: String {
        switch quest.blockReason {
        case .licenseRequired: return "Verify License"
        case .levelTooLow: return "View Skill Path"
        case .skillNotSelected: return "Add Skill"
        default: return "Unlock"
        }
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let miles = meters / 1609.34
            return String(format: "%.1f mi", miles)
        }
    }
}

// MARK: - Mini Locked Quest Banner

struct MiniLockedQuestBanner: View {
    let topLockedQuest: LockedQuest?
    let totalLocked: Int
    let onTap: () -> Void
    
    var body: some View {
        if let quest = topLockedQuest {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Lock icon
                    ZStack {
                        Circle()
                            .fill(Color.instantYellow.opacity(0.2))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.instantYellow)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(quest.task.formattedPayment) quest nearby")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Upgrade to unlock \(totalLocked) more")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textMuted)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.instantYellow)
                }
                .padding(12)
                .background(
                    LinearGradient(
                        colors: [
                            Color.instantYellow.opacity(0.1),
                            Color.instantYellow.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.instantYellow.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Floating Locked Count Badge

struct LockedQuestCountBadge: View {
    let count: Int
    let topEarnings: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                
                Text("\(count) locked")
                    .font(.system(size: 13, weight: .semibold))
                
                Text("(\(String(format: "$%.0f", topEarnings))+)")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.instantYellow)
                    .shadow(color: .instantYellow.opacity(0.4), radius: 8, y: 4)
            )
        }
    }
}

// MARK: - Preview

#Preview("Locked Quests Tab") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack {
            let mockSkill = WorkerSkill(
                id: "elec-1",
                name: "Electrical Work",
                category: .trades,
                type: .licensed,
                icon: "bolt.fill",
                licenseType: .electrician,
                requiredLevel: 1,
                xpToUnlock: 0,
                tasksToUnlock: 0
            )
            
            let mockTask = HXTask(
                id: "1",
                title: "Install ceiling fan - Need licensed electrician",
                description: "Need a licensed electrician to install a new ceiling fan",
                payment: 125,
                location: "Pacific Heights",
                latitude: 37.79,
                longitude: -122.44,
                estimatedDuration: "1-2 hours",
                posterId: "poster-1",
                posterName: "Sarah K.",
                posterRating: 4.9,
                hustlerId: nil,
                hustlerName: nil,
                state: .posted,
                requiredTier: .elite,
                createdAt: Date(),
                claimedAt: nil,
                completedAt: nil
            )
            
            let lockedQuest = LockedQuest(
                id: "locked-1",
                task: mockTask,
                requiredSkill: mockSkill,
                blockReason: .licenseRequired,
                unlockAction: .uploadLicense(.electrician),
                distanceMeters: 1200,
                potentialEarnings: 125
            )
            
            LockedQuestsTab(
                lockedQuests: [lockedQuest],
                onUnlockAction: { _ in }
            )
            
            Spacer()
            
            MiniLockedQuestBanner(
                topLockedQuest: lockedQuest,
                totalLocked: 5,
                onTap: {}
            )
            .padding(.horizontal, 16)
            
            LockedQuestCountBadge(
                count: 5,
                topEarnings: 125,
                onTap: {}
            )
            .padding(.bottom, 20)
        }
    }
}
