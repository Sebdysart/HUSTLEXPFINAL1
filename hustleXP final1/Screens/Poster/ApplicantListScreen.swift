//
//  ApplicantListScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Shows applicants for a posted task; poster can accept or reject each.
//

import SwiftUI

struct ApplicantListScreen: View {
    @Environment(Router.self) private var router

    let taskId: String

    @State private var applicants: [TaskApplicant] = []
    @State private var isLoading = true
    @State private var loadError: Error?
    @State private var processingId: String?
    @State private var showAcceptConfirm = false
    @State private var selectedApplicant: TaskApplicant?
    @State private var actionError: String?
    @State private var showActionError = false

    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()

            if isLoading {
                LoadingState(message: "Loading applicants...")
            } else if let error = loadError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.warningOrange)
                    HXText("Failed to Load Applicants", style: .headline)
                    HXText(error.localizedDescription, style: .caption, color: .textSecondary)
                    HXButton("Try Again", icon: "arrow.clockwise", variant: .secondary) {
                        Task { await loadApplicants() }
                    }
                }
                .padding(24)
            } else if applicants.isEmpty {
                EmptyState(
                    icon: "person.2.slash",
                    title: "No Applicants Yet",
                    message: "When hustlers apply for your task, they\u{2019}ll appear here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(applicants) { applicant in
                            ApplicantCard(
                                applicant: applicant,
                                isProcessing: processingId == applicant.id,
                                onAccept: {
                                    selectedApplicant = applicant
                                    showAcceptConfirm = true
                                },
                                onReject: {
                                    rejectApplicant(applicant)
                                }
                            )
                        }
                    }
                    .padding(24)
                }
                .refreshable {
                    await refreshApplicants()
                }
            }
        }
        .navigationTitle("Applicants")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Accept Applicant?", isPresented: $showAcceptConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Accept") {
                if let applicant = selectedApplicant {
                    acceptApplicant(applicant)
                }
            }
        } message: {
            if let applicant = selectedApplicant {
                Text("Assign \(applicant.name) to this task? Other applicants will be notified.")
            }
        }
        .alert("Action Failed", isPresented: $showActionError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(actionError ?? "Something went wrong. Please try again.")
        }
        .task {
            await loadApplicants()
        }
    }

    // MARK: - Data Loading

    private func loadApplicants() async {
        isLoading = true
        loadError = nil
        do {
            applicants = try await TaskService.shared.listApplicants(taskId: taskId)
            HXLogger.info("ApplicantList: Loaded \(applicants.count) applicants", category: "Task")
        } catch {
            loadError = error
            HXLogger.error("ApplicantList: Failed to load - \(error.localizedDescription)", category: "Task")
        }
        isLoading = false
    }

    /// Pull-to-refresh variant: refreshes without showing the skeleton loading state.
    private func refreshApplicants() async {
        do {
            applicants = try await TaskService.shared.listApplicants(taskId: taskId)
            HXLogger.info("ApplicantList: Refreshed \(applicants.count) applicants", category: "Task")
        } catch {
            HXLogger.error("ApplicantList: Refresh failed - \(error.localizedDescription)", category: "Task")
        }
    }

    // MARK: - Actions

    private func acceptApplicant(_ applicant: TaskApplicant) {
        processingId = applicant.id
        Task {
            do {
                _ = try await TaskService.shared.assignWorker(taskId: taskId, workerId: applicant.userId)
                HXLogger.info("ApplicantList: Accepted \(applicant.name)", category: "Task")
                let haptic = UINotificationFeedbackGenerator()
                haptic.notificationOccurred(.success)
                // Navigate back to task detail; task is now claimed
                router.popPoster()
            } catch {
                HXLogger.error("ApplicantList: Accept failed - \(error.localizedDescription)", category: "Task")
                actionError = "Could not assign worker: \(error.localizedDescription)"
                showActionError = true
            }
            processingId = nil
        }
    }

    private func rejectApplicant(_ applicant: TaskApplicant) {
        processingId = applicant.id
        Task {
            do {
                try await TaskService.shared.rejectApplicant(taskId: taskId, workerId: applicant.userId)
                applicants.removeAll { $0.id == applicant.id }
                HXLogger.info("ApplicantList: Rejected \(applicant.name)", category: "Task")
            } catch {
                HXLogger.error("ApplicantList: Reject failed - \(error.localizedDescription)", category: "Task")
                actionError = "Could not decline applicant: \(error.localizedDescription)"
                showActionError = true
            }
            processingId = nil
        }
    }
}

// MARK: - Applicant Card

private struct ApplicantCard: View {
    let applicant: TaskApplicant
    let isProcessing: Bool
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header row
            HStack(spacing: 14) {
                HXAvatar(
                    initials: String(applicant.name.prefix(2)).uppercased(),
                    size: .medium
                )

                VStack(alignment: .leading, spacing: 4) {
                    HXText(applicant.name, style: .headline)

                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.warningOrange)
                            HXText(String(format: "%.1f", applicant.rating), style: .caption)
                        }

                        HXText("\u{2022}", style: .caption, color: .textTertiary)

                        HXText("\(applicant.completedTasks) tasks", style: .caption, color: .textSecondary)
                    }
                }

                Spacer()

                HXBadge(variant: .tier(applicant.tier))
            }

            // Message (if present)
            if let message = applicant.message, !message.isEmpty {
                HXText(message, style: .body, color: .textSecondary)
                    .lineLimit(3)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(10)
            }

            // Action buttons
            HStack(spacing: 12) {
                HXButton("Accept", icon: "checkmark", variant: .primary, isLoading: isProcessing) {
                    onAccept()
                }
                .disabled(isProcessing)

                Button(action: onReject) {
                    HXText("Decline", style: .subheadline, color: .errorRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.errorRed.opacity(0.1))
                        .cornerRadius(12)
                }
                .disabled(isProcessing)
                .accessibilityLabel("Decline applicant")
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        ApplicantListScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
