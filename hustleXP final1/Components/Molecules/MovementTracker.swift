//
//  MovementTracker.swift
//  hustleXP final1
//
//  Movement tracking display for GPS fraud detection - v1.9.0
//

import SwiftUI

struct MovementTracker: View {
    let session: MovementTrackingSession
    let isActive: Bool
    var isCompact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 14) {
            // Header
            HStack {
                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(isActive ? Color.successGreen : Color.textMuted)
                        .frame(width: 8, height: 8)
                    
                    Text(isActive ? "Tracking Active" : "Tracking Paused")
                        .font(.system(size: isCompact ? 11 : 13, weight: .semibold))
                        .foregroundStyle(isActive ? Color.successGreen : Color.textMuted)
                }
                
                Spacer()
                
                // Duration
                Text(session.durationFormatted)
                    .font(.system(size: isCompact ? 11 : 13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                
                // Flag indicator if any
                if !session.flags.isEmpty {
                    FlagIndicator(flags: session.flags, isCompact: isCompact)
                }
            }
            
            // Stats row
            HStack(spacing: isCompact ? 12 : 20) {
                MovementStat(
                    icon: "figure.walk",
                    value: formatDistance(session.totalDistanceMeters),
                    label: "Distance",
                    isCompact: isCompact
                )
                
                MovementStat(
                    icon: "speedometer",
                    value: formatSpeed(session.averageSpeed),
                    label: "Avg Speed",
                    isCompact: isCompact
                )
                
                MovementStat(
                    icon: "location.fill",
                    value: "\(session.locations.count)",
                    label: "Points",
                    isCompact: isCompact
                )
            }
            
            // Mini path visualization
            if !isCompact {
                MovementPathMini(locations: session.locations)
                    .frame(height: 50)
            }
        }
        .padding(isCompact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            session.status == .suspicious
                                ? Color.errorRed.opacity(0.3)
                                : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1f km", meters / 1000)
    }
    
    private func formatSpeed(_ mps: Double) -> String {
        // Convert m/s to km/h
        let kmh = mps * 3.6
        return String(format: "%.1f km/h", kmh)
    }
}

// MARK: - Movement Stat

struct MovementStat: View {
    let icon: String
    let value: String
    let label: String
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: isCompact ? 2 : 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 10 : 12, weight: .medium))
                    .foregroundStyle(Color.brandPurple)
                
                Text(value)
                    .font(.system(size: isCompact ? 12 : 14, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Text(label)
                .font(.system(size: isCompact ? 9 : 10))
                .foregroundStyle(Color.textMuted)
        }
    }
}

// MARK: - Movement Path Mini

struct MovementPathMini: View {
    let locations: [TrackedLocation]
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard locations.count > 1 else { return }
                
                // Find bounds
                let lats = locations.map { $0.latitude }
                let lons = locations.map { $0.longitude }
                
                guard let minLat = lats.min(),
                      let maxLat = lats.max(),
                      let minLon = lons.min(),
                      let maxLon = lons.max() else { return }
                
                let latRange = max(maxLat - minLat, 0.001)
                let lonRange = max(maxLon - minLon, 0.001)
                
                // Convert to screen points
                var path = Path()
                
                for (index, location) in locations.enumerated() {
                    let x = ((location.longitude - minLon) / lonRange) * (size.width - 20) + 10
                    let y = (1 - (location.latitude - minLat) / latRange) * (size.height - 10) + 5
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw path with gradient
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [Color.brandPurple.opacity(0.3), Color.brandPurple]),
                        startPoint: CGPoint(x: 0, y: size.height / 2),
                        endPoint: CGPoint(x: size.width, y: size.height / 2)
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                
                // Draw current position dot
                if let last = locations.last {
                    let x = ((last.longitude - minLon) / lonRange) * (size.width - 20) + 10
                    let y = (1 - (last.latitude - minLat) / latRange) * (size.height - 10) + 5
                    
                    let dotPath = Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                    context.fill(dotPath, with: .color(Color.brandPurple))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.surfaceSecondary)
        )
    }
}

