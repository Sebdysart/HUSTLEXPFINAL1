//
//  ClaimCard.swift
//  hustleXP final1
//
//  Molecule: Insurance Claim Card
//  Shows claim details with status badge
//

import SwiftUI

struct ClaimCard: View {
    let claim: InsuranceClaim
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HXText(claim.taskTitle, style: .headline)
                        HXText("Filed \(formatDate(claim.filedAt))", style: .caption, color: .textSecondary)
                    }
                    
                    Spacer()
                    
                    ClaimStatusBadge(status: claim.status)
                }
                
                // Description preview
                Text(claim.descriptionPreview)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Amount row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HXText("Requested", style: .caption, color: .textMuted)
                        Text(claim.formattedRequestedAmount)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    
                    Spacer()
                    
                    if let approvedAmount = claim.formattedApprovedAmount {
                        VStack(alignment: .trailing, spacing: 2) {
                            HXText("Approved", style: .caption, color: .textMuted)
                            Text(approvedAmount)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.successGreen)
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(statusBorderColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var statusBorderColor: Color {
        switch claim.status {
        case .filed: return .textMuted
        case .underReview: return .warningOrange
        case .approved: return .successGreen
        case .denied: return .errorRed
        case .paid: return .infoBlue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Claim Status Badge

struct ClaimStatusBadge: View {
    let status: ClaimStatus
    
    private var badgeColor: Color {
        switch status {
        case .filed: return .textMuted
        case .underReview: return .warningOrange
        case .approved: return .successGreen
        case .denied: return .errorRed
        case .paid: return .infoBlue
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 10))
            
            Text(status.displayName)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Claim Detail Card

struct ClaimDetailCard: View {
    let claim: InsuranceClaim
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Status header
            HStack {
                ClaimStatusBadge(status: claim.status)
                
                Spacer()
                
                if claim.status.isFinal {
                    Image(systemName: claim.status == .paid ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(claim.status == .paid ? Color.successGreen : Color.errorRed)
                }
            }
            
            // Task info
            VStack(alignment: .leading, spacing: 4) {
                HXText("Related Task", style: .caption, color: .textMuted)
                HXText(claim.taskTitle, style: .headline)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 4) {
                HXText("Incident Description", style: .caption, color: .textMuted)
                Text(claim.incidentDescription)
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Amounts
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Requested", style: .caption, color: .textMuted)
                    Text(claim.formattedRequestedAmount)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                if let approvedAmount = claim.formattedApprovedAmount {
                    VStack(alignment: .leading, spacing: 4) {
                        HXText("Approved", style: .caption, color: .textMuted)
                        Text(approvedAmount)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.successGreen)
                    }
                }
            }
            
            // Timeline
            VStack(alignment: .leading, spacing: 8) {
                HXText("Timeline", style: .caption, color: .textMuted)
                
                TimelineItem(
                    icon: "doc.text",
                    title: "Claim Filed",
                    date: claim.filedAt,
                    isComplete: true
                )
                
                if let reviewedAt = claim.reviewedAt {
                    TimelineItem(
                        icon: "magnifyingglass",
                        title: "Reviewed",
                        date: reviewedAt,
                        isComplete: true
                    )
                } else if claim.status == .underReview {
                    TimelineItem(
                        icon: "magnifyingglass",
                        title: "Under Review",
                        date: nil,
                        isComplete: false,
                        isCurrent: true
                    )
                }
                
                if claim.status == .paid {
                    TimelineItem(
                        icon: "banknote",
                        title: "Payment Sent",
                        date: claim.reviewedAt,
                        isComplete: true
                    )
                }
            }
            
            // Reviewer notes
            if let notes = claim.reviewerNotes {
                VStack(alignment: .leading, spacing: 4) {
                    HXText("Reviewer Notes", style: .caption, color: .textMuted)
                    
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surfaceSecondary)
                        .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
        )
    }
}

// MARK: - Timeline Item

private struct TimelineItem: View {
    let icon: String
    let title: String
    let date: Date?
    let isComplete: Bool
    var isCurrent: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isComplete ? Color.successGreen.opacity(0.15) :
                          isCurrent ? Color.warningOrange.opacity(0.15) :
                          Color.surfaceSecondary)
                    .frame(width: 32, height: 32)
                
                Image(systemName: isComplete ? "checkmark" : icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isComplete ? Color.successGreen :
                                     isCurrent ? Color.warningOrange :
                                     Color.textMuted)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                
                if let date = date {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                } else if isCurrent {
                    Text("In progress...")
                        .font(.caption)
                        .foregroundStyle(Color.warningOrange)
                }
            }
            
            Spacer()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 16) {
                ClaimCard(
                    claim: InsuranceClaim(
                        id: "claim-001",
                        taskId: "task-001",
                        taskTitle: "Furniture delivery gone wrong",
                        incidentDescription: "The poster never responded after I completed the work. I delivered the furniture as requested but they ghosted me.",
                        requestedAmountCents: 7500,
                        approvedAmountCents: 6000,
                        status: .approved,
                        filedAt: Date().addingTimeInterval(-86400 * 5),
                        reviewedAt: Date().addingTimeInterval(-86400 * 2),
                        reviewerNotes: "Claim approved at 80% coverage."
                    ),
                    onTap: {}
                )
                
                ClaimCard(
                    claim: InsuranceClaim(
                        id: "claim-002",
                        taskId: "task-002",
                        taskTitle: "Package delivery issue",
                        incidentDescription: "Package was damaged during delivery and client refused to pay.",
                        requestedAmountCents: 5000,
                        approvedAmountCents: nil,
                        status: .underReview,
                        filedAt: Date().addingTimeInterval(-86400),
                        reviewedAt: nil,
                        reviewerNotes: nil
                    ),
                    onTap: {}
                )
                
                ClaimDetailCard(
                    claim: InsuranceClaim(
                        id: "claim-001",
                        taskId: "task-001",
                        taskTitle: "Furniture delivery gone wrong",
                        incidentDescription: "The poster never responded after I completed the work. I delivered the furniture as requested but they ghosted me after multiple attempts to contact them.",
                        requestedAmountCents: 7500,
                        approvedAmountCents: 6000,
                        status: .paid,
                        filedAt: Date().addingTimeInterval(-86400 * 10),
                        reviewedAt: Date().addingTimeInterval(-86400 * 5),
                        reviewerNotes: "Claim approved at 80% coverage based on task completion evidence and communication logs."
                    )
                )
            }
            .padding()
        }
    }
}
