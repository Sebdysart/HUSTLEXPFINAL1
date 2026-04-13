//
//  ReviewTaskSheet.swift
//  hustleXP final1
//
//  Review and edit task details before posting.
//  Shown after AI conversation fills the draft.
//  Matches EditTaskSheet fields: title, description, payment, location (city/state/radius), duration (value + unit).
//

import SwiftUI

struct ReviewTaskSheet: View {
    @ObservedObject private var draft: AITaskDraftWrapper
    let onPost: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var durationValue: String
    @State private var durationUnit: DurationUnit
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, description, payment, city, durationVal, requirements }

    private static let radiusOptions = [25, 50, 75, 100]

    private static let usStates: [(code: String, name: String)] = [
        ("AL", "Alabama"), ("AK", "Alaska"), ("AZ", "Arizona"), ("AR", "Arkansas"),
        ("CA", "California"), ("CO", "Colorado"), ("CT", "Connecticut"), ("DE", "Delaware"),
        ("FL", "Florida"), ("GA", "Georgia"), ("HI", "Hawaii"), ("ID", "Idaho"),
        ("IL", "Illinois"), ("IN", "Indiana"), ("IA", "Iowa"), ("KS", "Kansas"),
        ("KY", "Kentucky"), ("LA", "Louisiana"), ("ME", "Maine"), ("MD", "Maryland"),
        ("MA", "Massachusetts"), ("MI", "Michigan"), ("MN", "Minnesota"), ("MS", "Mississippi"),
        ("MO", "Missouri"), ("MT", "Montana"), ("NE", "Nebraska"), ("NV", "Nevada"),
        ("NH", "New Hampshire"), ("NJ", "New Jersey"), ("NM", "New Mexico"), ("NY", "New York"),
        ("NC", "North Carolina"), ("ND", "North Dakota"), ("OH", "Ohio"), ("OK", "Oklahoma"),
        ("OR", "Oregon"), ("PA", "Pennsylvania"), ("RI", "Rhode Island"), ("SC", "South Carolina"),
        ("SD", "South Dakota"), ("TN", "Tennessee"), ("TX", "Texas"), ("UT", "Utah"),
        ("VT", "Vermont"), ("VA", "Virginia"), ("WA", "Washington"), ("WV", "West Virginia"),
        ("WI", "Wisconsin"), ("WY", "Wyoming"), ("DC", "Washington D.C."),
    ]

    init(draft: AITaskDraft, onPost: @escaping () -> Void) {
        self.draft = AITaskDraftWrapper(draft: draft)
        self.onPost = onPost
        let parsed = DurationUnit.parse(draft.duration)
        _durationValue = State(initialValue: parsed.value)
        _durationUnit = State(initialValue: parsed.unit)
    }

    private var isValid: Bool {
        !draft.inner.title.isEmpty
        && !draft.inner.description.isEmpty
        && (draft.inner.payment ?? 0) >= 5
        && draft.inner.hasLocation
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    fieldSection(label: "Title", field: .title) {
                        TextField("Task title", text: Binding(
                            get: { draft.inner.title },
                            set: { draft.inner.title = $0 }
                        ))
                        .focused($focusedField, equals: .title)
                    }

                    // Description
                    fieldSection(label: "Description", field: .description) {
                        TextField("Describe the task", text: Binding(
                            get: { draft.inner.description },
                            set: { draft.inner.description = $0 }
                        ), axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .description)
                    }

                    // Payment
                    fieldSection(label: "Payment ($)", field: .payment) {
                        TextField("Amount", text: Binding(
                            get: { draft.inner.payment.map { String(Int($0)) } ?? "" },
                            set: { draft.inner.payment = Double($0) }
                        ))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .payment)
                    }

                    // Location: City
                    VStack(alignment: .leading, spacing: 6) {
                        Text("City")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        HStack {
                            TextField("City name", text: Binding(
                                get: { draft.inner.locationCity },
                                set: { draft.inner.locationCity = $0 }
                            ))
                            .font(.body)
                            .foregroundStyle(Color.textPrimary)
                            .focused($focusedField, equals: .city)

                            Button {
                                draft.inner.locationCity = "Anywhere"
                                draft.inner.locationState = ""
                            } label: {
                                Text("Anywhere")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(draft.inner.locationCity == "Anywhere" ? .white : Color.brandPurple)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(draft.inner.locationCity == "Anywhere" ? Color.brandPurple : Color.brandPurple.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(14)
                        .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .city ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                        )
                    }

                    // State picker
                    if draft.inner.locationCity != "Anywhere" {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("State")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.textSecondary)

                            Menu {
                                ForEach(Self.usStates, id: \.code) { state in
                                    Button(state.name) { draft.inner.locationState = state.code }
                                }
                            } label: {
                                HStack {
                                    Text(Self.usStates.first(where: { $0.code == draft.inner.locationState })?.name ?? "Select state")
                                        .font(.body)
                                        .foregroundStyle(draft.inner.locationState.isEmpty ? Color.textMuted : Color.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.textTertiary)
                                }
                                .padding(14)
                                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.borderSubtle, lineWidth: 1)
                                )
                            }
                        }

                        // Radius
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Service Radius")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.textSecondary)

                            HStack(spacing: 8) {
                                ForEach(Self.radiusOptions, id: \.self) { miles in
                                    Button {
                                        draft.inner.locationRadiusMiles = miles
                                    } label: {
                                        Text("\(miles) mi")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(draft.inner.locationRadiusMiles == miles ? .white : Color.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(draft.inner.locationRadiusMiles == miles ? Color.brandPurple : Color.surfaceElevated)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(draft.inner.locationRadiusMiles == miles ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Duration with unit picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Estimated Duration")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        HStack(spacing: 12) {
                            TextField("1", text: $durationValue)
                                .font(.body)
                                .foregroundStyle(Color.textPrimary)
                                .keyboardType(.decimalPad)
                                .frame(width: 70)
                                .padding(14)
                                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .durationVal ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                                )
                                .focused($focusedField, equals: .durationVal)

                            HStack(spacing: 0) {
                                ForEach(DurationUnit.allCases, id: \.self) { unit in
                                    Button {
                                        durationUnit = unit
                                    } label: {
                                        Text(unit.rawValue)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(durationUnit == unit ? .white : Color.textPrimary)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(durationUnit == unit ? Color.brandPurple : Color.surfaceElevated)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.borderSubtle, lineWidth: 1)
                            )
                        }
                    }

                    // Requirements
                    fieldSection(label: "Requirements (optional)", field: .requirements) {
                        TextField("Skills or tools needed", text: Binding(
                            get: { draft.inner.requirements },
                            set: { draft.inner.requirements = $0 }
                        ), axis: .vertical)
                        .lineLimit(2...4)
                        .focused($focusedField, equals: .requirements)
                    }

                    // Difficulty badge
                    if !draft.inner.difficulty.isEmpty {
                        HStack {
                            let color: Color = draft.inner.difficulty == "easy" ? .successGreen : draft.inner.difficulty == "medium" ? .warningOrange : .errorRed
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(color)
                            Text("Difficulty: \(draft.inner.difficulty.capitalized)")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                        }
                    }

                    // Post button
                    Button {
                        // Apply duration back to draft
                        draft.inner.duration = durationUnit.format(value: durationValue)
                        dismiss()
                        onPost()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Post Task")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.successGreen, Color.successGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBlack)
            .navigationTitle("Review Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func fieldSection<Content: View>(label: String, field: Field, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            content()
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .padding(14)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == field ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                )
        }
    }
}

/// Wrapper to use @Observable AITaskDraft with @ObservedObject pattern in sheet
class AITaskDraftWrapper: ObservableObject {
    let inner: AITaskDraft
    init(draft: AITaskDraft) { self.inner = draft }
}
