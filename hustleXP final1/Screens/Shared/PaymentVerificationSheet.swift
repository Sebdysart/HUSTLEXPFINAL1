//
//  PaymentVerificationSheet.swift
//  hustleXP final1
//
//  Shown to a hustler when they're about to abandon a task,
//  to detect off-platform payments and protect both parties.
//

import SwiftUI

struct PaymentVerificationSheet: View {
    let taskId: String
    let taskTitle: String
    @Binding var isPresented: Bool
    /// Called with the user's answer + optional reason. Caller decides what to do.
    let onComplete: (PaymentVerificationOutcome) -> Void

    @State private var selectedOutcome: PaymentVerificationOutcome?
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Before you go…", style: .largeTitle)
                            HXText("Quick check on \"\(taskTitle)\"", style: .body, color: .textSecondary)
                        }
                        .padding(.top, 8)

                        // Question
                        HXText("Did the task happen?", style: .headline)

                        VStack(spacing: 12) {
                            outcomeOption(
                                .didntDo,
                                title: "I didn't end up doing the task",
                                subtitle: "Released back to the feed for someone else"
                            )
                            outcomeOption(
                                .completedAndPaidInApp,
                                title: "I completed it and was paid through HustleXP",
                                subtitle: "Then you don't need to abandon — submit proof instead"
                            )
                            outcomeOption(
                                .completedButPaidOffPlatform,
                                title: "I completed it but was paid outside the app",
                                subtitle: "We need to know — see warning below"
                            )
                            outcomeOption(
                                .somethingElse,
                                title: "Something else came up",
                                subtitle: "Tell us what happened"
                            )
                        }

                        // Off-platform warning
                        if selectedOutcome == .completedButPaidOffPlatform {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(Color.warningOrange)
                                    HXText("Off-platform payment notice", style: .subheadline, color: .warningOrange)
                                }

                                Text("HustleXP's Terms of Service require all task payments to go through the app. Off-platform payments mean:\n\n• You lose insurance and dispute protection\n• Your reputation/tier won't reflect this work\n• Repeated off-platform activity may result in account suspension")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .padding(14)
                            .background(Color.warningOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Optional note
                        if selectedOutcome != nil {
                            VStack(alignment: .leading, spacing: 6) {
                                HXText("Notes (optional)", style: .caption, color: .textSecondary)
                                TextField("", text: $note, prompt: Text("Anything else we should know?").foregroundColor(.textTertiary), axis: .vertical)
                                    .font(.body)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(3...6)
                                    .padding(12)
                                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }

                        // Submit button
                        if let outcome = selectedOutcome {
                            HXButton(submitLabel(for: outcome), variant: .primary) {
                                onComplete(outcome)
                                isPresented = false
                            }
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Confirm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func outcomeOption(_ outcome: PaymentVerificationOutcome, title: String, subtitle: String) -> some View {
        let isSelected = selectedOutcome == outcome
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedOutcome = outcome
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.brandPurple : Color.textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(14)
            .background(
                isSelected ? Color.brandPurple.opacity(0.1) : Color.surfaceElevated,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brandPurple : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func submitLabel(for outcome: PaymentVerificationOutcome) -> String {
        switch outcome {
        case .didntDo: return "Drop the task"
        case .completedAndPaidInApp: return "Go submit proof instead"
        case .completedButPaidOffPlatform: return "I understand — drop the task"
        case .somethingElse: return "Drop the task"
        }
    }
}

enum PaymentVerificationOutcome: Equatable {
    case didntDo
    case completedAndPaidInApp
    case completedButPaidOffPlatform
    case somethingElse
}
