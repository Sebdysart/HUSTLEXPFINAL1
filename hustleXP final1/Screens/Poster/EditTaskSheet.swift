//
//  EditTaskSheet.swift
//  hustleXP final1
//
//  Edit an existing task (OPEN state only).
//  Calls task.update on the backend.
//

import SwiftUI

enum DurationUnit: String, CaseIterable {
    case hours = "Hours"
    case days = "Days"
    case months = "Months"

    var suffix: String {
        switch self {
        case .hours: return "hr"
        case .days: return "day"
        case .months: return "month"
        }
    }

    static func parse(_ duration: String) -> (value: String, unit: DurationUnit) {
        let lower = duration.lowercased()
        let numStr = duration.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

        if lower.contains("month") {
            return (numStr.isEmpty ? "1" : numStr, .months)
        } else if lower.contains("day") || lower.contains("week") {
            if lower.contains("week") {
                let weeks = Double(numStr) ?? 1
                return (String(Int(weeks * 7)), .days)
            }
            return (numStr.isEmpty ? "1" : numStr, .days)
        } else {
            return (numStr.isEmpty ? "1" : numStr, .hours)
        }
    }

    func format(value: String) -> String {
        let num = Int(Double(value) ?? 1)
        let s = num != 1 ? "s" : ""
        return "\(num) \(suffix)\(s)"
    }
}

