//
//  ProofReviewScreen.swift
//  hustleXP final1
//
//  Archetype: C (Task Lifecycle)
//

import SwiftUI

struct ProofReviewScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    
    let taskId: String

    @State private var task: HXTask?
    @State private var proofDetail: ProofDetail?
    @State private var rating: Int = 0
    @State private var tipAmount: Double = 0
    @State private var showApproveConfirmation = false
    @State private var showRejectSheet = false
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    let tipOptions: [Double] = [0, 5, 10, 20]
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            if showSuccess {
                PaymentSuccessView {
                    router.posterPath = NavigationPath()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Photo proof section
                        ProofPhotoSection(photoUrls: proofDetail?.photoUrls ?? [])

                        // Hustler notes
                        HustlerNotesSection(
                            notes: proofDetail?.description,
                            submittedAt: proofDetail?.submittedAt
                        )
                        
                        HXDivider()
                        
                        // Rating section
                        RatingSection(rating: $rating)
                        
                        // Tip section
                        TipSection(selectedAmount: $tipAmount, options: tipOptions)
                        
                        // Payment summary
                        if let task = task {
                            PaymentSummarySection(task: task, tipAmount: tipAmount)
                        }
                        
                        Spacer(minLength: 150)
                    }
                    .padding(24)
                }
                
                // Bottom action bar
                VStack {
                    Spacer()
                    ReviewActionBar(
                        rating: rating,
                        isProcessing: isProcessing,
                        onApprove: { showApproveConfirmation = true },
                        onReject: { showRejectSheet = true }
                    )
                }
            }
        }
        .navigationTitle("Review Proof")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Approve & Pay?", isPresented: $showApproveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Approve") {
                approveAndPay()
            }
        } message: {
            if let task = task {
                Text("You'll pay $\(Int(task.payment + tipAmount)) to complete this task.")
            }
        }
        .sheet(isPresented: $showRejectSheet) {
            RequestChangesSheet(taskId: taskId)
        }
        .task {
            // Fetch task and proof in parallel
            async let taskFetch: () = loadTask()
            async let proofFetch: () = loadProof()
            _ = await (taskFetch, proofFetch)
        }
    }
    
    private func loadTask() async {
        do {
            task = try await TaskService.shared.getTask(id: taskId)
            HXLogger.info("ProofReview: Loaded task from API", category: "Task")
        } catch {
            HXLogger.error("ProofReview: Task API failed - \(error.localizedDescription)", category: "Task")
            task = LiveDataService.shared.getTask(by: taskId)
        }
    }

    private func loadProof() async {
        do {
            proofDetail = try await ProofService.shared.getProof(taskId: taskId)
            HXLogger.info("ProofReview: Loaded proof with \(proofDetail?.photoUrls.count ?? 0) photos", category: "Task")
        } catch {
            HXLogger.error("ProofReview: Proof API failed - \(error.localizedDescription)", category: "Task")
        }
    }

    private func approveAndPay() {
        isProcessing = true

        Task {
            do {
                // 1. Approve the proof
                _ = try await TaskService.shared.reviewProof(
                    taskId: taskId,
                    approved: true,
                    feedback: rating > 0 ? "Rated \(rating)/5" : nil
                )
                HXLogger.info("ProofReview: Approved via API", category: "Task")

                // 2. Complete the task (PROOF_SUBMITTED → COMPLETED)
                _ = try await TaskService.shared.completeTask(taskId: taskId)
                HXLogger.info("ProofReview: Task completed via API", category: "Task")

                // 3. Release escrow to worker
                do {
                    let escrow = try await EscrowService.shared.getEscrowByTask(taskId: taskId)
                    _ = try await EscrowService.shared.releaseToWorker(escrowId: escrow.id)
                    HXLogger.info("ProofReview: Escrow released to worker", category: "Task")
                } catch {
                    // Escrow release may fail if worker hasn't set up Stripe Connect yet.
                    // The funds remain in escrow and can be released later.
                    HXLogger.error("ProofReview: Escrow release failed - \(error.localizedDescription)", category: "Task")
                }

                // 4. Submit rating if user gave one
                if rating > 0 {
                    do {
                        try await RatingService.shared.submitRating(
                            taskId: taskId,
                            rating: rating,
                            review: nil
                        )
                        HXLogger.info("ProofReview: Rating \(rating)/5 submitted via API", category: "Task")
                    } catch {
                        HXLogger.error("ProofReview: Rating submission failed - \(error.localizedDescription)", category: "Task")
                    }
                }
            } catch {
                HXLogger.error("ProofReview: API approve failed - \(error.localizedDescription)", category: "Task")
            }
            isProcessing = false
            withAnimation(.spring(response: 0.5)) {
                showSuccess = true
            }
        }
    }
}

