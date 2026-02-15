//
//  AlphaTelemetryService.swift
//  hustleXP final1
//
//  Real tRPC service for alpha instrumentation and health dashboard
//  Maps to backend alpha-telemetry.ts router
//
//  Provides:
//  - Edge state distribution analytics
//  - Time-spent metrics per edge state
//  - Dispute rate tracking
//  - Proof correction rate tracking
//  - Trust tier movement histogram
//  - Client-side edge state impression/exit event emission
//

import Foundation
import Combine

// MARK: - Edge State Types

/// Edge states matching backend enum
enum EdgeState: String, Codable, CaseIterable {
    case noTasksAvailable = "E1_NO_TASKS_AVAILABLE"
    case eligibilityMismatch = "E2_ELIGIBILITY_MISMATCH"
    case trustTierLocked = "E3_TRUST_TIER_LOCKED"
}

/// Exit types for edge state exit events
enum EdgeStateExitType: String, Codable {
    case continueAction = "continue"
    case back = "back"
    case appBackground = "app_background"
    case sessionEnd = "session_end"
}

/// User role for telemetry
enum TelemetryRole: String, Codable {
    case hustler = "hustler"
    case poster = "poster"
}

/// Trust delta type for tier movement
enum TrustDeltaType: String, Codable {
    case xp = "xp"
    case tier = "tier"
    case streak = "streak"
}

// MARK: - Response Types

/// Edge state distribution row
struct EdgeStateDistribution: Codable {
    let state: String
    let count: Int
    let uniqueUsers: Int

    enum CodingKeys: String, CodingKey {
        case state
        case count
        case uniqueUsers = "unique_users"
    }
}

/// Time spent per edge state
struct EdgeStateTimeSpent: Codable {
    let state: String
    let avgTimeMs: Int
    let medianTimeMs: Int
    let p90TimeMs: Int
    let exitCount: Int

    enum CodingKeys: String, CodingKey {
        case state
        case avgTimeMs = "avg_time_ms"
        case medianTimeMs = "median_time_ms"
        case p90TimeMs = "p90_time_ms"
        case exitCount = "exit_count"
    }
}

/// Dispute rate response
struct DisputeRateResponse: Codable {
    let totalTasks: Int
    let totalAttempts: Int
    let disputeRatePer100: Double

    enum CodingKeys: String, CodingKey {
        case totalTasks = "total_tasks"
        case totalAttempts = "total_attempts"
        case disputeRatePer100 = "dispute_rate_per_100"
    }
}

/// Proof correction rate response
struct ProofCorrectionRateResponse: Codable {
    let totalFailures: Int
    let totalResolved: Int
    let correctionSuccessRate: Double

    enum CodingKeys: String, CodingKey {
        case totalFailures = "total_failures"
        case totalResolved = "total_resolved"
        case correctionSuccessRate = "correction_success_rate"
    }
}

/// Trust tier movement row
struct TrustTierMovement: Codable {
    let deltaType: String
    let reasonCode: String
    let count: Int
    let avgDelta: Double
    let totalDelta: Double

    enum CodingKeys: String, CodingKey {
        case deltaType = "delta_type"
        case reasonCode = "reason_code"
        case count
        case avgDelta = "avg_delta"
        case totalDelta = "total_delta"
    }
}

// MARK: - Alpha Telemetry Service

/// Manages alpha instrumentation and health dashboard via tRPC
@MainActor
final class AlphaTelemetryService: ObservableObject {
    static let shared = AlphaTelemetryService()

    private let trpc = TRPCClient.shared

    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Query: Edge State Distribution

    /// Gets edge state distribution counts over a time period
    func getEdgeStateDistribution(
        startDate: Date,
        endDate: Date? = nil,
        role: TelemetryRole? = nil
    ) async throws -> [EdgeStateDistribution] {
        struct DistributionInput: Codable {
            let start_date: Date
            let end_date: Date?
            let role: String?
        }

        let rows: [EdgeStateDistribution] = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "getEdgeStateDistribution",
            type: .query,
            input: DistributionInput(
                start_date: startDate,
                end_date: endDate,
                role: role?.rawValue
            )
        )

