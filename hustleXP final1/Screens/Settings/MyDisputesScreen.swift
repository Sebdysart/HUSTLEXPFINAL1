//
//  MyDisputesScreen.swift
//  hustleXP final1
//
//  v2.6.0: List all disputes for the current user
//

import SwiftUI

struct MyDisputesScreen: View {
    @State private var disputes: [DisputeItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(.brandPurple)
            } else if disputes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.successGreen)
                    Text("No Disputes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("You don't have any disputes. That's great!")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(disputes) { dispute in
                            DisputeRow(dispute: dispute)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("My Disputes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await loadDisputes()
        }
    }

    private func loadDisputes() async {
        isLoading = true
        do {
            struct EmptyInput: Codable {}
            let result: [DisputeItem] = try await TRPCClient.shared.call(
                router: "dispute",
                procedure: "getMine",
                type: .query,
                input: EmptyInput()
            )
            disputes = result.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
        } catch {
            HXLogger.error("MyDisputes: Failed to load - \(error.localizedDescription)", category: "Dispute")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Dispute Item Model

struct DisputeItem: Identifiable, Codable {
    let id: String
    let taskId: String?
    let state: String
    let reason: String
    let description: String?
    let resolution: String?
    let resolutionNotes: String?
    let outcomeEscrowAction: String?
    let createdAt: Date?
    let resolvedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, state, reason, description, resolution
        case taskId = "task_id"
        case resolutionNotes = "resolution_notes"
        case outcomeEscrowAction = "outcome_escrow_action"
        case createdAt = "created_at"
        case resolvedAt = "resolved_at"
    }

    var stateDisplay: String {
        switch state.uppercased() {
        case "OPEN": return "Open"
        case "EVIDENCE_REQUESTED": return "Evidence Requested"
        case "ESCALATED": return "Escalated"
        case "RESOLVED": return "Resolved"
        default: return state.capitalized
        }
    }

    var stateColor: Color {
        switch state.uppercased() {
        case "OPEN": return .warningOrange
        case "EVIDENCE_REQUESTED": return .infoBlue
        case "ESCALATED": return .errorRed
        case "RESOLVED": return .successGreen
        default: return .textMuted
        }
    }

    var stateIcon: String {
        switch state.uppercased() {
        case "OPEN": return "exclamationmark.circle.fill"
        case "EVIDENCE_REQUESTED": return "doc.text.magnifyingglass"
        case "ESCALATED": return "arrow.up.circle.fill"
        case "RESOLVED": return "checkmark.circle.fill"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Dispute Row

private struct DisputeRow: View {
    let dispute: DisputeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Status badge
                HStack(spacing: 4) {
                    Image(systemName: dispute.stateIcon)
                        .font(.system(size: 12))
                    Text(dispute.stateDisplay)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(dispute.stateColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(dispute.stateColor.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                if let date = dispute.createdAt {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }

            // Reason
            Text(dispute.reason.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            if let desc = dispute.description, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            // Resolution (if resolved)
            if dispute.state.uppercased() == "RESOLVED" {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.successGreen)

                    if let action = dispute.outcomeEscrowAction {
                        Text("Outcome: \(action.capitalized)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.successGreen)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        MyDisputesScreen()
    }
}