struct EditTaskSheet: View {
    let task: HXTask
    let onSave: (HXTask) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var payment: String
    @State private var locationCity: String
    @State private var locationState: String
    @State private var locationRadiusMiles: Int
    @State private var durationValue: String
    @State private var durationUnit: DurationUnit
    @State private var deadline: Date?
    @State private var requirements: String
    @State private var templateSlug: String
    @State private var riskLevel: String
    @State private var isSaving = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, description, payment, city, duration, requirements }

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

    init(task: HXTask, onSave: @escaping (HXTask) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _payment = State(initialValue: String(Int(task.payment)))
        let parsed = DurationUnit.parse(task.estimatedDuration)
        _durationValue = State(initialValue: parsed.value)
        _durationUnit = State(initialValue: parsed.unit)
        _deadline = State(initialValue: task.deadline)
        _requirements = State(initialValue: "")
        _templateSlug = State(initialValue: task.templateSlug ?? "standard_physical")
        _riskLevel = State(initialValue: task.riskLevel ?? "LOW")

        // Parse location - try "City, ST" format
        let parts = task.location.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count >= 2 {
            // Remove radius info like "(25 mi)" from state
            let statePart = parts[1].components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? parts[1]
            _locationCity = State(initialValue: parts[0])
            _locationState = State(initialValue: statePart.count == 2 ? statePart : "")
        } else if task.location == "Anywhere" {
            _locationCity = State(initialValue: "Anywhere")
            _locationState = State(initialValue: "")
        } else {
            _locationCity = State(initialValue: task.location)
            _locationState = State(initialValue: "")
        }
        _locationRadiusMiles = State(initialValue: 25)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !description.trimmingCharacters(in: .whitespaces).isEmpty
        && (Double(payment) ?? 0) >= 5
        && !locationCity.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var locationDisplay: String {
        if locationCity == "Anywhere" { return "Anywhere" }
        if locationState.isEmpty { return locationCity }
        return "\(locationCity), \(locationState) (\(locationRadiusMiles) mi)"
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
                        TextField("Amount in dollars", text: $payment)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .payment)
                    }

                    // Location: City
                    VStack(alignment: .leading, spacing: 6) {
                        Text("City")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)

                        HStack {
                            TextField("City name or Anywhere", text: $locationCity)
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

                    // Location: State picker (hidden if Anywhere)
                    if locationCity != "Anywhere" {
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

                        // Distance radius
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
                                        .stroke(focusedField == .duration ? Color.brandPurple : Color.borderSubtle, lineWidth: 1)
                                )
                                .focused($focusedField, equals: .duration)

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
                                            .background(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .fill(durationUnit == unit ? Color.brandPurple : Color.surfaceElevated)
                                            )
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

                    // Classification
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "cpu")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandPurple)
                            Text("CLASSIFICATION")
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.5)
                                .foregroundStyle(Color.textMuted)
                            Spacer()
                        }

                        // Template picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Template")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.textSecondary)

                            Menu {
                                ForEach(Self.templateOptions, id: \.slug) { opt in
                                    Button {
                                        templateSlug = opt.slug
                                    } label: {
                                        Label(opt.name, systemImage: opt.icon)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: templateIcon(templateSlug))
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.brandPurple)
                                    Text(templateDisplayName(templateSlug))
                                        .font(.body)
                                        .foregroundStyle(Color.textPrimary)
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

                        // Risk level display
                        HStack(spacing: 12) {
                            Image(systemName: riskIcon(riskLevel))
                                .font(.system(size: 16))
                                .foregroundStyle(riskColor(riskLevel))
                            Text("Risk: \(riskLevel)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(riskColor(riskLevel))
                            Spacer()
                        }
                        .padding(12)
                        .background(riskColor(riskLevel).opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

                        // Template implications
                        if let note = templateNote(templateSlug) {
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

                    fieldSection(label: "Requirements (optional)", field: .requirements) {
                        TextField("Skills or tools needed", text: $requirements, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .requirements)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.errorRed)
                    }

                    Button(action: save) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isValid && !isSaving ? Color.brandPurple : Color.textMuted.opacity(0.5))
                        )
                    }
                    .disabled(!isValid || isSaving)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBlack)
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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

    // MARK: - Template Data

    private static let templateOptions: [(slug: String, name: String, icon: String, defaultRisk: String)] = [
        ("standard_physical", "Standard", "shippingbox.fill", "LOW"),
        ("in_home", "In-Home", "house.fill", "MEDIUM"),
        ("care", "Care", "heart.fill", "HIGH"),
        ("content_creator", "Content", "camera.fill", "MEDIUM"),
        ("event_appearance", "Event", "person.2.fill", "MEDIUM"),
        ("creative_production", "Creative", "film", "MEDIUM"),
        ("specialized_licensed", "Licensed", "checkmark.seal.fill", "MEDIUM"),
        ("wildcard_bizarre", "Custom", "sparkles", "MEDIUM"),
    ]

    private func templateDisplayName(_ s: String) -> String {
        Self.templateOptions.first(where: { $0.slug == s })?.name ?? "Standard"
    }

    private func templateIcon(_ s: String) -> String {
        Self.templateOptions.first(where: { $0.slug == s })?.icon ?? "briefcase.fill"
    }

    private func templateNote(_ s: String) -> String? {
        ["care": "Requires background-checked hustler (Trusted+). Manual payment release.",
         "in_home": "48-hour review period before payment auto-releases.",
         "content_creator": "Content release agreement will be required.",
         "specialized_licensed": "Hustler must verify their professional license.",
         "wildcard_bizarre": "Mutual consent checklist required for both parties."][s]
    }

    private func riskIcon(_ r: String) -> String {
        r == "LOW" ? "shield.checkered" : r == "MEDIUM" ? "shield.lefthalf.filled" : "exclamationmark.shield.fill"
    }

    private func riskColor(_ r: String) -> Color {
        r == "LOW" ? .successGreen : r == "MEDIUM" ? .warningOrange : .errorRed
    }

    private func save() {
        guard isValid else { return }
        focusedField = nil
        isSaving = true
        errorMessage = nil

        Task {
            do {
                let priceCents = Int((Double(payment) ?? 0) * 100)
                let formattedDuration = durationUnit.format(value: durationValue)
                let updatedTask = try await TaskService.shared.updateTask(
                    taskId: task.id,
                    title: title.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces),
                    price: priceCents,
                    location: locationDisplay,
                    estimatedDuration: formattedDuration,
                    requirements: requirements.trimmingCharacters(in: .whitespaces).isEmpty ? nil : requirements,
                    deadline: deadline,
                    templateSlug: templateSlug
                )
                isSaving = false
                onSave(updatedTask)
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    EditTaskSheet(
        task: HXTask(
            id: "1", title: "Test", description: "Test desc",
            payment: 50, location: "Houston, TX", latitude: nil, longitude: nil,
            estimatedDuration: "1 hr", posterId: "p1", posterName: "Me",
            posterRating: 5.0, hustlerId: nil, hustlerName: nil,
            state: .posted, requiredTier: .rookie,
            createdAt: Date(), claimedAt: nil, completedAt: nil
        ),
        onSave: { _ in }
    )
}