        print("✅ AlphaTelemetry: Fetched \(rows.count) edge state distribution rows")
        return rows
    }

    // MARK: - Query: Edge State Time Spent

    /// Gets average time spent per edge state
    func getEdgeStateTimeSpent(
        startDate: Date,
        endDate: Date? = nil,
        state: EdgeState? = nil
    ) async throws -> [EdgeStateTimeSpent] {
        struct TimeSpentInput: Codable {
            let start_date: Date
            let end_date: Date?
            let state: String?
        }

        let rows: [EdgeStateTimeSpent] = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "getEdgeStateTimeSpent",
            type: .query,
            input: TimeSpentInput(
                start_date: startDate,
                end_date: endDate,
                state: state?.rawValue
            )
        )

        print("✅ AlphaTelemetry: Fetched \(rows.count) time spent rows")
        return rows
    }

    // MARK: - Query: Dispute Rate

    /// Gets dispute attempts per 100 tasks
    func getDisputeRate(
        startDate: Date,
        endDate: Date? = nil
    ) async throws -> DisputeRateResponse {
        struct DisputeInput: Codable {
            let start_date: Date
            let end_date: Date?
        }

        let response: DisputeRateResponse = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "getDisputeRate",
            type: .query,
            input: DisputeInput(start_date: startDate, end_date: endDate)
        )

        print("✅ AlphaTelemetry: Dispute rate = \(response.disputeRatePer100) per 100 tasks")
        return response
    }

    // MARK: - Query: Proof Correction Rate

    /// Gets proof failure → correction success rate
    func getProofCorrectionRate(
        startDate: Date,
        endDate: Date? = nil
    ) async throws -> ProofCorrectionRateResponse {
        struct CorrectionInput: Codable {
            let start_date: Date
            let end_date: Date?
        }

        let response: ProofCorrectionRateResponse = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "getProofCorrectionRate",
            type: .query,
            input: CorrectionInput(start_date: startDate, end_date: endDate)
        )

        print("✅ AlphaTelemetry: Correction success rate = \(response.correctionSuccessRate)%")
        return response
    }

    // MARK: - Query: Trust Tier Movement

    /// Gets trust tier movement histogram
    func getTrustTierMovement(
        startDate: Date,
        endDate: Date? = nil,
        deltaType: TrustDeltaType? = nil
    ) async throws -> [TrustTierMovement] {
        struct TierInput: Codable {
            let start_date: Date
            let end_date: Date?
            let delta_type: String?
        }

        let rows: [TrustTierMovement] = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "getTrustTierMovement",
            type: .query,
            input: TierInput(
                start_date: startDate,
                end_date: endDate,
                delta_type: deltaType?.rawValue
            )
        )

        print("✅ AlphaTelemetry: Fetched \(rows.count) trust tier movement rows")
        return rows
    }

    // MARK: - Mutation: Emit Edge State Impression

    /// Fires when edge screen becomes primary visible screen
    func emitEdgeStateImpression(
        state: EdgeState,
        role: TelemetryRole,
        trustTier: Int,
        locationRadiusMiles: Double? = nil,
        instantModeEnabled: Bool,
        edgeStateVersion: String = "v1"
    ) async throws {
        struct ImpressionInput: Codable {
            let state: String
            let role: String
            let trust_tier: Int
            let location_radius_miles: Double?
            let instant_mode_enabled: Bool
            let edge_state_version: String
        }

        struct SuccessResponse: Codable {
            let success: Bool
        }

        let _: SuccessResponse = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "emitEdgeStateImpression",
            input: ImpressionInput(
                state: state.rawValue,
                role: role.rawValue,
                trust_tier: trustTier,
                location_radius_miles: locationRadiusMiles,
                instant_mode_enabled: instantModeEnabled,
                edge_state_version: edgeStateVersion
            )
        )

        print("✅ AlphaTelemetry: Emitted edge state impression [\(state.rawValue)]")
    }

    // MARK: - Mutation: Emit Edge State Exit

    /// Fires when user leaves the edge screen
    func emitEdgeStateExit(
        state: EdgeState,
        role: TelemetryRole,
        timeOnScreenMs: Int,
        exitType: EdgeStateExitType,
        edgeStateVersion: String = "v1"
    ) async throws {
        struct ExitInput: Codable {
            let state: String
            let role: String
            let time_on_screen_ms: Int
            let exit_type: String
            let edge_state_version: String
        }

        struct SuccessResponse: Codable {
            let success: Bool
        }

        let _: SuccessResponse = try await trpc.call(
            router: "alphaTelemetry",
            procedure: "emitEdgeStateExit",
            input: ExitInput(
                state: state.rawValue,
                role: role.rawValue,
                time_on_screen_ms: timeOnScreenMs,
                exit_type: exitType.rawValue,
                edge_state_version: edgeStateVersion
            )
        )

        print("✅ AlphaTelemetry: Emitted edge state exit [\(state.rawValue)] after \(timeOnScreenMs)ms")
    }
}
