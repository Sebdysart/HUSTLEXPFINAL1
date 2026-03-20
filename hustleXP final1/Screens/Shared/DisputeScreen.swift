//
//  DisputeScreen.swift
//  hustleXP final1
//
//  Dispute and safety mechanism screen
//

import SwiftUI

struct DisputeScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    let taskId: String
    
    @State private var selectedReason: DisputeReason?
    @State private var details: String = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    @State private var attachedPhotos: [String] = []
    @State private var errorMessage: String?
    @State private var createdDisputeId: String?
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            if showConfirmation {
                DisputeConfirmationView(disputeId: createdDisputeId, onDone: { dismiss() })
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Warning banner
                        WarningBanner()
                        
                        // Task info
                        TaskInfoCard(taskId: taskId)
                        
                        // Reason selection
                        ReasonSelectionSection(selectedReason: $selectedReason)
                        
                        // Details input
                        DetailsSection(details: $details)
                        
                        // Photo attachment
                        PhotoAttachmentSection(attachedPhotos: $attachedPhotos)
                        
                        // What happens next
                        WhatHappensNextSection()
                        
                        Spacer(minLength: 120)
                    }
                    .padding(24)
                }
                
                // Bottom action
                VStack {
                    Spacer()
                    SubmitActionBar(
                        selectedReason: selectedReason,
                        details: details,
                        isSubmitting: isSubmitting,
                        onSubmit: submitDispute
                    )
                }
            }
        }
        .navigationTitle("Report Issue")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Submission Failed", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Input / Output types for dispute.create

    private struct CreateDisputeInput: Encodable {
        let taskId: String
        let reason: String
        let description: String
    }

    private struct CreateDisputeResponse: Decodable {
        let id: String
        let state: String
    }

    private func submitDispute() {
        guard let reason = selectedReason else { return }
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                let response: CreateDisputeResponse = try await TRPCClient.shared.call(
                    router: "dispute",
                    procedure: "create",
                    input: CreateDisputeInput(
                        taskId: taskId,
                        reason: reason.backendValue,
                        description: details.isEmpty ? reason.rawValue : details
                    )
                )
                createdDisputeId = response.id
                withAnimation(.spring(response: 0.5)) {
                    showConfirmation = true
                }
            } catch let error as APIError {
                errorMessage = error.userFacingMessage
            } catch {
                errorMessage = "Network error. Please try again."
            }
        }
    }
}

// MARK: - Dispute Reason Enum
enum DisputeReason: String, CaseIterable {
    case notCompleted = "Task not completed"
    case qualityIssue = "Quality doesn't meet expectations"
    case noShow = "Hustler didn't show up"
    case wrongItem = "Wrong item/service"
    case safety = "Safety concern"
    case communication = "Communication issues"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .notCompleted: return "xmark.circle"
        case .qualityIssue: return "star.slash"
        case .noShow: return "person.slash"
        case .wrongItem: return "exclamationmark.triangle"
        case .safety: return "shield.slash"
        case .communication: return "message.badge.fill"
        case .other: return "ellipsis.circle"
        }
    }
    
    var isCritical: Bool {
        self == .safety
    }

    /// Maps the UI-facing enum case to the backend `reason` string accepted by
    /// `dispute.create`. The backend accepts any non-empty string up to 500 chars.
    var backendValue: String {
        switch self {
        case .notCompleted:  return "WORK_NOT_DONE"
        case .qualityIssue:  return "QUALITY_ISSUE"
        case .noShow:        return "NO_SHOW"
        case .wrongItem:     return "WRONG_ITEM"
        case .safety:        return "SAFETY_CONCERN"
        case .communication: return "COMMUNICATION"
        case .other:         return "OTHER"
        }
    }
}

