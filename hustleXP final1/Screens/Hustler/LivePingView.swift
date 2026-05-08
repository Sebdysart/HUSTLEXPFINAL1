//
//  LivePingView.swift
//  hustleXP final1
//
//  Full-screen overlay shown when a Smart Dispatch ping arrives.
//  Hustler has 30 seconds to accept or decline before the ping auto-expires.
//

import SwiftUI
import Combine

struct LivePingView: View {
    let ping: IncomingPing
    let onAccept: () -> Void
    let onDecline: () -> Void

    @State private var secondsLeft: Int = 30
    @State private var pulseScale: CGFloat = 1.0
    @State private var isAccepting: Bool = false
    @State private var ringProgress: CGFloat = 1.0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Darkened scrim
            Color.black.opacity(0.92).ignoresSafeArea()

            // Neon halo behind card
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brandPurple.opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 260
                    )
                )
                .frame(width: 520, height: 520)
                .scaleEffect(pulseScale)
                .blur(radius: 40)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Ping card ──────────────────────────────────────────────
                VStack(spacing: 28) {
                    // Wave badge + countdown ring
                    ZStack {
                        // Countdown ring track
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 6)
                            .frame(width: 100, height: 100)

                        // Countdown ring fill
                        Circle()
                            .trim(from: 0, to: ringProgress)
                            .stroke(
                                AngularGradient(
                                    colors: [Color.brandPurple, Color.aiPurple, Color.brandPurpleLight],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: ringProgress)

                        // Seconds remaining
                        VStack(spacing: 2) {
                            Text("\(secondsLeft)")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color.textPrimary)
                                .contentTransition(.numericText())
                            Text("sec")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1.2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    // Title
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            // Wave indicator
                            Text("WAVE \(ping.waveNumber)")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.5)
                                .foregroundStyle(Color.brandPurple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.brandPurple.opacity(0.15))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.brandPurple.opacity(0.4), lineWidth: 1)
                                )

                            Spacer()

                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.warningOrange)
                                .shadow(color: Color.warningOrange, radius: 6)
                        }

                        Text(ping.taskTitle)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Payment + location row
                    HStack(spacing: 16) {
                        // Pay
                        VStack(alignment: .leading, spacing: 4) {
                            Text("YOUR CUT")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(1.5)
                                .foregroundStyle(Color.textMuted)
                            Text(ping.paymentFormatted)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.moneyGreen)
                        }

                        Spacer()

                        // Location
                        if let loc = ping.location {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("LOCATION")
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(1.5)
                                    .foregroundStyle(Color.textMuted)
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.infoBlue)
                                    Text(loc)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.textSecondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .frame(maxWidth: 160)
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // Action buttons
                    HStack(spacing: 12) {
                        // Decline
                        Button(action: onDecline) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Pass")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(Color.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .disabled(isAccepting)

                        // Accept
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAccepting = true
                            }
                            onAccept()
                        } label: {
                            ZStack {
                                if isAccepting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("Accept")
                                            .font(.system(size: 16, weight: .heavy))
                                    }
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color.brandPurple, Color.aiPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.brandPurple.opacity(0.5), radius: 12, y: 4)
                        }
                        .disabled(isAccepting)
                        .scaleEffect(isAccepting ? 0.97 : 1.0)
                    }
                }
                .padding(28)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.surfaceElevated)
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.brandPurple.opacity(0.5), Color.aiPurple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                )
                .padding(.horizontal, 20)
                .shadow(color: Color.brandPurple.opacity(0.3), radius: 40, y: 10)

                Spacer()
                    .frame(height: 48)
            }
        }
        .onAppear {
            secondsLeft = ping.secondsRemaining
            ringProgress = CGFloat(secondsLeft) / 30.0

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
        .onReceive(timer) { _ in
            let remaining = Int(ping.expiresAt.timeIntervalSinceNow)
            secondsLeft = max(0, remaining)
            ringProgress = CGFloat(secondsLeft) / 30.0
        }
    }
}

#Preview {
    LivePingView(
        ping: IncomingPing(
            id: "preview",
            taskId: "task-123",
            taskTitle: "Move furniture from storage unit",
            paymentCents: 4500,
            location: "123 Main St, Seattle",
            waveNumber: 1,
            receivedAt: Date(),
            expiresAt: Date().addingTimeInterval(22)
        ),
        onAccept: {},
        onDecline: {}
    )
}
