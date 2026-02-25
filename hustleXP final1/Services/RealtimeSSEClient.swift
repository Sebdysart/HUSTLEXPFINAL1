import Foundation
import Combine

/// SSE client for real-time events from the backend
@MainActor
final class RealtimeSSEClient: ObservableObject {
    static let shared = RealtimeSSEClient()

    @Published var isConnected = false

    let messageReceived = PassthroughSubject<SSEMessage, Never>()

    private var task: URLSessionDataTask?
    private var sseSession: URLSession?
    private var retryCount = 0
    private let maxRetries = 10

    /// Derive SSE stream URL from AppConfig (environment-aware: staging vs production)
    private var streamURL: String {
        AppConfig.backendBaseURL.absoluteString + "/realtime/stream"
    }

    struct SSEMessage {
        let event: String
        let data: Data
    }

    private init() {}

    func connect(authToken: String) {
        guard task == nil else { return }

        guard var components = URLComponents(string: streamURL) else { return }
        components.queryItems = [URLQueryItem(name: "token", value: authToken)]
        guard let url = components.url else { return }

        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 0 // No timeout for SSE

        // Reuse a single session to avoid URLSession resource leaks.
        // Each connect() previously created a new session without invalidation.
        if sseSession == nil {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(INT_MAX)
            config.timeoutIntervalForResource = TimeInterval(INT_MAX)
            sseSession = URLSession(configuration: config)
        }

        task = sseSession?.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    HXLogger.error("SSE connection error: \(error)", category: "Network")
                    self.isConnected = false
                    self.scheduleReconnect(authToken: authToken)
                    return
                }

                guard let data = data, let text = String(data: data, encoding: .utf8) else { return }
                self.parseSSEData(text)
            }
        }

        task?.resume()
        isConnected = true
        retryCount = 0
    }

    func disconnect() {
        task?.cancel()
        task = nil
        // Invalidate the session to release resources (delegate, socket, cache)
        sseSession?.invalidateAndCancel()
        sseSession = nil
        isConnected = false
    }

    private func parseSSEData(_ text: String) {
        let lines = text.components(separatedBy: "\n")
        var currentEvent = "message"
        var currentData = ""

        for line in lines {
            if line.hasPrefix("event: ") {
                currentEvent = String(line.dropFirst(7))
            } else if line.hasPrefix("data: ") {
                currentData = String(line.dropFirst(6))
            } else if line.isEmpty && !currentData.isEmpty {
                if let data = currentData.data(using: .utf8) {
                    messageReceived.send(SSEMessage(event: currentEvent, data: data))
                }
                currentEvent = "message"
                currentData = ""
            }
        }
    }

    private func scheduleReconnect(authToken: String) {
        guard retryCount < maxRetries else {
            HXLogger.error("SSE: Max reconnection attempts reached", category: "Network")
            return
        }

        retryCount += 1
        let delay = min(Double(1 << retryCount), 30.0) // Exponential backoff, max 30s
        let jitter = Double.random(in: 0...1)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + jitter) { [weak self] in
            self?.task = nil
            self?.connect(authToken: authToken)
        }
    }
}
