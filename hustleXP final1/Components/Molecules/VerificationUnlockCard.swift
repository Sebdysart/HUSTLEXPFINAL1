//
//  VerificationUnlockCard.swift
//  hustleXP final1
//
//  Molecule: Verification Unlock Progress Card
//  Shows progress toward free ID verification
//

import SwiftUI

struct VerificationUnlockCard: View {
    let status: VerificationUnlockStatus
    let onUnlockTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Free Verification", style: .headline)
                    HXText(
                        status.unlocked ? "Ready to submit!" : "Earn to unlock",
                        style: .caption,
                        color: .textSecondary
                    )
                }
                
                Spacer()
                
                if status.unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.successGreen)
                }
            }
            
            // Progress or Unlocked state
            if status.unlocked {
                unlockedView
            } else {
                progressView
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            status.unlocked 
                                ? Color.successGreen.opacity(0.3) 
                                : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: status.unlocked ? Color.successGreen.opacity(0.1) : .clear,
            radius: 10,
            y: 5
        )
    }
    
    // MARK: - Progress View
    
    private var progressView: some View {
        VStack(spacing: 16) {
            // Circular progress
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.surfaceSecondary, lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: status.progress)
                    .stroke(
                        AngularGradient(
                            colors: [Color.verificationProgress.opacity(0.6), Color.verificationProgress],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // Percentage text
                VStack(spacing: 0) {
                    Text("\(Int(status.percentage))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text("%")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            
            // Earnings info
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(status.formattedEarned)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.verificationProgress)
                    
                    Text("of \(status.formattedThreshold)")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Text("Earn \(status.formattedRemaining) more to unlock")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                
                // Tasks estimate
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                        .font(.caption)
                    Text("~\(status.estimatedTasksRemaining) more tasks")
                        .font(.caption)
                }
                .foregroundStyle(Color.textTertiary)
            }
        }
    }
    
    // MARK: - Unlocked View
    
    private var unlockedView: some View {
        VStack(spacing: 16) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.successGreen)
            }
            
            VStack(spacing: 4) {
                HXText("Verification Unlocked!", style: .headline, color: .successGreen)
                HXText("Submit your ID for free", style: .caption, color: .textSecondary)
            }
            
            HXButton("Submit Verification", variant: .primary, icon: "checkmark.shield") {
                onUnlockTap()
            }
        }
    }
}

// MARK: - Compact Variant

struct VerificationUnlockCardCompact: View {
    let status: VerificationUnlockStatus
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Mini progress ring
                ZStack {
                    Circle()
                        .stroke(Color.surfaceSecondary, lineWidth: 4)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: status.progress)
                        .stroke(
                            status.unlocked ? Color.successGreen : Color.verificationProgress,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    if status.unlocked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.successGreen)
                    } else {
                        Text("\(Int(status.percentage))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Free Verification", style: .subheadline)
                    if status.unlocked {
                        HXText("Ready to submit", style: .caption, color: .successGreen)
                    } else {
                        HXText("Earn \(status.formattedRemaining) more", style: .caption, color: .textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            // In progress
            VerificationUnlockCard(
                status: VerificationUnlockStatus(
                    earnedCents: 2500,
                    thresholdCents: 4000,
                    percentage: 62.5,
                    unlocked: false,
                    tasksCompleted: 8,
                    remainingCents: 1500
                ),
                onUnlockTap: {}
            )
            
            // Unlocked
            VerificationUnlockCard(
                status: VerificationUnlockStatus(
                    earnedCents: 4000,
                    thresholdCents: 4000,
                    percentage: 100,
                    unlocked: true,
                    tasksCompleted: 15,
                    remainingCents: 0
                ),
                onUnlockTap: {}
            )
            
            // Compact
            VerificationUnlockCardCompact(
                status: VerificationUnlockStatus(
                    earnedCents: 2500,
                    thresholdCents: 4000,
                    percentage: 62.5,
                    unlocked: false,
                    tasksCompleted: 8,
                    remainingCents: 1500
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
