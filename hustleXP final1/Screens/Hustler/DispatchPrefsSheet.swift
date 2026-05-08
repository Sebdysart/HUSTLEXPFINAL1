//
//  DispatchPrefsSheet.swift
//  hustleXP final1
//
//  Bottom sheet for configuring Smart Dispatch preferences:
//  max distance, min payout, preferred categories, ping sound toggle.
//

import SwiftUI

struct DispatchPrefsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GoModeManager.self) private var goModeManager

    // Local edit state — applied on Save
    @State private var maxDistanceMiles: Int = 10
    @State private var minPayoutDollars: Double = 0
    @State private var pingSoundEnabled: Bool = true
    @State private var isSaving: Bool = false
    @State private var saveError: String? = nil

    private let distanceOptions = [1, 2, 5, 10, 15, 20, 30, 50]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── Max Distance ─────────────────────────────────
                        prefSection(title: "MAX DISTANCE", icon: "location.circle.fill", iconColor: .infoBlue) {
                            VStack(spacing: 16) {
                                // Current value display
                                HStack {
                                    Text("\(maxDistanceMiles) miles")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text("radius from you")
                                        .font(.caption)
                                        .foregroundStyle(Color.textSecondary)
                                }

                                // Distance picker chips
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                    ForEach(distanceOptions, id: \.self) { miles in
                                        Button {
                                            withAnimation(.spring(response: 0.25)) {
                                                maxDistanceMiles = miles
                                            }
                                        } label: {
                                            Text("\(miles)mi")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(maxDistanceMiles == miles ? .white : Color.textSecondary)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 38)
                                                .background(
                                                    maxDistanceMiles == miles
                                                    ? Color.brandPurple
                                                    : Color.surfaceSecondary
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            maxDistanceMiles == miles
                                                            ? Color.brandPurple.opacity(0.6)
                                                            : Color.white.opacity(0.06),
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                        }

                        // ── Minimum Payout ───────────────────────────────
                        prefSection(title: "MIN PAYOUT", icon: "dollarsign.circle.fill", iconColor: .moneyGreen) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text(minPayoutDollars == 0 ? "Any amount" : String(format: "$%.0f+", minPayoutDollars))
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                }

                                Slider(value: $minPayoutDollars, in: 0...200, step: 5)
                                    .tint(Color.moneyGreen)

                                HStack {
                                    Text("Any")
                                        .font(.caption)
                                        .foregroundStyle(Color.textMuted)
                                    Spacer()
                                    Text("$200")
                                        .font(.caption)
                                        .foregroundStyle(Color.textMuted)
                                }
                            }
                        }

                        // ── Ping Sound ───────────────────────────────────
                        prefSection(title: "NOTIFICATIONS", icon: "bell.fill", iconColor: .brandPurple) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ping sound")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.textPrimary)
                                    Text("Play sound when a new task ping arrives")
                                        .font(.caption)
                                        .foregroundStyle(Color.textSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: $pingSoundEnabled)
                                    .tint(Color.brandPurple)
                                    .labelsHidden()
                            }
                        }

                        // ── Error ────────────────────────────────────────
                        if let err = saveError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(Color.errorRed)
                                .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Dispatch Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await savePrefs() }
                    } label: {
                        if isSaving {
                            ProgressView().tint(Color.brandPurple)
                        } else {
                            Text("Save")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.brandPurple)
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear { loadCurrentPrefs() }
    }

    // MARK: - Helpers

    private func prefSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.4)
                    .foregroundStyle(Color.textSecondary)
            }
            content()
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surfaceElevated)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        )
        .padding(.horizontal, 20)
    }

    private func loadCurrentPrefs() {
        let prefs = goModeManager.dispatchPrefs
        maxDistanceMiles = prefs.maxDistanceMiles
        minPayoutDollars = prefs.minPayoutDollars
        pingSoundEnabled = prefs.pingSoundEnabled
    }

    private func savePrefs() async {
        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            try await DispatchServiceClient.shared.setPrefs(
                maxDistanceMiles: maxDistanceMiles,
                minPayoutCents: Int(minPayoutDollars * 100),
                pingSoundEnabled: pingSoundEnabled
            )
            // Refresh local prefs
            let updated = try await DispatchServiceClient.shared.getPrefs()
            goModeManager.dispatchPrefs = updated
            dismiss()
        } catch {
            saveError = "Couldn't save preferences. Please try again."
        }
    }
}

#Preview {
    DispatchPrefsSheet()
        .environment(GoModeManager.shared)
}
