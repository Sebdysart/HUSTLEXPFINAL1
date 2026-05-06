//
//  TaskMapView.swift
//  hustleXP final1
//
//  Live MapKit map for task details - shows real tiles, task pin, user location
//

import MapKit
import SwiftUI

struct TaskMapView: View {
    let task: HXTask
    let userLocation: GPSCoordinates?
    let walkingETA: WalkingETA?
    var showRoute: Bool = true
    var onOpenMaps: (() -> Void)? = nil
    var isCompact: Bool = false

    @State private var position: MapCameraPosition = .automatic

    private var canNavigate: Bool {
        task.hasCoordinates ||
        (!task.location.trimmingCharacters(in: .whitespaces).isEmpty &&
         task.location.lowercased() != "anywhere")
    }

    private var taskCoordinate: CLLocationCoordinate2D? {
        guard let lat = task.latitude, let lon = task.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Live map
            Map(position: $position) {
                if let coord = taskCoordinate {
                    Annotation("", coordinate: coord) {
                        TaskDestinationPin()
                    }
                }
                UserAnnotation()
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .frame(height: isCompact ? 120 : 160)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16
                )
            )
            .onAppear { updateCamera() }
            .onChange(of: userLocation) { _, _ in updateCamera() }

            // Info bar
            HStack {
                if let eta = walkingETA {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                        Text(eta.formattedDuration)
                            .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.brandPurple)

                    Text("•")
                        .foregroundStyle(Color.textMuted)

                    Text(eta.formattedDistance)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if canNavigate {
                    Button(action: { onOpenMaps?() }) {
                        HStack(spacing: 4) {
                            Text("Navigate")
                                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                .font(.system(size: isCompact ? 14 : 16))
                        }
                        .foregroundStyle(Color.brandPurple)
                    }
                }
            }
            .padding(.horizontal, isCompact ? 12 : 16)
            .padding(.vertical, isCompact ? 10 : 14)
            .background(Color.surfaceElevated)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Camera

    private func updateCamera() {
        if let coord = taskCoordinate, let userLoc = userLocation {
            // Frame both the task pin and the user's dot
            let centerLat = (coord.latitude + userLoc.latitude) / 2
            let centerLon = (coord.longitude + userLoc.longitude) / 2
            let spanLat = max(abs(coord.latitude - userLoc.latitude) * 2.5, 0.005)
            let spanLon = max(abs(coord.longitude - userLoc.longitude) * 2.5, 0.005)
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            ))
        } else if let coord = taskCoordinate {
            position = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))
        } else if let userLoc = userLocation {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: userLoc.latitude, longitude: userLoc.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
}

// MARK: - Task Destination Pin (used as MapKit Annotation content)

struct TaskDestinationPin: View {
    @State private var glowAnimation: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.errorRed.opacity(0.3))
                .frame(width: 44, height: 44)
                .scaleEffect(glowAnimation ? 1.15 : 1.0)
                .opacity(glowAnimation ? 0.5 : 0.8)

            Circle()
                .fill(Color.errorRed)
                .frame(width: 32, height: 32)

            Image(systemName: "mappin")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: Color.errorRed.opacity(0.5), radius: 8, y: 4)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowAnimation)
        .onAppear { glowAnimation = true }
    }
}

// MARK: - Distance Badge (used in annotation overlays)

struct DistanceBadge: View {
    let eta: WalkingETA

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "figure.walk")
                .font(.system(size: 10, weight: .bold))
            Text(eta.shortDuration)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.brandPurple)
        .clipShape(Capsule())
    }
}

// MARK: - Compact Task Map (for list items)

struct CompactTaskMap: View {
    let task: HXTask
    let walkingETA: WalkingETA?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 44, height: 44)
                Image(systemName: "map.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandPurple.opacity(0.7))
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.errorRed)
                    .offset(x: 8, y: -8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.location)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                if let eta = walkingETA {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk").font(.caption2)
                        Text(eta.formattedDuration).font(.caption)
                        Text("•")
                        Text(eta.formattedDistance).font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandPurple)
                .rotationEffect(.degrees(15))
        }
        .padding(12)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TaskMapView(
            task: HXTask(
                id: "1", title: "Deliver Package", description: "desc", payment: 30,
                location: "Mission District", latitude: 37.7599, longitude: -122.4148,
                estimatedDuration: "30 min", posterId: "p1", posterName: "John",
                posterRating: 4.5, state: .posted, requiredTier: .rookie, createdAt: Date()
            ),
            userLocation: GPSCoordinates(latitude: 37.7749, longitude: -122.4194),
            walkingETA: WalkingETA(
                distanceMeters: 800, durationSeconds: 600, route: nil, calculatedAt: Date()
            )
        )

        CompactTaskMap(
            task: HXTask(
                id: "2", title: "Grocery Run", description: "desc", payment: 20,
                location: "Castro", latitude: 37.7609, longitude: -122.4350,
                estimatedDuration: "45 min", posterId: "p2", posterName: "Jane",
                posterRating: 4.8, state: .posted, requiredTier: .rookie, createdAt: Date()
            ),
            walkingETA: WalkingETA(
                distanceMeters: 1200, durationSeconds: 900, route: nil, calculatedAt: Date()
            )
        )
    }
    .padding()
    .background(Color.brandBlack)
}
