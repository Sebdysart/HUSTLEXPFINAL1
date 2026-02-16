//
//  HeatMapService.swift
//  hustleXP final1
//
//  Real tRPC service for task heat maps and demand alerts
//  Maps to backend heatmap.ts router
//

import Foundation
import Combine

// MARK: - Heat Map Types

struct HeatMapResponse: Codable {
    let zones: [HeatMapZone]
    let generatedAt: Date?
}

struct HeatMapZone: Codable, Identifiable {
    let id: String?
    let centerLat: Double
    let centerLng: Double
    let radiusMeters: Double
    let intensity: Double
    let taskCount: Int
    let averagePaymentCents: Int?

    var identifier: String { id ?? "\(centerLat),\(centerLng)" }
}

struct HeatMapDemandAlert: Codable, Identifiable {
    let id: String
    let lat: Double
    let lng: Double
    let category: String?
    let demandLevel: String
    let estimatedTasks: Int
    let message: String?
    let createdAt: Date?
}

// MARK: - Heat Map Service

/// Handles heat map data and demand alerts via tRPC
@MainActor
final class HeatMapService: ObservableObject {
    static let shared = HeatMapService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false

    private init() {}

    /// Get heat map data around a center point
    func getHeatMap(
        centerLat: Double,
        centerLng: Double,
        radiusMiles: Double? = nil,
        category: String? = nil
    ) async throws -> HeatMapResponse {
        isLoading = true
        defer { isLoading = false }

        struct HeatMapInput: Codable {
            let centerLat: Double
            let centerLng: Double
            let radiusMiles: Double?
            let category: String?
        }

        let result: HeatMapResponse = try await trpc.call(
            router: "heatmap",
            procedure: "getHeatMap",
            type: .query,
            input: HeatMapInput(
                centerLat: centerLat,
                centerLng: centerLng,
                radiusMiles: radiusMiles,
                category: category
            )
        )

        HXLogger.info("HeatMapService: Fetched \(result.zones.count) heat zones", category: "General")
        return result
    }

    /// Get demand alerts near a location
    func getHeatMapDemandAlerts(
        lat: Double,
        lng: Double
    ) async throws -> [HeatMapDemandAlert] {
        isLoading = true
        defer { isLoading = false }

        struct AlertInput: Codable {
            let lat: Double
            let lng: Double
        }

        let alerts: [HeatMapDemandAlert] = try await trpc.call(
            router: "heatmap",
            procedure: "getDemandAlerts",
            type: .query,
            input: AlertInput(lat: lat, lng: lng)
        )

        HXLogger.info("HeatMapService: Fetched \(alerts.count) demand alerts", category: "General")
        return alerts
    }
}
