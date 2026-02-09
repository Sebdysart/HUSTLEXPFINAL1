//
//  LiveModeToggle.swift
//  hustleXP final1
//
//  LIVE Mode Toggle - Premium toggle for activating radar mode
//  Shows session stats, battery status, and live status
//

import SwiftUI

struct LiveModeToggle: View {
    @Binding var isActive: Bool
    let session: LiveModeSession?
    let questCount: Int
    let onToggle: (Bool) -> Void
    
    @State private var pulseRing = false
    @State private var radarSweep: Double = 0
    
    var body: some View {
        HStack(spacing: 14) {
            // Radar icon with animation
            ZStack {
                // Outer ring (animated when active)
                if isActive {
                    Circle()
                        .stroke(Color.brandPurple.opacity(0.3), lineWidth: 2)
                        .frame(width: 48, height: 48)
                        .scaleEffect(pulseRing ? 1.2 : 1.0)
                        .opacity(pulseRing ? 0 : 1)
                }
                
                // Background
                Circle()
                    .fill(isActive ? Color.brandPurple.opacity(0.15) : Color.surfaceElevated)
                    .frame(width: 44, height: 44)
                
                // Mini radar
                ZStack {
                    // Grid
                    Circle()
                        .stroke(Color.brandPurple.opacity(isActive ? 0.4 : 0.2), lineWidth: 1)
                        .frame(width: 28, height: 28)
                    Circle()
                        .stroke(Color.brandPurple.opacity(isActive ? 0.3 : 0.15), lineWidth: 1)
                        .frame(width: 18, height: 18)
                    
                    // Sweep
                    if isActive {
                        Rectangle()
                            .fill(Color.brandPurple.opacity(0.6))
                            .frame(width: 1, height: 14)
                            .offset(y: -7)
                            .rotationEffect(.degrees(radarSweep))
                    }
                    
                    // Center
                    Circle()
                        .fill(isActive ? Color.brandPurple : Color.textMuted)
                        .frame(width: 6, height: 6)
                    
                    // Quest blips
                    if questCount > 0 && isActive {
                        ForEach(0..<min(questCount, 3), id: \.self) { i in
                            Circle()
                                .fill(Color.errorRed)
                                .frame(width: 4, height: 4)
                                .offset(x: 8)
                                .rotationEffect(.degrees(Double(i) * 120 + 30))
                        }
                    }
                }
                
                // Quest count badge
                if questCount > 0 {
                    Text("\(questCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(Color.errorRed))
                        .offset(x: 16, y: -16)
                }
            }
            
            // Status info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(isActive ? "LIVE MODE" : "GO LIVE")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isActive ? Color.brandPurple : Color.textPrimary)
                    
                    if isActive {
                        // Live indicator
                        Circle()
                            .fill(Color.successGreen)
                            .frame(width: 6, height: 6)
                    }
                }
                
                if isActive, let session = session {
                    HStack(spacing: 8) {
                        // Session duration
                        Text(session.sessionDurationText)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textSecondary)
                        
                        Text("•")
                            .foregroundStyle(Color.textMuted)
                        
                        // Signal strength
                        HStack(spacing: 2) {
                            Image(systemName: session.signalStrength.icon)
                                .font(.system(size: 9))
                            Text(session.signalStrength.rawValue.capitalized)
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(session.signalStrength.color)
                    }
                } else {
                    Text("Tap to start hunting")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                }
            }
            
            Spacer()
            
            // Toggle switch
            Toggle("", isOn: Binding(
                get: { isActive },
                set: { newValue in
                    withAnimation(.spring(response: 0.3)) {
                        onToggle(newValue)
                    }
                }
            ))
            .toggleStyle(LiveModeToggleStyle())
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isActive ? Color.brandPurple.opacity(0.3) : Color.borderSubtle,
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: isActive ? Color.brandPurple.opacity(0.2) : .clear, radius: 10, y: 4)
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            pulseRing = true
        }
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            radarSweep = 360
        }
    }
}

// MARK: - Custom Toggle Style

struct LiveModeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            ZStack {
                // Track
                Capsule()
                    .fill(configuration.isOn ? Color.brandPurple : Color.surfaceSecondary)
                    .frame(width: 52, height: 30)
                    .overlay(
                        Capsule()
                            .stroke(configuration.isOn ? Color.brandPurple.opacity(0.3) : Color.borderSubtle, lineWidth: 1)
                    )
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .overlay(
                        Group {
                            if configuration.isOn {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color.brandPurple)
                            }
                        }
                    )
                    .offset(x: configuration.isOn ? 11 : -11)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    configuration.isOn.toggle()
                }
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }
    }
}

// MARK: - Live Mode Status Bar

struct LiveModeStatusBar: View {
    let session: LiveModeSession
    let onEndSession: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Live indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 8, height: 8)
                
                Text("LIVE")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.successGreen)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.successGreen.opacity(0.15))
            )
            
            // Stats
            HStack(spacing: 16) {
                // Duration
                Label {
                    Text(session.sessionDurationText)
                        .font(.system(size: 12, weight: .medium))
                } icon: {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.textSecondary)
                
                // Quests accepted
                Label {
                    Text("\(session.questsAccepted)")
                        .font(.system(size: 12, weight: .medium))
                } icon: {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.brandPurple)
                
                // Earnings
                if session.earningsThisSession > 0 {
                    Text("$\(Int(session.earningsThisSession))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                }
            }
            
            Spacer()
            
            // End session
            Button(action: onEndSession) {
                Text("End")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.errorRed)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.errorRed.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.surfaceElevated)
    }
}

// MARK: - Preview

#Preview("Live Mode Toggle") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Inactive state
            LiveModeToggle(
                isActive: .constant(false),
                session: nil,
                questCount: 0,
                onToggle: { _ in }
            )
            .padding(.horizontal, 16)
            
            // Active state
            LiveModeToggle(
                isActive: .constant(true),
                session: LiveModeSession(
                    id: "1",
                    workerId: "w1",
                    startedAt: Date().addingTimeInterval(-1800),
                    lastPingAt: Date(),
                    location: GPSCoordinates(latitude: 37.77, longitude: -122.42),
                    heading: 90,
                    speed: 1.2,
                    isMoving: true,
                    batteryLevel: 0.75,
                    signalStrength: .excellent,
                    availableFor: [.lockout, .jumpstart],
                    maxDistance: 3218,
                    questsReceived: 5,
                    questsAccepted: 2,
                    questsCompleted: 1,
                    earningsThisSession: 85
                ),
                questCount: 2,
                onToggle: { _ in }
            )
            .padding(.horizontal, 16)
            
            // Status bar
            LiveModeStatusBar(
                session: LiveModeSession(
                    id: "1",
                    workerId: "w1",
                    startedAt: Date().addingTimeInterval(-1800),
                    lastPingAt: Date(),
                    location: GPSCoordinates(latitude: 37.77, longitude: -122.42),
                    heading: 90,
                    speed: 1.2,
                    isMoving: true,
                    batteryLevel: 0.75,
                    signalStrength: .excellent,
                    availableFor: [.lockout, .jumpstart],
                    maxDistance: 3218,
                    questsReceived: 5,
                    questsAccepted: 2,
                    questsCompleted: 1,
                    earningsThisSession: 85
                ),
                onEndSession: {}
            )
        }
    }
}
