//
//  LiveBroadcastsScreen.swift
//  hustleXP final1
//
//  v2.6.0: Live Broadcasts list — shows active task broadcasts near the user.
//  Data source: LiveModeService.shared.listBroadcasts (live.listBroadcasts tRPC)
//  Real-time: subscribes to SSE events live_broadcast_new / live_broadcast_updated /
//             live_broadcast_expired and refreshes the list on each event.
//

import SwiftUI
import Combine
import CoreLocation

struct LiveBroadcastsScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    // MARK: - State

    @State private var broadcasts: [LiveBroadcast] = []
    @State private var isLoading = true
    @State private var loadError: AppError?
    @State private var userLocation: GPSCoordinates?
    @State private var sseSubscription: AnyCancellable?

    // MARK: - Constants

    private let defaultRadius: Double = 10 // miles
    private let liveModeService = LiveModeService.shared

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if isLoading {
                loadingState
            } else if let error = loadError {
                ErrorStateView(error: error, onRetry: {
                    Task { await loadBroadcasts() }
                })
            } else if broadcasts.isEmpty {
                emptyState
            } else {
                broadcastList
            }
        }
        .navigationTitle("Live Broadcasts")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task { await loadBroadcasts() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brandPurple)
                }
                .accessibilityLabel("Refresh broadcasts")
            }
        }
        .task {
            await loadLocation()
            await loadBroadcasts()
            subscribeToSSE()
        }
        .onDisappear {
            sseSubscription?.cancel()
            sseSubscription = nil
        }
        .refreshable {
            await loadBroadcasts()
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        ScrollView {
            VStack(spacing: 0) {
                SkeletonList(count: 4)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: "antenna.radiowaves.left.and.right",
            title: "No Live Broadcasts",
            message: "There are no active task broadcasts in your area right now. Check back soon or expand your radius.",
            ctaLabel: "Refresh",
            ctaAction: {
                Task { await loadBroadcasts() }
            }
        )
    }

    // MARK: - Broadcast List

    private var broadcastList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Header count
                HStack {
                    Text("\(broadcasts.count) active broadcast\(broadcasts.count == 1 ? "" : "s") nearby")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ForEach(broadcasts) { broadcast in
                    Button {
                        router.navigateToHustler(.taskDetail(taskId: broadcast.taskId))
                    } label: {
                        LiveBroadcastRow(
                            broadcast: broadcast,
                            userLocation: userLocation
                        )
                    }
                    .buttonStyle(.plain)

                    HXDivider()
                        .padding(.leading, 16)
                }
            }
        }
    }

    // MARK: - Actions

    private func loadLocation() async {
        let (coords, _) = await LocationService.current.captureLocation()
        userLocation = coords
    }

    private func loadBroadcasts() async {
        isLoading = broadcasts.isEmpty
        loadError = nil

        let lat = userLocation?.latitude ?? 37.7749   // Default: San Francisco
        let lon = userLocation?.longitude ?? -122.4194

        do {
            broadcasts = try await liveModeService.listBroadcasts(
                latitude: lat,
                longitude: lon,
                radiusMiles: defaultRadius
            )
            HXLogger.info("LiveBroadcasts: Loaded \(broadcasts.count) broadcasts", category: "LiveMode")
        } catch {
            HXLogger.error("LiveBroadcasts: Load failed - \(error.localizedDescription)", category: "LiveMode")
            if broadcasts.isEmpty {
                loadError = .server
            }
        }
        isLoading = false
    }

    // MARK: - SSE Subscription

    private func subscribeToSSE() {
        sseSubscription = RealtimeSSEClient.shared.messageReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                let refreshEvents = [
                    "live_broadcast_new",
                    "live_broadcast_updated",
                    "live_broadcast_expired"
                ]
                guard refreshEvents.contains(message.event) else { return }
                HXLogger.info("LiveBroadcasts: SSE '\(message.event)' — refreshing", category: "Network")
                Task {
                    await loadBroadcasts()
                }
            }
    }
}

// MARK: - LiveBroadcastRow

private struct LiveBroadcastRow: View {
    let broadcast: LiveBroadcast
    let userLocation: GPSCoordinates?

    // MARK: - Computed

    private var distanceText: String? {
        guard let userLat = userLocation?.latitude,
              let userLon = userLocation?.longitude,
              let bLat = broadcast.latitude,
              let bLon = broadcast.longitude else { return nil }

        let userCL = CLLocation(latitude: userLat, longitude: userLon)
        let broadcastCL = CLLocation(latitude: bLat, longitude: bLon)
        let metres = userCL.distance(from: broadcastCL)

        if metres < 1000 {
            return "\(Int(metres)) m away"
        } else {
            let miles = metres / 1609.34
            return String(format: "%.1f mi away", miles)
        }
    }

    private var timeRemainingText: String? {
        guard let deadline = broadcast.deadline else { return nil }
        let seconds = deadline.timeIntervalSinceNow
        guard seconds > 0 else { return "Expired" }

        if seconds < 60 {
            return "\(Int(seconds))s left"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m left"
        } else {
            return "\(Int(seconds / 3600))h left"
        }
    }

    private var isExpiringSoon: Bool {
        guard let deadline = broadcast.deadline else { return false }
        return deadline.timeIntervalSinceNow < 300 // < 5 minutes
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Category icon
            categoryIcon

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(broadcast.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                    Text(broadcast.location)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }

                // Metadata row: distance + deadline
                HStack(spacing: 12) {
                    if let dist = distanceText {
                        Label(dist, systemImage: "location.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.infoBlue)
                    }

                    if let remaining = timeRemainingText {
                        Label(remaining, systemImage: "clock")
                            .font(.system(size: 11))
                            .foregroundStyle(isExpiringSoon ? Color.errorRed : Color.textMuted)
                    }
                }
            }

            Spacer(minLength: 8)

            // Pay amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(Int(broadcast.price))")
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.moneyGreen)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color.brandPurple.opacity(0.15))
                .frame(width: 44, height: 44)

            Image(systemName: iconForCategory(broadcast.category))
                .font(.system(size: 18))
                .foregroundStyle(Color.brandPurple)
        }
    }

    private func iconForCategory(_ category: String?) -> String {
        switch category?.lowercased() {
        case "delivery", "courier": return "shippingbox.fill"
        case "cleaning": return "sparkles"
        case "moving", "heavy_lifting": return "figure.strengthtraining.traditional"
        case "handyman", "repair": return "wrench.and.screwdriver.fill"
        case "tech", "it", "technology": return "laptopcomputer"
        case "errands": return "bag.fill"
        case "pet", "dog": return "pawprint.fill"
        case "lawn", "outdoor", "garden": return "leaf.fill"
        default: return "bolt.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LiveBroadcastsScreen()
    }
    .environment(Router())
    .environment(AppState())
}
