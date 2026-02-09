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
                        ProofPhotoSection()
                        
                        // Hustler notes
                        HustlerNotesSection()
                        
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
        .onAppear {
            task = MockDataService.shared.getTask(by: taskId)
        }
    }
    
    private func approveAndPay() {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            withAnimation(.spring(response: 0.5)) {
                showSuccess = true
            }
        }
    }
}

// MARK: - Proof Photo Section
private struct ProofPhotoSection: View {
    @State private var selectedPhotoIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HXText("Submitted Proof", style: .headline)
                Spacer()
                HXText("2 photos", style: .caption, color: .textSecondary)
            }
            
            // Main photo
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                    .aspectRatio(4/3, contentMode: .fit)
                
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textSecondary)
                    
                    HXText("Task completion photo", style: .caption, color: .textTertiary)
                }
            }
            
            // Thumbnail strip
            HStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(Color.textTertiary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    selectedPhotoIndex == index ? Color.brandPurple : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            selectedPhotoIndex = index
                        }
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                        HXText("Full Screen", style: .caption)
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
        }
    }
}

// MARK: - Hustler Notes Section
private struct HustlerNotesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Hustler's Notes", style: .headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HXText(
                    "Task completed as requested. Picked up all items from the store and delivered to the specified location. Receipt is attached in the second photo.",
                    style: .body,
                    color: .textSecondary
                )
                
                HXDivider()
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)
                    
                    HXText("Submitted 15 minutes ago", style: .caption, color: .textTertiary)
                }
            }
            .padding(16)
            .background(Color.surfaceElevated)
            .cornerRadius(12)
        }
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
                
                Button(action: onReject) {
                    HXText("Request Changes", style: .subheadline, color: .warningOrange)
                }
                .disabled(isProcessing)
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

#Preview {
    NavigationStack {
        ProofReviewScreen(taskId: "1")
    }
    .environment(Router())
    .environment(AppState())
}
