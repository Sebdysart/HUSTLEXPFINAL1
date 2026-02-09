//
//  QuestAlertCard.swift
//  hustleXP final1
//
//  LIVE Mode Quest Alert Card - High-urgency task card with countdown timer
//  Red glow/pulse effect for maximum visibility
//

import SwiftUI

struct QuestAlertCard: View {
    let quest: QuestAlert
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var timeRemaining: Int
    @State private var pulseGlow = false
    @State private var showPriceBoost = false
    @State private var previousPayment: Double
    
    init(quest: QuestAlert, onAccept: @escaping () -> Void, onDecline: @escaping () -> Void) {
        self.quest = quest
        self.onAccept = onAccept
        self.onDecline = onDecline
        self._timeRemaining = State(initialValue: quest.timeRemaining)
        self._previousPayment = State(initialValue: quest.currentPayment)
    }
    
    private var urgencyColor: Color {
        if timeRemaining < 15 {
            return .errorRed
        } else if timeRemaining < 30 {
            return .warningOrange
        } else {
            return .moneyGreen
        }
    }
    
    private var timerText: String {
        if timeRemaining < 60 {
            return "\(timeRemaining)s"
        } else {
            return "\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Urgent header bar
            HStack {
                // LIVE indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseGlow ? 1.3 : 1.0)
                    
                    Text("LIVE QUEST")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color.errorRed)
                }
                
                Spacer()
                
                // Countdown timer
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12, weight: .semibold))
                    Text(timerText)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(urgencyColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(urgencyColor.opacity(0.15))
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.errorRed.opacity(0.1))
            
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                // Category and distance
                HStack {
                    // Category badge
                    Label {
                        Text("URGENT")
                            .font(.system(size: 10, weight: .bold))
                    } icon: {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.errorRed)
                    )
                    
                    Spacer()
                    
                    // Distance
                    if let distance = quest.distanceMeters {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                            Text(formatDistance(distance))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.brandPurple)
                    }
                }
                
                // Title
                Text(quest.task.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                
                // Payment section
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        // Original vs boosted price
                        if quest.priceBoosts > 0 {
                            Text("$\(Int(quest.initialPayment))")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textMuted)
                                .strikethrough()
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("$")
                                .font(.system(size: 18, weight: .bold))
                            Text("\(Int(quest.totalPayment))")
                                .font(.system(size: 28, weight: .black))
                            
                            if showPriceBoost {
                                Text("+$\(Int(quest.currentPayment - previousPayment))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.moneyGreen))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundStyle(Color.moneyGreen)
                    }
                    
                    Spacer()
                    
                    // Surge indicator
                    if quest.urgencyPremium > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("SURGE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.warningOrange)
                            Text("+\(Int(quest.urgencyPremium / quest.initialPayment * 100))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.warningOrange)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.warningOrange.opacity(0.15))
                        )
                    }
                }
                
                // Quick info row
                HStack(spacing: 16) {
                    // Duration
                    Label {
                        Text(quest.task.estimatedDuration)
                            .font(.system(size: 12))
                    } icon: {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Color.textSecondary)
                    
                    // Location
                    Label {
                        Text(quest.task.location)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Color.textSecondary)
                    
                    Spacer()
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    // Decline
                    Button(action: onDecline) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.surfaceElevated)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.borderSubtle, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Accept
                    Button(action: onAccept) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("ACCEPT QUEST")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.errorRed, Color.errorRed.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.errorRed.opacity(0.4), radius: 8, y: 4)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [urgencyColor.opacity(0.6), urgencyColor.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: urgencyColor.opacity(pulseGlow ? 0.4 : 0.2), radius: pulseGlow ? 20 : 10, y: 4)
        .onAppear {
            startCountdown()
            startPulse()
        }
        .onChange(of: quest.currentPayment) { oldValue, newValue in
            if newValue > oldValue {
                withAnimation(.spring(response: 0.3)) {
                    showPriceBoost = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showPriceBoost = false
                        previousPayment = newValue
                    }
                }
                // Haptic feedback for price boost
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            }
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Haptic at key moments
                if timeRemaining == 30 || timeRemaining == 10 || timeRemaining == 5 {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func startPulse() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseGlow = true
        }
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1f mi", meters / 1609.34)
        }
    }
}

// MARK: - Mini Quest Alert (for notification banner)

struct MiniQuestAlert: View {
    let quest: QuestAlert
    let onTap: () -> Void
    
    @State private var slideIn = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Pulse indicator
                ZStack {
                    Circle()
                        .fill(Color.errorRed.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("LIVE QUEST NEARBY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Color.errorRed)
                    
                    Text(quest.task.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(Int(quest.totalPayment))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.moneyGreen)
                    
                    Text("\(quest.timeRemaining)s")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.errorRed)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.errorRed.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.errorRed.opacity(0.2), radius: 10, y: 4)
        }
        .offset(y: slideIn ? 0 : -100)
        .opacity(slideIn ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                slideIn = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Quest Alert Card") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            let mockTask = HXTask(
                id: "1",
                title: "Locked out of apartment - URGENT",
                description: "Need help",
                payment: 45,
                location: "Mission District",
                latitude: 37.76,
                longitude: -122.42,
                estimatedDuration: "15-30 min",
                posterId: "poster-1",
                posterName: "Alex M.",
                posterRating: 4.8,
                hustlerId: nil,
                hustlerName: nil,
                state: .posted,
                requiredTier: .elite,
                createdAt: Date(),
                claimedAt: nil,
                completedAt: nil
            )
            
            let quest = QuestAlert(
                id: "1",
                task: mockTask,
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(45),
                initialPayment: 45,
                currentPayment: 52,
                surgeMultiplier: 1.0,
                urgencyPremium: 11.25,
                decisionWindowSeconds: 60,
                priceBoosts: 2,
                maxRadius: 3218,
                posterLocation: GPSCoordinates(latitude: 37.76, longitude: -122.42),
                status: .broadcasting
            )
            
            QuestAlertCard(
                quest: quest,
                onAccept: {},
                onDecline: {}
            )
            .padding(.horizontal, 16)
            
            MiniQuestAlert(quest: quest, onTap: {})
                .padding(.horizontal, 16)
        }
    }
}
