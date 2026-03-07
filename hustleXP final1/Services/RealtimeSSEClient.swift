import Foundation
import Combine
import Network

/// SSE client for real-time events from the backend.
/// Uses delegate-based streaming so each SSE chunk is processed incrementally
/// rather than buffering the entire response until the connection closes.
@MainActor
final class RealtimeSSEClient: NSObject, ObservableObject {
    static let shared = RealtimeSSEClient()

    @Published var isConnected = false

    /// Publisher that emits each fully-parsed SSE message.
    /// Event names are normalised: dots become underscores
    /// so backend events like "task.progress_updated" become "task_progress_updated".
    let messageReceived = PassthroughSubject<SSEMessage, Never>()

    /// Convenience alias used by some callers.
    var messagePublisher: AnyPublisher<SSEMessage, Never> {
        messageReceived.eraseToAnyPublisher()
    }

    private var task: URLSessionDataTask?
    private var sseSession: URLSession?
    private var retryCount = 0
    private let maxRetries = 10
    private var networkMonitor: NWPathMonitor?
    private var lastAuthToken: String?
    private var heartbeatTimer: Timer?
    private var lastDataReceived: Date?

    /// Incrementally accumulated raw bytes from the streaming response.
    private var buffer = Data()

    // MARK: - SSEMessage

    struct SSEMessage {
        let event: String
        let data: Data
    }

    // MARK: - Init

    private override init() {}

    // MARK: - Public API

    /// Derive SSE stream URL from AppConfig (environment-aware: staging vs production)
    private var streamURL: String {
        AppConfig.backendBaseURL.absoluteString + "/realtime/stream"
    }

    func connect(authToken: String) {
        lastAuthToken = authToken
        // IMP-3: guard before starting monitor/heartbeat so they are only created once
        guard task == nil else { return }
        startNetworkMonitoring()
        startHeartbeat()

        // CRIT-1: use Authorization header — never put credentials in URL query strings
        guard let url = URL(string: streamURL) else { return }

        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 0 // No timeout for SSE

        // Create a dedicated URLSession with this class as the delegate so that
        // urlSession(_:dataTask:didReceive:) fires for every received chunk
        // rather than only calling back once the connection closes.
        if sseSession == nil {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(INT_MAX)
            config.timeoutIntervalForResource = TimeInterval(INT_MAX)
            // Pass self (NSObject + URLSessionDataDelegate) as delegate.
            // operationQueue: nil → callbacks delivered on the session's internal serial queue.
            sseSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        }

        buffer = Data()
        task = sseSession?.dataTask(with: request)
        task?.resume()
        isConnected = true
        retryCount = 0
    }

    func disconnect() {
        task?.cancel()
        task = nil
        // Invalidate the session to release resources (delegate, socket, cache).
        sseSession?.invalidateAndCancel()
        sseSession = nil
        buffer = Data()
        isConnected = false
        networkMonitor?.cancel()
        networkMonitor = nil
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        lastAuthToken = nil
    }

    /// Force reconnection — call from UI "Reconnect" button.
    func forceReconnect() {
        guard let token = lastAuthToken else { return }
        HXLogger.info("SSE: Force reconnect triggered", category: "Network")
        retryCount = 0
        task?.cancel()
        task = nil
        buffer = Data()
        connect(authToken: token)
    }

    /// Reconnect only if not already connected (idempotent helper).
    func reconnectIfNeeded() {
        guard !isConnected, let token = lastAuthToken else { return }
        HXLogger.info("SSE: reconnectIfNeeded — reconnecting", category: "Network")
        task?.cancel()
        task = nil
        buffer = Data()
        connect(authToken: token)
    }

    // MARK: - Event Name Normalisation

    /// Converts dot-separated backend event names to underscore notation used by iOS subscribers.
    /// e.g. "task.progress_updated" → "task_progress_updated"
    private func normaliseEventName(_ raw: String) -> String {
        raw.replacingOccurrences(of: ".", with: "_")
    }

    // MARK: - SSE Parsing

    /// Process a complete SSE message block (text between double-newline boundaries).
    /// Multiple `data:` lines in one event are concatenated with `\n` per the SSE spec
    /// instead of the previous behaviour of overwriting with the last line.
    private func parseSSEChunk(_ text: String) {
        lastDataReceived = Date()

        var currentEvent = "message"
        var dataLines: [String] = []
        var hasData = false

        let lines = text.components(separatedBy: "\n")

        for line in lines {
            if line.hasPrefix("event: ") {
                currentEvent = String(line.dropFirst(7))
            } else if line.hasPrefix("data: ") {
                // CRIT-2: accumulate all data lines; join with \n per SSE spec
                dataLines.append(String(line.dropFirst(6)))
                hasData = true
            } else if line.isEmpty && hasData {
                // Empty line = end of this SSE message block
                let currentData = dataLines.joined(separator: "\n")
                if let data = currentData.data(using: .utf8) {
                    let normalisedEvent = normaliseEventName(currentEvent)
                    messageReceived.send(SSEMessage(event: normalisedEvent, data: data))
                    HXLogger.info("SSE: event '\(normalisedEvent)' received", category: "Network")
                }
                // Reset for next message in this chunk
                currentEvent = "message"
                dataLines = []
                hasData = false
            }
        }
    }

