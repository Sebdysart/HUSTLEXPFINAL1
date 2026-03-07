//
//  HustlerFeedScreen.swift
//  hustleXP final1
//
//  Archetype: B (Feed/Opportunity)
//  Premium task discovery with filters and search
//

import SwiftUI

struct HustlerFeedScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(LiveDataService.self) private var dataService
    
    // v2.2.0: Real API service
    @StateObject private var taskDiscovery = TaskDiscoveryService.shared
    
    @State private var searchText: String = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var isLoading: Bool = false
    @State private var showFilters: Bool = false
    @State private var feedFilters = FeedFilterParams()
    @State private var apiTasks: [HXTask] = []
    @State private var apiError: AppError?
    @State private var showApiError: Bool = false
    
    // v1.9.0 Spatial Intelligence
    @State private var showMapView: Bool = false
    @State private var currentLocation: GPSCoordinates?
    @State private var batchRecommendation: BatchRecommendation?
    
    // v2.1.0 Professional Licensing - Eligibility Filtering
    @State private var matchmakerResult: AIMatchmakerResult?
    private let licenseService = LicenseVerificationService.shared

    // v2.2.0: Real skill data for filtering
    @State private var userSkills: [WorkerSkillRecord] = []

    // v2.2.0: API-loaded heat zones
    @State private var apiHeatZones: [HeatZone]?
    
    // v2.2.0: Use API tasks when available, fall back to mock data
    private var filteredTasks: [HXTask] {
        // Use API tasks if loaded, otherwise fall back to mock
        var tasks = apiTasks.isEmpty ? (matchmakerResult?.eligibleTasks ?? dataService.availableTasks) : apiTasks
        
        // Apply search filter
        if !searchText.isEmpty {
            tasks = tasks.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .nearby:
            // v1.9.0: Implement nearby filter with location service
            if let location = currentLocation {
                tasks = LocationService.current.sortTasksByDistance(tasks: tasks, from: location)
                // Limit to top 10 nearest
                tasks = Array(tasks.prefix(10))
            }
        case .highPay:
            tasks = tasks.filter { $0.payment >= 50 }
        case .quickTask:
            tasks = tasks.filter { $0.estimatedDuration.contains("min") || $0.estimatedDuration.contains("30") }
        case .mySkills:
            // v2.2.0: Filter by real skills when available, fall back to matchmaker
            if !userSkills.isEmpty {
                let skillNames = Set(userSkills.map { $0.skillName.lowercased() })
                tasks = tasks.filter { task in
                    // Check if task category or title matches any user skill
                    if let category = task.category?.rawValue {
                        return skillNames.contains(category.lowercased())
                    }
                    return skillNames.contains(where: { task.title.lowercased().contains($0) })
                }
            }
            // else: Already filtered by matchmaker based on skills
        }
        
        return tasks
    }
    
    private var lockedQuests: [LockedQuest] {
        matchmakerResult?.lockedQuests ?? []
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.brandBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Stats header
                feedHeader
                
                // Filter chips
                filterSection

                // v2.6.0: Active filter summary banner
                if feedFilters.isActive {
                    activeFilterBanner
                }

                // v1.9.0: Toggle between list and map view
                if showMapView {
                    mapViewSection
                } else {
                    taskListSection
                }
            }
            
            // v1.9.0: Floating map toggle button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MapToggleButton(showMapView: $showMapView)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
            
            // v1.9.0: Batch recommendation overlay
            if let recommendation = batchRecommendation, !showMapView {
                VStack {
                    Spacer()
                    NearbyTaskCard(
                        recommendation: recommendation,
                        onAccept: {
                            router.navigateToHustler(.batchDetails(batchId: recommendation.id))
                        },
                        onDismiss: {
                            withAnimation(.spring(response: 0.3)) {
                                batchRecommendation = nil
                            }
                        },
                        isCompact: true
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // v2.1.0: Locked quests floating badge
            if !lockedQuests.isEmpty && !showMapView && batchRecommendation == nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LockedQuestCountBadge(
                            count: lockedQuests.count,
                            topEarnings: lockedQuests.first?.potentialEarnings ?? 0,
                            onTap: {
                                router.navigateToHustler(.lockedQuests)
                            }
                        )
                        .padding(.trailing, 80) // Account for map toggle
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $searchText, prompt: "Search tasks, locations...")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // v2.1.0: Skills button
                Button {
                    router.navigateToHustler(.skillSelection)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Skills")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.brandPurple.opacity(0.15))
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Manage skills")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilters.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(feedFilters.isActive ? Color.brandPurple : Color.surfaceElevated)
                            .frame(width: 36, height: 36)

                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(feedFilters.isActive ? .white : Color.brandPurple)

                        if feedFilters.isActive {
                            Circle()
                                .fill(Color.warningOrange)
                                .frame(width: 10, height: 10)
                                .offset(x: 12, y: -12)
                        }
                    }
                }
                .accessibilityLabel("Filter tasks")
            }
        }
        .sheet(isPresented: $showFilters) {
            FeedFilterSheet(
                isPresented: $showFilters,
                filters: $feedFilters,
                onApply: {
                    Task { await refreshWithFilters() }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await loadLocationData()
        }
    }
    
    // MARK: - v1.9.0 Map View Section
    
    private var mapViewSection: some View {
        VStack(spacing: 0) {
            HeatMapView(
                heatZones: apiHeatZones ?? [],
                tasks: filteredTasks,
                userLocation: currentLocation,
                onZoneTapped: { zone in
                    // Could show zone details
                },
                onTaskTapped: { task in
                    router.navigateToHustler(.taskDetail(taskId: task.id))
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Legend
            HeatMapLegend()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            Spacer()
        }
    }
    
    // MARK: - Location Data Loading
    
    private func loadLocationData() async {
        let (coords, _) = await LocationService.current.captureLocation()
        currentLocation = coords

        // v2.2.0: Fetch heat map from real API
        do {
            let response = try await HeatMapService.shared.getHeatMap(
                centerLat: coords.latitude,
                centerLng: coords.longitude
            )
            apiHeatZones = response.zones.map { z in
                HeatZone(
                    id: z.identifier,
                    name: "Zone",
                    centerLatitude: z.centerLat,
                    centerLongitude: z.centerLng,
                    radiusMeters: z.radiusMeters,
                    intensity: HeatIntensity.from(taskCount: z.taskCount),
                    taskCount: z.taskCount,
                    averagePayment: Double(z.averagePaymentCents ?? 0) / 100.0,
                    lastUpdated: Date()
                )
            }
        } catch {
            HXLogger.error("HustlerFeed: HeatMap API failed - \(error.localizedDescription)", category: "Task")
        }

        // v2.2.0: Load real skills from API, then fetch tasks with skill filtering
        do {
            let skills = try await SkillService.shared.getMySkills()
            userSkills = skills
            let skillIds = skills.map { $0.skillId }
            HXLogger.info("HustlerFeed: Loaded \(skills.count) skills from API", category: "Task")

            // Fetch tasks with skill-based filtering via the discovery feed
            await loadTasksFromAPI(location: coords, skills: skillIds.isEmpty ? nil : skillIds)
        } catch {
            HXLogger.error("HustlerFeed: Skills API failed - \(error.localizedDescription)", category: "Task")
            // Load tasks without skill filtering — skills unavailable this session
            await loadTasksFromAPI(location: coords)
        }
        
        // v2.2.0: Generate batch recommendation - try real API first
        if let firstTask = filteredTasks.first {
            do {
                let suggestions = try await BatchQuestService.shared.getSuggestions(
                    currentTaskId: firstTask.id,
                    maxResults: 5
                )

                if !suggestions.isEmpty {
                    let allAvailableTasks = apiTasks.isEmpty ? dataService.availableTasks : apiTasks
                    let suggestedTaskIds = Set(suggestions.map { $0.taskId })
                    let nearbyTasks = allAvailableTasks.filter { suggestedTaskIds.contains($0.id) }

                    if !nearbyTasks.isEmpty {
                        let allTasks = [firstTask] + nearbyTasks
                        let totalPayment = allTasks.reduce(0.0) { $0 + $1.payment }
                        let savings = TaskBatchingService.shared.calculateBatchSavingsLocal(tasks: allTasks)

                        batchRecommendation = BatchRecommendation(
                            id: "batch_\(firstTask.id)_\(UUID().uuidString.prefix(8))",
                            primaryTask: firstTask,
                            nearbyTasks: nearbyTasks,
                            totalPayment: totalPayment,
                            totalEstimatedTime: "\(allTasks.count * 30) min",
                            savings: savings,
                            expiresAt: Date().addingTimeInterval(30 * 60)
                        )
                        HXLogger.info("HustlerFeed: Built batch recommendation from API suggestions", category: "Task")
                        return
                    }
                }
            } catch {
                HXLogger.error("HustlerFeed: Batch API failed, falling back to mock - \(error.localizedDescription)", category: "Task")
            }

            // Fallback: use mock batch recommendation
            batchRecommendation = TaskBatchingService.shared.generateRecommendation(
                for: firstTask,
                availableTasks: apiTasks.isEmpty ? dataService.availableTasks : apiTasks,
                userLocation: coords
            )
        }
    }
    
    // v2.2.0: Load tasks from real API with optional skill filtering
    private func loadTasksFromAPI(location: GPSCoordinates?, skills: [String]? = nil) async {
        do {
            let response = try await taskDiscovery.getFeed(
                latitude: location?.latitude ?? 37.7749,
                longitude: location?.longitude ?? -122.4194,
                radiusMeters: 16093, // 10 miles
                skills: skills,
                limit: 50,
                filters: feedFilters.isActive ? feedFilters : nil
            )
            apiTasks = response.tasks
            apiError = nil
            HXLogger.info("HustlerFeed: Loaded \(apiTasks.count) tasks from API", category: "Task")
        } catch {
            if let apiErr = error as? APIError {
                switch apiErr {
                case .networkError:
                    apiError = .network
                case .unauthorized:
                    apiError = .authExpired
                default:
                    apiError = .server
                }
            } else {
                apiError = .server
            }
            showApiError = true
            HXLogger.error("HustlerFeed: API failed - \(error.localizedDescription)", category: "Task")
        }
    }

    // v2.6.0: Refresh feed with updated filter params
    private func refreshWithFilters() async {
        isLoading = true
        let skillIds = userSkills.isEmpty ? nil : userSkills.map { $0.skillId }
        await loadTasksFromAPI(location: currentLocation, skills: skillIds)
        isLoading = false
    }
    
    // MARK: - Feed Header
    
    private var feedHeader: some View {
        HStack(spacing: 16) {
            // Available tasks count
            VStack(alignment: .leading, spacing: 4) {
                Text("\(filteredTasks.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("tasks available")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            // Total potential earnings
            VStack(alignment: .trailing, spacing: 4) {
                let totalPotential = filteredTasks.reduce(0) { $0 + $1.payment }
                Text("$\(Int(totalPotential))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.moneyGreen)
                
                Text("potential earnings")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.brandPurple.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Active Filter Banner (v2.6.0)

    private var activeFilterBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.brandPurple)

            Text(filterSummaryText)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)

            Spacer()

            Button {
                feedFilters = FeedFilterParams()
                Task { await refreshWithFilters() }
            } label: {
                Text("Clear")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPurple)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.brandPurple.opacity(0.08))
    }

    private var filterSummaryText: String {
        var parts: [String] = []
        if let cat = feedFilters.category { parts.append(cat.displayName) }
        if feedFilters.minPriceCents != nil || feedFilters.maxPriceCents != nil {
            let min = feedFilters.minPriceCents.map { "$\($0 / 100)" } ?? "$0"
            let max = feedFilters.maxPriceCents.map { "$\($0 / 100)" } ?? "$500+"
            parts.append("\(min)-\(max)")
        }
        if let dist = feedFilters.maxDistanceMiles { parts.append("\(Int(dist)) mi") }
        if let sort = feedFilters.sortBy, sort != .relevance { parts.append(sort.displayName) }
        return parts.joined(separator: " · ")
    }

    // MARK: - Task List Section
    
    private var taskListSection: some View {
        Group {
            if isLoading {
                LoadingState(variant: .skeleton)
            } else if showApiError, let error = apiError {
                // v2.5.0: Show error state instead of silent fallback
                apiErrorView(error: error)
            } else if filteredTasks.isEmpty {
                emptyStateView
            } else {
                taskList
            }
        }
    }
    
    // MARK: - API Error View (v2.5.0)
    
    private func apiErrorView(error: AppError) -> some View {
        ErrorStateView(error: error, onRetry: {
            Task {
                showApiError = false
                isLoading = true
                await loadTasksFromAPI(location: currentLocation)
                isLoading = false
            }
        })
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Tasks Found",
            message: "Try adjusting your filters or check back later.",
            ctaLabel: "Clear Filters",
            ctaAction: {
                selectedFilter = .all
                searchText = ""
            }
        )
    }
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Featured task (first one with highest pay)
                if let featured = filteredTasks.max(by: { $0.payment < $1.payment }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.warningOrange)
                            
                            Text("HOT OPPORTUNITY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(Color.warningOrange)
                        }
                        
                        TaskCard(
                            title: featured.title,
                            payment: featured.payment,
                            location: featured.location,
                            duration: featured.estimatedDuration,
                            variant: .featured,
                            posterName: "Top Poster",
                            category: "Best Match"
                        ) {
                            router.navigateToHustler(.taskDetail(taskId: featured.id))
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Regular tasks
                ForEach(filteredTasks) { task in
                    TaskCard(
                        title: task.title,
                        payment: task.payment,
                        location: task.location,
                        duration: task.estimatedDuration,
                        variant: .expanded,
                        posterName: "Task Poster"
                    ) {
                        router.navigateToHustler(.taskDetail(taskId: task.id))
                    }
                }
            }
            .padding(20)
        }
        .refreshable {
            await refreshTasksAsync()
        }
    }
    
    private func refreshTasksAsync() async {
        isLoading = true
        let skillIds = userSkills.isEmpty ? nil : userSkills.map { $0.skillId }
        await loadTasksFromAPI(location: currentLocation, skills: skillIds)
        isLoading = false
    }
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case nearby = "Nearby"
    case highPay = "High Pay"
    case quickTask = "Quick"
    case mySkills = "My Skills"
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .nearby: return "location"
        case .highPay: return "dollarsign"
        case .quickTask: return "bolt"
        case .mySkills: return "star"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }
                
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brandPurple, Color.brandPurpleLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Capsule()
                            .fill(Color.surfaceElevated)
                        
                        Capsule()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color.brandPurple.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        HustlerFeedScreen()
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
