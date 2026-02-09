//
//  InsurancePoolCard.swift
//  hustleXP final1
//
//  Molecule: Insurance Pool Card
//  Shows pool status and user contributions
//

import SwiftUI

struct InsurancePoolCard: View {
    let poolStatus: InsurancePoolStatus
    let onFileClaimTap: () -> Void
    let onViewClaimsTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.insurancePool.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.insurancePool)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Insurance Protection", style: .headline)
                    HXText("2% per task contribution", style: .caption, color: .textSecondary)
                }
                
                Spacer()
            }
            
            // Pool balance
            VStack(alignment: .leading, spacing: 4) {
                HXText("Community Pool", style: .caption, color: .textMuted)
                
                Text(poolStatus.formattedPoolBalance)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.insurancePool)
            }
            
            // Stats row
            HStack(spacing: 0) {
                StatItem(
                    icon: "person.2.fill",
                    value: "\(poolStatus.activeClaimsCount)",
                    label: "Active Claims"
                )
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 12)
                
                StatItem(
                    icon: "arrow.up.circle.fill",
                    value: poolStatus.formattedUserContributions,
                    label: "Your Contributions"
                )
            }
            .padding(12)
            .background(Color.surfaceSecondary)
            .cornerRadius(12)
            
            // Actions
            HStack(spacing: 12) {
                Button(action: onViewClaimsTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet.rectangle")
                        Text("My Claims")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(10)
                }
                
                Button(action: onFileClaimTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("File Claim")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.insuranceClaim)
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

// MARK: - Stat Item

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
                
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Compact Variant

struct InsurancePoolCardCompact: View {
    let poolStatus: InsurancePoolStatus
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.insurancePool.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.insurancePool)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HXText("Insurance", style: .subheadline)
                    HXText("\(poolStatus.activeClaimsCount) active claims", style: .caption, color: .textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(poolStatus.formattedUserContributions)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.insurancePool)
                    
                    Text("contributed")
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
                }
                
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
            InsurancePoolCard(
                poolStatus: InsurancePoolStatus(
                    poolBalanceCents: 12500000,
                    totalContributionsCents: 15000000,
                    totalPaidClaimsCents: 2500000,
                    activeClaimsCount: 12,
                    userContributionsCents: 650
                ),
                onFileClaimTap: {},
                onViewClaimsTap: {}
            )
            
            InsurancePoolCardCompact(
                poolStatus: InsurancePoolStatus(
                    poolBalanceCents: 12500000,
                    totalContributionsCents: 15000000,
                    totalPaidClaimsCents: 2500000,
                    activeClaimsCount: 12,
                    userContributionsCents: 650
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
