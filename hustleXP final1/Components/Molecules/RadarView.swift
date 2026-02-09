//
//  RadarView.swift
//  hustleXP final1
//
//  LIVE Mode Radar - Visual radar display showing nearby quests and workers
//  Replaces boring list view with an immersive radar experience
//

import SwiftUI

struct RadarView: View {
    let quests: [QuestAlert]
    let userLocation: GPSCoordinates?
    let maxRadius: Double // in meters
    let onQuestTap: (QuestAlert) -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var sweepAngle: Double = 0
    @State private var showSweep = true
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radarRadius = size / 2 - 20
            
            ZStack {
                // Background
                Circle()
                    .fill(Color.brandBlack)
                    .frame(width: size, height: size)
                
                // Grid circles (distance rings)
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { ratio in
                    Circle()
                        .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
                        .frame(width: radarRadius * 2 * ratio, height: radarRadius * 2 * ratio)
                }
                
                // Grid lines (crosshairs)
                ForEach(0..<8, id: \.self) { i in
                    Rectangle()
                        .fill(Color.brandPurple.opacity(0.1))
                        .frame(width: 1, height: radarRadius * 2)
                        .rotationEffect(.degrees(Double(i) * 22.5))
                }
                
                // Sweep line
                if showSweep {
                    RadarSweep(angle: sweepAngle, radius: radarRadius)
                        .onAppear {
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                sweepAngle = 360
                            }
                        }
                }
                
                // Distance labels
                distanceLabels(radius: radarRadius)
                
                // Quest blips
                ForEach(quests) { quest in
                    if let distance = quest.distanceMeters {
                        QuestBlip(
                            quest: quest,
                            position: blipPosition(
                                distance: distance,
                                maxRadius: maxRadius,
                                radarRadius: radarRadius,
                                center: center
                            ),
                            onTap: { onQuestTap(quest) }
                        )
                    }
                }
                
                // Center point (user location)
                ZStack {
                    // Pulse rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.brandPurple.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                            .frame(width: 20 + CGFloat(i) * 15, height: 20 + CGFloat(i) * 15)
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                                value: pulseScale
                            )
                    }
                    
                    // Center dot
                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                .onAppear {
                    pulseScale = 2.0
                }
            }
            .position(center)
        }
    }
    
    private func distanceLabels(radius: CGFloat) -> some View {
        ZStack {
            // 0.5 mi label
            Text("0.5 mi")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.textMuted)
                .offset(x: radius * 0.5 + 20, y: 0)
            
            // 1 mi label
            Text("1 mi")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.textMuted)
                .offset(x: radius * 0.75 + 15, y: 0)
            
            // 2 mi label (edge)
            Text("2 mi")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.textMuted)
                .offset(x: radius + 15, y: 0)
        }
    }
    
    private func blipPosition(
        distance: Double,
        maxRadius: Double,
        radarRadius: CGFloat,
        center: CGPoint
    ) -> CGPoint {
        // Random angle for visual distribution
        let angle = Double.random(in: 0..<360) * .pi / 180
        
        // Normalize distance to radar radius
        let normalizedDistance = min(distance / maxRadius, 1.0)
        let blipRadius = CGFloat(normalizedDistance) * radarRadius
        
        return CGPoint(
            x: center.x + blipRadius * CGFloat(cos(angle)),
            y: center.y + blipRadius * CGFloat(sin(angle))
        )
    }
}

// MARK: - Radar Sweep

struct RadarSweep: View {
    let angle: Double
    let radius: CGFloat
    
    var body: some View {
        ZStack {
            // Sweep gradient
            AngularGradient(
                gradient: Gradient(colors: [
                    Color.brandPurple.opacity(0),
                    Color.brandPurple.opacity(0.3),
                    Color.brandPurple.opacity(0)
                ]),
                center: .center,
                startAngle: .degrees(angle - 45),
                endAngle: .degrees(angle)
            )
            .mask(
                Circle()
                    .frame(width: radius * 2, height: radius * 2)
            )
            
            // Sweep line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.brandPurple.opacity(0), Color.brandPurple],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 2, height: radius)
                .offset(y: -radius / 2)
                .rotationEffect(.degrees(angle))
        }
    }
}

// MARK: - Quest Blip

struct QuestBlip: View {
    let quest: QuestAlert
    let position: CGPoint
    let onTap: () -> Void
    
    @State private var glowPulse = false
    @State private var showDetails = false
    
    private var urgencyColor: Color {
        if quest.timeRemaining < 15 {
            return .errorRed
        } else if quest.timeRemaining < 30 {
            return .warningOrange
        } else {
            return .moneyGreen
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow ring
                Circle()
                    .fill(urgencyColor.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .scaleEffect(glowPulse ? 1.3 : 1.0)
                    .opacity(glowPulse ? 0 : 1)
                
                // Main blip
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [urgencyColor, urgencyColor.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                
                // Icon
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                // Price badge
                Text("$\(Int(quest.totalPayment))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.brandBlack.opacity(0.8))
                    )
                    .offset(y: 28)
                
                // Timer badge
                Text("\(quest.timeRemaining)s")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(urgencyColor)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(
                        Capsule()
                            .fill(Color.brandBlack.opacity(0.8))
                    )
                    .offset(y: -28)
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Compact Radar (for feed header)

struct CompactRadarView: View {
    let questCount: Int
    let isActive: Bool
    
    @State private var sweepAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Mini radar background
            Circle()
                .fill(Color.surfaceElevated)
                .frame(width: 56, height: 56)
            
            // Grid
            ForEach([0.5, 1.0], id: \.self) { ratio in
                Circle()
                    .stroke(Color.brandPurple.opacity(0.3), lineWidth: 1)
                    .frame(width: 40 * ratio, height: 40 * ratio)
            }
            
            // Sweep
            if isActive {
                Rectangle()
                    .fill(Color.brandPurple.opacity(0.5))
                    .frame(width: 1, height: 20)
                    .offset(y: -10)
                    .rotationEffect(.degrees(sweepAngle))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            sweepAngle = 360
                        }
                    }
            }
            
            // Center dot
            Circle()
                .fill(isActive ? Color.brandPurple : Color.textMuted)
                .frame(width: 8, height: 8)
            
            // Blip indicators
            if questCount > 0 {
                ForEach(0..<min(questCount, 3), id: \.self) { i in
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 6, height: 6)
                        .offset(x: 12, y: 0)
                        .rotationEffect(.degrees(Double(i) * 120 + 45))
                }
            }
            
            // Quest count badge
            if questCount > 0 {
                Text("\(questCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(Color.errorRed))
                    .offset(x: 20, y: -20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    isActive ? Color.brandPurple : Color.borderSubtle,
                    lineWidth: isActive ? 2 : 1
                )
        )
    }
}

// MARK: - Preview

#Preview("Radar View") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack {
            RadarView(
                quests: [],
                userLocation: GPSCoordinates(latitude: 37.7749, longitude: -122.4194),
                maxRadius: 3218,
                onQuestTap: { _ in }
            )
            .frame(height: 350)
            .padding()
            
            CompactRadarView(questCount: 2, isActive: true)
        }
    }
}
