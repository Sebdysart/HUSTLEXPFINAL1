//
//  OnTheWayTrackingScreen.swift
//  hustleXP final1
//
//  On-The-Way Tracking - Live view showing worker moving toward destination
//  Includes navigation deadline, ghosting warnings, and arrival confirmation
//

import SwiftUI

struct OnTheWayTrackingScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let trackingId: String
    
    @State private var tracking: OnTheWaySession?
    @State private var hasStartedNavigation = false
    @State private var showGhostingWarning = false
    @State private var countdown: Int = 60
    @State private var pathProgress: CGFloat = 0
    @State private var workerPosition: CGFloat = 0
    
    private let liveModeService = MockLiveModeService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color.brandBlack.ignoresSafeArea()
            
            if let tracking = tracking {
                VStack(spacing: 0) {
                    // Header
                    headerSection(tracking)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Map visualization
                            mapVisualization(tracking)
                            
                            // Status card
                            statusCard(tracking)
                            
                            // Navigation prompt (if not started)
                            if !hasStartedNavigation {
                                navigationPrompt(tracking)
                            }
                            
                            // ETA and distance
                            etaCard(tracking)
                            
                            // Task details
                            taskDetailsCard(tracking)
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
                
                // Bottom action
                VStack {
                    Spacer()
                    bottomAction(tracking)
                }
                
                // Ghosting warning overlay
                if showGhostingWarning {
                    ghostingWarningOverlay
                }
            } else {
                // Loading
                ProgressView()
                    .tint(Color.brandPurple)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadTracking()
            startCountdown()
            startPathAnimation()
        }
    }
    
    // MARK: - Header
    
    private func headerSection(_ tracking: OnTheWaySession) -> some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surfaceElevated))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(hasStartedNavigation ? Color.successGreen : Color.warningOrange)
                        .frame(width: 8, height: 8)
                    
                    Text(hasStartedNavigation ? "EN ROUTE" : "START NAVIGATION")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(hasStartedNavigation ? Color.successGreen : Color.warningOrange)
                }
                
                if !hasStartedNavigation {
                    Text("\(countdown)s remaining")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.errorRed)
                }
            }
            
            Spacer()
            
            // Emergency contact
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surfaceElevated))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Map Visualization
    
    private func mapVisualization(_ tracking: OnTheWaySession) -> some View {
        ZStack {
            // Dark map background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .frame(height: 200)
            
            // Grid overlay
            VStack(spacing: 20) {
                ForEach(0..<5, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.brandPurple.opacity(0.1))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                ForEach(0..<6, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.brandPurple.opacity(0.1))
                        .frame(width: 1)
                }
            }
            .padding(.vertical, 20)
            
            // Path line
            GeometryReader { geometry in
                let startX: CGFloat = 40
                let endX: CGFloat = geometry.size.width - 40
                let centerY: CGFloat = geometry.size.height / 2
                
                // Background path
                Path { path in
                    path.move(to: CGPoint(x: startX, y: centerY))
                    path.addLine(to: CGPoint(x: endX, y: centerY))
                }
                .stroke(Color.brandPurple.opacity(0.3), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 4]))
                
                // Progress path
                Path { path in
                    path.move(to: CGPoint(x: startX, y: centerY))
                    path.addLine(to: CGPoint(x: startX + (endX - startX) * pathProgress, y: centerY))
                }
                .stroke(Color.brandPurple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                
                // Worker marker
                ZStack {
                    Circle()
                        .fill(Color.brandPurple.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .position(x: startX + (endX - startX) * workerPosition, y: centerY)
                
                // Destination marker
                ZStack {
                    Circle()
                        .fill(Color.errorRed.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "mappin")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .position(x: endX, y: centerY)
                
                // Start marker
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 12, height: 12)
                    .position(x: startX, y: centerY)
            }
        }
    }
    
    // MARK: - Status Card
    
    private func statusCard(_ tracking: OnTheWaySession) -> some View {
        HStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(hasStartedNavigation ? Color.successGreen.opacity(0.15) : Color.warningOrange.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: hasStartedNavigation ? "location.fill" : "location.slash")
                    .font(.system(size: 22))
                    .foregroundStyle(hasStartedNavigation ? Color.successGreen : Color.warningOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hasStartedNavigation ? "Navigating to destination" : "Waiting for navigation")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                if hasStartedNavigation {
                    Text("Keep moving toward the location")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text("Start navigation within \(countdown) seconds")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.errorRed)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(hasStartedNavigation ? Color.successGreen.opacity(0.3) : Color.warningOrange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Navigation Prompt
    
    private func navigationPrompt(_ tracking: OnTheWaySession) -> some View {
        Button(action: startNavigation) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Navigation")
                        .font(.system(size: 16, weight: .bold))
                    Text("Open Maps to get directions")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
                
                Spacer()
                
                // Countdown badge
                Text("\(countdown)s")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.brandPurple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color.brandPurple.opacity(0.4), radius: 12, y: 4)
        }
    }
    
    // MARK: - ETA Card
    
    private func etaCard(_ tracking: OnTheWaySession) -> some View {
        HStack(spacing: 0) {
            // ETA
            VStack(spacing: 4) {
                Text("\(tracking.currentETA / 60)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Color.textPrimary)
                Text("min ETA")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.borderSubtle)
                .frame(width: 1, height: 40)
            
            // Distance
            VStack(spacing: 4) {
                Text(formatDistance(tracking.distanceRemaining))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("remaining")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.borderSubtle)
                .frame(width: 1, height: 40)
            
            // Speed
            VStack(spacing: 4) {
                Text(String(format: "%.1f", tracking.averageSpeed * 3.6))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("km/h")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
        )
    }
    
    // MARK: - Task Details
    
    private func taskDetailsCard(_ tracking: OnTheWaySession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quest Details")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                HXBadge(variant: .status(.inProgress))
            }
            
            // Would show actual quest details here
            VStack(alignment: .leading, spacing: 8) {
                Text("Locked out of apartment - URGENT")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                
                HStack(spacing: 16) {
                    Label("Mission District", systemImage: "mappin.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                    
                    Label("$63", systemImage: "dollarsign.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.moneyGreen)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceSecondary)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
        )
    }
    
    // MARK: - Bottom Action
    
    private func bottomAction(_ tracking: OnTheWaySession) -> some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            Button(action: markArrived) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("I've Arrived")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.successGreen)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .colorScheme(.dark)
            )
        }
    }
    
    // MARK: - Ghosting Warning
    
    private var ghostingWarningOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.errorRed)
                
                Text("Ghosting Warning")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text("You haven't started moving toward the destination. If you don't start within the next 30 seconds, you'll receive a strike and the quest will be re-listed.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button(action: cancelQuest) {
                        Text("Cancel Quest")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.errorRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.errorRed.opacity(0.15))
                            )
                    }
                    
                    Button(action: {
                        showGhostingWarning = false
                        startNavigation()
                    }) {
                        Text("Start Now")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.brandPurple)
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Actions
    
    private func loadTracking() {
        // Mock tracking data
        tracking = OnTheWaySession(
            id: trackingId,
            questId: "quest-1",
            workerId: appState.userId ?? "mock",
            acceptedAt: Date(),
            navigationStartedAt: nil,
            arrivedAt: nil,
            destinationLocation: GPSCoordinates(latitude: 37.76, longitude: -122.42),
            workerLocation: GPSCoordinates(latitude: 37.77, longitude: -122.43),
            pathPoints: [],
            currentETA: 420, // 7 minutes
            distanceRemaining: 850,
            averageSpeed: 1.4,
            status: .accepted,
            navigationDeadline: Date().addingTimeInterval(60),
            movementDeadline: Date().addingTimeInterval(120)
        )
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
                
                if countdown == 30 && !hasStartedNavigation {
                    showGhostingWarning = true
                }
            } else {
                timer.invalidate()
                if !hasStartedNavigation {
                    // Would trigger ghosting
                }
            }
        }
    }
    
    private func startPathAnimation() {
        // Animate the path progress
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            pathProgress = 1.0
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            workerPosition = 0.9
        }
    }
    
    private func startNavigation() {
        hasStartedNavigation = true
        liveModeService.startNavigation(trackingId: trackingId)
        
        // Would open Maps app in production
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func markArrived() {
        liveModeService.markArrived(trackingId: trackingId)
        
        // Navigate to task in progress
        router.navigateToHustler(.taskInProgress(taskId: tracking?.questId ?? ""))
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func cancelQuest() {
        // Would handle cancellation
        dismiss()
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1f km", meters / 1000)
        }
    }
}

// MARK: - Preview

#Preview {
    OnTheWayTrackingScreen(trackingId: "tracking-1")
        .environment(Router())
        .environment(AppState())
}
