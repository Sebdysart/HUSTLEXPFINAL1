//
//  CreateTaskScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//  Premium glassmorphism task creation — fintech + AI dashboard aesthetic
//
//  v4.0.0: Full redesign — frosted glass cards, gradient depth, micro-interactions
//

import SwiftUI
import StripePaymentSheet

struct CreateTaskScreen: View {
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    @State private var viewModel = CreateTaskViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, description, payment, city, durationVal
    }

    private static let radiusOptions = [25, 50, 75, 100]
    private static let usStates: [(code: String, name: String)] = [
        ("AL","Alabama"),("AK","Alaska"),("AZ","Arizona"),("AR","Arkansas"),
        ("CA","California"),("CO","Colorado"),("CT","Connecticut"),("DE","Delaware"),
        ("FL","Florida"),("GA","Georgia"),("HI","Hawaii"),("ID","Idaho"),
        ("IL","Illinois"),("IN","Indiana"),("IA","Iowa"),("KS","Kansas"),
        ("KY","Kentucky"),("LA","Louisiana"),("ME","Maine"),("MD","Maryland"),
        ("MA","Massachusetts"),("MI","Michigan"),("MN","Minnesota"),("MS","Mississippi"),
        ("MO","Missouri"),("MT","Montana"),("NE","Nebraska"),("NV","Nevada"),
        ("NH","New Hampshire"),("NJ","New Jersey"),("NM","New Mexico"),("NY","New York"),
        ("NC","North Carolina"),("ND","North Dakota"),("OH","Ohio"),("OK","Oklahoma"),
        ("OR","Oregon"),("PA","Pennsylvania"),("RI","Rhode Island"),("SC","South Carolina"),
        ("SD","South Dakota"),("TN","Tennessee"),("TX","Texas"),("UT","Utah"),
        ("VT","Vermont"),("VA","Virginia"),("WA","Washington"),("WV","West Virginia"),
        ("WI","Wisconsin"),("WY","Wyoming"),("DC","Washington D.C."),
    ]

    var body: some View {
        ZStack {
            // Deep gradient mesh background
            meshBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // 1. Title & Description — Primary Focus
                    taskInfoCard

                    // 2. Budget — Highlighted
                    if !viewModel.useAIPricing {
                        budgetCard
                    }

                    // AI Pricing toggle
                    aiPricingToggle

                    // 3. Location + Duration — Inline
                    locationDurationCard

                    // 4. Tier Selection — Interactive pills
                    tierCard

                    // 5. Classification — Status dashboard
                    if viewModel.isValid {
                        classificationDashboard
                        summaryCard
                    }

                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)

            // Floating CTA
            VStack {
                Spacer()
                floatingCTA
            }
        }
        .navigationTitle("Create Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.router = router
            viewModel.dataService = dataService
            withAnimation(.easeOut(duration: 0.5)) { viewModel.showContent = true }
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

    // =========================================================================
    // MARK: - Mesh Background
    // =========================================================================

    private var meshBackground: some View {
        Color(red: 0.04, green: 0.04, blue: 0.08)
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.brandPurple.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: 300))
                        .frame(width: 600, height: 600)
                        .offset(x: -100, y: -250)
                        .blur(radius: 80)

                    Circle()
                        .fill(RadialGradient(colors: [Color.pink.opacity(0.08), .clear], center: .center, startRadius: 0, endRadius: 250))
                        .frame(width: 500, height: 500)
                        .offset(x: 180, y: 350)
                        .blur(radius: 100)

                    Circle()
                        .fill(RadialGradient(colors: [Color.blue.opacity(0.06), .clear], center: .center, startRadius: 0, endRadius: 200))
                        .frame(width: 400, height: 400)
                        .offset(x: -150, y: 500)
                        .blur(radius: 90)
                }
                .ignoresSafeArea()
            )
    }

    // =========================================================================
    // MARK: - Glass Card Helper
    // =========================================================================

    private func glassCard<Content: View>(
        glowColor: Color = .brandPurple,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [glowColor.opacity(0.25), Color.white.opacity(0.06), glowColor.opacity(0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: glowColor.opacity(0.08), radius: 20, y: 8)
    }

    // =========================================================================
    // MARK: - 1. Task Info Card (Title + Description)
    // =========================================================================

    private var taskInfoCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 16) {
                // Section header
                sectionHeader(icon: "sparkles", title: "TASK DETAILS", color: .brandPurple)

                // Title
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Task Title", required: true)

                    TextField("What needs to be done?", text: Binding(get: { viewModel.title }, set: { viewModel.title = $0 }))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(fieldBg(focused: focusedField == .title))
                        .overlay(fieldBorder(focused: focusedField == .title))
                        .focused($focusedField, equals: .title)
                        .onChange(of: viewModel.title) { _, v in viewModel.validateTitle(v) }

                    if let err = viewModel.errors["title"] {
                        errorLabel(err)
                    }
                }

                // Description
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Description", required: true)

                    TextField("Describe the task in detail...", text: Binding(get: { viewModel.description }, set: { viewModel.description = $0 }), axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .lineLimit(3...8)
                        .padding(14)
                        .background(fieldBg(focused: focusedField == .description))
                        .overlay(fieldBorder(focused: focusedField == .description))
                        .focused($focusedField, equals: .description)

                    if !viewModel.description.isEmpty && viewModel.description.count < 10 {
                        Text("\(10 - viewModel.description.count) more characters needed")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.warningOrange.opacity(0.7))
                    }
                }
                .onChange(of: viewModel.description) { _, _ in viewModel.updateTemplateFromCategory() }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0)
    }

    // =========================================================================
    // MARK: - 2. Budget Card (BIG, highlighted)
    // =========================================================================

    private var budgetCard: some View {
        glassCard(glowColor: .moneyGreen) {
            VStack(spacing: 16) {
                sectionHeader(icon: "dollarsign.circle.fill", title: "BUDGET", color: .moneyGreen)

                // Large price display
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.moneyGreen, .green.opacity(0.6)], startPoint: .top, endPoint: .bottom))

                    TextField("0", text: Binding(get: { viewModel.payment }, set: { viewModel.payment = $0 }))
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundStyle(.white)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 160)
                        .focused($focusedField, equals: .payment)

                    Spacer()

                    // AI price badge
                    if viewModel.taskWasAIPriced {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                            Text("AI")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(LinearGradient(colors: [.brandPurple, .pink], startPoint: .leading, endPoint: .trailing)))
                    }
                }

                // Quick amount pills
                HStack(spacing: 8) {
                    ForEach([25, 50, 100, 200, 500], id: \.self) { amount in
                        quickAmountPill(amount)
                    }
                }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.08)
    }

    private func quickAmountPill(_ amount: Int) -> some View {
        let isSelected = viewModel.payment == "\(amount)"
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { viewModel.payment = "\(amount)" }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text("$\(amount)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(isSelected ? 1 : 0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(
                        isSelected
                            ? AnyShapeStyle(LinearGradient(colors: [.moneyGreen, .green.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.white.opacity(0.06))
                    )
                )
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.white.opacity(0.06), lineWidth: 0.5))
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // =========================================================================
    // MARK: - AI Pricing Toggle
    // =========================================================================

    private var aiPricingToggle: some View {
        glassCard(glowColor: .pink) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.brandPurple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Price Suggestion")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Let AI analyze and suggest the best price")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Toggle("", isOn: Binding(get: { viewModel.useAIPricing }, set: { viewModel.useAIPricing = $0 }))
                    .tint(Color.brandPurple)
                    .labelsHidden()
                    .onChange(of: viewModel.useAIPricing) { _, v in viewModel.handleAIPricingToggle(v) }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.05)
    }

    // =========================================================================
    // MARK: - 3. Location + Duration Card
    // =========================================================================

    private var locationDurationCard: some View {
        glassCard(glowColor: .pink) {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(icon: "mappin.and.ellipse", title: "LOCATION & DURATION", color: .pink)

                // City
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("City", required: true)

                    HStack(spacing: 10) {
                        TextField("Enter city", text: Binding(get: { viewModel.locationCity }, set: { viewModel.locationCity = $0 }))
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                            .focused($focusedField, equals: .city)

                        Button {
                            viewModel.locationCity = "Anywhere"; viewModel.locationState = ""
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text("Anywhere")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(
                                        viewModel.locationCity == "Anywhere"
                                            ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink], startPoint: .leading, endPoint: .trailing))
                                            : AnyShapeStyle(Color.white.opacity(0.08))
                                    )
                                )
                        }
                    }
                    .padding(12)
                    .background(fieldBg(focused: focusedField == .city))
                    .overlay(fieldBorder(focused: focusedField == .city))
                }

                // State + Radius (conditional)
                if viewModel.locationCity != "Anywhere" && !viewModel.locationCity.isEmpty {
                    // State
                    Menu {
                        ForEach(Self.usStates, id: \.code) { s in
                            Button(s.name) { viewModel.locationState = s.code }
                        }
                    } label: {
                        HStack {
                            Text(Self.usStates.first { $0.code == viewModel.locationState }?.name ?? "Select state")
                                .font(.system(size: 14))
                                .foregroundStyle(viewModel.locationState.isEmpty ? .white.opacity(0.3) : .white)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .padding(12)
                        .background(fieldBg(focused: false))
                        .overlay(fieldBorder(focused: false))
                    }

                    // Radius pills
                    HStack(spacing: 8) {
                        ForEach(Self.radiusOptions, id: \.self) { mi in
                            let sel = viewModel.locationRadiusMiles == mi
                            Button {
                                viewModel.locationRadiusMiles = mi
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Text("\(mi) mi")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(sel ? 1 : 0.4))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(sel
                                                  ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                                                  : AnyShapeStyle(Color.white.opacity(0.04)))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Duration
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Duration")

                    HStack(spacing: 10) {
                        TextField("1", text: Binding(get: { viewModel.durationValue }, set: { viewModel.durationValue = $0 }))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60, height: 44)
                            .background(fieldBg(focused: focusedField == .durationVal))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(fieldBorder(focused: focusedField == .durationVal))
                            .focused($focusedField, equals: .durationVal)

                        HStack(spacing: 0) {
                            ForEach(DurationUnit.allCases, id: \.self) { unit in
                                let sel = viewModel.durationUnit == unit
                                Button {
                                    withAnimation(.spring(response: 0.25)) { viewModel.durationUnit = unit }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Text(unit.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white.opacity(sel ? 1 : 0.35))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            sel
                                                ? AnyShapeStyle(LinearGradient(colors: [.brandPurple, .pink.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                                                : AnyShapeStyle(Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(height: 44)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
                    }
                }

                // Deadline
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Deadline (optional)")

                    HStack {
                        if let deadline = viewModel.deadline {
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { deadline },
                                    set: { viewModel.deadline = $0 }
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
                                viewModel.deadline = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.textMuted)
                            }
                        } else {
                            Button {
                                viewModel.deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())
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
                                .background(Color.brandPurple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.brandPurple.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.12)
    }

    // =========================================================================
    // MARK: - 4. Tier Selection
    // =========================================================================

    private var tierCard: some View {
        glassCard(glowColor: .infoBlue) {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(icon: "shield.checkered", title: "HUSTLER TIER", color: .infoBlue)

                HStack(spacing: 10) {
                    ForEach([TrustTier.rookie, .verified, .trusted], id: \.self) { tier in
                        tierPill(tier)
                    }
                }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.18)
    }

    private func tierPill(_ tier: TrustTier) -> some View {
        let sel = viewModel.requiredTier == tier

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { viewModel.selectTier(tier) }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tier.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        sel
                            ? AnyShapeStyle(LinearGradient(colors: tier.gradientColors, startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color.white.opacity(0.25))
                    )

                Text(tier.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(sel ? 1 : 0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(sel
                    ? AnyShapeStyle(LinearGradient(colors: [tier.gradientColors[0].opacity(0.25), tier.gradientColors[1].opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(Color.white.opacity(0.04)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14).stroke(
                    sel
                        ? LinearGradient(colors: tier.gradientColors.map { $0.opacity(0.5) }, startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom),
                    lineWidth: sel ? 1 : 0.5
                )
            )
            .shadow(color: sel ? tier.color.opacity(0.3) : .clear, radius: 8, y: 2)
            .scaleEffect(sel ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // =========================================================================
    // MARK: - 5. Classification Dashboard
    // =========================================================================

    private var classificationDashboard: some View {
        glassCard(glowColor: .brandPurple) {
            VStack(spacing: 14) {
                sectionHeader(icon: "cpu", title: "CLASSIFICATION", color: .brandPurple)

                HStack(spacing: 0) {
                    classChip(icon: templateIcon(viewModel.templateSlug), label: templateDisplayName(viewModel.templateSlug), sub: "Template", color: .brandPurple)
                    classChip(icon: riskIcon(viewModel.riskLevel), label: viewModel.riskLevel, sub: "Risk", color: riskColor(viewModel.riskLevel))
                    classChip(icon: viewModel.determineCategory().icon, label: viewModel.determineCategory().displayName, sub: "Category", color: .infoBlue)
                }

                if let note = templateNote(viewModel.templateSlug) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill").font(.system(size: 11)).foregroundStyle(Color.infoBlue)
                        Text(note).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.infoBlue.opacity(0.08)))
                }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.22)
    }

    private func classChip(icon: String, label: String, sub: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .top, endPoint: .bottom))
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(sub)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
    }

    // =========================================================================
    // MARK: - 6. Summary Card
    // =========================================================================

    private var summaryCard: some View {
        glassCard(glowColor: .successGreen) {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(icon: "checkmark.seal.fill", title: "SUMMARY", color: .successGreen)

                VStack(spacing: 8) {
                    summaryRow(icon: "briefcase.fill", label: "Task", value: viewModel.title, color: .brandPurple)
                    Divider().background(Color.white.opacity(0.06))
                    summaryRow(icon: "dollarsign.circle.fill", label: "Payment", value: viewModel.useAIPricing ? "AI Suggested" : "$\(viewModel.payment)", color: .moneyGreen)
                    Divider().background(Color.white.opacity(0.06))
                    summaryRow(icon: "mappin.circle.fill", label: "Location", value: viewModel.locationDisplay, color: .pink)
                    Divider().background(Color.white.opacity(0.06))
                    summaryRow(icon: "clock.fill", label: "Duration", value: viewModel.formattedDuration.isEmpty ? "—" : viewModel.formattedDuration, color: .brandPurple)
                    Divider().background(Color.white.opacity(0.06))
                    summaryRow(icon: "shield.fill", label: "Tier", value: viewModel.requiredTier.name, color: .infoBlue)
                }
            }
        }
        .staggerIn(show: viewModel.showContent, delay: 0.26)
    }

    private func summaryRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                .frame(width: 18)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .padding(.vertical, 2)
    }

    // =========================================================================
    // MARK: - 7. Floating CTA
    // =========================================================================

    private var floatingCTA: some View {
        Button {
            focusedField = nil
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewModel.postTask()
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Post Task")
                        .font(.system(size: 17, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Capsule().fill(
                    viewModel.isValid
                        ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                )
            )
            .shadow(color: viewModel.isValid ? .brandPurple.opacity(0.5) : .clear, radius: 20, y: 8)
            .scaleEffect(viewModel.isSubmitting ? 0.97 : 1.0)
        }
        .disabled(!viewModel.isValid || viewModel.isSubmitting)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .animation(.spring(response: 0.3), value: viewModel.isValid)
    }

    // =========================================================================
    // MARK: - Shared Components
    // =========================================================================

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(title)
                .font(.system(size: 13, weight: .heavy))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
        }
    }

    private func fieldLabel(_ text: String, required: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
            if required {
                Circle().fill(Color.brandPurple).frame(width: 4, height: 4)
            }
        }
    }

    private func fieldBg(focused: Bool) -> some ShapeStyle {
        Color.white.opacity(focused ? 0.07 : 0.04)
    }

    private func fieldBorder(focused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                focused
                    ? LinearGradient(colors: [.brandPurple, .pink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom),
                lineWidth: focused ? 1 : 0.5
            )
    }

    private func errorLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 10))
            Text(text).font(.system(size: 10))
        }
        .foregroundStyle(.red.opacity(0.8))
    }

    // =========================================================================
    // MARK: - Template Helpers
    // =========================================================================

    private func templateDisplayName(_ s: String) -> String {
        ["standard_physical":"Standard","in_home":"In-Home","care":"Care","content_creator":"Content",
         "event_appearance":"Event","creative_production":"Creative","specialized_licensed":"Licensed","wildcard_bizarre":"Custom"][s] ?? "Standard"
    }

    private func templateIcon(_ s: String) -> String {
        ["standard_physical":"shippingbox.fill","in_home":"house.fill","care":"heart.fill","content_creator":"camera.fill",
         "event_appearance":"person.2.fill","creative_production":"film","specialized_licensed":"checkmark.seal.fill","wildcard_bizarre":"sparkles"][s] ?? "briefcase.fill"
    }

    private func templateNote(_ s: String) -> String? {
        ["care":"Background-checked hustler required (Trusted+). Manual release.",
         "in_home":"48-hour review before auto-release.",
         "content_creator":"Content release agreement required.",
         "specialized_licensed":"Professional license verification needed.",
         "wildcard_bizarre":"Mutual consent checklist required."][s]
    }

    private func riskIcon(_ r: String) -> String {
        r == "LOW" ? "shield.checkered" : r == "MEDIUM" ? "shield.lefthalf.filled" : "exclamationmark.shield.fill"
    }

    private func riskColor(_ r: String) -> Color {
        r == "LOW" ? .successGreen : r == "MEDIUM" ? .warningOrange : .errorRed
    }
}

// MARK: - Stagger Animation Modifier

private extension View {
    func staggerIn(show: Bool, delay: Double) -> some View {
        self
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: show)
    }
}

// MARK: - Legacy Views (kept for AI pricing modal compatibility)

struct PremiumQuickAmountButton: View {
    let amount: Int; @Binding var currentAmount: String; var isCompact: Bool = false
    var body: some View {
        Button { currentAmount = "\(amount)" } label: {
            Text("$\(amount)").font(.caption.weight(.semibold)).foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6).background(Capsule().fill(Color.brandPurple))
        }
    }
}

