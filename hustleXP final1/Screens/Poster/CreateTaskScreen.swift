//
//  CreateTaskScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Premium task creation with elegant form and animations
//
//  v3.0.0: Refactored — logic extracted to CreateTaskViewModel
//

import SwiftUI
import StripePaymentSheet

struct CreateTaskScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    @State private var viewModel = CreateTaskViewModel()
    @FocusState private var focusedField: Field?

    private enum Field {
        case title, description, payment, city, durationVal
    }

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

    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                backgroundLayer

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: isCompact ? 18 : 24) {
                        titleField(isCompact: isCompact)
                        descriptionField(isCompact: isCompact)
                        aiPricingSection(isCompact: isCompact)

                        if !viewModel.useAIPricing {
                            paymentSection(isCompact: isCompact)
                        }

                        locationField(isCompact: isCompact)
                        durationSection(isCompact: isCompact)
                        tierSection(isCompact: isCompact)

                        if viewModel.isValid {
                            classificationCard(isCompact: isCompact)
                            summarySection(isCompact: isCompact)
                        }

                        Spacer(minLength: isCompact ? 100 : 120)
                    }
                    .padding(.horizontal, isCompact ? 16 : 20)
                    .padding(.top, isCompact ? 4 : 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationTitle("Post a Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .onAppear {
            viewModel.router = router
            viewModel.dataService = dataService
            withAnimation(.easeOut(duration: 0.5)) {
                viewModel.showContent = true
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showAIPricingModal },
            set: { viewModel.showAIPricingModal = $0 }
        )) {
            if let suggestion = viewModel.aiSuggestion {
                AIPricingSuggestionModal(
                    suggestion: suggestion,
                    onAccept: { viewModel.acceptAISuggestion() },
                    onEdit: { viewModel.editAISuggestion() }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.10)
                .ignoresSafeArea()

            // Subtle gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brandPurple.opacity(0.12), Color.clear],
                        center: .center, startRadius: 0, endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: -120, y: -200)
                .blur(radius: 60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.pink.opacity(0.08), Color.clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 400)
                .blur(radius: 80)
        }
        .ignoresSafeArea()
    }

    // MARK: - Modern Glass Input Helper

    private func glassInput<Content: View>(
        label: String,
        required: Bool = true,
        icon: String,
        isFocused: Bool,
        error: String? = nil,
        delay: Double = 0,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                if required {
                    Circle()
                        .fill(Color.brandPurple)
                        .frame(width: 5, height: 5)
                }
            }

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(
                        isFocused
                            ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white.opacity(0.3))
                    )
                    .frame(width: 20)

                content()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isFocused ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isFocused
                            ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom),
                        lineWidth: isFocused ? 1.5 : 0.5
                    )
            )

            if let error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(error)
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.errorRed)
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 15)
        .animation(.easeOut(duration: 0.4).delay(delay), value: viewModel.showContent)
    }

    // MARK: - Title Field

    private func titleField(isCompact: Bool) -> some View {
        glassInput(label: "Task Title", icon: "pencil.line", isFocused: focusedField == .title, error: viewModel.errors["title"], delay: 0) {
            TextField("What needs to be done?", text: Binding(
                get: { viewModel.title },
                set: { viewModel.title = $0 }
            ))
            .font(.system(size: 15))
            .foregroundStyle(Color.white)
            .focused($focusedField, equals: .title)
            .onChange(of: viewModel.title) { _, newValue in
                viewModel.validateTitle(newValue)
            }
        }
    }

    // MARK: - Description Field

    private func descriptionField(isCompact: Bool) -> some View {
        glassInput(label: "Description", icon: "text.alignleft", isFocused: focusedField == .description, delay: 0.05) {
            TextField("Describe the task in detail", text: Binding(
                get: { viewModel.description },
                set: { viewModel.description = $0 }
            ), axis: .vertical)
            .font(.system(size: 15))
            .foregroundStyle(Color.white)
            .lineLimit(3...6)
            .focused($focusedField, equals: .description)
        }
        .onChange(of: viewModel.description) { _, _ in
            viewModel.updateTemplateFromCategory()
        }
    }

    // MARK: - Payment Section

    private func paymentSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("Payment")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                Circle().fill(Color.brandPurple).frame(width: 5, height: 5)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text("$")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.moneyGreen, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                        )

                    TextField("0", text: Binding(
                        get: { viewModel.payment },
                        set: { viewModel.payment = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: 120)
                    .focused($focusedField, equals: .payment)

                    Spacer()
                }

                // Quick amounts — pill style
                HStack(spacing: 8) {
                    ForEach([25, 50, 100, 200], id: \.self) { amount in
                        let isSelected = viewModel.payment == "\(amount)"
                        Button {
                            viewModel.payment = "\(amount)"
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text("$\(amount)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : Color.white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isSelected
                                              ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                              : AnyShapeStyle(Color.white.opacity(0.06)))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(focusedField == .payment ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        focusedField == .payment
                            ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom),
                        lineWidth: focusedField == .payment ? 1.5 : 0.5
                    )
            )

            if let error = viewModel.errors["payment"] {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 11))
                    Text(error).font(.system(size: 11))
                }
                .foregroundStyle(Color.errorRed)
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 15)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: viewModel.showContent)
    }

    // MARK: - Location Field

    private func locationField(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text("Location")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                Circle().fill(Color.brandPurple).frame(width: 5, height: 5)
            }

            // City input with Anywhere pill
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(
                        focusedField == .city
                            ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white.opacity(0.3))
                    )

                TextField("City name", text: Binding(
                    get: { viewModel.locationCity },
                    set: { viewModel.locationCity = $0 }
                ))
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
                .focused($focusedField, equals: .city)

                Button {
                    viewModel.locationCity = "Anywhere"
                    viewModel.locationState = ""
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text("Anywhere")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(
                                viewModel.locationCity == "Anywhere"
                                    ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color.white.opacity(0.1))
                            )
                        )
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(focusedField == .city ? 0.08 : 0.05)))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        focusedField == .city
                            ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom),
                        lineWidth: focusedField == .city ? 1.5 : 0.5
                    )
            )

            if viewModel.locationCity != "Anywhere" && !viewModel.locationCity.isEmpty {
                // State picker
                Menu {
                    ForEach(Self.usStates, id: \.code) { state in
                        Button(state.name) { viewModel.locationState = state.code }
                    }
                } label: {
                    HStack {
                        Text(Self.usStates.first(where: { $0.code == viewModel.locationState })?.name ?? "Select state")
                            .font(.system(size: 15))
                            .foregroundStyle(viewModel.locationState.isEmpty ? Color.white.opacity(0.3) : Color.white)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
                }

                // Radius — gradient pills
                VStack(alignment: .leading, spacing: 6) {
                    Text("Service Radius")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.4))

                    HStack(spacing: 8) {
                        ForEach(Self.radiusOptions, id: \.self) { miles in
                            let isSelected = viewModel.locationRadiusMiles == miles
                            Button {
                                viewModel.locationRadiusMiles = miles
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Text("\(miles) mi")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isSelected
                                                  ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                                                  : AnyShapeStyle(Color.white.opacity(0.05)))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 15)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: viewModel.showContent)
    }

    // MARK: - Duration Section

    private func durationSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated Duration")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.6))

            HStack(spacing: 12) {
                TextField("1", text: Binding(
                    get: { viewModel.durationValue },
                    set: { viewModel.durationValue = $0 }
                ))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(focusedField == .durationVal ? 0.08 : 0.05)))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            focusedField == .durationVal
                                ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom),
                            lineWidth: focusedField == .durationVal ? 1.5 : 0.5
                        )
                )
                .focused($focusedField, equals: .durationVal)

                // Segmented unit picker with gradient
                HStack(spacing: 0) {
                    ForEach(DurationUnit.allCases, id: \.self) { unit in
                        let isSelected = viewModel.durationUnit == unit
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.durationUnit = unit
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text(unit.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(isSelected ? 1 : 0.4))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    isSelected
                                        ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                                        : AnyShapeStyle(Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 15)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: viewModel.showContent)
    }

    // MARK: - Tier Section

    private func tierSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Minimum Hustler Tier")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                Text("Higher tiers = more verified hustlers")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.3))
            }

            HStack(spacing: 8) {
                ForEach([TrustTier.rookie, .verified, .trusted], id: \.self) { tier in
                    let isSelected = viewModel.requiredTier == tier
                    let tierColor: Color = tier == .rookie ? .white.opacity(0.5) : tier == .verified ? .brandPurple : .infoBlue

                    Button {
                        viewModel.selectTier(tier)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 13))
                                .foregroundStyle(isSelected ? tierColor : Color.white.opacity(0.2))

                            Text(tier.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.white.opacity(0.4))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? tierColor.opacity(0.15) : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? tierColor.opacity(0.4) : Color.white.opacity(0.06), lineWidth: isSelected ? 1 : 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 15)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: viewModel.showContent)
    }

    // MARK: - AI Pricing Section (v1.8.0)

    private func aiPricingSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 12) {
            AIPricingToggle(isEnabled: Binding(
                get: { viewModel.useAIPricing },
                set: { viewModel.useAIPricing = $0 }
            ), isCompact: isCompact)
                .onChange(of: viewModel.useAIPricing) { _, newValue in
                    viewModel.handleAIPricingToggle(newValue)
                }

            if viewModel.useAIPricing {
                HStack(spacing: isCompact ? 6 : 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundStyle(Color.aiPurple)

                    Text("Scoper AI will suggest an optimal price based on your task details")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(isCompact ? 10 : 12)
                .background(Color.aiPurple.opacity(0.1))
                .cornerRadius(isCompact ? 8 : 10)
            }
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .offset(y: viewModel.showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(0.08), value: viewModel.showContent)
    }

    // MARK: - AI Classification Card

    private func classificationCard(isCompact: Bool) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 11))
                    .foregroundStyle(
                        LinearGradient(colors: [.brandPurple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("CLASSIFICATION")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Color.white.opacity(0.4))
                Spacer()
            }

            HStack(spacing: 16) {
                // Template
                VStack(spacing: 4) {
                    Image(systemName: templateIcon(viewModel.templateSlug))
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundStyle(Color.brandPurple)
                    Text(templateDisplayName(viewModel.templateSlug))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    Text("Template")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity)

                // Risk
                let riskColor: Color = viewModel.riskLevel == "LOW" ? .successGreen : viewModel.riskLevel == "MEDIUM" ? .warningOrange : .errorRed
                VStack(spacing: 4) {
                    Image(systemName: viewModel.riskLevel == "LOW" ? "shield.checkered" : viewModel.riskLevel == "MEDIUM" ? "shield.lefthalf.filled" : "exclamationmark.shield.fill")
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundStyle(riskColor)
                    Text(viewModel.riskLevel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(riskColor)
                    Text("Risk")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity)

                // Category
                let cat = viewModel.determineCategory()
                VStack(spacing: 4) {
                    Image(systemName: cat.icon)
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundStyle(Color.infoBlue)
                    Text(cat.displayName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("Category")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity)
            }

            // Template note
            if let note = templateNote(viewModel.templateSlug) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.infoBlue)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(isCompact ? 8 : 10)
                .background(Color.infoBlue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [.brandPurple.opacity(0.3), .pink.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 0.5
                )
        )
        .opacity(viewModel.showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.28), value: viewModel.showContent)
    }

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
        case "care": return "Requires background-checked hustler (Trusted tier+). Manual payment release."
        case "in_home": return "48-hour review period before payment auto-releases."
        case "content_creator": return "Content release agreement required."
        case "specialized_licensed": return "Hustler must verify professional license."
        case "wildcard_bizarre": return "Mutual consent checklist required."
        default: return nil
        }
    }

    // MARK: - Summary Section

    private func summarySection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(colors: [.successGreen, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                Text("Task Summary")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
            }

            VStack(spacing: 10) {
                modernSummaryRow(icon: "briefcase.fill", label: "Task", value: viewModel.title, color: .brandPurple)

                HStack {
                    modernSummaryRow(
                        icon: "dollarsign.circle.fill",
                        label: "Payment",
                        value: viewModel.useAIPricing ? "AI will suggest" : "$\(viewModel.payment)",
                        color: viewModel.useAIPricing ? .pink : .moneyGreen
                    )
                    if viewModel.taskWasAIPriced {
                        AIPricedBadge()
                    }
                }

                modernSummaryRow(icon: "mappin.circle.fill", label: "Location", value: viewModel.locationDisplay, color: .pink)
                modernSummaryRow(icon: "clock.fill", label: "Duration", value: viewModel.formattedDuration.isEmpty ? "Not set" : viewModel.formattedDuration, color: .brandPurple)
                modernSummaryRow(icon: "shield.checkered", label: "Min. Tier", value: viewModel.requiredTier.name, color: .infoBlue)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(colors: [.successGreen.opacity(0.3), .brandPurple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 0.5
                    )
            )
        }
        .opacity(viewModel.showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: viewModel.showContent)
    }

    private func modernSummaryRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 18)

            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.5))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(colors: [Color.clear, Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 1)

            Button(action: {
                focusedField = nil
                viewModel.postTask()
            }) {
                HStack(spacing: 10) {
                    if viewModel.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Post Task")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            viewModel.isValid
                                ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: viewModel.isValid ? Color.brandPurple.opacity(0.4) : .clear, radius: 16, y: 6)
            }
            .accessibilityLabel("Post task")
            .disabled(!viewModel.isValid || viewModel.isSubmitting)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(red: 0.06, green: 0.06, blue: 0.10).opacity(0.95))
        }
    }
}

