//
//  HXLogger.swift
//  hustleXP final1
//
//  Centralized logging — only outputs in DEBUG builds
//

import Foundation
import os.log
import UIKit

/// Centralized logger that only outputs in DEBUG builds.
/// Replaces all print() calls for production safety.
enum HXLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.hustlexp"

    static let auth     = Logger(subsystem: subsystem, category: "Auth")
    static let task     = Logger(subsystem: subsystem, category: "Task")
    static let network  = Logger(subsystem: subsystem, category: "Network")
    static let nav      = Logger(subsystem: subsystem, category: "Navigation")
    static let live     = Logger(subsystem: subsystem, category: "LiveMode")
    static let payment  = Logger(subsystem: subsystem, category: "Payment")
    static let push     = Logger(subsystem: subsystem, category: "Push")
    static let skill    = Logger(subsystem: subsystem, category: "Skill")
    static let ui       = Logger(subsystem: subsystem, category: "UI")
    static let general  = Logger(subsystem: subsystem, category: "General")
    static let analytics = Logger(subsystem: subsystem, category: "Analytics")

    /// Quick debug log — only prints in DEBUG builds
    static func debug(_ message: String, category: String = "General") {
        #if DEBUG
        let logger = Logger(subsystem: subsystem, category: category)
        logger.debug("\(message, privacy: .public)")
        HXRemoteDiagnostics.shared.record(kind: "log", level: "debug", category: category, message: message)
        #endif
    }

    /// Info level
    static func info(_ message: String, category: String = "General") {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.info("\(message, privacy: .public)")
        HXRemoteDiagnostics.shared.record(kind: "log", level: "info", category: category, message: message)
    }

    /// Error level — always logs
    static func error(_ message: String, category: String = "General") {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.error("\(message, privacy: .public)")
        HXRemoteDiagnostics.shared.record(kind: "error", level: "error", category: category, message: message)
    }

    /// Attribute subsequent diagnostics to a signed-in user.
    static func setDiagnosticsUser(_ id: String?) {
        HXRemoteDiagnostics.shared.setUser(id)
    }
}

// MARK: - Live Diagnostics Shipper (TestFlight log gateway)

/// Ships log lines + analytics events to the beta diagnostics sink
/// (`AppConfig.liveDiagnosticsURL`) so TestFlight failures are visible
/// remotely in near-real-time.
///
/// Design rules:
/// - FAIL-SILENT: diagnostics must never crash, block, or slow the app.
/// - Batched: flushes every 5s or at 40 buffered entries, ≤100 per request.
/// - Bounded: buffer capped at 400 entries (oldest dropped first).
/// - OFF in App Store builds (`AppConfig.liveDiagnosticsEnabled`).
final class HXRemoteDiagnostics: @unchecked Sendable {
    static let shared = HXRemoteDiagnostics()

    private let queue = DispatchQueue(label: "com.hustlexp.diagnostics", qos: .utility)
    private var buffer: [[String: Any]] = []
    private var timer: DispatchSourceTimer?
    private var inFlight = false
    private var started = false
    private var userId: String?

    private let sessionId = UUID().uuidString
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let maxBuffer = 400
    private let flushThreshold = 40
    private let maxPerRequest = 100

    private init() {}

    func setUser(_ id: String?) {
        queue.async { self.userId = id }
    }

    func record(kind: String, level: String?, category: String?, message: String, metadata: [String: String]? = nil) {
        guard AppConfig.liveDiagnosticsEnabled else { return }
        let ts = isoFormatter.string(from: Date())
        queue.async {
            self.startIfNeeded()
            var entry: [String: Any] = [
                "kind": kind,
                "message": String(message.prefix(4000)),
                "ts": ts,
            ]
            if let level { entry["level"] = level }
            if let category { entry["category"] = String(category.prefix(64)) }
            if let metadata, !metadata.isEmpty { entry["metadata"] = metadata }
            self.buffer.append(entry)
            if self.buffer.count > self.maxBuffer {
                self.buffer.removeFirst(self.buffer.count - self.maxBuffer)
            }
            if self.buffer.count >= self.flushThreshold {
                self.flushLocked()
            }
        }
    }

    /// Must be called on `queue`.
    private func startIfNeeded() {
        guard !started else { return }
        started = true
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + 5, repeating: 5)
        t.setEventHandler { [weak self] in self?.flushLocked() }
        t.resume()
        timer = t
    }

    /// Must be called on `queue`.
    private func flushLocked() {
        guard !inFlight, !buffer.isEmpty else { return }
        let batch = Array(buffer.prefix(maxPerRequest))
        buffer.removeFirst(batch.count)
        inFlight = true

        var device: [String: Any] = [
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
            "sessionId": sessionId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?",
            "osVersion": "iOS " + UIDevice.current.systemVersion,
        ]
        if let userId { device["userId"] = userId }

        let payload: [String: Any] = ["device": device, "entries": batch]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            inFlight = false
            return
        }

        var request = URLRequest(url: AppConfig.liveDiagnosticsURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.liveDiagnosticsToken, forHTTPHeaderField: "x-hx-log-token")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }
            self.queue.async {
                self.inFlight = false
                let ok = error == nil && (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? false
                if !ok {
                    // Requeue at the front, respecting the cap — diagnostics are
                    // best-effort; older entries are dropped before newer ones.
                    let requeued = batch + self.buffer
                    self.buffer = Array(requeued.suffix(self.maxBuffer))
                }
            }
        }.resume()
    }
}
