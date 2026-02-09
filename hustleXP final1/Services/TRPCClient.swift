import Foundation
import Combine

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

    init() {
        // Railway production backend
        self.baseURL = URL(string: "https://hustlexp-ai-backend-staging-production.up.railway.app")!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic tRPC Call

    /// Makes a tRPC procedure call to the backend
    /// - Parameters:
    ///   - router: The tRPC router name (e.g., "user", "task", "escrow")
    ///   - procedure: The procedure name (e.g., "register", "listOpen", "accept")
    ///   - input: Encodable input parameters for the procedure
    /// - Returns: Decoded response of type Output
    func call<Input: Encodable, Output: Decodable>(
        router: String,
        procedure: String,
        input: Input
    ) async throws -> Output {
        let endpoint = "/trpc/\(router).\(procedure)"
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode input
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(input)

        // Make request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(TRPCError.self, from: data) {
                throw APIError.serverError(errorResponse.error.message)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(Output.self, from: data)
        } catch {
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
    case notFound

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
        case .notFound:
            return "Resource not found"
        }
    }
}

// MARK: - tRPC Error Response

struct TRPCError: Codable {
    let error: ErrorDetails

    struct ErrorDetails: Codable {
        let message: String
        let code: String?
    }
}
