//
//  GoModeView.swift
//  hustleXP final1
//
//  Go Mode card embedded in HustlerHomeScreen.
//  Shows the hustler's online/offline status and lets them toggle dispatching.
//

import SwiftUI

struct GoModeView: View {
    @Environment(GoModeManager.self) private var goModeManager
    @Environment(Router.self) private var router

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var showPrefs: Bool = false

    var body: some View {
        ZStack {
            // Background glow (only when online)
            if goModeManager.isOnline {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.successGreen.opacity(glowOpacity * 0.25))
                    .blur(radius: 20)
                    .padding(-4)
            }

            // Card
            VStack(spacing: 0) {
                // ── Header row ───────────────────────────────────────────
                HStack(alignment: .center, spacing: 14) {
                    // Status orb
                    ZStack {
                        if goModeManager.isOnline {
                            Circle()
                                .fill(Color.successGreen.opacity(0.2))
                                .frame(width: 52, height: 52)
                                .scaleEffect(pulseScale)
                                .blur(radius: 4)
                        }

                        Circle()
                            .fill(
                                goModeManager.isOnline
                                ? LinearGradient(colors: [Color.successGreen, Color.successGreen.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.surfaceSecondary, Color.surfaceSecondary], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: goModeManager.isOnline ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(goModeManager.isOnline ? Color.brandBlack : Color.textMuted)
                    }

                    // Status text
                    VStack(alignment: .leading, spacing: 3) {
                        Text(goModeManager.isOnline ? "GO MODE — ONLINE" : "GO MODE — OFFLINE")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.4)
                            .foregroundStyle(goModeManager.isOnline ? Color.successGreen : Color.textSecondary)

                        Text(goModeManager.isOnline ? "Receiving dispatch pings" : "Not receiving pings")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.textSecondary)

                        if goModeManager.isOnline, let updatedAt = goModeManager.locationUpdatedAt {
                            Text("Location updated \(relativeTime(updatedAt))")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.textMuted)
                        }
                    }

                    Spacer()

                    // Settings button
                    Button {
                        showPrefs = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 34, height: 34)
                            .background(Color.surfaceSecondary)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Dispatch settings")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // ── Divider ──────────────────────────────────────────────
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                // ── Toggle button ─────────────────────────────────────────
                Button {
                    Task { await goModeManager.setGoMode(enabled: !goModeManager.isGoModeEnabled) }
                } label: {
                    HStack(spacing: 10) {
                        if goModeManager.isLoading {
                            ProgressView()
                                .tint(goModeManager.isGoModeEnabled ? Color.brandBlack : Color.brandPurple)
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: goModeManager.isGoModeEnabled ? "stop.fill" : "bolt.fill")
                                .font(.system(size: 16, weight: .bold))
                        }
                        Text(goModeManager.isGoModeEnabled ? "Go Offline" : "Go Online")
                            .font(.system(size: 16, weight: .heavy))
                    }
                    .foregroundStyle(goModeManager.isGoModeEnabled ? Color.brandBlack : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        if goModeManager.isGoModeEnabled {
                            Color.successGreen
                        } else {
                            LinearGradient(
                                colors: [Color.brandPurple, Color.aiPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(
                        color: goModeManager.isGoModeEnabled
                            ? Color.successGreen.opacity(0.4)
                            : Color.brandPurple.opacity(0.4),
                        radius: 10, y: 4
                    )
                }
                .disabled(goModeManager.isLoading)
                .padding(.horizontal, 20)

                // ── Error message ─────────────────────────────────────────
                if let err = goModeManager.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(Color.errorRed)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                // ── Prefs summary chips ───────────────────────────────────
                if goModeManager.isGoModeEnabled {
                    HStack(spacing: 8) {
                        prefChip(
                            icon: "location",
                            label: "\(goModeManager.dispatchPrefs.maxDistanceMiles)mi"
                        )
                        if goModeManager.dispatchPrefs.minPayoutCents > 0 {
                            prefChip(
                                icon: "dollarsign",
                                label: String(format: "$%.0f+", goModeManager.dispatchPrefs.minPayoutDollars)
                            )
                        }
                        prefChip(
                            icon: goModeManager.dispatchPrefs.pingSoundEnabled ? "bell.fill" : "bell.slash",
                            label: goModeManager.dispatchPrefs.pingSoundEnabled ? "Sound on" : "Silent"
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                Spacer(minLength: 20)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.surfaceElevated)
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            goModeManager.isOnline
                            ? LinearGradient(colors: [Color.successGreen.opacity(0.5), Color.successGreen.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.07), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                }
            )
        }
        .sheet(isPresented: $showPrefs) {
            DispatchPrefsSheet()
                .environment(goModeManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.brandBlack)
        }
        .onAppear {
            if goModeManager.isOnline {
                startPulseAnimation()
            }
        }
        .onChange(of: goModeManager.isOnline) { _, online in
            if online {
                startPulseAnimation()
            } else {
                pulseScale = 1.0
                glowOpacity = 0.3
            }
        }
    }

    // MARK: - Helpers

    private func prefChip(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(Color.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.surfaceSecondary)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.25
            glowOpacity = 0.6
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        return "\(seconds / 3600)h ago"
    }
}

#Preview {
    GoModeView()
        .environment(GoModeManager.shared)
        .environment(Router())
        .padding()
        .background(Color.brandBlack)
}
