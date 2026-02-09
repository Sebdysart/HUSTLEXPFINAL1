//
//  AIPricing.swift
//  hustleXP final1
//
//  AI-Suggested Pricing models for v1.8.0
//

import Foundation

// MARK: - AI Price Suggestion

struct AIPriceSuggestion: Codable {
    let suggestedPriceCents: Int
    let xpReward: Int
    let rationale: String
    let priceRangeLowCents: Int
    let priceRangeHighCents: Int
    let confidence: PricingConfidence
    let factors: [PricingFactor]
    
    /// Formatted suggested price as dollars
    var formattedSuggestedPrice: String {
        let dollars = Double(suggestedPriceCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
    
    /// Formatted price range
    var formattedPriceRange: String {
        let low = Double(priceRangeLowCents) / 100.0
        let high = Double(priceRangeHighCents) / 100.0
        return String(format: "$%.0f - $%.0f", low, high)
    }
    
    /// Suggested price as Double (for binding)
    var suggestedPriceDollars: Double {
        Double(suggestedPriceCents) / 100.0
    }
    
    /// Range low as Double
    var rangeLowDollars: Double {
        Double(priceRangeLowCents) / 100.0
    }
    
    /// Range high as Double
    var rangeHighDollars: Double {
        Double(priceRangeHighCents) / 100.0
    }
}

// MARK: - Pricing Confidence

enum PricingConfidence: String, Codable {
    case high
    case medium
    case low
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var description: String {
        switch self {
        case .high: return "Strong market data available"
        case .medium: return "Based on similar tasks"
        case .low: return "Limited comparison data"
        }
    }
}

// MARK: - Pricing Factor

struct PricingFactor: Identifiable, Codable {
    let id: String
    let name: String
    let impact: FactorImpact
    let description: String
    
    init(id: String = UUID().uuidString, name: String, impact: FactorImpact, description: String) {
        self.id = id
        self.name = name
        self.impact = impact
        self.description = description
    }
}

enum FactorImpact: String, Codable {
    case positive
    case negative
    case neutral
    
    var icon: String {
        switch self {
        case .positive: return "arrow.up.circle.fill"
        case .negative: return "arrow.down.circle.fill"
        case .neutral: return "equal.circle.fill"
        }
    }
}

// MARK: - Task Category (for AI pricing)

enum TaskCategory: String, Codable, CaseIterable {
    case delivery = "delivery"
    case moving = "moving"
    case cleaning = "cleaning"
    case yardWork = "yard_work"
    case assembly = "assembly"
    case petCare = "pet_care"
    case shopping = "shopping"
    case tech = "tech"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .delivery: return "Delivery"
        case .moving: return "Moving"
        case .cleaning: return "Cleaning"
        case .yardWork: return "Yard Work"
        case .assembly: return "Assembly"
        case .petCare: return "Pet Care"
        case .shopping: return "Shopping"
        case .tech: return "Tech Help"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .delivery: return "shippingbox"
        case .moving: return "truck.box"
        case .cleaning: return "sparkles"
        case .yardWork: return "leaf"
        case .assembly: return "wrench.and.screwdriver"
        case .petCare: return "pawprint"
        case .shopping: return "cart"
        case .tech: return "laptopcomputer"
        case .other: return "questionmark.circle"
        }
    }
    
    /// Base price range for this category (in cents)
    var basePriceRange: ClosedRange<Int> {
        switch self {
        case .delivery: return 1500...5000
        case .moving: return 5000...15000
        case .cleaning: return 4000...12000
        case .yardWork: return 3000...10000
        case .assembly: return 3000...8000
        case .petCare: return 2000...6000
        case .shopping: return 2000...5000
        case .tech: return 4000...10000
        case .other: return 2000...10000
        }
    }
}

// MARK: - AI Pricing Request

struct AIPricingRequest {
    let title: String
    let description: String
    let category: TaskCategory
    let estimatedDuration: String?
    let location: String?
    
    /// Generate a mock AI suggestion (for prototyping)
    func generateMockSuggestion() -> AIPriceSuggestion {
        let baseRange = category.basePriceRange
        let midPoint = (baseRange.lowerBound + baseRange.upperBound) / 2
        
        // Add some variation based on description length (proxy for complexity)
        let complexityBonus = min(description.count / 50, 3) * 500
        let suggested = midPoint + complexityBonus
        
        return AIPriceSuggestion(
            suggestedPriceCents: suggested,
            xpReward: suggested / 10,
            rationale: "Based on similar \(category.displayName.lowercased()) tasks in your area",
            priceRangeLowCents: baseRange.lowerBound,
            priceRangeHighCents: baseRange.upperBound,
            confidence: .medium,
            factors: [
                PricingFactor(name: "Category", impact: .neutral, description: category.displayName),
                PricingFactor(name: "Complexity", impact: complexityBonus > 0 ? .positive : .neutral, description: "Based on task details"),
                PricingFactor(name: "Market Rate", impact: .neutral, description: "Competitive pricing for your area")
            ]
        )
    }
}
