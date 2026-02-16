import Foundation
import Combine

// MARK: - ISO 8601 with fractional seconds

/// Formatter that handles both `"2026-02-10T09:14:05Z"` and `"2026-02-10T09:14:05.161Z"`
private let iso8601Full: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

private let iso8601NoFraction: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

/// tRPC API client for communicating with the Node.js backend
///
/// Handles all network communication with the Railway-deployed backend,
/// including authentication token management and request/response serialization.
@MainActor
final class TRPCClient: ObservableObject {
    static let shared = TRPCClient()

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?
    private var isRefreshingToken = false

    init() {
        // Railway production backend
        // swiftlint:disable:next force_unwrapping
        guard let url = URL(string: "https://hustlexp-ai-backend-staging-production.up.railway.app") else {
            fatalError("TRPCClient: Invalid hardcoded base URL — this is a programmer error")
        }
        self.baseURL = url

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    /// tRPC procedure type – determines HTTP method
    enum ProcedureType {
        case query    // GET  – read operations
        case mutation // POST – write operations
    }

    // MARK: - Generic tRPC Call

    /// Makes a tRPC procedure call to the backend
    /// - Parameters:
    ///   - router: The tRPC router name (e.g., "user", "task", "escrow")
    ///   - procedure: The procedure name (e.g., "register", "listOpen", "accept")
    ///   - type: `.query` (GET) or `.mutation` (POST). Defaults to `.mutation`.
    ///   - input: Encodable input parameters for the procedure
    /// - Returns: Decoded response of type Output
    func call<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        type: ProcedureType = .mutation,
        input: Input
    ) async throws -> Output {
        try await performCall(router: router, procedure: procedure, type: type, input: input, isRetry: false)
    }

    /// Internal call implementation with automatic 401 token refresh + retry
    private func performCall<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        type: ProcedureType,
        input: Input,
        isRetry: Bool
    ) async throws -> Output {
        let path = "\(router).\(procedure)"
        var request: URLRequest

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        switch type {
        case .query:
            // tRPC queries use GET with input as JSON-encoded URL param
            let inputData = try encoder.encode(input)
            let inputJSON = String(data: inputData, encoding: .utf8) ?? "{}"
            guard var components = URLComponents(url: baseURL.appendingPathComponent("/trpc/\(path)"), resolvingAgainstBaseURL: false) else {
                throw APIError.invalidResponse
            }
            // Only add input param if it contains real data (not empty object)
            if inputJSON != "{}" {
                components.queryItems = [URLQueryItem(name: "input", value: inputJSON)]
            }
            guard let queryURL = components.url else {
                throw APIError.invalidResponse
            }
            request = URLRequest(url: queryURL)
            request.httpMethod = "GET"

        case .mutation:
            // tRPC mutations use POST with JSON body
            request = URLRequest(url: baseURL.appendingPathComponent("/trpc/\(path)"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(input)
        }

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Make request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Log error details for debugging
            HXLogger.error("tRPC HTTP \(httpResponse.statusCode) for \(path)", category: "Network")
            if let body = String(data: data, encoding: .utf8) {
                HXLogger.error("tRPC error body: \(body.prefix(500))", category: "Network")
            }

            // 401 auto-refresh: If token expired, refresh and retry once
            if httpResponse.statusCode == 401 && !isRetry && !isRefreshingToken {
                HXLogger.info("tRPC: 401 received for \(path) — attempting token refresh", category: "Network")
                isRefreshingToken = true
                do {
                    try await AuthService.shared.refreshToken()
                    isRefreshingToken = false
                    HXLogger.info("tRPC: Token refreshed — retrying \(path)", category: "Network")
                    return try await performCall(router: router, procedure: procedure, type: type, input: input, isRetry: true)
                } catch {
                    isRefreshingToken = false
                    HXLogger.error("tRPC: Token refresh failed — \(error.localizedDescription)", category: "Network")
                    throw APIError.unauthorized
                }
            }

            // Try to decode tRPC error with HX error code support
            if let errorResponse = try? JSONDecoder().decode(TRPCError.self, from: data) {
                let message = errorResponse.error.message
                // Check for HX-series constitutional error codes (e.g., HX001, HX904)
                if let hxCode = errorResponse.error.code,
                   hxCode.hasPrefix("HX") || message.contains("HX") {
                    throw APIError.constitutionalViolation(code: hxCode, message: message)
                }
                // Map tRPC error codes to APIError types
                switch errorResponse.error.code {
                case "UNAUTHORIZED":
                    throw APIError.unauthorized
                case "NOT_FOUND":
                    throw APIError.notFound
                case "FORBIDDEN":
                    throw APIError.forbidden(message)
                default:
                    throw APIError.serverError(message)
                }
            }
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response - unwrap tRPC envelope { "result": { "data": ... } }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = iso8601Full.date(from: dateString) { return date }
            if let date = iso8601NoFraction.date(from: dateString) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(dateString)"
            )
        }

        do {
            let envelope = try decoder.decode(TRPCResponse<Output>.self, from: data)
            return envelope.result.data
        } catch {
            HXLogger.error("tRPC decode error: \(error)", category: "Network")
            if let str = String(data: data, encoding: .utf8) {
                HXLogger.error("tRPC raw response: \(str.prefix(500))", category: "Network")
            }
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Authentication

    /// Sets the Firebase ID token for authenticated requests
    func setAuthToken(_ token: String) {
        self.authToken = token
        KeychainManager.shared.save(token, forKey: "authToken")
    }

    /// Clears the authentication token
    func clearAuthToken() {
        self.authToken = nil
        KeychainManager.shared.delete(forKey: "authToken")
    }

    /// Loads the auth token from secure storage
    func loadAuthToken() {
        if let savedToken = KeychainManager.shared.get(forKey: "authToken") {
            self.authToken = savedToken
        }
    }
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case forbidden(String)
    case notFound
    case constitutionalViolation(code: String, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "Server error (HTTP \(code))"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Authentication required"
        case .forbidden(let message):
            return message
        case .notFound:
            return "Resource not found"
        case .constitutionalViolation(let code, let message):
            return "[\(code)] \(message)"
        }
    }

    /// HX error code if this is a constitutional violation
    var hxCode: String? {
        if case .constitutionalViolation(let code, _) = self { return code }
        return nil
    }

    /// User-friendly message for HX codes
    var userFacingMessage: String {
        switch self {
        case .constitutionalViolation(let code, _):
            switch code {
            case "HX001": return "This action would create an invalid task state."
            case "HX002": return "Escrow funds cannot be modified in this state."
            case "HX003": return "XP cannot be awarded for this action."
            case "HX100": return "You don't have permission for this trust tier."
            case "HX200": return "Dispute resolution is already in progress."
            case "HX300": return "Verification requirements not met."
            case "HX904": return "Live Mode is in cooldown. Please wait."
            case "HX905": return "Live Mode access is temporarily restricted."
            default: return errorDescription ?? "An error occurred."
            }
        default:
            return errorDescription ?? "An error occurred."
        }
    }
}

// MARK: - tRPC Response Envelope

/// Wrapper for tRPC success response: { "result": { "data": ... } }
private struct TRPCResponse<T: Decodable>: Decodable {
    let result: TRPCResult<T>
}

private struct TRPCResult<T: Decodable>: Decodable {
    let data: T
}

// MARK: - tRPC Error Response

struct TRPCError: Codable {
    let error: ErrorDetails

    struct ErrorDetails: Codable {
        let message: String
        let code: String?
    }
}
