//
//  HustlerHomeScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//  Premium dashboard with neon aesthetics and dynamic stats
//

import SwiftUI

struct HustlerHomeScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    @State private var showGreeting = false
    @State private var statsAnimated = false
    @State private var glowPulse: Double = 0.3
    
    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                // Neon background
                neonBackground
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 28) {
                        // Welcome header with avatar
                        welcomeHeader(isCompact: isCompact)
                            .padding(.top, isCompact ? 4 : 8)
                        
                        // Premium XP card
                        xpProgressCard(isCompact: isCompact)
                        
                        // Quick stats grid
                        statsGrid(isCompact: isCompact)
                        
                        // Active task section
                        activeTaskSection(isCompact: isCompact)
                        
                        // Recommended tasks
                        recommendedSection(isCompact: isCompact)
                        
                        Spacer(minLength: max(24, geometry.safeAreaInsets.bottom + 16))
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                profileButton
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showGreeting = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                statsAnimated = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = 0.8
            }
        }
        .task {
            await dataService.refreshAll()
        }
    }
    
    // MARK: - Neon Background
    
    private var neonBackground: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width

            ZStack {
                Color.brandBlack.ignoresSafeArea()

            // Animated gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brandPurple.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: screenWidth * 0.5
                    )
                )
                .frame(width: screenWidth, height: screenWidth)
                .offset(x: -screenWidth * 0.13, y: -150)
                .blur(radius: 60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.aiPurple.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: screenWidth * 0.38
                    )
                )
                .frame(width: screenWidth * 0.75, height: screenWidth * 0.75)
                .offset(x: screenWidth * 0.25, y: 400)
                .blur(radius: 50)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Profile Button
    
    private var profileButton: some View {
        Button(action: { router.navigateToHustler(.profile) }) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.2))
                    .frame(width: 40, height: 40)

                Circle()
                    .stroke(Color.brandPurple.opacity(0.5), lineWidth: 1)
                    .frame(width: 40, height: 40)

                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
            }
        }
        .accessibilityLabel("View profile")
    }
    
    // MARK: - Welcome Header
    
    private func welcomeHeader(isCompact: Bool) -> some View {
        HStack(alignment: .top, spacing: isCompact ? 12 : 16) {
            // Avatar with neon glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.brandPurple.opacity(glowPulse * 0.5))
                    .frame(width: isCompact ? 60 : 76, height: isCompact ? 60 : 76)
                    .blur(radius: 15)
                
                // Avatar ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isCompact ? 2 : 3
                    )
                    .frame(width: isCompact ? 52 : 66, height: isCompact ? 52 : 66)
                
                // Avatar fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.brandPurpleLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 46 : 58, height: isCompact ? 46 : 58)
                
                Text(String(dataService.currentUser.name.prefix(1)))
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: isCompact ? 4 : 6) {
                Text("Hey, \(dataService.currentUser.name)!")
                    .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                    .opacity(showGreeting ? 1 : 0)
                    .offset(x: showGreeting ? 0 : -20)
                
                Text("Ready to hustle?")
                    .font(.system(size: isCompact ? 14 : 15))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
                    .opacity(showGreeting ? 1 : 0)
                    .offset(x: showGreeting ? 0 : -20)
            }
            
            Spacer()
            
            // Trust tier badge with glow
            VStack(alignment: .trailing, spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tierColor.opacity(0.15))
                        .frame(height: 32)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tierColor.opacity(0.5), lineWidth: 1)
                        .frame(height: 32)
                    
                    HStack(spacing: 6) {
                        Image(systemName: tierIcon)
                            .font(.system(size: 12, weight: .bold))
                        Text(dataService.currentUser.trustTier.name.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.5)
                    }
                    .foregroundStyle(tierColor)
                    .padding(.horizontal, 12)
                }
                .shadow(color: tierColor.opacity(0.3), radius: 8)
                
                Text("Level \(trustTierLevel)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.horizontal, isCompact ? 16 : 20)
    }
    
    private var tierColor: Color {
        switch dataService.currentUser.trustTier {
        case .rookie: return Color.textMuted
        case .verified: return Color.infoBlue
        case .trusted: return Color.successGreen
        case .elite: return Color.aiPurple
        case .master: return Color.warningOrange
        }
    }
    
    private var tierIcon: String {
        switch dataService.currentUser.trustTier {
        case .rookie: return "star"
        case .verified: return "checkmark.shield.fill"
        case .trusted: return "shield.fill"
        case .elite: return "crown.fill"
        case .master: return "bolt.fill"
        }
    }
    
    private var trustTierLevel: Int {
        switch dataService.currentUser.trustTier {
        case .rookie: return 1
        case .verified: return 2
        case .trusted: return 3
        case .elite: return 4
        case .master: return 5
        }
    }
    
    // MARK: - XP Progress Card
    
    private func xpProgressCard(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.warningOrange)
                        .shadow(color: Color.warningOrange.opacity(0.8), radius: 5)
                    
                    Text("XP PROGRESS")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
                
                Button {
                    router.navigateToHustler(.xpBreakdown)
                } label: {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.brandPurple)
                }
                .accessibilityLabel("View XP details")
            }
            
            // XP display
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(dataService.currentUser.xp)")
                    .font(.system(size: isCompact ? 36 : 48, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("XP")
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.warningOrange)
                    .padding(.bottom, 8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Next: \(nextTierXP) XP")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    
                    Text(nextTierName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(tierColor)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPurple, Color.aiPurple, Color.brandPurpleGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: statsAnimated ? geo.size.width * xpProgress : 0, height: 12)
                        .shadow(color: Color.brandPurple.opacity(0.5), radius: 8)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.brandPurple.opacity(0.3), Color.aiPurple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal, isCompact ? 16 : 20)
    }
    
    private var xpProgress: CGFloat {
        let current = Double(dataService.currentUser.xp)
        let next = Double(nextTierXP)
        return min(CGFloat(current / next), 1.0)
    }
    
    private var nextTierXP: Int {
        switch dataService.currentUser.trustTier {
        case .rookie: return 100
        case .verified: return 250
        case .trusted: return 500
        case .elite: return 1000
        case .master: return 2000
        }
    }
    
    private var nextTierName: String {
        switch dataService.currentUser.trustTier {
        case .rookie: return "Verified"
        case .verified: return "Trusted"
        case .trusted: return "Elite"
        case .elite: return "Master"
        case .master: return "Legend"
        }
    }
    
    // MARK: - Stats Grid
    
    private func statsGrid(isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 8 : 12) {
            NeonStatCard(
                title: "Tasks",
                value: "\(dataService.currentUser.tasksCompleted)",
                icon: "checkmark.circle.fill",
                color: .successGreen,
                isAnimated: statsAnimated
            )
            
            NeonStatCard(
                title: "Earnings",
                value: "$\(Int(dataService.currentUser.totalEarnings))",
                icon: "dollarsign.circle.fill",
                color: .moneyGreen,
                isAnimated: statsAnimated
            )
            
            NeonStatCard(
                title: "Rating",
                value: String(format: "%.1f", dataService.currentUser.rating),
                icon: "star.fill",
                color: .warningOrange,
                isAnimated: statsAnimated
            )
        }
        .padding(.horizontal, isCompact ? 16 : 20)
    }
    
    // MARK: - Active Task Section
    
    private func activeTaskSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            neonSectionHeader(title: "Active Task", icon: "bolt.fill", iconColor: .warningOrange)
            
            if let activeTask = dataService.activeTask {
                ActiveTaskCard(task: activeTask) {
                    router.navigateToHustler(.taskInProgress(taskId: activeTask.id))
                }
                .padding(.horizontal, 20)
            } else {
                noActiveTaskCard
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private func neonSectionHeader(title: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(iconColor)
                    .shadow(color: iconColor.opacity(0.8), radius: 3)
            }
            
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 20)
    }
    
    private var noActiveTaskCard: some View {
        VStack(spacing: 20) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .blur(radius: 15)
                
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                    .frame(width: 72, height: 72)
                
                Image(systemName: "briefcase")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            
            VStack(spacing: 6) {
                Text("No active task")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Find your next opportunity")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            
            HXButton("Browse Tasks", icon: "magnifyingglass", variant: .primary, size: .medium, isFullWidth: false) {
                router.navigateToHustler(.feed)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        )
    }
    
    // MARK: - Recommended Section
    
    private func recommendedSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            HStack {
                neonSectionHeader(title: "Recommended for You", icon: "sparkles", iconColor: .aiPurple)
                
                Spacer()
                
                Button(action: { router.navigateToHustler(.feed) }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.brandPurple)
                }
                .accessibilityLabel("See all recommended tasks")
                .padding(.trailing, 20)
            }
            
            if dataService.availableTasks.isEmpty {
                EmptyState(
                    icon: "tray",
                    title: "No Tasks Yet",
                    message: "Tasks will appear here based on your skills"
                )
                .padding(.horizontal, 20)
            } else {
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(dataService.availableTasks.prefix(3).enumerated()), id: \.element.id) { index, task in
                                TaskCard(
                                    title: task.title,
                                    payment: task.payment,
                                    location: task.location,
                                    duration: task.estimatedDuration,
                                    variant: index == 0 ? .featured : .compact,
                                    category: index == 0 ? "Top Pick" : nil
                                ) {
                                    router.navigateToHustler(.taskDetail(taskId: task.id))
                                }
                                .frame(width: index == 0 ? min(300, geo.size.width * 0.77) : min(260, geo.size.width * 0.67))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .frame(height: 220)
            }
        }
    }
}

