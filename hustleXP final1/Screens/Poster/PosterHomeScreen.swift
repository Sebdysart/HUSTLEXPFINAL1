//
//  PosterHomeScreen.swift
//  hustleXP final1
//
//  Archetype: E (Progress/Status)
//  Premium poster dashboard with neon aesthetics
//

import SwiftUI

struct PosterHomeScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    @State private var showContent = false
    @State private var glowPulse: Double = 0.3
    @State private var aiButtonGlow: Double = 0.5
    
    private var myPostedTasks: [HXTask] {
        dataService.postedTasks
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            ZStack {
                // Neon background
                neonBackground
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 28) {
                        // Welcome header
                        welcomeHeader(isCompact: isCompact)
                            .padding(.top, isCompact ? 4 : 8)
                        
                        // Post task CTA
                        postTaskCTA(isCompact: isCompact)
                        
                        // Stats grid
                        statsSection(isCompact: isCompact)
                        
                        // Active tasks section
                        activeTasksSection(isCompact: isCompact)
                        
                        Spacer(minLength: max(24, geometry.safeAreaInsets.bottom + 16))
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Dashboard")
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
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = 0.8
                aiButtonGlow = 1.0
            }
        }
        .task {
            await dataService.refreshAll()
        }
    }
    
    // MARK: - Neon Background
    
    private var neonBackground: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            // Animated gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.aiPurple.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -100)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brandPurple.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 120, y: 350)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Profile Button
    
    private var profileButton: some View {
        Button(action: { router.navigateToPoster(.profile) }) {
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
    }
    
    // MARK: - Welcome Header
    
    private func welcomeHeader(isCompact: Bool) -> some View {
        HStack(alignment: .top, spacing: isCompact ? 12 : 16) {
            // Avatar with neon glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.accentPurple.opacity(glowPulse * 0.4))
                    .frame(width: isCompact ? 64 : 76, height: isCompact ? 64 : 76)
                    .blur(radius: 15)
                
                // Avatar ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.accentPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isCompact ? 2 : 3
                    )
                    .frame(width: isCompact ? 54 : 66, height: isCompact ? 54 : 66)
                
                // Avatar fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPurple, Color.accentViolet],
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
                    .foregroundStyle(Color.textPrimary)
                
                Text("What needs doing today?")
                    .font(isCompact ? .footnote : .subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(x: showContent ? 0 : -20)
            
            Spacer()
        }
        .padding(.horizontal, isCompact ? 16 : 20)
    }
    
    // MARK: - Post Task CTA
    
    private func postTaskCTA(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 10 : 12) {
            // AI Task Creation - Primary CTA with enhanced neon
            aiTaskCreationButton(isCompact: isCompact)
            
            // Manual task creation - Secondary
            manualTaskButton(isCompact: isCompact)
        }
        .padding(.horizontal, isCompact ? 16 : 20)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
    }
    
    // MARK: - AI Task Creation Button
    
    private func aiTaskCreationButton(isCompact: Bool) -> some View {
        Button(action: { 
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            router.navigateToPoster(.aiTaskCreation) 
        }) {
            HStack(spacing: isCompact ? 12 : 16) {
                // AI Icon with enhanced glow
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color.aiPurple.opacity(aiButtonGlow * 0.4))
                        .frame(width: isCompact ? 48 : 60, height: isCompact ? 48 : 60)
                        .blur(radius: 12)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.aiPurple, Color.brandPurpleGlow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCompact ? 42 : 52, height: isCompact ? 42 : 52)
                    
                    // Sparkle icon
                    Image(systemName: "sparkles")
                        .font(.system(size: isCompact ? 18 : 22, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.5), radius: 5)
                }
                
                VStack(alignment: .leading, spacing: isCompact ? 4 : 6) {
                    HStack(spacing: isCompact ? 6 : 8) {
                        Text("Create with AI")
                            .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        // NEW badge with glow
                        Text("NEW")
                            .font(.system(size: isCompact ? 8 : 9, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, isCompact ? 6 : 8)
                            .padding(.vertical, isCompact ? 2 : 3)
                            .background(
                                Capsule()
                                    .fill(Color.successGreen)
                                    .shadow(color: Color.successGreen.opacity(0.6), radius: 4)
                            )
                    }
                    
                    Text("Just describe what you need")
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                
                Spacer()
                
                // Arrow with glow
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: isCompact ? 36 : 44, height: isCompact ? 36 : 44)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(isCompact ? 14 : 18)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [Color.aiPurple, Color.brandPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Shimmer overlay
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: isCompact ? 20 : 24))
            .shadow(color: Color.aiPurple.opacity(aiButtonGlow * 0.6), radius: isCompact ? 15 : 20, x: 0, y: isCompact ? 8 : 10)
        }
    }
    
    // MARK: - Manual Task Button
    
    private func manualTaskButton(isCompact: Bool) -> some View {
        Button(action: { 
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            router.navigateToPoster(.createTask) 
        }) {
            HStack(spacing: isCompact ? 10 : 12) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceSecondary)
                        .frame(width: isCompact ? 32 : 36, height: isCompact ? 32 : 36)
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                
                Text("Create manually")
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, isCompact ? 12 : 16)
            .padding(.vertical, isCompact ? 12 : 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                        .fill(Color.surfaceElevated)
                    
                    RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            )
        }
    }
    
    // MARK: - Stats Section
    
    private func statsSection(isCompact: Bool) -> some View {
        HStack(spacing: isCompact ? 8 : 12) {
            NeonPosterStatCard(
                title: "Posted",
                value: "\(dataService.currentUser.tasksPosted)",
                icon: "doc.text.fill",
                color: .brandPurple,
                isCompact: isCompact
            )
            NeonPosterStatCard(
                title: "Active",
                value: "\(myPostedTasks.count)",
                icon: "clock.fill",
                color: .infoBlue,
                isCompact: isCompact
            )
            NeonPosterStatCard(
                title: "Spent",
                value: "$\(Int(dataService.currentUser.totalSpent))",
                icon: "dollarsign.circle.fill",
                color: .moneyGreen,
                isCompact: isCompact
            )
        }
        .padding(.horizontal, isCompact ? 16 : 20)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
    }
    
    // MARK: - Active Tasks Section
    
    private func activeTasksSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            // Section header
            HStack {
                HStack(spacing: isCompact ? 8 : 10) {
                    ZStack {
                        Circle()
                            .fill(Color.warningOrange.opacity(0.15))
                            .frame(width: isCompact ? 24 : 28, height: isCompact ? 24 : 28)
                        
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                            .foregroundStyle(Color.warningOrange)
                            .shadow(color: Color.warningOrange.opacity(0.8), radius: 3)
                    }
                    
                    Text("Your Active Tasks")
                        .font(isCompact ? .subheadline.weight(.bold) : .headline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
                
                if !myPostedTasks.isEmpty {
                    Button(action: { router.navigateToPoster(.activeTasks) }) {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(isCompact ? .footnote.weight(.semibold) : .subheadline.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.brandPurple)
                    }
                }
            }
            .padding(.horizontal, isCompact ? 16 : 20)
            
            if myPostedTasks.isEmpty {
                emptyTasksView(isCompact: isCompact)
            } else {
                VStack(spacing: isCompact ? 10 : 12) {
                    ForEach(myPostedTasks.prefix(3)) { task in
                        TaskCard(
                            title: task.title,
                            payment: task.payment,
                            location: task.location,
                            duration: task.estimatedDuration,
                            status: task.badgeStatus,
                            variant: .expanded
                        ) {
                            router.navigateToPoster(.taskDetail(taskId: task.id))
                        }
                    }
                }
                .padding(.horizontal, isCompact ? 16 : 20)
            }
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
    }
    
    private func emptyTasksView(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 18 : 24) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: isCompact ? 72 : 88, height: isCompact ? 72 : 88)
                    .blur(radius: 15)
                
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: isCompact ? 64 : 80, height: isCompact ? 64 : 80)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                    .frame(width: isCompact ? 64 : 80, height: isCompact ? 64 : 80)
                
                Image(systemName: "doc.text")
                    .font(.system(size: isCompact ? 26 : 32, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            
            VStack(spacing: isCompact ? 6 : 8) {
                Text("No active tasks")
                    .font(isCompact ? .subheadline.weight(.semibold) : .headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Post your first task to get started")
                    .font(isCompact ? .footnote : .subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            
            HXButton("Post a Task", icon: "plus", variant: .primary, size: isCompact ? .small : .medium, isFullWidth: false) {
                router.navigateToPoster(.aiTaskCreation)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 32 : 44)
        .padding(.horizontal, isCompact ? 16 : 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        )
        .padding(.horizontal, isCompact ? 16 : 20)
    }
}

// MARK: - Neon Poster Stat Card

struct NeonPosterStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
                
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 11 : 14, weight: .bold))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.6), radius: 3)
            }
            
            // Value
            Text(value)
                .font(.system(size: isCompact ? 18 : 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            
            // Label
            Text(title)
                .font(isCompact ? .caption2.weight(.medium) : .caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(isCompact ? 10 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: isCompact ? 14 : 18)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: isCompact ? 14 : 18)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: isCompact ? 14 : 18)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            }
        )
    }
}

#Preview {
    NavigationStack {
        PosterHomeScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
