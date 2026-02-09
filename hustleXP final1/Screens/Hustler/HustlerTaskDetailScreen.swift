//
//  HustlerTaskDetailScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Premium task details with glassmorphism and rich visuals
//

import SwiftUI

struct HustlerTaskDetailScreen: View {
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    @Environment(AppState.self) private var appState
    
    let taskId: String
    
    @State private var showContent = false
    @State private var isAccepting = false
    
    private var task: HXTask? {
        dataService.availableTasks.first { $0.id == taskId } ??
        dataService.activeTask
    }
    
    var body: some View {
        if let task = task {
            ZStack {
                // Background
                backgroundLayer
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Hero card with task info
                        taskHeroCard(task)
                        
                        // Quick stats row
                        quickStatsRow(task)
                        
                        // Description card
                        descriptionCard(task)
                        
                        // Location card
                        locationCard(task)
                        
                        // Poster card
                        posterCard(task)
                        
                        // Eligibility check
                        if task.requiredTier.rawValue > appState.trustTier.rawValue {
                            eligibilityWarning(task)
                        }
                        
                        // XP reward info
                        xpRewardCard(task)
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar(task)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
        } else {
            loadingOrErrorView
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            // Ambient glow
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandPurple.opacity(0.15),
                                Color.brandPurple.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: -100)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Hero Card
    
    private func taskHeroCard(_ task: HXTask) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status tag
            HStack {
                Label {
                    Text("Task")
                        .font(.caption.weight(.semibold))
                } icon: {
                    Image(systemName: "briefcase.fill")
                        .font(.caption)
                }
                .foregroundStyle(Color.brandPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.brandPurple.opacity(0.15))
                )
                
                Spacer()
                
                if task.state != .posted {
                    HXBadge(variant: .status(task.badgeStatus))
                } else {
                    // Posted time
                    Text("Posted 2h ago")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            
            // Title
            Text(task.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
            
            // Price and duration row
            HStack(spacing: 20) {
                // Payment
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.moneyGreen.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "dollarsign")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.moneyGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$\(Int(task.payment))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.moneyGreen)
                        Text("Payment")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                
                Spacer()
                
                // Duration
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPurple.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.brandPurple)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.estimatedDuration)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        Text("Duration")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                
                Spacer()
                
                // Required tier
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(tierColor(task.requiredTier).opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(tierColor(task.requiredTier))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.requiredTier.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(tierColor(task.requiredTier))
                        Text("Min Tier")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: showContent)
    }
    
    // MARK: - Quick Stats Row
    
    private func quickStatsRow(_ task: HXTask) -> some View {
        HStack(spacing: 12) {
            quickStatItem(icon: "bolt.fill", value: "+\(xpReward(for: task))", label: "XP", color: .brandPurple)
            quickStatItem(icon: "star.fill", value: String(format: "%.1f", task.posterRating), label: "Rating", color: .yellow)
            quickStatItem(icon: "checkmark.circle.fill", value: "89%", label: "Success", color: .successGreen)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
    }
    
    private func quickStatItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Description Card
    
    private func descriptionCard(_ task: HXTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
                Text("Description")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Text(task.description)
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: showContent)
    }
    
    // MARK: - Location Card
    
    private func locationCard(_ task: HXTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.errorRed)
                Text("Location")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.caption)
                        Text("Open Maps")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
            
            HStack(spacing: 12) {
                // Map placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandBlack)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "map")
                            .font(.title2)
                            .foregroundStyle(Color.textMuted)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.location)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("1.2 miles away")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.caption2)
                        Text("~5 min drive")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 2)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
    }
    
    // MARK: - Poster Card
    
    private func posterCard(_ task: HXTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
                Text("Posted by")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            HStack(spacing: 14) {
                // Avatar with glow
                ZStack {
                    Circle()
                        .fill(Color.brandPurple.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .blur(radius: 8)
                    
                    HXAvatar(initials: String(task.posterName.prefix(2)), size: .medium)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.posterName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", task.posterRating))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.textPrimary)
                            Text("(24)")
                                .font(.caption)
                                .foregroundStyle(Color.textMuted)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(Color.successGreen)
                            Text("Verified")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.brandPurple)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.brandPurple.opacity(0.15))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: showContent)
    }
    
    // MARK: - Eligibility Warning
    
    private func eligibilityWarning(_ task: HXTask) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.warningOrange.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.warningOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tier Requirement Not Met")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.warningOrange)
                
                Text("This task requires \(task.requiredTier.name) tier. You are \(appState.trustTier.name).")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.warningOrange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
    }
    
    // MARK: - XP Reward Card
    
    private func xpRewardCard(_ task: HXTask) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.brandPurpleLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Earn \(xpReward(for: task)) XP")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Complete this task to level up your trust tier")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.textMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.brandPurple.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.35), value: showContent)
    }
    
    // MARK: - Bottom Action Bar
    
    private func bottomActionBar(_ task: HXTask) -> some View {
        let isEligible = task.requiredTier.rawValue <= appState.trustTier.rawValue
        
        return VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
            
            HStack(spacing: 16) {
                // Save button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 52, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
                
                // Main action button
                Button(action: {
                    if task.state == .posted {
                        acceptTask(task)
                    } else {
                        router.navigateToHustler(.taskInProgress(taskId: task.id))
                    }
                }) {
                    HStack(spacing: 8) {
                        if isAccepting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: task.state == .posted ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text(task.state == .posted ? "Accept Task" : "View Progress")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                isEligible
                                    ? LinearGradient(
                                        colors: [Color.brandPurple, Color.brandPurpleLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.textMuted, Color.textMuted],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                    )
                    .shadow(color: isEligible ? Color.brandPurple.opacity(0.3) : .clear, radius: 12, y: 4)
                }
                .disabled(!isEligible || isAccepting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .colorScheme(.dark)
            )
        }
    }
    
    // MARK: - Loading/Error View
    
    private var loadingOrErrorView: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color.brandPurple)
                
                Text("Loading task...")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func tierColor(_ tier: TrustTier) -> Color {
        switch tier {
        case .rookie: return Color.textSecondary
        case .verified: return Color.brandPurple
        case .trusted: return Color.infoBlue
        case .elite: return Color.moneyGreen
        case .master: return Color.yellow
        }
    }
    
    private func xpReward(for task: HXTask) -> Int {
        let baseXP = 10
        let paymentBonus = Int(task.payment / 10)
        return baseXP + paymentBonus
    }
    
    // MARK: - Actions
    
    private func acceptTask(_ task: HXTask) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        isAccepting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dataService.claimTask(task.id)
            router.navigateToHustler(.taskInProgress(taskId: task.id))
        }
    }
}

#Preview {
    NavigationStack {
        HustlerTaskDetailScreen(taskId: "task-001")
    }
    .environment(Router())
    .environment(MockDataService.shared)
    .environment(AppState())
}
