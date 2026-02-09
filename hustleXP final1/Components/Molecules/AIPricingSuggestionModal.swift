//
//  AIPricingSuggestionModal.swift
//  hustleXP final1
//
//  Molecule: AI Pricing Suggestion Modal
//  Shows Scoper AI's price recommendation
//

import SwiftUI

struct AIPricingSuggestionModal: View {
    let suggestion: AIPriceSuggestion
    let onAccept: () -> Void
    let onEdit: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDetails = false
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Background
            Color.brandBlack.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    // AI Icon header
                    aiHeader
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .opacity(animateIn ? 1 : 0)
                    
                    // Price display
                    priceSection
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                    
                    // Range slider visual
                    rangeSection
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                    
                    // Rationale
                    rationaleSection
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                    
                    // Factors (expandable)
                    if showDetails {
                        factorsSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Actions
                    actionsSection
                        .offset(y: animateIn ? 0 : 30)
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.surfaceElevated)
                        .shadow(color: Color.aiPurple.opacity(0.2), radius: 30, y: -10)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - AI Header
    
    private var aiHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color.aiPurple.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPurple, Color.brandPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                // Sparkle icon
                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            
            HXText("AI Price Suggestion", style: .title2)
            HXText("Powered by Scoper AI", style: .caption, color: .textSecondary)
        }
    }
    
    // MARK: - Price Section
    
    private var priceSection: some View {
        VStack(spacing: 8) {
            Text(suggestion.formattedSuggestedPrice)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.aiPurple, Color.brandPurpleLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandPurple)
                
                Text("\(suggestion.xpReward) XP for hustlers")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
    
    // MARK: - Range Section
    
    private var rangeSection: some View {
        VStack(spacing: 8) {
            // Range bar
            GeometryReader { geometry in
                let width = geometry.size.width
                let low = suggestion.rangeLowDollars
                let high = suggestion.rangeHighDollars
                let suggested = suggestion.suggestedPriceDollars
                let position = (suggested - low) / (high - low)
                
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 8)
                    
                    // Gradient fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.aiPurple.opacity(0.3), Color.aiPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * position, height: 8)
                    
                    // Indicator
                    Circle()
                        .fill(Color.aiPurple)
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.aiPurple.opacity(0.5), radius: 4)
                        .offset(x: width * position - 8)
                }
            }
            .frame(height: 16)
            
            // Range labels
            HStack {
                Text(String(format: "$%.0f", suggestion.rangeLowDollars))
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                
                Spacer()
                
                Text("Market Range")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Text(String(format: "$%.0f", suggestion.rangeHighDollars))
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Rationale Section
    
    private var rationaleSection: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                showDetails.toggle()
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.aiPurple)
                
                Text(suggestion.rationale)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(14)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Factors Section
    
    private var factorsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HXText("Pricing Factors", style: .caption, color: .textMuted)
            
            ForEach(suggestion.factors) { factor in
                HStack(spacing: 10) {
                    Image(systemName: factor.impact.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(factorColor(factor.impact))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(factor.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text(factor.description)
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.surfaceSecondary)
                .cornerRadius(10)
            }
            
            // Confidence indicator
            HStack(spacing: 8) {
                Text("Confidence:")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                
                Text(suggestion.confidence.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(confidenceColor)
                
                Spacer()
                
                Text(suggestion.confidence.description)
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.top, 4)
        }
    }
    
    private func factorColor(_ impact: FactorImpact) -> Color {
        switch impact {
        case .positive: return .successGreen
        case .negative: return .errorRed
        case .neutral: return .textMuted
        }
    }
    
    private var confidenceColor: Color {
        switch suggestion.confidence {
        case .high: return .successGreen
        case .medium: return .warningOrange
        case .low: return .textMuted
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            HXButton("Accept Suggestion", variant: .primary, icon: "checkmark.circle.fill") {
                onAccept()
                dismiss()
            }
            
            HXButton("Edit Price", variant: .secondary, icon: "pencil") {
                onEdit()
                dismiss()
            }
        }
    }
}

// MARK: - AI Pricing Toggle

struct AIPricingToggle: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isEnabled.toggle()
            }
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isEnabled ? Color.aiPurple.opacity(0.15) : Color.surfaceSecondary)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(isEnabled ? Color.aiPurple : Color.textMuted)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Let AI suggest a price")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(isEnabled ? "AI will analyze your task" : "Set your own price")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(Color.aiPurple)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isEnabled ? Color.aiPurple.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AI Priced Badge

struct AIPricedBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 10))
            
            Text("AI Priced")
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(Color.aiPurple)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.aiPurple.opacity(0.15))
        .cornerRadius(6)
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Toggle
            AIPricingToggle(isEnabled: .constant(true))
                .padding()
            
            // Badge
            HStack {
                Text("$27.50")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                AIPricedBadge()
            }
        }
    }
    .sheet(isPresented: .constant(true)) {
        AIPricingSuggestionModal(
            suggestion: AIPriceSuggestion(
                suggestedPriceCents: 2750,
                xpReward: 275,
                rationale: "Based on similar yard work tasks in your area",
                priceRangeLowCents: 2000,
                priceRangeHighCents: 3500,
                confidence: .medium,
                factors: [
                    PricingFactor(name: "Category", impact: .neutral, description: "Yard Work"),
                    PricingFactor(name: "Complexity", impact: .positive, description: "Medium difficulty"),
                    PricingFactor(name: "Market Rate", impact: .neutral, description: "Competitive pricing")
                ]
            ),
            onAccept: {},
            onEdit: {}
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
