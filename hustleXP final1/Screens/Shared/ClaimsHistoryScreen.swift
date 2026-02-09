//
//  ClaimsHistoryScreen.swift
//  hustleXP final1
//
//  Screen: Claims History
//  View all filed insurance claims
//

import SwiftUI

struct ClaimsHistoryScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    @Environment(MockDataService.self) private var dataService
    
    @State private var selectedFilter: ClaimFilter = .all
    @State private var selectedClaim: InsuranceClaim?
    @State private var showClaimDetail = false
    
    private enum ClaimFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case resolved = "Resolved"
        
        var statuses: [ClaimStatus] {
            switch self {
            case .all: return ClaimStatus.allCases
            case .active: return [.filed, .underReview]
            case .resolved: return [.approved, .denied, .paid]
            }
        }
    }
    
    private var filteredClaims: [InsuranceClaim] {
        dataService.insuranceClaims.filter { claim in
            selectedFilter.statuses.contains(claim.status)
        }
    }
    
    var body: some View {
        ZStack {
            Color.brandBlack.ignoresSafeArea()
            
            if dataService.insuranceClaims.isEmpty {
                emptyStateView
            } else {
                claimsListView
            }
        }
        .navigationTitle("My Claims")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBlack, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Navigate to file claim
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.brandPurple)
                }
            }
        }
        .sheet(isPresented: $showClaimDetail) {
            if let claim = selectedClaim {
                ClaimDetailSheet(claim: claim)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.insurancePool.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.insurancePool)
            }
            
            VStack(spacing: 8) {
                HXText("No Claims Filed", style: .title2)
                HXText(
                    "File a claim if you encounter issues with a completed task",
                    style: .body,
                    color: .textSecondary,
                    alignment: .center
                )
            }
            .padding(.horizontal, 40)
            
            HXButton("File a Claim", variant: .primary, icon: "plus.circle.fill") {
                // Navigate to file claim
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Claims List
    
    private var claimsListView: some View {
        VStack(spacing: 0) {
            // Filter tabs
            filterTabs
            
            // Claims list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredClaims) { claim in
                        ClaimCard(claim: claim) {
                            selectedClaim = claim
                            showClaimDetail = true
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Filter Tabs
    
    private var filterTabs: some View {
        HStack(spacing: 8) {
            ForEach(ClaimFilter.allCases, id: \.self) { filter in
                FilterChip(
                    title: filter.rawValue,
                    count: countForFilter(filter),
                    isSelected: selectedFilter == filter
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.surfaceSecondary)
    }
    
    private func countForFilter(_ filter: ClaimFilter) -> Int {
        dataService.insuranceClaims.filter { claim in
            filter.statuses.contains(claim.status)
        }.count
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.2) : Color.surfaceSecondary)
                        .cornerRadius(4)
                }
            }
            .foregroundStyle(isSelected ? .white : Color.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brandPurple : Color.surfaceElevated)
            .cornerRadius(10)
        }
    }
}

// MARK: - Claim Detail Sheet

private struct ClaimDetailSheet: View {
    let claim: InsuranceClaim
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ClaimDetailCard(claim: claim)
                        
                        // Contact support option for denied claims
                        if claim.status == .denied {
                            appealSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Claim Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
        }
    }
    
    private var appealSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Not satisfied with this decision?", style: .subheadline)
            
            HXButton("Contact Support", variant: .secondary, icon: "message.fill") {
                // Contact support action
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        ClaimsHistoryScreen()
    }
    .environment(AppState())
    .environment(Router())
    .environment(MockDataService.shared)
}