// MARK: - Premium Supporting Views

struct PremiumQuickAmountButton: View {
    let amount: Int
    @Binding var currentAmount: String
    var isCompact: Bool = false

    private var isSelected: Bool {
        currentAmount == "\(amount)"
    }

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            currentAmount = "\(amount)"
        }) {
            Text("$\(amount)")
                .font(isCompact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .padding(.horizontal, isCompact ? 10 : 14)
                .padding(.vertical, isCompact ? 6 : 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.brandPurple : Color.surfaceSecondary)
                )
        }
    }
}

struct PremiumDurationChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isCompact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .padding(.horizontal, isCompact ? 10 : 14)
                .padding(.vertical, isCompact ? 8 : 10)
                .background(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                        .fill(isSelected ? Color.brandPurple : Color.surfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

struct PremiumTierChip: View {
    let tier: TrustTier
    let isSelected: Bool
    var isCompact: Bool = false
    let action: () -> Void

    private var tierColor: Color {
        switch tier {
        case .unranked, .rookie: return Color.textSecondary
        case .verified: return Color.brandPurple
        case .trusted: return Color.infoBlue
        case .elite: return Color.moneyGreen
        case .master: return Color.yellow
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 4 : 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundStyle(isSelected ? tierColor : Color.textMuted)

                Text(tier.name)
                    .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
            }
            .padding(.horizontal, isCompact ? 10 : 14)
            .padding(.vertical, isCompact ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                    .fill(isSelected ? tierColor.opacity(0.15) : Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 10 : 12)
                    .stroke(isSelected ? tierColor.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

struct PremiumSummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundStyle(color)
                .frame(width: 20)

            Text(label)
                .font(isCompact ? .footnote : .subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(isCompact ? .footnote.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Legacy Supporting Views (kept for compatibility)

struct QuickAmountButton: View {
    let amount: Int
    @Binding var currentAmount: String

    var body: some View {
        Button(action: { currentAmount = "\(amount)" }) {
            Text("$\(amount)")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(currentAmount == "\(amount)" ? Color.brandPurple : Color.surfaceSecondary)
                .foregroundStyle(currentAmount == "\(amount)" ? .white : Color.textPrimary)
                .cornerRadius(16)
        }
    }
}

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HXText(title, style: .subheadline, color: isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.brandPurple : Color.surfaceElevated)
                .cornerRadius(20)
        }
    }
}

struct TierChip: View {
    let tier: TrustTier
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                Text(tier.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandPurple.opacity(0.1) : Color.surfaceElevated)
            .foregroundStyle(isSelected ? Color.brandPurple : Color.textPrimary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.brandPurple : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            HXText(label, style: .subheadline, color: .textSecondary)
            Spacer()
            HXText(value, style: .subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        CreateTaskScreen()
    }
    .environment(Router())
    .environment(LiveDataService.shared)
}