// MARK: - Proof Photo Section
private struct ProofPhotoSection: View {
    let photoUrls: [String]
    @State private var selectedPhotoIndex = 0
    @State private var showFullScreen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Submitted Proof", style: .headline)
                Spacer()
                if !photoUrls.isEmpty {
                    HXText("\(photoUrls.count) photo\(photoUrls.count == 1 ? "" : "s")", style: .caption, color: .textSecondary)
                }
            }

            if photoUrls.isEmpty {
                // No photos submitted
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.surfaceElevated)
                        .aspectRatio(4/3, contentMode: .fit)

                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.textSecondary)
                        HXText("No photos submitted", style: .caption, color: .textTertiary)
                    }
                }
            } else {
                // Main photo
                let currentUrl = photoUrls[min(selectedPhotoIndex, photoUrls.count - 1)]
                AsyncImage(url: URL(string: currentUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 280)
                            .clipped()
                            .cornerRadius(16)
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.surfaceElevated)
                                .aspectRatio(4/3, contentMode: .fit)
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundStyle(Color.warningOrange)
                                HXText("Failed to load photo", style: .caption, color: .textTertiary)
                            }
                        }
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.surfaceElevated)
                                .aspectRatio(4/3, contentMode: .fit)
                            ProgressView()
                                .tint(.brandPurple)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .onTapGesture {
                    showFullScreen = true
                }

                // Thumbnail strip (only if multiple photos)
                if photoUrls.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(Array(photoUrls.enumerated()), id: \.offset) { index, url in
                            AsyncImage(url: URL(string: url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    Color.surfaceSecondary
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundStyle(Color.textTertiary)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedPhotoIndex == index ? Color.brandPurple : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .onTapGesture {
                                withAnimation { selectedPhotoIndex = index }
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if !photoUrls.isEmpty {
                ProofFullScreenViewer(
                    photoUrls: photoUrls,
                    initialIndex: selectedPhotoIndex,
                    isPresented: $showFullScreen
                )
            }
        }
    }
}

// MARK: - Hustler Notes Section
private struct HustlerNotesSection: View {
    let notes: String?
    let submittedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Hustler's Notes", style: .headline)

            VStack(alignment: .leading, spacing: 12) {
                if let notes, !notes.isEmpty {
                    HXText(notes, style: .body, color: .textSecondary)
                } else {
                    HXText("No notes provided.", style: .body, color: .textTertiary)
                }

                HXDivider()

                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)

                    if let submittedAt {
                        HXText(timeAgoText(submittedAt), style: .caption, color: .textTertiary)
                    } else {
                        HXText("Submission time unknown", style: .caption, color: .textTertiary)
                    }
                }
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
    }

    private func timeAgoText(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Submitted " + formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Rating Section
private struct RatingSection: View {
    @Binding var rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Rate this Hustler", style: .headline)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            rating = star
                        }
                    }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(star <= rating ? Color.warningOrange : Color.textTertiary)
                            .scaleEffect(star <= rating ? 1.1 : 1.0)
                    }
                    .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                }
            }
            .frame(maxWidth: .infinity)
            
            if rating > 0 {
                HXText(ratingLabel, style: .subheadline, color: .textSecondary)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
    
    private var ratingLabel: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent!"
        default: return ""
        }
    }
}

