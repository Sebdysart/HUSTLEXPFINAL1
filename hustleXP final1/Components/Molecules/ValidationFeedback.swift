//
//  ValidationFeedback.swift
//  hustleXP final1
//
//  Molecule: Biometric Validation Feedback
//  Shows proof validation results with scores and flags
//

import SwiftUI

struct ValidationFeedback: View {
    let result: BiometricValidationResult
    let onDismiss: () -> Void
    let onRetake: (() -> Void)?
    
    init(result: BiometricValidationResult, onDismiss: @escaping () -> Void, onRetake: (() -> Void)? = nil) {
        self.result = result
        self.onDismiss = onDismiss
        self.onRetake = onRetake
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with recommendation
            headerSection
            
            // Reasoning
            reasoningSection
            
            // Flags (if any)
            if !result.flags.isEmpty {
                flagsSection
            }
            
            // Scores
            scoresSection
            
            // Risk badge
            HStack {
                Spacer()
                RiskBadge(level: result.riskLevel)
            }
            
            // Actions
            actionsSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 56, height: 56)
                
                Image(systemName: result.recommendation.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HXText(headerTitle, style: .title3)
                HXText(headerSubtitle, style: .caption, color: .textSecondary)
            }
            
            Spacer()
        }
    }
    
    private var headerTitle: String {
        switch result.recommendation {
        case .approve: return "Proof Approved"
        case .manualReview: return "Under Review"
        case .reject: return "Proof Rejected"
        }
    }
    
    private var headerSubtitle: String {
        switch result.recommendation {
        case .approve: return "All checks passed"
        case .manualReview: return "Manual review required"
        case .reject: return "Please try again"
        }
    }
    
    private var iconColor: Color {
        switch result.recommendation {
        case .approve: return .successGreen
        case .manualReview: return .warningOrange
        case .reject: return .errorRed
        }
    }
    
    private var iconBackgroundColor: Color {
        iconColor.opacity(0.15)
    }
    
    private var borderColor: Color {
        iconColor
    }
    
    // MARK: - Reasoning
    
    private var reasoningSection: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.textMuted)
            
            Text(result.reasoning)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
    }
    
    // MARK: - Flags
    
    private var flagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HXText("Flags", style: .caption, color: .textMuted)
            
            FlowLayout(spacing: 8) {
                ForEach(result.flags, id: \.self) { flag in
                    let validationFlag = ValidationFlag.fromCode(flag)
                    FlagChip(flag: validationFlag)
                }
            }
        }
    }
    
    // MARK: - Scores
    
    private var scoresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Validation Scores", style: .caption, color: .textMuted)
            
            VStack(spacing: 10) {
                ScoreBar(
                    label: "Liveness",
                    value: result.scores.liveness,
                    threshold: 70,
                    inverted: false
                )
                
                ScoreBar(
                    label: "Authenticity",
                    value: 100 - result.scores.deepfake, // Invert deepfake score
                    threshold: 20,
                    inverted: false
                )
                
                ScoreBar(
                    label: "GPS Proximity",
                    value: result.scores.gpsProximity,
                    threshold: 60,
                    inverted: false
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if result.isRejected, let onRetake = onRetake {
                HXButton("Retake Photo", variant: .primary, icon: "camera") {
                    onRetake()
                }
            }
            
            HXButton(
                result.isApproved ? "Done" : "Close",
                variant: result.isApproved ? .primary : .secondary
            ) {
                onDismiss()
            }
        }
    }
}

// MARK: - Score Bar

struct ScoreBar: View {
    let label: String
    let value: Int
    let threshold: Int
    let inverted: Bool
    
    private var passed: Bool {
        inverted ? value < threshold : value >= threshold
    }
    
    private var barColor: Color {
        if value >= 80 { return .successGreen }
        if value >= 60 { return .warningOrange }
        return .errorRed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("\(value)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(barColor)
                    
                    if passed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.successGreen)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.surfaceSecondary)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Flag Chip

struct FlagChip: View {
    let flag: ValidationFlag
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            
            Text(flag.displayName)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(Color.warningOrange)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.warningOrange.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 20) {
                // Approved
                ValidationFeedback(
                    result: BiometricValidationResult(
                        recommendation: .approve,
                        reasoning: "All validation checks passed. Proof looks authentic.",
                        flags: [],
                        scores: ValidationScores(liveness: 92, deepfake: 15, gpsProximity: 95),
                        riskLevel: .low
                    ),
                    onDismiss: {}
                )
                
                // Under review
                ValidationFeedback(
                    result: BiometricValidationResult(
                        recommendation: .manualReview,
                        reasoning: "Some validation flags raised. Manual review required.",
                        flags: ["low_accuracy", "weak_liveness"],
                        scores: ValidationScores(liveness: 68, deepfake: 25, gpsProximity: 72),
                        riskLevel: .medium
                    ),
                    onDismiss: {},
                    onRetake: {}
                )
                
                // Rejected
                ValidationFeedback(
                    result: BiometricValidationResult(
                        recommendation: .reject,
                        reasoning: "GPS location too far from task. Please retake at the task location.",
                        flags: ["gps_mismatch", "impossible_travel"],
                        scores: ValidationScores(liveness: 45, deepfake: 60, gpsProximity: 25),
                        riskLevel: .high
                    ),
                    onDismiss: {},
                    onRetake: {}
                )
            }
            .padding()
        }
    }
}
