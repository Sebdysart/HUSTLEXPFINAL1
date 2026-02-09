//
//  GeofenceIndicator.swift
//  hustleXP final1
//
//  Geofence proximity indicator for Smart Start - v1.9.0
//

import SwiftUI

struct GeofenceIndicator: View {
    let geofence: GeofenceRegion
    let currentDistance: Double?  // meters from center
    let isInside: Bool
    var onSmartStartTriggered: (() -> Void)? = nil
    var isCompact: Bool = false
    
    @State private var pulseAnimation: Bool = false
    @State private var ringAnimation: Bool = false
    
    private var proximityPercentage: Double {
        guard let distance = currentDistance else { return 0 }
        return max(0, min(1, 1 - (distance / geofence.radiusMeters)))
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 10 : 16) {
            // Circular proximity indicator
            ZStack {
                // Outer ring (geofence boundary)
                Circle()
                    .stroke(Color.brandPurple.opacity(0.2), lineWidth: 2)
                    .frame(width: isCompact ? 80 : 110, height: isCompact ? 80 : 110)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: proximityPercentage)
                    .stroke(
                        isInside ? Color.successGreen : Color.brandPurple,
                        style: StrokeStyle(lineWidth: isCompact ? 3 : 4, lineCap: .round)
                    )
                    .frame(width: isCompact ? 80 : 110, height: isCompact ? 80 : 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: proximityPercentage)
                
                // Pulsing ring when inside
                if isInside {
                    Circle()
                        .stroke(Color.successGreen.opacity(0.5), lineWidth: 2)
                        .frame(width: isCompact ? 80 : 110, height: isCompact ? 80 : 110)
                        .scaleEffect(ringAnimation ? 1.3 : 1.0)
                        .opacity(ringAnimation ? 0 : 0.8)
                }
                
                // Center icon area
                ZStack {
                    Circle()
                        .fill(
                            isInside
                                ? Color.successGreen.opacity(0.2)
                                : Color.brandPurple.opacity(0.15)
                        )
                        .frame(width: isCompact ? 56 : 76, height: isCompact ? 56 : 76)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    
                    // Icon
                    Image(systemName: isInside ? "checkmark.circle.fill" : "location.fill")
                        .font(.system(size: isCompact ? 22 : 28, weight: .semibold))
                        .foregroundStyle(isInside ? Color.successGreen : Color.brandPurple)
                }
            }
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: ringAnimation)
            
            // Status text
            VStack(spacing: isCompact ? 3 : 6) {
                Text(isInside ? "You're at the location!" : "Approaching task location")
                    .font(.system(size: isCompact ? 13 : 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                
                if let distance = currentDistance, !isInside {
                    Text("\(Int(distance))m away")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            
            // Smart Start badge
            if isInside {
                SmartStartBadge(isCompact: isCompact)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(isCompact ? 16 : 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isInside
                                ? Color.successGreen.opacity(0.3)
                                : Color.brandPurple.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: isInside
                ? Color.successGreen.opacity(0.2)
                : Color.brandPurple.opacity(0.15),
            radius: 16,
            y: 8
        )
        .onAppear {
            pulseAnimation = true
            ringAnimation = true
        }
        .onChange(of: isInside) { _, newValue in
            if newValue {
                // Trigger haptic feedback and callback
                onSmartStartTriggered?()
            }
        }
    }
}

// MARK: - Smart Start Badge

struct SmartStartBadge: View {
    var isCompact: Bool = false
    
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
            Text("Smart Start enabled")
                .font(.system(size: isCompact ? 11 : 13, weight: .semibold))
        }
        .foregroundStyle(Color.successGreen)
        .padding(.horizontal, isCompact ? 10 : 14)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            ZStack {
                Color.successGreen.opacity(0.15)
                
                // Shimmer
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.successGreen.opacity(0.2),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: shimmerOffset)
            }
        )
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 150
            }
        }
    }
}

// MARK: - Compact Geofence Status

struct CompactGeofenceStatus: View {
    let isInside: Bool
    let distanceMeters: Double?
    
    var body: some View {
        HStack(spacing: 8) {
            // Status dot
            Circle()
                .fill(isInside ? Color.successGreen : Color.brandPurple)
                .frame(width: 10, height: 10)
            
            // Text
            if isInside {
                Text("At location")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.successGreen)
            } else if let distance = distanceMeters {
                Text("\(Int(distance))m away")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Smart Start indicator
            if isInside {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(Color.successGreen)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isInside
                                ? Color.successGreen.opacity(0.3)
                                : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Geofence Progress Bar

struct GeofenceProgressBar: View {
    let progress: Double  // 0.0 to 1.0
    let isInside: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Approaching location")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isInside ? Color.successGreen : Color.brandPurple)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: isInside
                                    ? [Color.successGreen, Color.successGreen.opacity(0.7)]
                                    : [Color.brandPurple, Color.aiPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        GeofenceIndicator(
            geofence: GeofenceRegion(
                id: "geo_1",
                taskId: "task_1",
                centerLatitude: 37.7749,
                centerLongitude: -122.4194,
                radiusMeters: 50,
                isActive: true,
                createdAt: Date()
            ),
            currentDistance: 30,
            isInside: false
        )
        
        GeofenceIndicator(
            geofence: GeofenceRegion(
                id: "geo_2",
                taskId: "task_2",
                centerLatitude: 37.7749,
                centerLongitude: -122.4194,
                radiusMeters: 50,
                isActive: true,
                createdAt: Date()
            ),
            currentDistance: 10,
            isInside: true,
            isCompact: true
        )
        
        CompactGeofenceStatus(isInside: true, distanceMeters: nil)
        CompactGeofenceStatus(isInside: false, distanceMeters: 85)
        
        GeofenceProgressBar(progress: 0.7, isInside: false)
            .padding(.horizontal, 40)
    }
    .padding()
    .background(Color.brandBlack)
}
