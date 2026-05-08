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
    @State private var locationStreet: String
    @State private var locationCity: String
    @State private var locationState: String
    @State private var locationZip: String
    @State private var durationValue: String
    @State private var durationUnit: DurationUnit
    @State private var deadline: Date?
    @State private var requirements: String
    @State private var useSmartDispatch: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, description, payment, street, city, durationVal, requirements }

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
        _locationStreet = State(initialValue: draft.locationStreet)
        _locationCity = State(initialValue: draft.locationCity)
        _locationState = State(initialValue: draft.locationState)
        _locationZip = State(initialValue: draft.locationZip)
        _requirements = State(initialValue: draft.requirements)
        let parsed = DurationUnit.parse(draft.duration)
        _durationValue = State(initialValue: parsed.value)
        _durationUnit = State(initialValue: parsed.unit)
        if !draft.deadline.isEmpty {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            _deadline = State(initialValue: formatter.date(from: draft.deadline) ?? ISO8601DateFormatter().date(from: draft.deadline))
        } else {
            _deadline = State(initialValue: nil)
        }
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

                    // Street Address
                    fieldSection(label: "Street Address", field: .street) {
                        TextField("123 Main St", text: $locationStreet)
                            .focused($focusedField, equals: .street)
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

                        // ZIP Code
                        fieldSection(label: "ZIP Code", field: .durationVal) {
                            TextField("e.g. 77001", text: $locationZip)
                                .keyboardType(.numberPad)
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

                    // Deadline
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deadline (optional)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        HStack {
                            if let dl = deadline {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { dl },
                                        set: { deadline = $0 }
                                    ),
                                    in: Date()...,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .tint(.brandPurple)

                                Spacer()

                                Button {
                                    deadline = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.textMuted)
                                }
                            } else {
                                Button {
                                    deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 14))
                                        Text("Set deadline")
                                            .font(.subheadline.weight(.medium))
                                    }
                                    .foregroundStyle(Color.brandPurple)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.brandPurple.opacity(0.15))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.brandPurple.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
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

                    // Smart Dispatch toggle
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.successGreen, Color.brandPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 36, height: 36)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Smart Dispatch")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("NEW")
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(0.8)
                                    .foregroundStyle(Color.successGreen)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.successGreen.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            Text("Auto-match the best nearby hustler instantly")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.4))
                        }

                        Spacer()

                        Toggle("", isOn: $useSmartDispatch)
                            .tint(Color.successGreen)
                            .labelsHidden()
                    }
                    .padding(14)
                    .background(Color.surfaceElevated)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(useSmartDispatch ? Color.successGreen.opacity(0.4) : Color.borderSubtle, lineWidth: 1)
                    )

                    // Fee breakdown — transparency before payment
                    feeBreakdownCard

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

    /// Payment details card — shows the poster only what they are charged.
    private var feeBreakdownCard: some View {
        let amount = Double(payment) ?? 0
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandPurple)
                Text("Payment Details")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("$\(String(format: "%.2f", amount))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moneyGreen)
            }

            Divider().background(Color.white.opacity(0.08))

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.infoBlue)
                    .padding(.top, 1)
                Text("Held in secure escrow. Released only after you approve the completed work.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.successGreen)
                    .padding(.top, 1)
                Text("No hidden charges. You pay exactly what you set.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.brandPurple.opacity(0.2), lineWidth: 1)
            }
        )
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
        draft.locationStreet = locationStreet.trimmingCharacters(in: .whitespaces)
        draft.locationCity = locationCity
        draft.locationState = locationState
        draft.locationZip = locationZip.trimmingCharacters(in: .whitespaces)
        draft.duration = durationUnit.format(value: durationValue)
        draft.requirements = requirements.trimmingCharacters(in: .whitespaces)
        draft.fulfillmentMode = useSmartDispatch ? "smart_dispatch" : "broadcast"
        if let dl = deadline {
            draft.deadline = ISO8601DateFormatter().string(from: dl)
        } else {
            draft.deadline = ""
        }
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
