//
//  TaskInProgressScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Progress is visible, completion is within reach
//

import SwiftUI

struct TaskInProgressScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    let taskId: String

    @State private var currentStatus: TaskProgressStatus = .enRoute
    @State private var showMessageSheet: Bool = false
    @State private var apiTask: HXTask?

    // XP Burst celebration
    @State private var showXPBurst = false
    @State private var pendingProofTaskId: String?

    // v1.9.0 Spatial Intelligence
    @State private var geofence: GeofenceRegion?
    @State private var currentDistance: Double?
    @State private var isInsideGeofence: Bool = false
    @State private var movementSession: MovementTrackingSession?
    @State private var userLocation: GPSCoordinates?

    // v2.2.0: Use API task when available, fall back to mock
    private var task: HXTask? {
        apiTask ?? dataService.activeTask
    }

    /// Compute earned XP from task payment (1 XP per dollar, min 25)
    private func xpForTask(_ task: HXTask) -> Int {
        max(25, Int(task.payment))
    }

    var body: some View {
        if let task = task {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Status card
                    statusCard(task)

                    // Progress steps
                    progressSteps
                        .padding(.top, 32)

                    Spacer()

                    // Action buttons
                    actionButtons(task)
                }

                // XP Burst celebration overlay
                if showXPBurst {
                    XPBurstView(xpDelta: xpForTask(task)) {
                        showXPBurst = false
                        if let proofTaskId = pendingProofTaskId {
                            router.navigateToHustler(.proofSubmission(taskId: proofTaskId))
                            pendingProofTaskId = nil
                        }
                    }
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationTitle("Task In Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showMessageSheet) {
                ConversationScreen(conversationId: task.id)
            }
            .task {
                // v2.2.0: Load task from real API
                do {
                    apiTask = try await TaskService.shared.getTask(id: taskId)
                    HXLogger.info("TaskInProgress: Loaded task from API", category: "Task")

                    // Sync UI status with actual task state
                    if let state = apiTask?.state {
                        switch state {
                        case .inProgress:
                            currentStatus = .arrived
                        case .proofSubmitted:
                            // Proof already submitted — navigate to home
                            router.hustlerPath = NavigationPath()
                            return
                        case .completed:
                            router.hustlerPath = NavigationPath()
                            return
                        default:
                            break // .claimed/.posted stay as .enRoute
                        }
                    }
                } catch {
                    HXLogger.error("TaskInProgress: API load failed, using mock - \(error.localizedDescription)", category: "Task")
                }
                await setupSpatialIntelligence(for: task)
            }
            .onDisappear {
                cleanupSpatialIntelligence()
            }
        } else {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                ErrorState(
                    title: "No Active Task",
                    message: "You don't have an active task"
                ) {
                    router.hustlerPath = NavigationPath()
                }
            }
        }
    }
    
    // MARK: - Status Card
    
    private func statusCard(_ task: HXTask) -> some View {
        VStack(spacing: 16) {
            // v1.9.0: Show geofence indicator when en route
            if currentStatus == .enRoute, let geofence = geofence {
                GeofenceIndicator(
                    geofence: geofence,
                    currentDistance: currentDistance,
                    isInside: isInsideGeofence,
                    onSmartStartTriggered: {
                        handleSmartStart(task)
                    },
                    isCompact: true
                )
            } else {
                // Status icon with animation
                ZStack {
                    Circle()
                        .fill(currentStatus.color.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: currentStatus.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(currentStatus.color)
                }
                
                // Status text
                VStack(spacing: 4) {
                    HXText(currentStatus.title, style: .title2)
                    HXText(currentStatus.subtitle, style: .subheadline, color: .textSecondary)
                }
            }
            
            // v1.9.0: Show movement tracker when working
            if currentStatus == .working, let session = movementSession {
                MovementTracker(session: session, isActive: true, isCompact: true)
            }
            
            // Task info
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HXText(task.title, style: .headline)
                    HXText(task.location, style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                PriceDisplay(amount: task.payment, size: .small)
            }
            .padding()
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - v1.9.0 Spatial Intelligence
    
    private func setupSpatialIntelligence(for task: HXTask) async {
        // Get current location
        let (coords, _) = await LocationService.current.captureLocation()
        userLocation = coords

        // v2.2.0: Check proximity via real GeofenceService
        do {
            let proximity = try await GeofenceService.shared.checkProximity(
                taskId: task.id,
                lat: coords.latitude,
                lng: coords.longitude
            )
            currentDistance = proximity.distanceMeters
            isInsideGeofence = proximity.isWithinGeofence
            HXLogger.info("TaskInProgress: Geofence proximity - \(proximity.distanceMeters)m", category: "Task")
        } catch {
            HXLogger.error("TaskInProgress: Geofence API failed - \(error.localizedDescription)", category: "Task")
        }

        // Register local geofence for real-time monitoring
        geofence = GeofenceService.shared.registerGeofence(for: task)

        // Set up geofence callbacks
        GeofenceService.shared.onGeofenceEntered = { region in
            withAnimation(.spring(response: 0.3)) {
                isInsideGeofence = true
            }
        }

        GeofenceService.shared.onDwellingDetected = { region in
            // Auto-trigger Smart Start
            if GeofenceService.shared.smartStartEnabled && currentStatus == .enRoute {
                handleSmartStart(task)
            }
        }

        // Poll real location for distance updates
        startDistanceUpdates(for: task)
    }
    
    private func startDistanceUpdates(for task: HXTask) {
        // Poll real location every 5 seconds to update distance
        Task {
            while currentStatus == .enRoute && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // Every 5 seconds

                let (coords, _) = await LocationService.current.captureLocation()
                userLocation = coords

                // Update distance via local geofence check
                if let geofence = geofence {
                    let distance = GeofenceService.shared.distanceToGeofence(
                        from: coords,
                        region: geofence
                    )
                    currentDistance = distance

                    // Check local proximity (triggers enter/exit/dwell callbacks)
                    _ = GeofenceService.shared.checkLocalProximity(currentLocation: coords)
                }
            }
        }
    }
    
    private func handleSmartStart(_ task: HXTask) {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.3)) {
            currentStatus = .arrived
        }

        // v2.2.0: Update state via real API
        Task {
            do {
                apiTask = try await TaskService.shared.startTask(taskId: task.id)
                HXLogger.info("TaskInProgress: Smart Start - task started via API", category: "Task")
            } catch {
                HXLogger.error("TaskInProgress: API start failed - \(error.localizedDescription)", category: "Task")
                dataService.updateTaskState(task.id, to: .inProgress)
            }
        }
    }
    
    private func startMovementTracking(for task: HXTask) {
        Task {
            do {
                let initialLocation: GPSCoordinates
                if let userLocation {
                    initialLocation = userLocation
                } else {
                    let (coords, _) = await LocationService.current.captureLocation()
                    initialLocation = coords
                }

                let session = try await MovementTrackingService.shared.startTracking(
                    taskId: task.id,
                    initialLocation: initialLocation
                )
                movementSession = toLegacyMovementSession(session)
            } catch {
                HXLogger.error("TaskInProgress: Failed to start movement tracking - \(error.localizedDescription)", category: "Task")
            }
        }
    }
    
    private func cleanupSpatialIntelligence() {
        GeofenceService.shared.removeGeofence(taskId: taskId)
        Task {
            do {
                _ = try await MovementTrackingService.shared.stopTracking()
            } catch {
                HXLogger.error("TaskInProgress: Failed to stop movement tracking - \(error.localizedDescription)", category: "Task")
            }
        }
    }

    private func toLegacyMovementSession(_ session: MovementSession) -> MovementTrackingSession {
        let mappedStatus: MovementStatus
        switch session.status.uppercased() {
        case "COMPLETED", "CANCELLED":
            mappedStatus = .completed
        case "STATIONARY":
            mappedStatus = .stationary
        case "SUSPICIOUS":
            mappedStatus = .suspicious
        default:
            mappedStatus = .active
        }

        let locations = session.gpsTrail.map { point in
            TrackedLocation(
                latitude: point.latitude,
                longitude: point.longitude,
                timestamp: point.timestamp,
                accuracyMeters: point.accuracy,
                speedMps: nil
            )
        }

        return MovementTrackingSession(
            id: session.id,
            taskId: session.taskId,
            hustlerId: session.userId,
            startedAt: session.startedAt,
            locations: locations,
            status: mappedStatus,
            flags: []
        )
    }
    
    // MARK: - Progress Steps
    
    private var progressSteps: some View {
        VStack(spacing: 0) {
            ProgressStepRow(
                title: "En Route",
                subtitle: "Head to the task location",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.enRoute.rawValue,
                isCurrent: currentStatus == .enRoute
            )
            
            ProgressStepRow(
                title: "Arrived",
                subtitle: "You're at the location",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.arrived.rawValue,
                isCurrent: currentStatus == .arrived
            )
            
            ProgressStepRow(
                title: "Working",
                subtitle: "Complete the task",
                isComplete: currentStatus.rawValue >= TaskProgressStatus.working.rawValue,
                isCurrent: currentStatus == .working
            )
            
            ProgressStepRow(
                title: "Submit Proof",
                subtitle: "Show your completed work",
                isComplete: false,
                isCurrent: false,
                isLast: true
            )
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(_ task: HXTask) -> some View {
        VStack(spacing: 12) {
            // Primary action based on status
            switch currentStatus {
            case .enRoute:
                HXButton("I've Arrived", variant: .primary) {
                    withAnimation(.spring(response: 0.3)) {
                        currentStatus = .arrived
                    }
                    // v2.2.0: Update state via real API
                    Task {
                        do {
                            apiTask = try await TaskService.shared.startTask(taskId: task.id)
                            HXLogger.info("TaskInProgress: Arrived - task started via API", category: "Task")
                        } catch {
                            HXLogger.error("TaskInProgress: API start failed - \(error.localizedDescription)", category: "Task")
                            dataService.updateTaskState(task.id, to: .inProgress)
                        }
                    }
                }
                
            case .arrived:
                HXButton("Start Working", variant: .primary) {
                    withAnimation(.spring(response: 0.3)) {
                        currentStatus = .working
                        // v1.9.0: Start movement tracking
                        startMovementTracking(for: task)
                    }
                }
                
            case .working:
                HXButton("Submit Proof") {
                    // Fire XP burst, then navigate when animation completes
                    pendingProofTaskId = task.id
                    withAnimation { showXPBurst = true }
                }
            }
            
            // Message poster button
            Button(action: { showMessageSheet = true }) {
                HStack {
                    HXIcon(HXIcon.message, size: .small, color: .brandPurple)
                    HXText("Message Poster", style: .subheadline, color: .brandPurple)
                }
            }
            .accessibilityLabel("Message task poster")
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Task Progress Status

enum TaskProgressStatus: Int {
    case enRoute = 0
    case arrived = 1
    case working = 2
    
    var title: String {
        switch self {
        case .enRoute: return "On Your Way"
        case .arrived: return "You've Arrived"
        case .working: return "Working..."
        }
    }
    
    var subtitle: String {
        switch self {
        case .enRoute: return "Head to the task location"
        case .arrived: return "Let the poster know you're here"
        case .working: return "Complete the task and submit proof"
        }
    }
    
    var icon: String {
        switch self {
        case .enRoute: return "car.fill"
        case .arrived: return "mappin.circle.fill"
        case .working: return "wrench.and.screwdriver.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .enRoute: return .infoBlue
        case .arrived: return .warningOrange
        case .working: return .brandPurple
        }
    }
}

// MARK: - Progress Step Row

struct ProgressStepRow: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let isCurrent: Bool
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isComplete ? Color.brandPurple : Color.surfaceSecondary)
                        .frame(width: 28, height: 28)
                    
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isComplete ? Color.brandPurple : Color.surfaceSecondary)
                        .frame(width: 2, height: 40)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                HXText(title, style: isCurrent ? .headline : .subheadline, color: isCurrent ? .textPrimary : .textSecondary)
                HXText(subtitle, style: .caption, color: .textSecondary)
            }
            .padding(.bottom, isLast ? 0 : 16)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TaskInProgressScreen(taskId: "task-001")
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
