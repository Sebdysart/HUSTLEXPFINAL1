//
//  LiveRadarScreen.swift
//  hustleXP final1
//
//  LIVE Mode Radar Screen - The main radar interface for workers
//  Shows quests on radar, handles acceptance, and tracks sessions
//

import SwiftUI

struct LiveRadarScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    @Environment(AppState.self) private var appState
    
    @State private var isLiveMode = false
    @State private var session: LiveModeSession?
    @State private var visibleQuests: [QuestAlert] = []
    @State private var selectedQuest: QuestAlert?
    @State private var showQuestDetail = false
    @State private var userLocation: GPSCoordinates?
    @State private var showEligibilityWarning = false
    @State private var selectedCategories: Set<LiveTaskCategory> = Set(LiveTaskCategory.allCases)
    @State private var showCategoryPicker = false
    
    private let liveModeService = MockLiveModeService.shared
    
    // Eligibility check
    private var isEligible: Bool {
        appState.trustTier.rawValue >= TrustTier.elite.rawValue &&
        liveModeService.workerStats.isEligibleForLiveMode
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with toggle
                    headerSection
                    
                    if isLiveMode {
                        // Live mode active - show radar
                        liveRadarContent(geometry: geometry)
                    } else {
                        // Live mode inactive - show activation prompt
                        inactiveContent(geometry: geometry)
                    }
                }
                
                // Quest detail sheet
                if let quest = selectedQuest {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                selectedQuest = nil
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        QuestAlertCard(
                            quest: quest,
                            onAccept: { acceptQuest(quest) },
                            onDecline: { 
                                withAnimation {
                                    selectedQuest = nil
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                // Eligibility warning
                if showEligibilityWarning {
                    eligibilityWarningOverlay
                }
            }
        }
        .navigationTitle("Live Radar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showCategoryPicker = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            categoryPickerSheet
        }
        .task {
            await loadLocation()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Live mode toggle
            LiveModeToggle(
                isActive: $isLiveMode,
                session: session,
                questCount: visibleQuests.count,
                onToggle: { newValue in
                    if newValue {
                        startLiveMode()
                    } else {
                        endLiveMode()
                    }
                }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Status bar when live
            if isLiveMode, let session = session {
                LiveModeStatusBar(
                    session: session,
                    onEndSession: { endLiveMode() }
                )
            }
            
            Divider()
                .background(Color.borderSubtle)
        }
    }
    
    // MARK: - Live Radar Content
    
    private func liveRadarContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Radar view
            RadarView(
                quests: visibleQuests,
                userLocation: userLocation,
                maxRadius: liveModeService.maxRadiusMeters,
                onQuestTap: { quest in
                    withAnimation(.spring(response: 0.4)) {
                        selectedQuest = quest
                    }
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            )
            .frame(height: min(geometry.size.width - 32, 350))
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            // Quest list
            if !visibleQuests.isEmpty {
                questListSection
            } else {
                noQuestsSection
            }
            
            Spacer()
        }
    }
    
    // MARK: - Inactive Content
    
    private func inactiveContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Radar illustration (static)
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.05))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.15), lineWidth: 1)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.1), lineWidth: 1)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.brandPurple.opacity(0.5))
            }
            
            VStack(spacing: 12) {
                Text("Go Live to Start Hunting")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Toggle Live Mode to see urgent quests\non your radar in real-time")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                benefitRow(icon: "bolt.fill", text: "3-second head start on ASAP quests", color: .brandPurple)
                benefitRow(icon: "dollarsign.circle.fill", text: "Higher pay with surge pricing", color: .moneyGreen)
                benefitRow(icon: "location.fill", text: "GPS matching for fastest arrival", color: .errorRed)
                benefitRow(icon: "star.fill", text: "Build your reliability score", color: .yellow)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
            )
            .padding(.horizontal, 24)
            
            // Eligibility check
            if !isEligible {
                eligibilityCard
            }
            
            Spacer()
        }
    }
    
    private func benefitRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
            
            Spacer()
        }
    }
    
    // MARK: - Quest List
    
    private var questListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Quests")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Text("\(visibleQuests.count) active")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(visibleQuests) { quest in
                        MiniQuestCard(quest: quest) {
                            withAnimation(.spring(response: 0.4)) {
                                selectedQuest = quest
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var noQuestsSection: some View {
        VStack(spacing: 16) {
            Text("Scanning for quests...")
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
            
            Text("Stay in Live Mode to catch the next urgent request")
                .font(.system(size: 13))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }
    
    // MARK: - Eligibility
    
    private var eligibilityCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                Text("Elite Tier Required")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color.warningOrange)
            
            Text("Live Mode is available for Elite tier workers (Level 5+) with high reliability scores.")
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                router.navigateToHustler(.xpBreakdown)
            }) {
                Text("View Progress")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warningOrange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private var eligibilityWarningOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 48))
                .foregroundStyle(Color.warningOrange)
            
            Text("Elite Tier Required")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            
            Text("Live Mode quests are reserved for our most reliable Hustlers. Reach Elite tier to unlock.")
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showEligibilityWarning = false }) {
                Text("Got it")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.brandPurple)
                    )
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.surfaceElevated)
        )
        .padding(.horizontal, 32)
    }
    
    // MARK: - Category Picker
    
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(LiveTaskCategory.allCases, id: \.self) { category in
                    Button(action: {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(category.color)
                                .frame(width: 32)
                            
                            Text(category.rawValue)
                                .foregroundStyle(Color.textPrimary)
                            
                            Spacer()
                            
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.brandPurple)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.brandBlack)
            .navigationTitle("Quest Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showCategoryPicker = false
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Actions
    
    private func startLiveMode() {
        guard isEligible else {
            showEligibilityWarning = true
            isLiveMode = false
            return
        }
        
        guard let location = userLocation else { return }
        
        // v2.2.0: Toggle live mode via real API first, then load broadcasts
        Task {
            do {
                let status = try await LiveModeService.shared.toggle(enabled: true)
                print("✅ LiveRadar: Live mode toggled via API - \(status.state.rawValue)")
            } catch {
                print("⚠️ LiveRadar: API toggle failed - \(error.localizedDescription)")
            }

            // v2.2.0: Try to load live broadcasts from real API
            if let location = userLocation {
                do {
                    let broadcasts = try await LiveModeService.shared.listBroadcasts(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    print("✅ LiveRadar: Loaded \(broadcasts.count) live broadcasts from API")
                    // Broadcasts are stored on LiveModeService.shared.broadcasts
                    // Keep mock quests for UI since QuestAlert format differs from LiveBroadcast
                } catch {
                    print("⚠️ LiveRadar: Broadcast API failed - \(error.localizedDescription)")
                }
            }
        }

        session = liveModeService.startLiveMode(
            workerId: appState.userId ?? "mock-worker",
            location: location,
            categories: Array(selectedCategories)
        )

        // Load visible quests
        visibleQuests = liveModeService.getVisibleQuests(at: location, isLiveMode: true)
        
        // Haptic feedback
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func endLiveMode() {
        // v2.2.0: Toggle off via real API
        Task {
            do {
                _ = try await LiveModeService.shared.toggle(enabled: false)
                print("✅ LiveRadar: Live mode ended via API")
            } catch {
                print("⚠️ LiveRadar: API end failed - \(error.localizedDescription)")
            }
        }
        liveModeService.endLiveMode()
        session = nil
        visibleQuests = []
        isLiveMode = false
    }
    
    private func acceptQuest(_ quest: QuestAlert) {
        guard let location = userLocation else { return }
        
        if let tracking = liveModeService.acceptQuest(quest.id, workerId: appState.userId ?? "unknown-worker", workerLocation: location) {
            // Navigate to on-the-way tracking
            router.navigateToHustler(.onTheWayTracking(trackingId: tracking.id))
            selectedQuest = nil
            
            // Haptic
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.success)
        }
    }
    
    private func loadLocation() async {
        let (coords, _) = await LocationService.current.captureLocation()
        userLocation = coords
    }
}

// MARK: - Mini Quest Card

private struct MiniQuestCard: View {
    let quest: QuestAlert
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Timer
                    Text("\(quest.timeRemaining)s")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(quest.timeRemaining < 15 ? Color.errorRed : Color.warningOrange)
                    
                    Spacer()
                    
                    // Distance
                    if let distance = quest.distanceMeters {
                        Text(distance < 1000 ? "\(Int(distance))m" : String(format: "%.1f mi", distance / 1609.34))
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                
                Text(quest.task.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("$\(Int(quest.totalPayment))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.moneyGreen)
            }
            .padding(12)
            .frame(width: 160, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.errorRed.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LiveRadarScreen()
    }
    .environment(Router())
    .environment(LiveDataService.shared)
    .environment(AppState())
}