// MARK: - Warning Banner
private struct WarningBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.warningOrange)
            
            VStack(alignment: .leading, spacing: 4) {
                HXText("Filing a Report", style: .subheadline)
                HXText(
                    "Reports are taken seriously. False reports may affect your account.",
                    style: .caption,
                    color: .textSecondary
                )
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.warningOrange.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - Task Info Card
private struct TaskInfoCard: View {
    let taskId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Task Details", style: .caption, color: .textSecondary)
            
            HStack(spacing: 12) {
                HXAvatar(initials: "JD", size: .small)
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Deliver Package Downtown", style: .subheadline)
                    HXText("With Jane Doe", style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                HXText("$25", style: .headline, color: .moneyGreen)
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(12)
    }
}

// MARK: - Reason Selection Section
private struct ReasonSelectionSection: View {
    @Binding var selectedReason: DisputeReason?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("What happened?", style: .headline)
            
            VStack(spacing: 10) {
                ForEach(DisputeReason.allCases, id: \.self) { reason in
                    DisputeReasonRow(
                        reason: reason,
                        isSelected: selectedReason == reason
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedReason = reason
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Dispute Reason Row
private struct DisputeReasonRow: View {
    let reason: DisputeReason
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected
                            ? (reason.isCritical ? Color.errorRed.opacity(0.15) : Color.brandPurple.opacity(0.15))
                            : Color.surfaceSecondary
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: reason.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isSelected
                            ? (reason.isCritical ? Color.errorRed : Color.brandPurple)
                            : Color.textSecondary
                        )
                }
                
                HXText(reason.rawValue, style: .body, color: isSelected ? .textPrimary : .textSecondary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected
                        ? (reason.isCritical ? Color.errorRed : Color.brandPurple)
                        : Color.textTertiary
                    )
            }
            .padding(14)
            .background(isSelected
                ? (reason.isCritical ? Color.errorRed.opacity(0.1) : Color.brandPurple.opacity(0.1))
                : Color.surfaceElevated
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected
                        ? (reason.isCritical ? Color.errorRed.opacity(0.5) : Color.brandPurple.opacity(0.5))
                        : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Details Section
private struct DetailsSection: View {
    @Binding var details: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Additional Details", style: .headline)
                Spacer()
                HXText("Optional", style: .caption, color: .textTertiary)
            }
            
            TextField("", text: $details, prompt: Text("Describe what happened in detail...").foregroundColor(.textTertiary), axis: .vertical)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(4...8)
                .padding(16)
                .background(Color.surfaceElevated)
                .cornerRadius(12)
            
            HXText(
                "Be specific about what went wrong. Include times, locations, or any relevant information.",
                style: .caption,
                color: .textTertiary
            )
        }
    }
}

// MARK: - Photo Attachment Section
private struct PhotoAttachmentSection: View {
    @Binding var attachedPhotos: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Add Evidence", style: .headline)
                Spacer()
                HXText("Optional", style: .caption, color: .textTertiary)
            }
            
            HStack(spacing: 12) {
                // Add photo button
                Button(action: {}) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.brandPurple)

                        HXText("Add Photo", style: .caption, color: .textSecondary)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.surfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.borderSubtle, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
                .accessibilityLabel("Add evidence photo")
                
                // Attached photos would appear here
                ForEach(attachedPhotos, id: \.self) { photo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 80, height: 80)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - What Happens Next Section
private struct WhatHappensNextSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("What happens next?", style: .headline)
            
            VStack(spacing: 12) {
                StepRow(number: 1, text: "We'll review your report within 24 hours")
                StepRow(number: 2, text: "Both parties may be contacted for more information")
                StepRow(number: 3, text: "We'll take appropriate action and notify you")
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
    }
}

// MARK: - Step Row
private struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.brandBlack)
                .frame(width: 24, height: 24)
                .background(Color.brandPurple)
                .clipShape(Circle())
            
            HXText(text, style: .subheadline, color: .textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Submit Action Bar
private struct SubmitActionBar: View {
    let selectedReason: DisputeReason?
    let details: String
    let isSubmitting: Bool
    let onSubmit: () -> Void
    
    var isValid: Bool {
        selectedReason != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 12) {
                HXButton(
                    isSubmitting ? "Submitting..." : "Submit Report",
                    variant: selectedReason?.isCritical == true ? .danger : .primary,
                    isLoading: isSubmitting
                ) {
                    onSubmit()
                }
                .disabled(!isValid || isSubmitting)
                .opacity(isValid ? 1 : 0.5)
                .accessibilityLabel("Submit report")
                
                HXText(
                    "By submitting, you confirm this report is accurate and truthful.",
                    style: .caption,
                    color: .textTertiary
                )
                .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

// MARK: - Dispute Confirmation View
private struct DisputeConfirmationView: View {
    let disputeId: String?
    let onDone: () -> Void
    
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 100, height: 100)
                    .scaleEffect(showCheckmark ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showCheckmark = true
                }
            }
            
            VStack(spacing: 12) {
                HXText("Report Submitted", style: .title2)
                
                HXText(
                    "We've received your report and will review it within 24 hours. You'll be notified of the outcome.",
                    style: .body,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            // Case number — use first 8 chars of real dispute UUID as human-readable ref
            VStack(spacing: 8) {
                HXText("Case Number", style: .caption, color: .textTertiary)
                HXText(
                    "DSP-\(disputeId.map { String($0.prefix(8)).uppercased() } ?? "PENDING")",
                    style: .headline
                )
            }
            .padding(20)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
            
            Spacer()
            
            HXButton("Done", variant: .primary) {
                onDone()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    NavigationStack {
        DisputeScreen(taskId: "task-123")
    }
}
