//
//  TaskMapView.swift
//  hustleXP final1
//
//  Static map view for task details with walking route - v1.9.0
//

import SwiftUI

struct TaskMapView: View {
    let task: HXTask
    let userLocation: GPSCoordinates?
    let walkingETA: WalkingETA?
    var showRoute: Bool = true
    var onOpenMaps: (() -> Void)? = nil
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Mock map area
            ZStack {
                // Dark map background with grid
                MapGridBackground()
                    .background(Color.surfaceSecondary)
                
                // Route line (if showing)
                if showRoute, let _ = walkingETA, let userLoc = userLocation {
                    WalkingRouteLine(
                        from: userLoc,
                        to: task.gpsCoordinates,
                        containerSize: CGSize(width: 300, height: isCompact ? 120 : 160)
                    )
                }
                
                // Task pin with neon glow
                TaskDestinationPin()
                    .offset(y: isCompact ? -10 : -15)
                
                // User location dot (if available)
                if userLocation != nil {
                    UserLocationDot()
                        .offset(x: -60, y: isCompact ? 30 : 40)
                }
                
                // Distance indicator
                if let eta = walkingETA {
                    DistanceBadge(eta: eta)
                        .position(x: 50, y: isCompact ? 20 : 25)
                }
            }
            .frame(height: isCompact ? 120 : 160)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16
                )
            )
            
            // Info bar
            HStack {
                // Walking ETA
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
                
                // Open Maps button
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
}

// MARK: - Walking Route Line

struct WalkingRouteLine: View {
    let from: GPSCoordinates
    let to: GPSCoordinates?
    let containerSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            guard to != nil else { return }
            
            // Draw dashed route line from bottom-left to center
            let startPoint = CGPoint(x: size.width * 0.15, y: size.height * 0.75)
            let endPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.35)
            
            var path = Path()
            path.move(to: startPoint)
            
            // Create curved path
            let controlPoint1 = CGPoint(x: size.width * 0.25, y: size.height * 0.55)
            let controlPoint2 = CGPoint(x: size.width * 0.4, y: size.height * 0.45)
            
            path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
            
            context.stroke(
                path,
                with: .color(Color.walkingRoute),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 4])
            )
        }
    }
}

// MARK: - Task Destination Pin

struct TaskDestinationPin: View {
    @State private var glowAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color.errorRed.opacity(0.3))
                .frame(width: 50, height: 50)
                .scaleEffect(glowAnimation ? 1.2 : 1.0)
                .opacity(glowAnimation ? 0.5 : 0.8)
            
            // Pin body
            ZStack {
                Circle()
                    .fill(Color.errorRed)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "mappin")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .shadow(color: Color.errorRed.opacity(0.5), radius: 8, y: 4)
        }
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowAnimation)
        .onAppear {
            glowAnimation = true
        }
    }
}

// MARK: - User Location Dot

struct UserLocationDot: View {
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .stroke(Color.infoBlue.opacity(0.4), lineWidth: 2)
                .frame(width: 30, height: 30)
                .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                .opacity(pulseAnimation ? 0 : 1)
            
            // Outer ring
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 18, height: 18)
            
            // Inner dot
            Circle()
                .fill(Color.infoBlue)
                .frame(width: 12, height: 12)
        }
        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
        .onAppear {
            pulseAnimation = true
        }
    }
}

// MARK: - Distance Badge

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
            // Mini map icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "map.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandPurple.opacity(0.7))
                
                // Pin overlay
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.errorRed)
                    .offset(x: 8, y: -8)
            }
            
            // Location info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.location)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                
                if let eta = walkingETA {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption2)
                        Text(eta.formattedDuration)
                            .font(.caption)
                        Text("•")
                        Text(eta.formattedDistance)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }
            
            Spacer()
            
            // Direction arrow
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
                id: "1",
                title: "Test Task",
                description: "Description",
                payment: 30,
                location: "Downtown SF",
                latitude: 37.7749,
                longitude: -122.4194,
                estimatedDuration: "30 min",
                posterId: "p1",
                posterName: "John",
                posterRating: 4.5,
                state: .posted,
                requiredTier: .rookie,
                createdAt: Date()
            ),
            userLocation: GPSCoordinates(latitude: 37.77, longitude: -122.42),
            walkingETA: WalkingETA(
                distanceMeters: 800,
                durationSeconds: 600,
                route: nil,
                calculatedAt: Date()
            )
        )
        
        CompactTaskMap(
            task: HXTask(
                id: "1",
                title: "Test Task",
                description: "Description",
                payment: 30,
                location: "Mission District",
                latitude: 37.7599,
                longitude: -122.4148,
                estimatedDuration: "30 min",
                posterId: "p1",
                posterName: "John",
                posterRating: 4.5,
                state: .posted,
                requiredTier: .rookie,
                createdAt: Date()
            ),
            walkingETA: WalkingETA(
                distanceMeters: 1200,
                durationSeconds: 900,
                route: nil,
                calculatedAt: Date()
            )
        )
    }
    .padding()
    .background(Color.brandBlack)
}
