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
    @Environment(MockDataService.self) private var dataService
    
    @State private var showContent = false
    @State private var glowPulse: Double = 0.3
    @State private var aiButtonGlow: Double = 0.5
    
    private var myPostedTasks: [HXTask] {
        dataService.availableTasks.filter { $0.posterId == dataService.currentUser.id }
    }
    
    var body: some View {
        ZStack {
            // Neon background
            neonBackground
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Welcome header
                    welcomeHeader
                        .padding(.top, 8)
                    
                    // Post task CTA
                    postTaskCTA
                    
                    // Stats grid
                    statsSection
                    
                    // Active tasks section
                    activeTasksSection
                    
                    Spacer(minLength: 32)
                }
                .padding(.vertical)
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
    
    private var welcomeHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar with neon glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.accentPurple.opacity(glowPulse * 0.4))
                    .frame(width: 76, height: 76)
                    .blur(radius: 15)
                
                // Avatar ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.accentPurple, Color.aiPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 66, height: 66)
                
                // Avatar fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPurple, Color.accentViolet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                
                Text(String(dataService.currentUser.name.prefix(1)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Hey, \(dataService.currentUser.name)!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("What needs doing today?")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(x: showContent ? 0 : -20)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Post Task CTA
    
    private var postTaskCTA: some View {
        VStack(spacing: 12) {
            // AI Task Creation - Primary CTA with enhanced neon
            aiTaskCreationButton
            
            // Manual task creation - Secondary
            manualTaskButton
        }
        .padding(.horizontal, 20)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
    }
    
    // MARK: - AI Task Creation Button
    
    private var aiTaskCreationButton: some View {
        Button(action: { 
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            router.navigateToPoster(.aiTaskCreation) 
        }) {
            HStack(spacing: 16) {
                // AI Icon with enhanced glow
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color.aiPurple.opacity(aiButtonGlow * 0.4))
                        .frame(width: 60, height: 60)
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
                        .frame(width: 52, height: 52)
                    
                    // Sparkle icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.5), radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Create with AI")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        // NEW badge with glow
                        Text("NEW")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.successGreen)
                                    .shadow(color: Color.successGreen.opacity(0.6), radius: 4)
                            )
                    }
                    
                    Text("Just describe what you need")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                
                Spacer()
                
                // Arrow with glow
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(18)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [Color.aiPurple, Color.brandPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Shimmer overlay
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.aiPurple.opacity(aiButtonGlow * 0.6), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - Manual Task Button
    
    private var manualTaskButton: some View {
        Button(action: { 
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            router.navigateToPoster(.createTask) 
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceSecondary)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                
                Text("Create manually")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.surfaceElevated)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            )
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            NeonPosterStatCard(
                title: "Posted",
                value: "\(dataService.currentUser.tasksPosted)",
                icon: "doc.text.fill",
                color: .brandPurple
            )
            NeonPosterStatCard(
                title: "Active",
                value: "\(myPostedTasks.count)",
                icon: "clock.fill",
                color: .infoBlue
            )
            NeonPosterStatCard(
                title: "Spent",
                value: "$\(Int(dataService.currentUser.totalSpent))",
                icon: "dollarsign.circle.fill",
                color: .moneyGreen
            )
        }
        .padding(.horizontal, 20)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
    }
    
    // MARK: - Active Tasks Section
    
    private var activeTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.warningOrange.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.warningOrange)
                            .shadow(color: Color.warningOrange.opacity(0.8), radius: 3)
                    }
                    
                    Text("Your Active Tasks")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
                
                if !myPostedTasks.isEmpty {
                    Button(action: { router.navigateToPoster(.activeTasks) }) {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.subheadline.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.brandPurple)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if myPostedTasks.isEmpty {
                emptyTasksView
            } else {
                VStack(spacing: 12) {
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
                .padding(.horizontal, 20)
            }
        }
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
    }
    
    private var emptyTasksView: some View {
        VStack(spacing: 24) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 88, height: 88)
                    .blur(radius: 15)
                
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            
            VStack(spacing: 8) {
                Text("No active tasks")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Post your first task to get started")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            
            HXButton("Post a Task", icon: "plus", variant: .primary, size: .medium, isFullWidth: false) {
                router.navigateToPoster(.aiTaskCreation)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Neon Poster Stat Card

struct NeonPosterStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon with glow
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

#Preview {
    NavigationStack {
        PosterHomeScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(MockDataService.shared)
}
