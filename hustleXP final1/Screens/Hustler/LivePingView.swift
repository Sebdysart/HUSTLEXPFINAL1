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
        // Color is the layout root — fills exactly the full screen.
        // Overlays are sized/positioned within that frame, so nothing
        // can inflate the layout width (unlike ZStack with a 520pt Circle).
        Color.black.opacity(0.92)
            .ignoresSafeArea()
            // ── Neon halo (decorative, no layout impact) ──────────────────
            .overlay(alignment: .center) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.brandPurple.opacity(0.30), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 260
                        )
                    )
                    .frame(width: 520, height: 520)
                    .scaleEffect(pulseScale)
                    .blur(radius: 50)
                    .allowsHitTesting(false)
            }
            // ── Ping card ──────────────────────────────────────────────────
            .overlay(alignment: .center) {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)
                    cardView
                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 20)
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

    // MARK: - Card

    private var cardView: some View {
        VStack(spacing: 24) {
            countdownRing
            titleSection
            paymentRow
            Divider().background(Color.white.opacity(0.08))
            actionButtons
        }
        .padding(28)
        .background(cardBackground)
        .shadow(color: Color.brandPurple.opacity(0.3), radius: 40, y: 10)
    }

    // MARK: - Countdown ring

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 6)
                .frame(width: 100, height: 100)

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
    }

    // MARK: - Wave badge + title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("WAVE \(ping.waveNumber)")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandPurple.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.brandPurple.opacity(0.4), lineWidth: 1))

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
    }

    // MARK: - Payment + location

    private var paymentRow: some View {
        HStack(alignment: .top, spacing: 16) {
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

            if let loc = ping.location, !loc.isEmpty {
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
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onDecline) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                    Text("Pass").font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
            .disabled(isAccepting)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isAccepting = true }
                onAccept()
            } label: {
                ZStack {
                    if isAccepting {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark").font(.system(size: 14, weight: .bold))
                            Text("Accept").font(.system(size: 16, weight: .heavy))
                        }
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.brandPurple, Color.aiPurple],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.brandPurple.opacity(0.5), radius: 12, y: 4)
            }
            .disabled(isAccepting)
            .scaleEffect(isAccepting ? 0.97 : 1.0)
        }
    }

    // MARK: - Card background

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32).fill(Color.surfaceElevated)
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        colors: [Color.brandPurple.opacity(0.5), Color.aiPurple.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
    }
}

#Preview {
    LivePingView(
        ping: IncomingPing(
            id: "preview",
            taskId: "task-123",
            taskTitle: "Dog Washing Service Needed",
            paymentCents: 6500,
            location: "Redmond, WA",
            waveNumber: 1,
            receivedAt: Date(),
            expiresAt: Date().addingTimeInterval(22)
        ),
        onAccept: {},
        onDecline: {}
    )
}
