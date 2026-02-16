//
//  HeatMapFullscreenScreen.swift
//  hustleXP final1
//
//  Full-screen heat map view for v1.9.0 Spatial Intelligence
//

import SwiftUI

struct HeatMapFullscreenScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService
    
    @State private var selectedZone: HeatZone?
    @State private var showFilters: Bool = false
    @State private var userLocation: GPSCoordinates?
    @State private var minPaymentFilter: Double = 0
    @State private var apiZones: [HeatZone]?
    
    var body: some View {
        ZStack {
            // Full screen heat map
            HeatMapView(
                heatZones: filteredZones,
                tasks: dataService.availableTasks,
                userLocation: userLocation,
                onZoneTapped: { zone in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedZone = zone
                    }
                },
                onTaskTapped: { task in
                    router.navigateToHustler(.taskDetail(taskId: task.id))
                }
            )
            .ignoresSafeArea()
            
            // Overlay controls
            VStack {
                // Top bar with controls
                HStack {
                    // Close button
                    Button(action: { router.popHustler() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close heat map")
                    
                    Spacer()
                    
                    // Title
                    Text("Task Heat Map")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Filter button
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.brandPurple)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Filter heat map zones")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Legend
                HeatMapLegend()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
            
            // Zone detail sheet
            if let zone = selectedZone {
                HeatZoneDetailSheet(zone: zone) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedZone = nil
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Filters sheet
            if showFilters {
                FilterSheet(
                    minPayment: $minPaymentFilter,
                    onDismiss: { showFilters = false }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .task {
            let (coords, _) = await LocationService.current.captureLocation()
            userLocation = coords
            // v2.2.0: Load heat zones from real API
            do {
                let response = try await HeatMapService.shared.getHeatMap(
                    centerLat: coords.latitude,
                    centerLng: coords.longitude
                )
                // Convert API zones to local HeatZone model
                apiZones = response.zones.map { z in
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
                HXLogger.info("HeatMapFullscreen: Loaded \(response.zones.count) zones from API", category: "General")
            } catch {
                HXLogger.error("HeatMapFullscreen: API failed, using mock - \(error.localizedDescription)", category: "General")
            }
        }
    }
    
    private var filteredZones: [HeatZone] {
        let zones = apiZones ?? []
        if minPaymentFilter > 0 {
            return zones.filter { $0.averagePayment >= minPaymentFilter }
        }
        return zones
    }
}

// MARK: - Heat Zone Detail Sheet

struct HeatZoneDetailSheet: View {
    let zone: HeatZone
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.textMuted)
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(zone.intensity.color)
                                .frame(width: 12, height: 12)
                            
                            Text(zone.name)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        
                        Text(zone.intensity.displayName)
                            .font(.subheadline)
                            .foregroundStyle(zone.intensity.color)
                    }
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                
                // Stats
                HStack(spacing: 20) {
                    ZoneStatItem(
                        icon: "briefcase.fill",
                        value: "\(zone.taskCount)",
                        label: "Tasks",
                        color: .brandPurple
                    )
                    
                    ZoneStatItem(
                        icon: "dollarsign",
                        value: zone.formattedAveragePayment,
                        label: "Avg Pay",
                        color: .moneyGreen
                    )
                    
                    ZoneStatItem(
                        icon: "flame.fill",
                        value: zone.intensity.displayName,
                        label: "Activity",
                        color: zone.intensity.color
                    )
                }
                .padding(.horizontal, 20)
                
                // Action button
                Button(action: {
                    // Would filter feed by this zone
                    onDismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .bold))
                        Text("View Tasks in \(zone.name)")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPurple, Color.aiPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
                    .ignoresSafeArea()
            )
        }
    }
}

struct ZoneStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.headline.weight(.bold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var minPayment: Double
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.textMuted)
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // Header
                HStack {
                    Text("Filter Zones")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                
                // Min payment slider
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Minimum Avg. Payment")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                        
                        Spacer()
                        
                        Text(minPayment == 0 ? "Any" : "$\(Int(minPayment))+")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.moneyGreen)
                    }
                    
                    Slider(value: $minPayment, in: 0...100, step: 10)
                        .tint(Color.brandPurple)
                }
                .padding(.horizontal, 20)
                
                // Apply button
                Button(action: onDismiss) {
                    Text("Apply Filters")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceElevated)
                    .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Preview

#Preview {
    HeatMapFullscreenScreen()
        .environment(Router())
        .environment(LiveDataService.shared)
}