// MARK: - Flag Indicator

struct FlagIndicator: View {
    let flags: [MovementFlag]
    var isCompact: Bool = false
    
    private var flagColor: Color {
        if flags.contains(.impossibleSpeed) || flags.contains(.locationJump) {
            return .errorRed
        } else if flags.contains(.stationaryTooLong) {
            return .warningOrange
        }
        return .textMuted
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
            
            Text("\(flags.count)")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
        }
        .foregroundStyle(flagColor)
        .padding(.horizontal, isCompact ? 6 : 8)
        .padding(.vertical, isCompact ? 3 : 4)
        .background(flagColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Detailed Movement Summary

struct DetailedMovementSummary: View {
    let summary: MovementSummary
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: isCompact ? 12 : 16) {
            // Header
            HStack {
                Text("Movement Summary")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                // Risk level badge
                RiskLevelBadge(level: summary.riskLevel)
            }
            
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: isCompact ? 10 : 14) {
                SummaryStatCard(
                    icon: "figure.walk",
                    title: "Total Distance",
                    value: summary.formattedDistance,
                    color: .brandPurple
                )
                
                SummaryStatCard(
                    icon: "clock",
                    title: "Total Time",
                    value: summary.formattedTime,
                    color: .infoBlue
                )
                
                SummaryStatCard(
                    icon: "speedometer",
                    title: "Avg Speed",
                    value: summary.formattedSpeed,
                    color: .warningOrange
                )
                
                SummaryStatCard(
                    icon: "pause.circle",
                    title: "Stops",
                    value: "\(summary.stationaryPeriods)",
                    color: summary.stationaryPeriods > 2 ? .errorRed : .textMuted
                )
            }
            
            // Flags list if any
            if !summary.flags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ALERTS")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(Color.textMuted)
                    
                    ForEach(summary.flags, id: \.self) { flag in
                        FlagRow(flag: flag)
                    }
                }
            }
        }
        .padding(isCompact ? 14 : 18)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SummaryStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RiskLevelBadge: View {
    let level: RiskLevel
    
    private var color: Color {
        switch level {
        case .low: return .successGreen
        case .medium: return .warningOrange
        case .high: return .errorRed
        case .critical: return .riskCritical
        }
    }
    
    var body: some View {
        Text(level.displayName)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct FlagRow: View {
    let flag: MovementFlag
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: flag.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.errorRed)
                .frame(width: 24)
            
            Text(flag.displayName)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
        }
        .padding(10)
        .background(Color.errorRed.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        MovementTracker(
            session: MovementTrackingSession(
                id: "track_1",
                taskId: "task_1",
                hustlerId: "hustler_1",
                startedAt: Date().addingTimeInterval(-1800),
                locations: [
                    TrackedLocation(latitude: 37.7749, longitude: -122.4194, timestamp: Date().addingTimeInterval(-1800), accuracyMeters: 10, speedMps: 1.3),
                    TrackedLocation(latitude: 37.7755, longitude: -122.4180, timestamp: Date().addingTimeInterval(-1500), accuracyMeters: 12, speedMps: 1.4),
                    TrackedLocation(latitude: 37.7760, longitude: -122.4165, timestamp: Date().addingTimeInterval(-1200), accuracyMeters: 8, speedMps: 1.5),
                    TrackedLocation(latitude: 37.7768, longitude: -122.4150, timestamp: Date(), accuracyMeters: 10, speedMps: 1.2)
                ],
                status: .active,
                flags: []
            ),
            isActive: true
        )
        
        MovementTracker(
            session: MovementTrackingSession(
                id: "track_2",
                taskId: "task_2",
                hustlerId: "hustler_2",
                startedAt: Date().addingTimeInterval(-3600),
                locations: [],
                status: .suspicious,
                flags: [.stationaryTooLong]
            ),
            isActive: true,
            isCompact: true
        )
    }
    .padding()
    .background(Color.brandBlack)
}