// MARK: - Tip Section
private struct TipSection: View {
    @Binding var selectedAmount: Double
    let options: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Add a Tip", style: .headline)
                Spacer()
                HXText("Optional", style: .caption, color: .textTertiary)
            }
            
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { amount in
                    TipButton(
                        amount: amount,
                        isSelected: selectedAmount == amount,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedAmount = amount
                            }
                        }
                    )
                }
            }
            
            if selectedAmount > 0 {
                HXText(
                    "Tips go directly to the hustler and help recognize great work!",
                    style: .caption,
                    color: .textSecondary
                )
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Tip Button
private struct TipButton: View {
    let amount: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if amount == 0 {
                    HXText("No Tip", style: .caption, color: isSelected ? .white : .textSecondary)
                } else {
                    HXText("$\(Int(amount))", style: .headline, color: isSelected ? .white : .textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.brandPurple : Color.surfaceSecondary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Payment Summary Section
private struct PaymentSummarySection: View {
    let task: HXTask
    let tipAmount: Double
    
    var total: Double {
        task.payment + tipAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HXText("Payment Summary", style: .headline)
            
            VStack(spacing: 12) {
                HStack {
                    HXText("Task Payment", style: .body, color: .textSecondary)
                    Spacer()
                    HXText("$\(Int(task.payment))", style: .body)
                }
                
                if tipAmount > 0 {
                    HStack {
                        HXText("Tip", style: .body, color: .textSecondary)
                        Spacer()
                        HXText("+$\(Int(tipAmount))", style: .body, color: .successGreen)
                    }
                }
                
                HXDivider()
                
                HStack {
                    HXText("Total", style: .headline)
                    Spacer()
                    HXText("$\(Int(total))", style: .title2, color: .moneyGreen)
                }
            }
        }
        .padding(20)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

// MARK: - Review Action Bar
private struct ReviewActionBar: View {
    let rating: Int
    let isProcessing: Bool
    let onApprove: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.borderSubtle)
            
            VStack(spacing: 12) {
                HXButton(
                    isProcessing ? "Processing..." : "Approve & Pay",
                    variant: .primary,
                    isLoading: isProcessing
                ) {
                    onApprove()
                }
                .disabled(rating == 0 || isProcessing)
                .opacity(rating > 0 ? 1 : 0.5)
                .accessibilityLabel("Approve and pay")
                
                Button(action: onReject) {
                    HXText("Request Changes", style: .subheadline, color: .warningOrange)
                }
                .disabled(isProcessing)
                .accessibilityLabel("Request changes")
            }
            .padding(20)
            .background(Color.brandBlack)
        }
    }
}

// MARK: - Payment Success View
private struct PaymentSuccessView: View {
    let onDone: () -> Void
    
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showCheckmark = true
                }
            }
            
            VStack(spacing: 12) {
                HXText("Payment Sent!", style: .largeTitle)
                
                HXText(
                    "The hustler has been paid and will receive your rating.",
                    style: .body,
                    color: .textSecondary
                )
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            HXButton("Done", variant: .primary) {
                onDone()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Request Changes Sheet
private struct RequestChangesSheet: View {
    let taskId: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReason: String?
    @State private var instructions: String = ""
    
    let reasons = [
        "Photo doesn't show completion",
        "Task not fully completed",
        "Wrong item/location",
        "Quality doesn't meet expectations",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HXText("What needs to be changed?", style: .headline)
                        
                        VStack(spacing: 12) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: { selectedReason = reason }) {
                                    HStack {
                                        HXText(reason, style: .body)
                                        Spacer()
                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.brandPurple)
                                        }
                                    }
                                    .padding(16)
                                    .background(selectedReason == reason ? Color.brandPurple.opacity(0.15) : Color.surfaceElevated)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HXText("Instructions for Hustler", style: .subheadline, color: .textSecondary)
                            
                            TextField("", text: $instructions, prompt: Text("Explain what needs to be fixed...").foregroundColor(.textTertiary), axis: .vertical)
                                .font(.body)
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(4...8)
                                .padding(16)
                                .background(Color.surfaceElevated)
                                .cornerRadius(12)
                        }
                        
                        HXButton("Send Request", variant: .primary) {
                            // v2.2.0: Reject proof via real API
                            let feedback = "\(selectedReason ?? ""): \(instructions)"
                            Task {
                                do {
                                    _ = try await TaskService.shared.reviewProof(
                                        taskId: taskId,
                                        approved: false,
                                        feedback: feedback
                                    )
                                    HXLogger.info("ProofReview: Changes requested via API", category: "Task")
                                } catch {
                                    HXLogger.error("ProofReview: API reject failed - \(error.localizedDescription)", category: "Task")
                                }
                            }
                            dismiss()
                        }
                        .disabled(selectedReason == nil || instructions.isEmpty)
                        .opacity(selectedReason != nil && !instructions.isEmpty ? 1 : 0.5)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Request Changes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
}

// MARK: - Full Screen Photo Viewer
private struct ProofFullScreenViewer: View {
    let photoUrls: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photoUrls.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text("Failed to load")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photoUrls.count > 1 ? .always : .never))

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(16)
                    }
                }
                Spacer()

                if photoUrls.count > 1 {
                    Text("\(currentIndex + 1) of \(photoUrls.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 8)
                }
            }
        }
        .onAppear { currentIndex = initialIndex }
    }
}

#Preview {
    NavigationStack {
        ProofReviewScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
