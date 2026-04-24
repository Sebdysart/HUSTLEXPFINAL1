//
//  HustlerTaskDetailScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Premium task details with glassmorphism and rich visuals
//

import SwiftUI
import Combine

struct HustlerTaskDetailScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    @Environment(AppState.self) private var appState
    
    // v2.2.0: Real API service
    @StateObject private var taskService = TaskService.shared
    
    let taskId: String
    
    @State private var showContent = false
    @State private var isAccepting = false
    @State private var apiTask: HXTask?
    @State private var loadError: Error?
    @State private var acceptError: String?
    @State private var showAcceptError: Bool = false
    @State private var showRatingSheet = false
    @State private var sseSubscription: AnyCancellable?

    // Application state
    @State private var hasApplied = false
    @State private var isApplying = false
    @State private var showApplySheet = false
    @State private var applicationMessage = ""

    // v1.9.0 Spatial Intelligence
    @State private var userLocation: GPSCoordinates?
    @State private var walkingETA: WalkingETA?
    @State private var batchRecommendation: BatchRecommendation?
    
    // v2.2.0: Use API task when available, fall back to mock
    private var task: HXTask? {
        apiTask ?? dataService.availableTasks.first { $0.id == taskId } ?? dataService.activeTask
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
                    .accessibilityLabel("More options")
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar(task)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
                subscribeToSSE()
            }
            .onDisappear {
                sseSubscription?.cancel()
                sseSubscription = nil
            }
            .task {
                // v2.2.0: Load task from real API
                await loadTaskFromAPI()
            }
            // v2.5.0: Error alert for accept failures
            .alert("Couldn't Accept Task", isPresented: $showAcceptError) {
                if acceptError?.contains("background check") == true {
                    Button("Start Verification") {
                        appState.selectedTab = 3
                    }
                    Button("Cancel", role: .cancel) {}
                } else if acceptError?.contains("trust tier") == true {
                    Button("OK", role: .cancel) {}
                } else {
                    Button("Try Again") {
                        acceptTask(task)
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } message: {
                Text(acceptError ?? "An unexpected error occurred.")
            }
            // v2.6.0: Worker → Poster rating sheet
            .sheet(isPresented: $showRatingSheet) {
                RateTaskSheet(
                    taskId: task.id,
                    taskTitle: task.title,
                    otherUserName: task.posterName,
                    isPresented: $showRatingSheet
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            // Application sheet
            .sheet(isPresented: $showApplySheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Apply for Task")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Send a message to the poster explaining why you're a great fit.")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)

                        TextEditor(text: $applicationMessage)
                            .frame(minHeight: 100, maxHeight: 200)
                            .padding(8)
                            .background(Color.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1))
                            )

                        Button(action: {
                            applyForTask()
                        }) {
                            HStack {
                                if isApplying {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isApplying ? "Submitting..." : "Submit Application")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.brandPurple)
                            .cornerRadius(14)
                        }
                        .disabled(isApplying)
                    }
                    .padding(24)
                    .background(Color.brandBlack.ignoresSafeArea())
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cancel") { showApplySheet = false }
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
                .minimumScaleFactor(0.7)
            
            // Price, duration, and tier row
            HStack(spacing: 0) {
                // Payment
                statPill(
                    icon: "dollarsign",
                    iconColor: .moneyGreen,
                    value: "$\(Int(task.payment))",
                    valueColor: .moneyGreen,
                    label: "Payment"
                )

                Spacer(minLength: 8)

                // Duration
                statPill(
                    icon: "clock.fill",
                    iconColor: .brandPurple,
                    value: task.estimatedDuration,
                    valueColor: .textPrimary,
                    label: "Duration"
                )

                Spacer(minLength: 8)

                // Required tier
                statPill(
                    icon: "shield.checkered",
                    iconColor: tierColor(task.requiredTier),
                    value: task.requiredTier.name,
                    valueColor: tierColor(task.requiredTier),
                    label: "Min Tier"
                )
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
    
    /// Compact stat pill used in the hero card — icon + value + label, never wraps.
    private func statPill(icon: String, iconColor: Color, value: String, valueColor: Color, label: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(valueColor)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
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
                    .minimumScaleFactor(0.7)
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
    
    // MARK: - Location Card (v1.9.0 with TaskMapView)
    
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
                
                // Location name
                Text(task.location)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            // v1.9.0: TaskMapView with walking ETA
            TaskMapView(
                task: task,
                userLocation: userLocation,
                walkingETA: walkingETA,
                showRoute: true,
                onOpenMaps: {
                    openInMaps(task)
                }
            )
            
            // v1.9.0: Show batch recommendation if available
            if let recommendation = batchRecommendation {
                MiniNearbyIndicator(
                    nearbyCount: recommendation.nearbyTasks.count,
                    walkingTime: recommendation.savings.timeSavedMinutes
                )
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
        .task {
            await loadLocationData(for: task)
        }
    }
    
    // MARK: - Location Data Loading
    
    private func loadLocationData(for task: HXTask) async {
        let (coords, _) = await LocationService.current.captureLocation()
        userLocation = coords
        
        // Calculate walking ETA if task has coordinates
        if let taskCoords = task.gpsCoordinates {
            walkingETA = LocationService.current.calculateWalkingETA(from: coords, to: taskCoords)
        }
        
        // v2.2.0: Fetch batch suggestions from real API
        Task {
            do {
                let suggestions = try await BatchQuestService.shared.getSuggestions(
                    currentTaskId: task.id,
                    maxResults: 5
                )
                HXLogger.info("HustlerTaskDetail: Got \(suggestions.count) batch suggestions from API", category: "Task")
            } catch {
                HXLogger.error("HustlerTaskDetail: Batch API failed - \(error.localizedDescription)", category: "Task")
            }
        }

        // Check for batch recommendations (mock fallback for UI)
        batchRecommendation = TaskBatchingService.shared.generateRecommendation(
            for: task,
            availableTasks: dataService.availableTasks,
            userLocation: coords
        )
    }
    
    private func openInMaps(_ task: HXTask) {
        guard let lat = task.latitude, let lon = task.longitude else { return }
        // In production, would open Apple Maps
        HXLogger.debug("[Maps] Opening directions to \(lat), \(lon)", category: "Navigation")
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
                .accessibilityLabel("Message poster")
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
                .accessibilityLabel("Save task")
                
                // Main action button
                if task.state == .proofSubmitted {
                    // Awaiting poster review — no action needed
                    HStack(spacing: 8) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Awaiting Poster Review")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(Color.infoBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.infoBlue.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.infoBlue.opacity(0.3), lineWidth: 1)
                    )
                } else if task.state == .completed {
                    VStack(spacing: 10) {
                        // v2.6.0: Rate poster for completed tasks
                        Button(action: { showRatingSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Rate \(task.posterName)")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.warningOrange, Color.warningOrange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: Color.warningOrange.opacity(0.3), radius: 12, y: 4)
                        }

                        // Report Issue / File Dispute
                        Button(action: {
                            router.navigateToHustler(.dispute(taskId: task.id))
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                Text("Report Issue")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(Color.errorRed)
                        }
                    }
                } else {
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
                                Image(systemName: task.state == .posted ? "bolt.fill" : "arrow.right.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }

                            Text(task.state == .posted ? (isAccepting ? "Accepting..." : "Accept Task") : "View Progress")
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
    
    // MARK: - Loading/Error View (v2.5.0 Enhanced)
    
    private var loadingOrErrorView: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            if loadError != nil {
                // v2.5.0: Show error state with retry option
                VStack(spacing: 24) {
                    ErrorState(
                        icon: "exclamationmark.triangle.fill",
                        title: "Couldn't Load Task",
                        message: "There was a problem loading this task. Please check your connection and try again.",
                        retryAction: {
                            Task {
                                loadError = nil
                                await loadTaskFromAPI()
                            }
                        }
                    )
                    
                    // Show fallback option if mock data available
                    if dataService.availableTasks.first(where: { $0.id == taskId }) != nil {
                        VStack(spacing: 12) {
                            HXDivider()
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                withAnimation {
                                    loadError = nil
                                    // Use mock data fallback
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14))
                                    Text("Show Cached Version")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(Color.brandPurple)
                            }
                            
                            HXText(
                                "Data may be outdated",
                                style: .caption,
                                color: .textMuted
                            )
                        }
                    }
                }
                .padding(24)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color.brandPurple)
                    
                    Text("Loading task...")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
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
        case .unranked, .rookie: return Color.textSecondary
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
        
        // v2.2.0: Use real API to accept task
        Task {
            do {
                let updatedTask = try await taskService.acceptTask(taskId: task.id)
                apiTask = updatedTask

                // Update local state (don't call claimTask — it would re-call the API)
                dataService.availableTasks.removeAll { $0.id == task.id }
                dataService.activeTask = updatedTask

                router.navigateToHustler(.taskInProgress(taskId: task.id))
            } catch {
                HXLogger.error("TaskDetail: API accept failed - \(error.localizedDescription)", category: "Task")

                // Timeout or network error — the backend may have succeeded.
                // Re-fetch the task to check its actual state before showing an error.
                if let refreshed = try? await TaskService.shared.getTask(id: task.id),
                   refreshed.state == .claimed || refreshed.state == .inProgress {
                    HXLogger.info("TaskDetail: Accept timed out but task is accepted — proceeding", category: "Task")
                    apiTask = refreshed
                    dataService.availableTasks.removeAll { $0.id == task.id }
                    dataService.activeTask = refreshed
                    isAccepting = false
                    router.navigateToHustler(.taskInProgress(taskId: task.id))
                    return
                }

                acceptError = error.localizedDescription
                showAcceptError = true
            }
            isAccepting = false
        }
    }
    
    // v2.5.0: Fallback accept with mock data (only after user acknowledges error)
    private func acceptTaskOffline(_ task: HXTask) {
        dataService.claimTask(task.id)
        router.navigateToHustler(.taskInProgress(taskId: task.id))
    }

    // MARK: - Apply for Task

    private func applyForTask() {
        guard let task = task else { return }
        isApplying = true
        Task {
            do {
                _ = try await taskService.applyForTask(
                    taskId: task.id,
                    message: applicationMessage.isEmpty ? nil : applicationMessage
                )
                hasApplied = true
                showApplySheet = false
                applicationMessage = ""

                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
            } catch {
                HXLogger.error("TaskDetail: Apply failed - \(error.localizedDescription)", category: "Task")
                HXLogger.error("TaskDetail: Apply full error - \(String(describing: error))", category: "Task")
                acceptError = "Could not submit application: \(error.localizedDescription)"
                showAcceptError = true
            }
            isApplying = false
        }
    }

    // v2.2.0: Load task from API
    private func loadTaskFromAPI() async {
        do {
            apiTask = try await taskService.getTask(id: taskId)
            HXLogger.info("TaskDetail: Loaded task from API", category: "Task")
        } catch {
            loadError = error
            HXLogger.error("TaskDetail: API load failed, using mock - \(error.localizedDescription)", category: "Task")
        }
    }

    // MARK: - SSE Subscription

    private func subscribeToSSE() {
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                let relevantEvents = [
                    "task_updated", "task_state_changed", "proof_submitted",
                    "task_completed", "application_accepted", "application_rejected"
                ]
                guard relevantEvents.contains(message.event) else { return }

                if let json = try? JSONSerialization.jsonObject(with: message.data) as? [String: Any],
                   let eventTaskId = json["taskId"] as? String ?? json["task_id"] as? String,
                   eventTaskId == taskId {
                    HXLogger.info("HustlerTaskDetail: SSE event \(message.event) for task \(taskId)", category: "Network")
                    Task {
                        await loadTaskFromAPI()
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        HustlerTaskDetailScreen(taskId: "task-001")
    }
    .environment(Router())
    .environment(LiveDataService.shared)
    .environment(AppState())
}
