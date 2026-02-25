import Foundation
import Combine
import Network

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
/// including authentication token management, request/response serialization,
/// and offline request queuing for resilience during network interruptions.
@MainActor
final class TRPCClient: ObservableObject {
    static let shared = TRPCClient()

    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?
    private var isRefreshingToken = false

    /// Offline queue: mutations that failed due to network issues are queued here
    /// and automatically retried when connectivity is restored.
    private var offlineQueue: [QueuedRequest] = []
    private var isProcessingQueue = false

    /// Published property so UI can show offline indicator
    @Published var pendingOfflineCount: Int = 0

    /// Network path monitor for automatic offline queue replay
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.hustlexp.networkMonitor")

    init() {
        // Environment-aware backend URL from AppConfig
        self.baseURL = AppConfig.backendBaseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
        // NOTE: waitsForConnectivity must be false so that URLError is thrown immediately
        // when offline, allowing the offline queue to capture failed mutations.
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config, delegate: SSLPinningDelegate(), delegateQueue: nil)

        // Load any persisted offline queue from disk
        loadOfflineQueue()

        // Refresh SSL pins on launch
        Task { await CertificatePins.refreshRemotePins() }

        // Start monitoring network connectivity for offline queue replay
        startNetworkMonitor()
    }

    deinit {
        networkMonitor.cancel()
    }

    /// Start monitoring network path changes to replay queued mutations when connectivity returns.
    private func startNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in
                await self?.processOfflineQueue()
            }
        }
        networkMonitor.start(queue: monitorQueue)
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

        // Make request — catch network errors for mutation offline queuing
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where type == .mutation && !isRetry && isOfflineError(urlError) {
            // Queue the mutation for later retry when connectivity returns
            if let bodyData = request.httpBody {
                enqueueOfflineRequest(router: router, procedure: procedure, bodyData: bodyData)
            }
            throw APIError.networkError(urlError)
        }

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

    // MARK: - Offline Queue

    /// Returns true if the URLError indicates a pre-connection failure where the server
    /// **definitely never received** the request. Only these codes are safe for blind replay
    /// because the request never left the device.
    ///
    /// Excluded (unsafe for replay without idempotency keys):
    /// - `.timedOut` — server may have received and processed the request before the client gave up.
    /// - `.networkConnectionLost` — connection can drop *after* the request body is sent and
    ///   the server has begun (or completed) processing. Replaying risks double execution.
    private func isOfflineError(_ error: URLError) -> Bool {
        let offlineCodes: Set<URLError.Code> = [
            .notConnectedToInternet,   // No network interface at all — request never sent
            .cannotFindHost,           // DNS resolution failed — request never sent
            .cannotConnectToHost,      // TCP handshake failed — request never sent
            .dnsLookupFailed,          // DNS failed — request never sent
            .dataNotAllowed,           // Cellular data disabled — request never sent
            .internationalRoamingOff,  // Roaming disabled — request never sent
        ]
        return offlineCodes.contains(error.code)
    }

    /// Enqueue a failed mutation for later retry.
    /// Only mutations are queued (queries are idempotent and can just be re-fetched).
    private func enqueueOfflineRequest(router: String, procedure: String, bodyData: Data) {
        let queued = QueuedRequest(
            id: UUID().uuidString,
            router: router,
            procedure: procedure,
            bodyData: bodyData,
            enqueuedAt: Date()
        )
        offlineQueue.append(queued)
        pendingOfflineCount = offlineQueue.count
        persistOfflineQueue()
        HXLogger.info("tRPC: Queued offline mutation \(router).\(procedure) (\(offlineQueue.count) pending)", category: "Network")
    }

    /// Process all queued requests. Called when network connectivity is restored.
    func processOfflineQueue() async {
        guard !isProcessingQueue, !offlineQueue.isEmpty else { return }
        isProcessingQueue = true
        HXLogger.info("tRPC: Processing \(offlineQueue.count) offline requests", category: "Network")

        var remaining: [QueuedRequest] = []

        for queued in offlineQueue {
            // Skip requests older than 24 hours (stale)
            if Date().timeIntervalSince(queued.enqueuedAt) > 86_400 {
                HXLogger.info("tRPC: Dropping stale offline request \(queued.router).\(queued.procedure)", category: "Network")
                continue
            }

            let path = "\(queued.router).\(queued.procedure)"
            var request = URLRequest(url: baseURL.appendingPathComponent("/trpc/\(path)"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = queued.bodyData

            if let token = authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            do {
                let (_, response) = try await session.data(for: request)
                if let http = response as? HTTPURLResponse {
                    if (200...299).contains(http.statusCode) {
                        HXLogger.info("tRPC: Offline request \(path) succeeded", category: "Network")
                    } else if http.statusCode == 401 {
                        // 401 Unauthorized — token likely expired while queued.
                        // Attempt token refresh and retry this one request.
                        HXLogger.info("tRPC: Offline request \(path) got 401 — refreshing token", category: "Network")
                        do {
                            try await AuthService.shared.refreshToken()
                            // Retry with fresh token
                            var retryReq = request
                            if let freshToken = authToken {
                                retryReq.setValue("Bearer \(freshToken)", forHTTPHeaderField: "Authorization")
                            }
                            let (_, retryResp) = try await session.data(for: retryReq)
                            if let retryHttp = retryResp as? HTTPURLResponse, (200...299).contains(retryHttp.statusCode) {
                                HXLogger.info("tRPC: Offline request \(path) succeeded after token refresh", category: "Network")
                            } else {
                                // Still failing after refresh — drop to avoid infinite loop
                                HXLogger.error("tRPC: Offline request \(path) failed after token refresh — dropping", category: "Network")
                            }
                        } catch {
                            // Token refresh failed — keep in queue for next connectivity event
                            HXLogger.error("tRPC: Token refresh failed for \(path) — re-queuing", category: "Network")
                            remaining.append(queued)
                        }
                    } else if (400...499).contains(http.statusCode) {
                        // Permanent client error (400, 409, 422, etc.) — drop, will never succeed on retry
                        HXLogger.error("tRPC: Offline request \(path) permanently rejected (HTTP \(http.statusCode)) — dropping", category: "Network")
                    } else {
                        // Server error (5xx) — keep for retry
                        remaining.append(queued)
                    }
                } else {
                    remaining.append(queued)
                }
            } catch {
                // Still offline or transient error -- keep in queue
                remaining.append(queued)
            }
        }

        offlineQueue = remaining
        pendingOfflineCount = offlineQueue.count
        persistOfflineQueue()
        isProcessingQueue = false
    }

    // MARK: - Queue Persistence

    private static let offlineQueueKey = "com.hustlexp.trpc.offlineQueue"

    private func persistOfflineQueue() {
        if let data = try? JSONEncoder().encode(offlineQueue) {
            UserDefaults.standard.set(data, forKey: Self.offlineQueueKey)
        }
    }

    private func loadOfflineQueue() {
        guard let data = UserDefaults.standard.data(forKey: Self.offlineQueueKey),
              let queue = try? JSONDecoder().decode([QueuedRequest].self, from: data) else {
            return
        }
        // Filter out stale requests (>24h) on load to prevent indefinite accumulation
        let fresh = queue.filter { Date().timeIntervalSince($0.enqueuedAt) <= 86_400 }
        offlineQueue = fresh
        pendingOfflineCount = fresh.count
        // Re-persist if stale entries were pruned
        if fresh.count != queue.count {
            persistOfflineQueue()
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

// MARK: - Offline Queue Model

/// Represents a mutation request queued while offline.
struct QueuedRequest: Codable, Identifiable {
    let id: String
    let router: String
    let procedure: String
    let bodyData: Data
    let enqueuedAt: Date
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
