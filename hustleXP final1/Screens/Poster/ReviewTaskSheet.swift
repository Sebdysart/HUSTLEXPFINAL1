//
//  ReviewTaskSheet.swift
//  hustleXP final1
//
//  Review and edit task details before posting.
//  Shown after AI conversation fills the draft.
//

import SwiftUI

struct ReviewTaskSheet: View {
    let draft: AITaskDraft
    let onPost: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var payment: String
    @State private var locationCity: String
    @State private var locationState: String
    @State private var locationRadiusMiles: Int
    @State private var durationValue: String
    @State private var durationUnit: DurationUnit
    @State private var requirements: String
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
        self.draft = draft
        self.onPost = onPost
        _title = State(initialValue: draft.title)
        _description = State(initialValue: draft.description)
        _payment = State(initialValue: draft.payment.map { String(Int($0)) } ?? "")
        _locationCity = State(initialValue: draft.locationCity)
        _locationState = State(initialValue: draft.locationState)
        _locationRadiusMiles = State(initialValue: draft.locationRadiusMiles)
        _requirements = State(initialValue: draft.requirements)
        let parsed = DurationUnit.parse(draft.duration)
        _durationValue = State(initialValue: parsed.value)
        _durationUnit = State(initialValue: parsed.unit)
    }

    private var hasLocation: Bool {
        locationCity == "Anywhere" || (!locationCity.isEmpty && !locationState.isEmpty)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !description.trimmingCharacters(in: .whitespaces).isEmpty
        && (Double(payment) ?? 0) >= 5
        && hasLocation
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    fieldSection(label: "Title", field: .title) {
                        TextField("Task title", text: $title)
                            .focused($focusedField, equals: .title)
                    }

                    fieldSection(label: "Description", field: .description) {
                        TextField("Describe the task", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .description)
                    }

                    fieldSection(label: "Payment ($)", field: .payment) {
                        TextField("Amount", text: $payment)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .payment)
                    }

                    // City
                    VStack(alignment: .leading, spacing: 6) {
                        Text("City")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        HStack {
                            TextField("City name", text: $locationCity)
                                .font(.body)
                                .foregroundStyle(Color.textPrimary)
                                .focused($focusedField, equals: .city)

                            Button {
                                locationCity = "Anywhere"
                                locationState = ""
                            } label: {
                                Text("Anywhere")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(locationCity == "Anywhere" ? .white : Color.brandPurple)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(locationCity == "Anywhere" ? Color.brandPurple : Color.brandPurple.opacity(0.15))
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

                    if locationCity != "Anywhere" {
                        // State
                        VStack(alignment: .leading, spacing: 6) {
                            Text("State")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.textSecondary)

                            Menu {
                                ForEach(Self.usStates, id: \.code) { state in
                                    Button(state.name) { locationState = state.code }
                                }
                            } label: {
                                HStack {
                                    Text(Self.usStates.first(where: { $0.code == locationState })?.name ?? "Select state")
                                        .font(.body)
                                        .foregroundStyle(locationState.isEmpty ? Color.textMuted : Color.textPrimary)
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
                                        locationRadiusMiles = miles
                                    } label: {
                                        Text("\(miles) mi")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(locationRadiusMiles == miles ? .white : Color.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(locationRadiusMiles == miles ? Color.brandPurple : Color.surfaceElevated)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(locationRadiusMiles == miles ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Duration
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
                        TextField("Skills or tools needed", text: $requirements, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .requirements)
                    }

                    // AI Classification Card
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "cpu")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandPurple)
                            Text("AI CLASSIFICATION")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.5)
                                .foregroundStyle(Color.textMuted)
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            // Template
                            VStack(spacing: 4) {
                                Image(systemName: templateIcon(draft.templateSlug))
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.brandPurple)
                                Text(templateDisplayName(draft.templateSlug))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)
                                    .multilineTextAlignment(.center)
                                Text("Template")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.textMuted)
                            }
                            .frame(maxWidth: .infinity)

                            // Difficulty
                            if !draft.difficulty.isEmpty {
                                VStack(spacing: 4) {
                                    let diffColor: Color = draft.difficulty == "easy" ? .successGreen : draft.difficulty == "medium" ? .warningOrange : .errorRed
                                    Image(systemName: draft.difficulty == "easy" ? "gauge.with.dots.needle.0percent" : draft.difficulty == "medium" ? "gauge.with.dots.needle.50percent" : "gauge.with.dots.needle.100percent")
                                        .font(.system(size: 18))
                                        .foregroundStyle(diffColor)
                                    Text(draft.difficulty.capitalized)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(diffColor)
                                    Text("Difficulty")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Color.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                            }

                            // Risk
                            VStack(spacing: 4) {
                                let riskColor: Color = draft.riskLevel == "LOW" ? .successGreen : draft.riskLevel == "MEDIUM" ? .warningOrange : .errorRed
                                Image(systemName: draft.riskLevel == "LOW" ? "shield.checkered" : draft.riskLevel == "MEDIUM" ? "shield.lefthalf.filled" : "exclamationmark.shield.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(riskColor)
                                Text(draft.riskLevel)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(riskColor)
                                Text("Risk")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Template implications
                        if let note = templateNote(draft.templateSlug) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.infoBlue)
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .padding(10)
                            .background(Color.infoBlue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .background(Color.surfaceElevated)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
                    )

                    // Post button
                    Button {
                        applyToDraft()
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

    /// Apply edited values back to the draft before posting
    private func applyToDraft() {
        draft.title = title.trimmingCharacters(in: .whitespaces)
        draft.description = description.trimmingCharacters(in: .whitespaces)
        draft.payment = Double(payment)
        draft.locationCity = locationCity
        draft.locationState = locationState
        draft.locationRadiusMiles = locationRadiusMiles
        draft.duration = durationUnit.format(value: durationValue)
        draft.requirements = requirements.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Template Helpers

    private func templateDisplayName(_ slug: String) -> String {
        switch slug {
        case "standard_physical": return "Standard"
        case "in_home": return "In-Home"
        case "care": return "Care"
        case "content_creator": return "Content"
        case "event_appearance": return "Event"
        case "creative_production": return "Creative"
        case "specialized_licensed": return "Licensed"
        case "wildcard_bizarre": return "Custom"
        default: return "Standard"
        }
    }

    private func templateIcon(_ slug: String) -> String {
        switch slug {
        case "standard_physical": return "shippingbox.fill"
        case "in_home": return "house.fill"
        case "care": return "heart.fill"
        case "content_creator": return "camera.fill"
        case "event_appearance": return "person.2.fill"
        case "creative_production": return "film"
        case "specialized_licensed": return "checkmark.seal.fill"
        case "wildcard_bizarre": return "sparkles"
        default: return "briefcase.fill"
        }
    }

    private func templateNote(_ slug: String) -> String? {
        switch slug {
        case "care": return "Requires background-checked hustler (Trusted tier+). Manual payment release only."
        case "in_home": return "48-hour review period before payment auto-releases."
        case "content_creator": return "Content release agreement will be required."
        case "specialized_licensed": return "Hustler must verify their professional license."
        case "wildcard_bizarre": return "Mutual consent checklist required for both parties."
        default: return nil
        }
    }
}
