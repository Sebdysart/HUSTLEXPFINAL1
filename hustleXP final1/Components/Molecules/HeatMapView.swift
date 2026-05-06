//
//  HeatMapView.swift
//  hustleXP final1
//
//  Real MapKit heat map visualization for v1.9.0
//

import MapKit
import SwiftUI

struct HeatMapView: View {
    let heatZones: [HeatZone]
    let tasks: [HXTask]
    let userLocation: GPSCoordinates?
    var mapBounds: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)? = nil
    var onZoneTapped: ((HeatZone) -> Void)? = nil
    var onTaskTapped: ((HXTask) -> Void)? = nil
    var isCompact: Bool = false

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            // Heat zone circles + tappable annotation badges
            ForEach(heatZones) { zone in
                let coord = CLLocationCoordinate2D(
                    latitude: zone.centerLatitude,
                    longitude: zone.centerLongitude
                )

                MapCircle(center: coord, radius: CLLocationDistance(max(zone.radiusMeters, 200)))
                    .foregroundStyle(zone.intensity.color.opacity(0.2))
                    .stroke(zone.intensity.color.opacity(0.5), lineWidth: 2)

                Annotation("", coordinate: coord) {
                    Button(action: { onZoneTapped?(zone) }) {
                        ZStack {
                            Circle()
                                .fill(zone.intensity.color.opacity(0.18))
                                .frame(width: isCompact ? 40 : 52, height: isCompact ? 40 : 52)
                            VStack(spacing: 1) {
                                Text("\(zone.taskCount)")
                                    .font(.system(size: isCompact ? 11 : 13, weight: .bold))
                                    .foregroundStyle(zone.intensity.color)
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: isCompact ? 8 : 9))
                                    .foregroundStyle(zone.intensity.color)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Task pin markers
            ForEach(tasks.filter { $0.hasCoordinates }) { task in
                if let lat = task.latitude, let lon = task.longitude {
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        Button(action: { onTaskTapped?(task) }) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 14, height: 14)
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.brandPurple)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Standard iOS blue user-location dot
            UserAnnotation()
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onAppear { applyInitialCamera() }
        .onChange(of: userLocation) { _, _ in applyInitialCamera() }
        .onChange(of: heatZones) { _, _ in applyZoneCamera() }
    }

    // MARK: - Camera helpers

    private func applyInitialCamera() {
        guard heatZones.isEmpty, let loc = userLocation else { return }
        position = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    private func applyZoneCamera() {
        guard !heatZones.isEmpty else { return }
        if let b = mapBounds {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (b.minLat + b.maxLat) / 2,
                    longitude: (b.minLon + b.maxLon) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: (b.maxLat - b.minLat) * 1.3,
                    longitudeDelta: (b.maxLon - b.minLon) * 1.3
                )
            ))
        } else {
            let lats = heatZones.map(\.centerLatitude)
            let lons = heatZones.map(\.centerLongitude)
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (lats.min()! + lats.max()!) / 2,
                    longitude: (lons.min()! + lons.max()!) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: max((lats.max()! - lats.min()!) * 1.5, 0.05),
                    longitudeDelta: max((lons.max()! - lons.min()!) * 1.5, 0.05)
                )
            ))
        }
    }
}

// MARK: - Map Grid Background (used by TaskMapView and BatchDetailsScreen)

struct MapGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = 30

            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.mapGrid), lineWidth: 0.5)
            }

            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.mapGrid), lineWidth: 0.5)
            }
        }
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
