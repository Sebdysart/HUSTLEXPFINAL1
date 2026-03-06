import Foundation
@testable import hustleXP_final1

/// Test double for TRPCClient that returns stubbed JSON responses.
/// Stubs are keyed by "router.procedure" (e.g., "task.create").
final class MockTRPCClient: TRPCClientProtocol {

    /// Stubbed JSON responses keyed by "router.procedure"
    private var stubs: [String: Data] = [:]

    /// Stubbed errors keyed by "router.procedure"
    private var errors: [String: Error] = [:]

    /// Every call recorded as (router, procedure) for verification
    private(set) var recordedCalls: [(router: String, procedure: String)] = []

    // MARK: - Stub API

    /// Stub a successful response with a JSON string.
    func stubJSON(_ key: String, json: String) {
        stubs[key] = json.data(using: .utf8)!
    }

    /// Stub an error for the given key.
    func stubError(_ key: String, error: Error) {
        errors[key] = error
    }

    /// Clear all stubs and recorded calls.
    func reset() {
        stubs.removeAll()
        errors.removeAll()
        recordedCalls.removeAll()
    }

    /// Returns true if a call was recorded matching the key.
    func wasCalled(_ key: String) -> Bool {
        recordedCalls.contains { "\($0.router).\($0.procedure)" == key }
    }

    /// Count of calls matching the key.
    func callCount(_ key: String) -> Int {
        recordedCalls.filter { "\($0.router).\($0.procedure)" == key }.count
    }

    // MARK: - TRPCClientProtocol

    func call<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        type: ProcedureType,
        input: Input
    ) async throws -> Output {
        let key = "\(router).\(procedure)"
        recordedCalls.append((router: router, procedure: procedure))

        if let error = errors[key] {
            throw error
        }

        guard let data = stubs[key] else {
            fatalError("MockTRPCClient: No stub for '\(key)'. Add mockClient.stubJSON(\"\(key)\", json: \"...\") in setUp().")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Output.self, from: data)
    }
}
