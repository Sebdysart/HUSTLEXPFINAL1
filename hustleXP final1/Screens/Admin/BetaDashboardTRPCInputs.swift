//
//  BetaDashboardTRPCInputs.swift
//  hustleXP final1
//
//  tRPC input payloads for beta dashboard (Foundation-only so Encodable is not
//  MainActor-isolated when used from TRPCClient in Swift 6).
//

import Foundation

/// Sendable payloads with explicit `nonisolated` encoding so they can be used from
/// `TRPCClient` without MainActor-isolated `Encodable` (Swift 6).
struct BetaMetricsInput: Sendable {
    let windowDays: Int
}

extension BetaMetricsInput: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(windowDays, forKey: .windowDays)
    }

    private enum CodingKeys: String, CodingKey {
        case windowDays
    }
}

/// Encodes to `{}` — TRPCClient treats as empty input.
struct BetaDashboardEmptyInput: Sendable {}

extension BetaDashboardEmptyInput: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: CodingKeys.self)
    }

    private enum CodingKeys: CodingKey {}
}
