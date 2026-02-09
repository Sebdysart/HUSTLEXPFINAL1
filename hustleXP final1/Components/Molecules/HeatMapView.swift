//
//  HeatMapView.swift
//  hustleXP final1
//
//  Mock Heat Map visualization for v1.9.0 - Shows task density zones
//

import SwiftUI

struct HeatMapView: View {
    let heatZones: [HeatZone]
    let tasks: [HXTask]
    let userLocation: GPSCoordinates?
    var onZoneTapped: ((HeatZone) -> Void)? = nil
    var onTaskTapped: ((HXTask) -> Void)? = nil
    var isCompact: Bool = false
    
    @State private var selectedZone: HeatZone?
    @State private var pulseAnimation: Bool = false
    
    // SF map bounds (approximate)
    private let minLat = 37.70
    private let maxLat = 37.82
    private let minLon = -122.52
    private let maxLon = -122.35
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                MapGridBackground()
                
                // Heat zone overlays
                ForEach(heatZones) { zone in
                    HeatZoneOverlay(
                        zone: zone,
                        size: geometry.size,
                        minLat: minLat,
                        maxLat: maxLat,
                        minLon: minLon,
                        maxLon: maxLon,
                        isSelected: selectedZone?.id == zone.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedZone = zone
                        }
                        onZoneTapped?(zone)
                    }
                }
                
                // Task markers
                ForEach(tasks.filter { $0.hasCoordinates }) { task in
                    TaskMapMarker(
                        task: task,
                        size: geometry.size,
                        minLat: minLat,
                        maxLat: maxLat,
                        minLon: minLon,
                        maxLon: maxLon
                    )
                    .onTapGesture {
                        onTaskTapped?(task)
                    }
                }
                
                // User location marker
                if let location = userLocation {
                    UserLocationMarker(
                        location: location,
                        size: geometry.size,
                        minLat: minLat,
                        maxLat: maxLat,
                        minLon: minLon,
                        maxLon: maxLon,
                        pulseAnimation: pulseAnimation
                    )
                }
                
                // Neighborhood labels
                ForEach(heatZones) { zone in
                    NeighborhoodLabel(
                        zone: zone,
                        size: geometry.size,
                        minLat: minLat,
                        maxLat: maxLat,
                        minLon: minLon,
                        maxLon: maxLon,
                        isCompact: isCompact
                    )
                }
            }
        }
        .background(Color.brandBlack)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandPurple.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            pulseAnimation = true
        }
    }
}

// MARK: - Map Grid Background

struct MapGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = 30
            
            // Vertical lines
            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.mapGrid), lineWidth: 0.5)
            }
            
            // Horizontal lines
            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.mapGrid), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - Heat Zone Overlay

struct HeatZoneOverlay: View {
    let zone: HeatZone
    let size: CGSize
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    var isSelected: Bool = false
    
    @State private var glowAnimation: Bool = false
    
    private var position: CGPoint {
        let x = (zone.centerLongitude - minLon) / (maxLon - minLon) * size.width
        let y = (1 - (zone.centerLatitude - minLat) / (maxLat - minLat)) * size.height
        return CGPoint(x: x, y: y)
    }
    
    private var zoneSize: CGFloat {
        // Scale based on intensity
        switch zone.intensity {
        case .low: return 60
        case .medium: return 75
        case .high: return 90
        case .hot: return 110
        }
    }
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            zone.intensity.color.opacity(zone.intensity.glowOpacity),
                            zone.intensity.color.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: zoneSize / 2
                    )
                )
                .frame(width: zoneSize * 1.5, height: zoneSize * 1.5)
                .scaleEffect(glowAnimation ? 1.1 : 1.0)
            
            // Core circle
            Circle()
                .fill(zone.intensity.color.opacity(0.3))
                .frame(width: zoneSize, height: zoneSize)
            
            // Inner highlight
            Circle()
                .fill(zone.intensity.color.opacity(0.6))
                .frame(width: zoneSize * 0.5, height: zoneSize * 0.5)
            
            // Selection ring
            if isSelected {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: zoneSize + 10, height: zoneSize + 10)
            }
        }
        .position(position)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
        .onAppear {
            glowAnimation = true
        }
    }
}

// MARK: - Task Map Marker

struct TaskMapMarker: View {
    let task: HXTask
    let size: CGSize
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    
    private var position: CGPoint {
        guard let lat = task.latitude, let lon = task.longitude else {
            return .zero
        }
        let x = (lon - minLon) / (maxLon - minLon) * size.width
        let y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color.brandPurple.opacity(0.3))
                .frame(width: 24, height: 24)
            
            // Pin
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.brandPurple)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                )
        }
        .position(position)
    }
}

// MARK: - User Location Marker

struct UserLocationMarker: View {
    let location: GPSCoordinates
    let size: CGSize
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    let pulseAnimation: Bool
    
    private var position: CGPoint {
        let x = (location.longitude - minLon) / (maxLon - minLon) * size.width
        let y = (1 - (location.latitude - minLat) / (maxLat - minLat)) * size.height
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .stroke(Color.infoBlue.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)
                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                .opacity(pulseAnimation ? 0 : 1)
                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
            
            // Outer ring
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 20, height: 20)
            
            // Inner dot
            Circle()
                .fill(Color.infoBlue)
                .frame(width: 14, height: 14)
        }
        .position(position)
    }
}

// MARK: - Neighborhood Label

struct NeighborhoodLabel: View {
    let zone: HeatZone
    let size: CGSize
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    var isCompact: Bool = false
    
    private var position: CGPoint {
        let x = (zone.centerLongitude - minLon) / (maxLon - minLon) * size.width
        let y = (1 - (zone.centerLatitude - minLat) / (maxLat - minLat)) * size.height
        // Offset label below the zone
        return CGPoint(x: x, y: y + (isCompact ? 35 : 45))
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(zone.name)
                .font(.system(size: isCompact ? 9 : 10, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            
            HStack(spacing: 4) {
                Text("\(zone.taskCount)")
                    .font(.system(size: isCompact ? 8 : 9, weight: .bold))
                Image(systemName: "briefcase.fill")
                    .font(.system(size: isCompact ? 7 : 8))
            }
            .foregroundStyle(zone.intensity.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.surfaceElevated.opacity(0.9))
        .clipShape(Capsule())
        .position(position)
    }
}

// MARK: - Map Toggle Button

struct MapToggleButton: View {
    @Binding var showMapView: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showMapView.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.surfaceElevated)
                    .frame(width: 56, height: 56)
                
                Circle()
                    .stroke(Color.brandPurple.opacity(0.5), lineWidth: 1)
                    .frame(width: 56, height: 56)
                
                Image(systemName: showMapView ? "list.bullet" : "map.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
            }
            .shadow(color: Color.brandPurple.opacity(0.3), radius: 12, y: 4)
        }
    }
}

// MARK: - Heat Map Legend

struct HeatMapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACTIVITY")
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(Color.textMuted)
            
            HStack(spacing: 12) {
                ForEach(HeatIntensity.allCases, id: \.self) { intensity in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(intensity.color)
                            .frame(width: 10, height: 10)
                        
                        Text(intensity.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.surfaceElevated.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        HeatMapView(
            heatZones: MockHeatMapService.shared.heatZones,
            tasks: [],
            userLocation: GPSCoordinates(latitude: 37.7749, longitude: -122.4194)
        )
        .frame(height: 300)
        .padding()
        
        HeatMapLegend()
            .padding()
    }
    .background(Color.brandBlack)
}
