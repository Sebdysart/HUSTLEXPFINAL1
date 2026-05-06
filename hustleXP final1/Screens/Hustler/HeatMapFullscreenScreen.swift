//
//  HeatMapFullscreenScreen.swift
//  hustleXP final1
//
//  Full-screen heat map view for v1.9.0 Spatial Intelligence
//

import CoreLocation
import MapKit
import SwiftUI

struct HeatMapFullscreenScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    @State private var selectedZone: HeatZone?
    @State private var showFilters: Bool = false
    @State private var userLocation: GPSCoordinates?
    @State private var minPaymentFilter: Double = 0
    @State private var apiZones: [HeatZone]?
    @State private var apiBounds: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)?
    @State private var zoneAddresses: [String: String] = [:]  // zoneId → "City, State"
    @State private var showZoneTasks = false
    @State private var zoneTasks: [HXTask] = []
    @State private var zoneTasksTitle = ""
    
    var body: some View {
        ZStack {
            // Full screen heat map
            HeatMapView(
                heatZones: filteredZones,
                tasks: dataService.availableTasks,
                userLocation: userLocation,
                mapBounds: apiBounds,
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
                HeatZoneDetailSheet(
                    zone: zone,
                    address: zoneAddresses[zone.id],
                    onDismiss: {
                        withAnimation(.spring(response: 0.3)) { selectedZone = nil }
                    },
                    onViewTasks: {
                        withAnimation(.spring(response: 0.3)) { selectedZone = nil }
                        zoneTasks = tasksNearZone(zone)
                        zoneTasksTitle = zoneAddresses[zone.id] ?? zone.name
                        showZoneTasks = true
                    }
                )
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
        .sheet(isPresented: $showZoneTasks) {
            ZoneTasksSheet(
                title: zoneTasksTitle,
                tasks: zoneTasks,
                onTaskTapped: { task in
                    showZoneTasks = false
                    router.navigateToHustler(.taskDetail(taskId: task.id))
                }
            )
        }
        .task {
            let (coords, _) = await LocationService.current.captureLocation()
            userLocation = coords
            do {
                let response = try await HeatMapService.shared.getHeatMap(
                    centerLat: coords.latitude,
                    centerLng: coords.longitude
                )
                let zones = response.zones.map { z in
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
                apiZones = zones
                if let b = response.bounds {
                    apiBounds = (minLat: b.minLat, maxLat: b.maxLat, minLon: b.minLng, maxLon: b.maxLng)
                }
                HXLogger.info("HeatMapFullscreen: Loaded \(zones.count) zones from API", category: "General")
                // Reverse geocode each zone to get city, state address
                for zone in zones {
                    if let address = await reverseGeocode(zone) {
                        zoneAddresses[zone.id] = address
                    }
                }
            } catch {
                HXLogger.error("HeatMapFullscreen: API failed - \(error.localizedDescription)", category: "General")
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

    /// Reverse geocode a zone's center to "Neighborhood, City, ST" or "City, ST"
    private func reverseGeocode(_ zone: HeatZone) async -> String? {
        let location = CLLocation(
            latitude: zone.centerLatitude,
            longitude: zone.centerLongitude
        )
        
        do {
            if #available(iOS 26.0, *) {
                guard let request = MKReverseGeocodingRequest(location: location) else {
                    return nil
                }
                
                let mapItems = try await request.mapItems
                guard let mapItem = mapItems.first,
                      let address = mapItem.address else {
                    return nil
                }
                
                let shortAddress = address.shortAddress?.trimmingCharacters(in: .whitespacesAndNewlines)
                let fullAddress = address.fullAddress.trimmingCharacters(in: .whitespacesAndNewlines)

                if let shortAddress, !shortAddress.isEmpty {
                    return shortAddress
                } else if !fullAddress.isEmpty {
                    return fullAddress
                } else {
                    return nil
                }
            } else {
                let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
                guard let placemark = placemarks.first else { return nil }
                
                let neighborhood = placemark.subLocality
                let city = placemark.locality
                let state = placemark.administrativeArea
                
                if let n = neighborhood, let c = city, let s = state {
                    return "\(n), \(c), \(s)"
                } else if let c = city, let s = state {
                    return "\(c), \(s)"
                }
                
                return nil
            }
        } catch {
            HXLogger.error(
                "Reverse geocoding failed: \(error.localizedDescription)",
                category: "General"
            )
            return nil
        }
    }

    /// Tasks within 1.5× the zone radius
    private func tasksNearZone(_ zone: HeatZone) -> [HXTask] {
        let zoneLocation = CLLocation(latitude: zone.centerLatitude, longitude: zone.centerLongitude)
        let threshold = zone.radiusMeters * 1.5
        return dataService.availableTasks.filter { task in
            guard let lat = task.latitude, let lon = task.longitude else { return false }
            let taskLocation = CLLocation(latitude: lat, longitude: lon)
            return taskLocation.distance(from: zoneLocation) <= threshold
        }
    }
}

// MARK: - Heat Zone Detail Sheet

struct HeatZoneDetailSheet: View {
    let zone: HeatZone
    var address: String?
    let onDismiss: () -> Void
    let onViewTasks: () -> Void

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

                            Text(address ?? "Loading...")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }

                        Text(zone.intensity.displayName + " Activity")
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

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: { navigateToZone(zone) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Navigate")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Color.brandPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandPurple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brandPurple.opacity(0.3), lineWidth: 1)
                        )
                    }

                    Button(action: onViewTasks) {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 14, weight: .bold))
                            Text("View Tasks")
                                .font(.subheadline.weight(.semibold))
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

    private func navigateToZone(_ zone: HeatZone) {
        let mapItem = MKMapItem(
            location: CLLocation(latitude: zone.centerLatitude, longitude: zone.centerLongitude),
            address: nil
        )
        mapItem.name = address ?? zone.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

// MARK: - Zone Tasks Sheet

struct ZoneTasksSheet: View {
    let title: String
    let tasks: [HXTask]
    let onTaskTapped: (HXTask) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                if tasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.textMuted)
                        Text("No tasks in this area")
                            .font(.headline)
                            .foregroundStyle(Color.textSecondary)
                        Text("Tasks here may have already been claimed\nor are outside the zone radius.")
                            .font(.subheadline)
                            .foregroundStyle(Color.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(tasks) { task in
                                Button(action: { onTaskTapped(task) }) {
                                    HStack(spacing: 14) {
                                        // Category icon
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.brandPurple.opacity(0.15))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "briefcase.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.brandPurple)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.title)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(Color.textPrimary)
                                                .lineLimit(1)

                                            Text(task.location)
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.textSecondary)
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(task.formattedHustlerNet)
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.moneyGreen)
                                            Text(task.estimatedDuration)
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.textTertiary)
                                        }
                                    }
                                    .padding(14)
                                    .background(Color.surfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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