struct PremiumSummaryRow: View {
    let icon: String; let label: String; let value: String; let color: Color; var isCompact: Bool = false
    var body: some View {
        HStack { Image(systemName: icon).foregroundStyle(color).frame(width: 18); Text(label).font(.caption).foregroundStyle(.white.opacity(0.5)); Spacer(); Text(value).font(.caption.weight(.medium)).foregroundStyle(.white) }
    }
}

struct PremiumDurationChip: View {
    let title: String; let icon: String; let isSelected: Bool; var isCompact: Bool = false; let action: () -> Void
    var body: some View { Button(action: action) { Text(title).font(.caption.weight(.medium)).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 8).background(Capsule().fill(isSelected ? Color.brandPurple : Color.white.opacity(0.06))) } }
}

struct PremiumTierChip: View {
    let tier: TrustTier; let isSelected: Bool; var isCompact: Bool = false; let action: () -> Void
    var body: some View { Button(action: action) { Text(tier.name).font(.caption.weight(.medium)).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 8).background(Capsule().fill(isSelected ? Color.brandPurple : Color.white.opacity(0.06))) } }
}

struct QuickAmountButton: View { let amount: Int; @Binding var currentAmount: String; var body: some View { PremiumQuickAmountButton(amount: amount, currentAmount: $currentAmount) } }
struct DurationChip: View { let title: String; let isSelected: Bool; let action: () -> Void; var body: some View { PremiumDurationChip(title: title, icon: "", isSelected: isSelected, action: action) } }
struct TierChip: View { let tier: TrustTier; let isSelected: Bool; let action: () -> Void; var body: some View { PremiumTierChip(tier: tier, isSelected: isSelected, action: action) } }
struct SummaryRow: View { let label: String; let value: String; var body: some View { HStack { Text(label).font(.caption).foregroundStyle(.white.opacity(0.5)); Spacer(); Text(value).font(.caption.weight(.medium)).foregroundStyle(.white) } } }

#Preview {
    NavigationStack { CreateTaskScreen() }
        .environment(Router())
        .environment(LiveDataService.shared)
}
