//
//  SkillGridSelectionScreen.swift
//  hustleXP final1
//
//  Skill selection backed by the real API catalog (UUIDs throughout)
//

import SwiftUI

struct SkillGridSelectionScreen: View {
    var isSettingsMode: Bool = false

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSkills: Set<String> = []       // API UUIDs
    @State private var skillGroups: [SkillGroup] = []
    @State private var expandedGroup: String? = nil            // group categoryName
    @State private var showLicensePrompt: Bool = false
    @State private var selectedLicenseSkill: APISkill? = nil
    @State private var searchText: String = ""
    @State private var verifiedSkillIds: Set<String> = []     // API UUIDs of license-verified skills
    @State private var isLoading: Bool = false
    @State private var saveError: String? = nil

    private let skillService = SkillService.shared

    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()

            // Ambient gradient orbs
            VStack {
                HStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.brandPurple.opacity(0.15), Color.clear],
                                             center: .center, startRadius: 0, endRadius: 150))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -80)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(RadialGradient(colors: [Color.accentViolet.opacity(0.1), Color.clear],
                                             center: .center, startRadius: 0, endRadius: 120))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 80, y: 100)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                if !isSettingsMode {
                    OnboardingProgressBar(
                        currentStep: OnboardingRoute.skillSelection.stepIndex,
                        totalSteps: OnboardingRoute.totalSteps
                    )
                    .padding(.top, 8)
                }

                header

                searchBar

                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(Color.brandPurple)
                    Spacer()
                } else if skillGroups.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(Color.textMuted)
                        Text("Couldn't load skills")
                            .font(.subheadline)
                            .foregroundStyle(Color.textMuted)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(skillGroups) { group in
                                categorySection(group)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }

            VStack {
                Spacer()
                bottomButton
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showLicensePrompt) {
            if let skill = selectedLicenseSkill {
                APILicensePromptSheet(
                    skillDisplayName: skill.displayName,
                    onVerifyNow: {
                        showLicensePrompt = false
                        // Navigate to verification settings
                        router.navigateToSettings(.verification)
                    },
                    onSkip: { showLicensePrompt = false }
                )
            }
        }
        .task {
            await loadSkills()
        }
    }

    // MARK: - Load

    private func loadSkills() async {
        isLoading = true
        defer { isLoading = false }

        // Load user's existing skills first (for pre-selection)
        if let records = try? await skillService.getMySkills() {
            selectedSkills = Set(records.map { $0.skillId })
            verifiedSkillIds = Set(records.filter { $0.licenseVerified }.map { $0.skillId })
        }

        // Load full catalog from API
        do {
            let all = try await skillService.getAllSkills()
            if all.isEmpty {
                HXLogger.info(
                    "SkillGrid: Catalog API returned 0 skills — the server database likely has no rows in `skills` (ensure migration 006-seed-skills ran).",
                    category: "Skill"
                )
            }
            // Group by category, preserving order
            var seen: [String] = []
            var map: [String: [APISkill]] = [:]
            for skill in all {
                if map[skill.categoryName] == nil {
                    seen.append(skill.categoryName)
                    map[skill.categoryName] = []
                }
                map[skill.categoryName]?.append(skill)
            }
            skillGroups = seen.compactMap { key in
                guard let skills = map[key], !skills.isEmpty,
                      let first = skills.first else { return nil }
                return SkillGroup(
                    categoryName: key,
                    displayName: first.categoryDisplayName,
                    skills: skills
                )
            }
        } catch {
            HXLogger.error("SkillGrid: Failed to load API skills — \(error.localizedDescription)", category: "Skill")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Text("\(selectedSkills.count) selected")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.trailing, 16)
            }
            .padding(.top, 8)

            VStack(spacing: 4) {
                Text("What can you do?")
                    .font(.system(size: 28, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                Text("Select skills to see matching quests")
                    .font(.system(size: 15))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textMuted)
            TextField("Search skills...", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Category Section

    private func categorySection(_ group: SkillGroup) -> some View {
        let skills = filteredSkills(for: group)
        let isExpanded = expandedGroup == group.categoryName

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    expandedGroup = isExpanded ? nil : group.categoryName
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(group.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: group.sfSymbol)
                            .font(.system(size: 18))
                            .foregroundStyle(group.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        let selectedCount = skills.filter { selectedSkills.contains($0.id) }.count
                        Text("\(selectedCount)/\(skills.count) selected")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textMuted)
                    }

                    Spacer()

                    // Licensed badge for groups that have licensed skills
                    if skills.contains(where: { $0.requiresLicense }) {
                        Text("LICENSE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.instantYellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.instantYellow.opacity(0.2))
                            .clipShape(Capsule())
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
                .padding(16)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 16 : 12, style: .continuous))
            }

            if isExpanded && !skills.isEmpty {
                skillsGrid(skills: skills, group: group)
                    .padding(.top, 1)
            }
        }
    }

    // MARK: - Skills Grid

    private func skillsGrid(skills: [APISkill], group: SkillGroup) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(skills) { skill in
                skillCard(skill, group: group)
            }
        }
        .padding(12)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Skill Card

    private func skillCard(_ skill: APISkill, group: SkillGroup) -> some View {
        let isSelected = selectedSkills.contains(skill.id)
        let needsLicense = skill.requiresLicense && !verifiedSkillIds.contains(skill.id)

        return Button {
            handleSkillTap(skill)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? group.color.opacity(0.3) : Color.surfaceElevated)
                        .frame(width: 44, height: 44)
                    Image(systemName: skill.iconName.flatMap { sfSymbolForSkillIcon($0) } ?? group.sfSymbol)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? group.color : Color.textMuted)

                    if needsLicense {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.instantYellow)
                                    .padding(4)
                                    .background(Color.brandBlack)
                                    .clipShape(Circle())
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                }

                Text(skill.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 32)

                // Status badge
                if needsLicense {
                    HStack(spacing: 3) {
                        Image(systemName: "lock.fill").font(.system(size: 9))
                        Text("License").font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Color.instantYellow)
                } else if isSelected {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark").font(.system(size: 9, weight: .bold))
                        Text("Ready").font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Color.successGreen)
                } else {
                    Text("Available")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? group.color.opacity(0.1) : Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? group.color : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        let verifiedCount = verifiedSkillIds.count

        return VStack(spacing: 12) {
            if let error = saveError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.errorRed)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 0) {
                statItem(value: "\(selectedSkills.count)", label: "Selected", color: .brandPurple)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 32)
                statItem(value: "\(verifiedSkillIds.count)", label: "Unlocked", color: .successGreen)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 32)
                statItem(value: "\(verifiedCount)", label: "Licensed", color: .instantYellow)
            }
            .padding(.vertical, 10)
            .background(Color.surfaceElevated)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal, 20)

            Button { saveAndContinue() } label: {
                HStack(spacing: 8) {
                    Text(isSettingsMode ? "Save Changes" : "Save Skills")
                        .font(.system(size: 17, weight: .semibold))
                        .minimumScaleFactor(0.7)
                    if !selectedSkills.isEmpty {
                        Text("(\(selectedSkills.count))")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background((!isSettingsMode && selectedSkills.isEmpty) ? Color.textMuted : Color.brandPurple)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Save selected skills")
            .disabled(!isSettingsMode && selectedSkills.isEmpty)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [.brandBlack.opacity(0), .brandBlack, .brandBlack],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 20, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 11)).foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func filteredSkills(for group: SkillGroup) -> [APISkill] {
        if searchText.isEmpty { return group.skills }
        return group.skills.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    private func handleSkillTap(_ skill: APISkill) {
        if skill.requiresLicense && !verifiedSkillIds.contains(skill.id) {
            selectedLicenseSkill = skill
            showLicensePrompt = true
            return
        }
        if selectedSkills.contains(skill.id) {
            selectedSkills.remove(skill.id)
        } else {
            selectedSkills.insert(skill.id)
        }
    }

    private func saveAndContinue() {
        saveError = nil
        Task {
            do {
                // selectedSkills are already API UUIDs — safe to send directly
                let saved = try await skillService.addSkills(skillIds: Array(selectedSkills))
                verifiedSkillIds = Set(saved.filter { $0.licenseVerified }.map { $0.skillId })
                HXLogger.info("SkillGrid: Saved \(saved.count) skills", category: "Skill")
                if isSettingsMode {
                    await MainActor.run { dismiss() }
                } else {
                    await MainActor.run { router.navigateToOnboarding(.complete) }
                }
            } catch {
                await MainActor.run {
                    saveError = "Couldn't save skills — try again"
                }
                HXLogger.error("SkillGrid: Save failed — \(error.localizedDescription)", category: "Skill")
            }
        }
    }

    // Lucide icon name → SF Symbol (backend seeds most skills without iconName, fallback to category icon)
    private func sfSymbolForSkillIcon(_ name: String) -> String? {
        switch name {
        case "truck": return "truck.box"
        case "package", "shippingbox": return "shippingbox.fill"
        case "monitor", "laptop": return "desktopcomputer"
        case "smartphone": return "iphone"
        case "wrench": return "wrench.fill"
        case "hammer": return "hammer.fill"
        case "palette": return "paintpalette.fill"
        case "camera": return "camera.fill"
        case "scissors": return "scissors"
        case "dog", "paw": return "pawprint.fill"
        case "book": return "book.fill"
        case "music": return "music.note"
        case "car": return "car.fill"
        case "home", "house": return "house.fill"
        case "briefcase": return "briefcase.fill"
        case "user", "person": return "person.fill"
        case "zap", "bolt": return "bolt.fill"
        default: return nil
        }
    }
}

// MARK: - SkillGroup (grouping model, not from API)

struct SkillGroup: Identifiable {
    let categoryName: String   // slug: "delivery"
    let displayName: String    // "Delivery"
    let skills: [APISkill]

    var id: String { categoryName }

    var sfSymbol: String {
        switch categoryName {
        case "general_labor": return "hammer.fill"
        case "delivery": return "shippingbox.fill"
        case "tech_help": return "desktopcomputer"
        case "home_services": return "house.fill"
        case "personal_services": return "person.fill"
        case "professional": return "briefcase.fill"
        case "creative": return "paintpalette.fill"
        default: return "star.fill"
        }
    }

    var color: Color {
        switch categoryName {
        case "general_labor": return .orange
        case "delivery": return Color.brandPurple
        case "tech_help": return .blue
        case "home_services": return .green
        case "personal_services": return .pink
        case "professional": return .indigo
        case "creative": return .yellow
        default: return Color.brandPurple
        }
    }
}

// MARK: - License Prompt Sheet (for API skills — no LicenseType enum needed)

struct APILicensePromptSheet: View {
    let skillDisplayName: String
    let onVerifyNow: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.instantYellow.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.instantYellow)
            }
            .padding(.top, 32)

            VStack(spacing: 8) {
                Text(skillDisplayName)
                    .font(.system(size: 24, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Requires Verification")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, 24)

            Text("To see \(skillDisplayName) tasks and earn premium rates, verify your license or credentials first.")
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onVerifyNow) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Verify Now")
                            .minimumScaleFactor(0.7)
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.brandBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.instantYellow)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Verify your license now")

                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.brandBlack)
    }
}

// MARK: - Preview

#Preview("Skill Grid") {
    SkillGridSelectionScreen()
        .environment(Router())
        .environment(AppState())
}