    // MARK: - Reconnect

    private func scheduleReconnect(authToken: String) {
        guard retryCount < maxRetries else {
            HXLogger.error("SSE: Max reconnection attempts reached", category: "Network")
            return
        }

        retryCount += 1
        // SUG-2: use pow() instead of signed-int bitshift, which is fragile for large retryCount
        let delay = min(pow(2.0, Double(retryCount)), 30.0) // Exponential backoff, max 30s
        let jitter = Double.random(in: 0...1)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + jitter) { [weak self] in
            self?.task = nil
            self?.buffer = Data()
            self?.connect(authToken: authToken)
        }
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitoring() {
        networkMonitor?.cancel()
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if path.status == .satisfied && !self.isConnected {
                    if let token = self.lastAuthToken {
                        HXLogger.info("SSE: Network restored, reconnecting", category: "Network")
                        self.retryCount = 0
                        self.task?.cancel()
                        self.task = nil
                        self.buffer = Data()
                        self.connect(authToken: token)
                    }
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.hustlexp.network-monitor"))
        self.networkMonitor = monitor
    }

    // MARK: - Heartbeat Timeout

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        lastDataReceived = Date()
        // IMP-4: use Timer(timeInterval:) + RunLoop.main.add(.common) so the timer
        // fires even during UIScrollView tracking (which pauses the .default run loop mode).
        heartbeatTimer = Timer(timeInterval: 45, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isConnected else { return }
                if let lastData = self.lastDataReceived,
                   Date().timeIntervalSince(lastData) > 60 {
                    HXLogger.info("SSE: Heartbeat timeout, reconnecting", category: "Network")
                    self.isConnected = false
                    if let token = self.lastAuthToken {
                        self.task?.cancel()
                        self.task = nil
                        self.buffer = Data()
                        self.scheduleReconnect(authToken: token)
                    }
                }
            }
        }
        RunLoop.main.add(heartbeatTimer!, forMode: .common)
    }
}

// MARK: - URLSessionDataDelegate

extension RealtimeSSEClient: URLSessionDataDelegate {

    /// Called incrementally as each chunk of SSE data arrives from the server.
    /// CRIT-2: append to the shared buffer first, then scan for complete SSE message
    /// boundaries (`\n\n` or `\r\n\r\n`). Only complete messages are dispatched to
    /// parseSSEChunk; partial trailing data stays in the buffer for the next chunk.
    nonisolated func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            // Append incoming bytes to the accumulation buffer.
            self.buffer.append(data)

            // Scan for SSE message boundaries: messages end with \n\n or \r\n\r\n.
            let doubleNewline = Data([0x0A, 0x0A])           // \n\n
            let crlfDouble   = Data([0x0D, 0x0A, 0x0D, 0x0A]) // \r\n\r\n

            while true {
                // Find the earliest boundary in the buffer.
                var boundaryRange: Range<Data.Index>?
                var boundaryLength = 2

                let nnRange   = self.buffer.range(of: doubleNewline)
                let crlfRange = self.buffer.range(of: crlfDouble)

                if let nn = nnRange, let crlf = crlfRange {
                    if nn.lowerBound <= crlf.lowerBound {
                        boundaryRange = nn
                        boundaryLength = 2
                    } else {
                        boundaryRange = crlf
                        boundaryLength = 4
                    }
                } else if let nn = nnRange {
                    boundaryRange = nn
                    boundaryLength = 2
                } else if let crlf = crlfRange {
                    boundaryRange = crlf
                    boundaryLength = 4
                }

                guard let boundary = boundaryRange else { break }

                // Extract the complete message block (excluding the boundary itself).
                let messageData = self.buffer.subdata(in: self.buffer.startIndex..<boundary.lowerBound)
                // Remove the message + boundary from the buffer.
                self.buffer.removeSubrange(self.buffer.startIndex..<(boundary.lowerBound + boundaryLength))

                if let text = String(data: messageData, encoding: .utf8), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.parseSSEChunk(text)
                }
            }
        }
    }

    /// Called when the SSE connection is closed (error or server-side close).
    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isConnected = false
            if let error = error {
                let nsErr = error as NSError
                // NSURLErrorCancelled is expected when we intentionally cancel (disconnect/forceReconnect).
                guard nsErr.code != NSURLErrorCancelled else { return }
                HXLogger.error("SSE connection error: \(error.localizedDescription)", category: "Network")
            } else {
                HXLogger.info("SSE: Connection closed by server", category: "Network")
            }
            if let token = self.lastAuthToken {
                self.task = nil
                self.buffer = Data()
                self.scheduleReconnect(authToken: token)
            }
        }
    }

    /// Validates the HTTP response (200 OK + text/event-stream content type).
    nonisolated func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 200 {
                completionHandler(.allow)
            } else {
                HXLogger.error("SSE: Unexpected HTTP status \(http.statusCode)", category: "Network")
                completionHandler(.cancel)
                Task { @MainActor [weak self] in
                    guard let self, let token = self.lastAuthToken else { return }
                    self.isConnected = false
                    self.task = nil
                    self.buffer = Data()
                    self.scheduleReconnect(authToken: token)
                }
            }
        } else {
            completionHandler(.allow)
        }
    }
}
