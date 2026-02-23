//
//  FeedFilterSheet.swift
//  hustleXP final1
//
//  v2.6.0: Advanced filter sheet for task discovery feed
//  Wired to backend taskDiscovery.getFeed filters (category, price, distance, sort)
//

import SwiftUI

struct FeedFilterSheet: View {
    @Binding var isPresented: Bool
    @Binding var filters: FeedFilterParams
    var onApply: () -> Void

    @State private var selectedCategory: TaskCategory?
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 500
    @State private var maxDistance: Double = 10
    @State private var sortBy: FeedSortOption = .relevance

    // Track whether user has customized price/distance from defaults
    @State private var priceFilterEnabled: Bool = false
    @State private var distanceFilterEnabled: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Sort by
                        sortSection

                        HXDivider()

                        // Category
                        categorySection

                        HXDivider()

                        // Price range
                        priceSection

                        HXDivider()

                        // Distance
                        distanceSection

                        // Apply / Reset
                        buttonSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Filter Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .onAppear { loadCurrentFilters() }
        }
    }

    // MARK: - Sort Section

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HXText("Sort By", style: .headline)

            HStack(spacing: 8) {
                ForEach(FeedSortOption.allCases) { option in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            sortBy = option
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.icon)
                                .font(.system(size: 16, weight: .semibold))
                            Text(option.displayName)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(sortBy == option ? .white : Color.textSecondary)
                        .background(sortBy == option ? Color.brandPurple : Color.surfaceElevated)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Category", style: .headline)
                Spacer()
                if selectedCategory != nil {
                    Button("Clear") {
                        withAnimation { selectedCategory = nil }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brandPurple)
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(TaskCategory.allCases, id: \.rawValue) { category in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 20))
                            Text(category.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(selectedCategory == category ? .white : Color.textSecondary)
                        .background(selectedCategory == category ? Color.brandPurple : Color.surfaceElevated)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCategory == category ? Color.brandPurple : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Price Section

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Price Range", style: .headline)
                Spacer()
                Toggle("", isOn: $priceFilterEnabled)
                    .labelsHidden()
                    .tint(Color.brandPurple)
            }

            if priceFilterEnabled {
                VStack(spacing: 16) {
                    HStack {
                        Text("$\(Int(minPrice))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.moneyGreen)
                        Spacer()
                        Text("to")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(maxPrice >= 500 ? "$500+" : "$\(Int(maxPrice))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.moneyGreen)
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Text("Min")
                                .font(.caption)
                                .foregroundStyle(Color.textMuted)
                            Slider(value: $minPrice, in: 0...490, step: 10) { _ in
                                if minPrice >= maxPrice { maxPrice = min(minPrice + 10, 500) }
                            }
                            .tint(Color.brandPurple)
                        }
                        HStack {
                            Text("Max")
                                .font(.caption)
                                .foregroundStyle(Color.textMuted)
                            Slider(value: $maxPrice, in: 10...500, step: 10) { _ in
                                if maxPrice <= minPrice { minPrice = max(maxPrice - 10, 0) }
                            }
                            .tint(Color.brandPurple)
                        }
                    }
                }
                .padding(16)
                .background(Color.surfaceElevated)
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3), value: priceFilterEnabled)
    }

    // MARK: - Distance Section

    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HXText("Max Distance", style: .headline)
                Spacer()
                Toggle("", isOn: $distanceFilterEnabled)
                    .labelsHidden()
                    .tint(Color.brandPurple)
            }

            if distanceFilterEnabled {
                VStack(spacing: 12) {
                    Text(maxDistance >= 50 ? "50+ miles" : "\(Int(maxDistance)) miles")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Slider(value: $maxDistance, in: 1...50, step: 1)
                        .tint(Color.brandPurple)

                    HStack {
                        Text("1 mi")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                        Spacer()
                        Text("50 mi")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(16)
                .background(Color.surfaceElevated)
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3), value: distanceFilterEnabled)
    }

    // MARK: - Buttons

    private var buttonSection: some View {
        VStack(spacing: 12) {
            HXButton("Apply Filters", variant: .primary) {
                applyFilters()
            }

            if hasActiveFilters {
                HXButton("Reset All", variant: .secondary) {
                    resetFilters()
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Logic

    private var hasActiveFilters: Bool {
        selectedCategory != nil || priceFilterEnabled || distanceFilterEnabled || sortBy != .relevance
    }

    private func loadCurrentFilters() {
        selectedCategory = filters.category
        sortBy = filters.sortBy ?? .relevance

        if let min = filters.minPriceCents {
            minPrice = Double(min) / 100.0
            priceFilterEnabled = true
        }
        if let max = filters.maxPriceCents {
            maxPrice = Double(max) / 100.0
            priceFilterEnabled = true
        }
        if let dist = filters.maxDistanceMiles {
            maxDistance = dist
            distanceFilterEnabled = true
        }
    }

    private func applyFilters() {
        filters = FeedFilterParams(
            category: selectedCategory,
            minPriceCents: priceFilterEnabled ? Int(minPrice * 100) : nil,
            maxPriceCents: priceFilterEnabled ? (maxPrice >= 500 ? nil : Int(maxPrice * 100)) : nil,
            maxDistanceMiles: distanceFilterEnabled ? (maxDistance >= 50 ? nil : maxDistance) : nil,
            sortBy: sortBy
        )
        isPresented = false
        onApply()
    }

    private func resetFilters() {
        selectedCategory = nil
        minPrice = 0
        maxPrice = 500
        maxDistance = 10
        sortBy = .relevance
        priceFilterEnabled = false
        distanceFilterEnabled = false
    }
}

#Preview {
    FeedFilterSheet(
        isPresented: .constant(true),
        filters: .constant(FeedFilterParams()),
        onApply: { }
    )
}