// MARK: - Neon Stat Card

struct NeonStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isAnimated: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.6), radius: 3)
            }
            
            // Value
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .opacity(isAnimated ? 1 : 0)
                .scaleEffect(isAnimated ? 1 : 0.8)
            
            // Label
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 18)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            }
        )
    }
}

// MARK: - Active Task Card

struct ActiveTaskCard: View {
    let task: HXTask
    let action: () -> Void
    
    @State private var pulseOpacity: Double = 0.3
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Status indicator
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.warningOrange)
                            .frame(width: 10, height: 10)
                            .shadow(color: Color.warningOrange, radius: 4)
                            .opacity(pulseOpacity)
                        
                        Text("IN PROGRESS")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(Color.warningOrange)
                    }
                    
                    Spacer()
                    
                    Text(task.estimatedDuration)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                
                // Task title
                Text(task.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                
                // Payment
                HStack {
                    Text("$\(String(format: "%.0f", task.payment))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.moneyGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Continue")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.brandPurple.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.surfaceElevated)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.warningOrange.opacity(0.5), Color.warningOrange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: Color.warningOrange.opacity(0.2), radius: 15, y: 5)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseOpacity = 1.0
            }
        }
    }
}

#Preview {
    NavigationStack {
        HustlerHomeScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
