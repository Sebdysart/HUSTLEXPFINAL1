//
//  SkillGridSelectionScreen.swift
//  hustleXP final1
//
//  100+ Skill Grid Selection
//  - Organized by category
//  - Visual distinction: Basic (unlocked), Experience (progress), Licensed (hard gate)
//  - License verification upsell for trades
//

import SwiftUI

struct SkillGridSelectionScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSkills: Set<String> = []
    @State private var expandedCategory: SkillCategory? = nil
    @State private var showLicensePrompt: Bool = false
    @State private var selectedLicenseType: LicenseType? = nil
    @State private var searchText: String = ""
    @State private var verifiedSkills: [WorkerSkillRecord] = []
    @State private var isLoadingSkills: Bool = false

    private let skillService = SkillService.shared
    
    var body: some View {
        ZStack {
            // Premium dark background
            Color.brandBlack.ignoresSafeArea()
            
            // Animated gradient orbs for premium feel
            VStack {
                HStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.brandPurple.opacity(0.15), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -80)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.accentViolet.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 80, y: 100)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar (shown during onboarding)
                OnboardingProgressBar(
                    currentStep: OnboardingRoute.skillSelection.stepIndex,
                    totalSteps: OnboardingRoute.totalSteps
                )
                .padding(.top, 8)

                // Header
                header

                // Search bar
                searchBar
                
                // Category list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(SkillCategory.allCases, id: \.self) { category in
                            categorySection(category)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for button
                }
            }
            
            // Bottom CTA
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
            if let licenseType = selectedLicenseType {
                LicensePromptSheet(
                    licenseType: licenseType,
                    onVerifyNow: {
                        showLicensePrompt = false
                        router.navigateToHustler(.licenseUpload(type: licenseType))
                    },
                    onSkip: {
                        showLicensePrompt = false
                    }
                )
            }
        }
        .task {
            // Load existing skills from real backend
            isLoadingSkills = true
            do {
                let records = try await skillService.getMySkills()
                verifiedSkills = records
                // Pre-select skills the user already has
                selectedSkills = Set(records.map { $0.skillId })
                print("SkillGrid: Loaded \(records.count) skills from backend")
            } catch {
                print("SkillGrid: Failed to load skills - \(error.localizedDescription)")
            }
            isLoadingSkills = false
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
    
    private func categorySection(_ category: SkillCategory) -> some View {
        let skills = filteredSkills(for: category)
        let isExpanded = expandedCategory == category
        
        return VStack(spacing: 0) {
            // Category header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    expandedCategory = isExpanded ? nil : category
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(category.color)
                    }
                    
                    // Title & count
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        
                        let selectedCount = skills.filter { selectedSkills.contains($0.id) }.count
                        Text("\(selectedCount)/\(skills.count) selected")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textMuted)
                    }
                    
                    Spacer()
                    
                    // Licensed badge
                    if category == .trades {
                        Text("LICENSE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.instantYellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.instantYellow.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    // Chevron
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
                .padding(16)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 16 : 12, style: .continuous))
            }
            
            // Skills grid
            if isExpanded && !skills.isEmpty {
                skillsGrid(skills: skills)
                    .padding(.top, 1)
            }
        }
    }
    
    // MARK: - Skills Grid
    
    private func skillsGrid(skills: [WorkerSkill]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(skills, id: \.id) { skill in
                skillCard(skill)
            }
        }
        .padding(12)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Skill Card
    
    private func skillCard(_ skill: WorkerSkill) -> some View {
        let isSelected = selectedSkills.contains(skill.id)
        let isUnlocked = isSkillUnlocked(skill.id)
        let needsLicense = skill.type == .licensed && !isUnlocked
        
        return Button {
            handleSkillTap(skill)
        } label: {
            VStack(spacing: 8) {
                // Icon with status
                ZStack {
                    Circle()
                        .fill(isSelected ? skill.category.color.opacity(0.3) : Color.surfaceElevated)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: skill.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? skill.category.color : .textMuted)
                    
                    // Lock badge for licensed
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
                
                // Name
                Text(skill.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 32)
                
                // Status indicator
                statusBadge(for: skill, isSelected: isSelected)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? skill.category.color.opacity(0.1) : Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? skill.category.color : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Status Badge
    
    @ViewBuilder
    private func statusBadge(for skill: WorkerSkill, isSelected: Bool) -> some View {
        let isUnlocked = isSkillUnlocked(skill.id)
        
        switch skill.type {
        case .basic:
            if isSelected {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                    Text("Ready")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.successGreen)
            } else {
                Text("Available")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            
        case .experienceBased:
            if isUnlocked {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                    Text("Unlocked")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.successGreen)
            } else {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 9))
                    Text("Lvl \(skill.requiredLevel)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.warningOrange)
            }
            
        case .licensed:
            if isUnlocked {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 9))
                    Text("Verified")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.successGreen)
            } else {
                HStack(spacing: 3) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                    Text("License")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.instantYellow)
            }
        }
    }
    
    // MARK: - Bottom Button
    
    private var bottomButton: some View {
        VStack(spacing: 12) {
            // Stats
            let verifiedCount = verifiedSkills.filter { $0.licenseVerified }.count
            HStack(spacing: 20) {
                statItem(value: "\(selectedSkills.count)", label: "Selected")
                statItem(value: "\(verifiedSkills.count)", label: "Unlocked")
                statItem(value: "\(verifiedCount)", label: "Licensed")
            }
            .padding(.horizontal, 20)
            
            // Save button
            Button {
                saveAndContinue()
            } label: {
                HStack(spacing: 8) {
                    Text("Save Skills")
                        .font(.system(size: 17, weight: .semibold))
                        .minimumScaleFactor(0.7)
                    
                    if selectedSkills.count > 0 {
                        Text("(\(selectedSkills.count))")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedSkills.isEmpty ? Color.textMuted : Color.brandPurple)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Save selected skills")
            .disabled(selectedSkills.isEmpty)
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
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.textMuted)
        }
    }
    
    // MARK: - Helpers
    
    private func filteredSkills(for category: SkillCategory) -> [WorkerSkill] {
        var skills = SkillCatalog.skills(for: category)
        
        if !searchText.isEmpty {
            skills = skills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return skills
    }
    
    private func handleSkillTap(_ skill: WorkerSkill) {
        // Check if it's a licensed skill that needs verification
        if skill.type == .licensed && !isSkillUnlocked(skill.id) {
            selectedLicenseType = skill.licenseType
            showLicensePrompt = true
            return
        }

        // Toggle selection (local state only; saved to backend on "Save Skills")
        if selectedSkills.contains(skill.id) {
            selectedSkills.remove(skill.id)
        } else {
            selectedSkills.insert(skill.id)
        }
    }
    
    private func saveAndContinue() {
        // Save selected skills to real backend
        Task {
            do {
                let saved = try await skillService.addSkills(skillIds: Array(selectedSkills))
                verifiedSkills = saved
                print("SkillGrid: \(saved.count) skills saved to backend")
            } catch {
                print("SkillGrid: Backend save failed - \(error.localizedDescription)")
            }
        }

        // Navigate to onboarding complete (or dismiss if accessed from settings)
        router.navigateToOnboarding(.complete)
    }

    // MARK: - Skill Unlock Check

    /// Checks if a skill is unlocked using real backend data.
    /// Basic skills are always considered unlocked.
    /// Licensed/experience-based skills require backend verification.
    private func isSkillUnlocked(_ skillId: String) -> Bool {
        // Basic skills are always unlocked
        if let skill = SkillCatalog.skill(byId: skillId), skill.type == .basic {
            return true
        }
        // Check real backend records for license/experience verification
        return verifiedSkills.contains { $0.skillId == skillId && $0.licenseVerified }
    }
}

// MARK: - License Prompt Sheet

struct LicensePromptSheet: View {
    let licenseType: LicenseType
    let onVerifyNow: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.instantYellow.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: licenseType.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.instantYellow)
            }
            .padding(.top, 32)
            
            // Title
            VStack(spacing: 8) {
                Text("\(licenseType.rawValue)")
                    .font(.system(size: 24, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.textPrimary)
                
                Text("is a Regulated Trade")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Description
            Text("To see \(licenseType.rawValue) quests and earn premium rates, you'll need to verify your professional license.")
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Fee info
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(Color.successGreen)
                Text("One-time verification: $\(String(format: "%.2f", licenseType.verificationFee))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    onVerifyNow()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Verify License Now")
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
                
                Button {
                    onSkip()
                } label: {
                    Text("Stick to General Labor")
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
