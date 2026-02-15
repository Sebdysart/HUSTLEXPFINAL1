//
//  FileClaimScreen.swift
//  hustleXP final1
//
//  Screen: File Insurance Claim
//  Submit a claim for a task issue
//

import SwiftUI

struct FileClaimScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(LiveDataService.self) private var dataService

    let preselectedTaskId: String?

    @State private var selectedTaskId: String = ""
    @State private var description: String = ""
    @State private var amountText: String = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errors: [String] = []
    @State private var eligibleTasks: [HXTask] = []
    @State private var submitError: String?
    @State private var loadError: Error?
    @FocusState private var focusedField: Field?

    private enum Field {
        case description, amount
    }

    init(taskId: String? = nil) {
        self.preselectedTaskId = taskId
    }
    
    private var amountCents: Int {
        Int((Double(amountText) ?? 0) * 100)
    }
    
    private var isValid: Bool {
        !selectedTaskId.isEmpty &&
        description.count >= 20 &&
        description.count <= 500 &&
        amountCents >= 100 &&
        amountCents <= 500000
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            if showSuccess {
                successView
            } else {
                formView
            }
        }
        .navigationTitle("File Claim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            if let taskId = preselectedTaskId {
                selectedTaskId = taskId
            }
            await loadEligibleTasks()
        }
    }
    
    // MARK: - Form View
    
    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Task selection
                taskSelectionSection
                
                // Description
                descriptionSection
                
                // Amount
                amountSection
                
                // Errors (validation + API errors)
                if !errors.isEmpty || submitError != nil {
                    errorsSection
                }
                
                // Info
                infoSection
                
                Spacer(minLength: 120)
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            submitButton
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HXText("Insurance Claim", style: .title2)
            HXText(
                "File a claim if you encountered issues with a completed task",
                style: .subheadline,
                color: .textSecondary
            )
        }
    }
    
    // MARK: - Task Selection
    
    private var taskSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Task")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            if eligibleTasks.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(Color.warningOrange)
                    Text("No eligible tasks for claims")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.surfaceElevated)
                .cornerRadius(14)
            } else {
                Menu {
                    ForEach(eligibleTasks) { task in
                        Button(action: { selectedTaskId = task.id }) {
                            HStack {
                                Text(task.title)
                                if selectedTaskId == task.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let task = eligibleTasks.first(where: { $0.id == selectedTaskId }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.body)
                                    .foregroundStyle(Color.textPrimary)
                                Text(task.formattedPayment)
                                    .font(.caption)
                                    .foregroundStyle(Color.textMuted)
                            }
                        } else {
                            Text("Select a task")
                                .font(.body)
                                .foregroundStyle(Color.textMuted)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }
                    .padding(16)
                    .background(Color.surfaceElevated)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("What happened?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            TextField(
                "",
                text: $description,
                prompt: Text("Describe the incident in detail...").foregroundColor(.textMuted),
                axis: .vertical
            )
            .lineLimit(5...10)
            .font(.body)
            .foregroundStyle(Color.textPrimary)
            .focused($focusedField, equals: .description)
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        focusedField == .description ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .description ? 2 : 1
                    )
            )
            
            HStack {
                Text("\(description.count)/500 characters")
                    .font(.caption)
                    .foregroundStyle(description.count > 500 ? Color.errorRed : Color.textMuted)
                
                Spacer()
                
                if description.count < 20 && !description.isEmpty {
                    Text("Minimum 20 characters")
                        .font(.caption)
                        .foregroundStyle(Color.warningOrange)
                }
            }
        }
    }
    
    // MARK: - Amount
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Claim Amount")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                Text("*")
                    .foregroundStyle(Color.errorRed)
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.insuranceClaim.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Text("$")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.insuranceClaim)
                }
                
                TextField("0", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .focused($focusedField, equals: .amount)
                
                Spacer()
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        focusedField == .amount ? Color.brandPurple : Color.white.opacity(0.08),
                        lineWidth: focusedField == .amount ? 2 : 1
                    )
            )
            
            HStack {
                Text("Maximum: $5,000 (80% coverage)")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                
                Spacer()
                
                if amountCents > 0 && amountCents < 100 {
                    Text("Minimum $1.00")
                        .font(.caption)
                        .foregroundStyle(Color.warningOrange)
                }
            }
        }
    }
    
    // MARK: - Errors
    
    private var errorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // v2.5.0: Show API submit error prominently
            if let apiError = submitError {
                HStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 16))
                    Text(apiError)
                        .font(.subheadline)
                }
                .foregroundStyle(Color.errorRed)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.errorRed.opacity(0.1))
                .cornerRadius(12)
            }
            
            ForEach(errors, id: \.self) { error in
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(Color.errorRed)
            }
        }
    }
    
    // MARK: - Info
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.infoBlue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Claim Review Process", style: .subheadline)
                    HXText(
                        "Claims are reviewed by our team within 3-5 business days. Approved claims are paid at 80% coverage via Stripe Connect.",
                        style: .caption,
                        color: .textSecondary
                    )
                }
            }
            .padding(14)
            .background(Color.infoBlue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        VStack(spacing: 8) {
            HXButton(
                isSubmitting ? "Submitting..." : "Submit Claim",
                icon: "shield.checkered",
                variant: isValid ? .primary : .secondary,
                isLoading: isSubmitting
            ) {
                submitClaim()
            }
            .disabled(!isValid || isSubmitting)
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Success View
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.insuranceClaim.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.insuranceClaim)
            }
            
            VStack(spacing: 8) {
                HXText("Claim Filed!", style: .title)
                HXText(
                    "Your claim has been submitted for review. You'll be notified within 3-5 business days.",
                    style: .body,
                    color: .textSecondary,
                    alignment: .center
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            HXButton("View My Claims") {
                router.popHustler()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Actions
    
    private func loadEligibleTasks() async {
        loadError = nil
        do {
            // Load completed tasks from API (tasks eligible for claims)
            let tasks = try await TaskService.shared.getTaskHistory(role: .hustler)
            eligibleTasks = tasks.filter { $0.state == .completed }
            print("✅ FileClaim: Loaded \(eligibleTasks.count) eligible tasks from API")
        } catch {
            // v2.5.0: Fall back to mock but log the error
            print("⚠️ FileClaim: API failed, using cached data - \(error.localizedDescription)")
            loadError = error
            eligibleTasks = dataService.getCompletedTasksForClaims()
        }
    }

    private func submitClaim() {
        focusedField = nil

        let request = FileClaimRequest(
            taskId: selectedTaskId,
            incidentDescription: description,
            requestedAmountCents: amountCents
        )

        errors = request.validationErrors

        guard request.isValid else { return }

        isSubmitting = true

        Task {
            do {
                _ = try await InsuranceService.shared.fileClaim(request: request)
                print("✅ FileClaim: Claim submitted via API")
                isSubmitting = false
                withAnimation(.spring(response: 0.4)) {
                    showSuccess = true
                }
            } catch {
                // v2.5.0: Show error to user instead of silent fallback
                print("⚠️ FileClaim: API submit failed - \(error.localizedDescription)")
                isSubmitting = false
                submitError = "Could not submit your claim. Please check your connection and try again."
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileClaimScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(LiveDataService.shared)
}
