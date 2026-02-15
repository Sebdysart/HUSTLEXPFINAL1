//
//  AnalyticsService.swift
//  hustleXP final1
//
//  Real tRPC service for analytics event tracking
//  Maps to backend analytics.ts router
//  Tracks: user events, screen views, task interactions, A/B tests
//

import Foundation
import UIKit

// MARK: - Analytics Event Types

/// Event category required by backend
enum AnalyticsEventCategory: String, Codable {
    case userAction = "user_action"
    case systemEvent = "system_event"
    case error = "error"
    case performance = "performance"
}

/// Standard analytics event - internal storage only
struct AnalyticsEvent: Codable {
    let eventType: String
    let properties: [String: String]?
    let timestamp: Date?
    let eventCategory: AnalyticsEventCategory

    init(eventType: String, properties: [String: String]? = nil, category: AnalyticsEventCategory = .userAction) {
        self.eventType = eventType
        self.properties = properties
        self.timestamp = Date()
        self.eventCategory = category
    }
}

/// Event format expected by backend API - includes sessionId, deviceId, platform on each event
struct APIAnalyticsEvent: Codable {
    let eventType: String
    let properties: [String: String]?
    let timestamp: Date?
    let eventCategory: String
    let sessionId: String
    let deviceId: String
    let platform: String
    
    init(from event: AnalyticsEvent, sessionId: String, deviceId: String) {
        self.eventType = event.eventType
        self.properties = event.properties
        self.timestamp = event.timestamp
        self.eventCategory = event.eventCategory.rawValue
        self.sessionId = sessionId
        self.deviceId = deviceId
        self.platform = "ios"
    }
}

/// Common event types used throughout the app
enum AnalyticsEventType: String {
    // Screen Views
    case screenView = "SCREEN_VIEW"

    // Auth Events
    case signUp = "SIGN_UP"
    case signIn = "SIGN_IN"
    case signOut = "SIGN_OUT"

    // Task Events
    case taskCreated = "TASK_CREATED"
    case taskViewed = "TASK_VIEWED"
    case taskAccepted = "TASK_ACCEPTED"
    case taskStarted = "TASK_STARTED"
    case taskCompleted = "TASK_COMPLETED"
    case taskCancelled = "TASK_CANCELLED"
    case taskAbandoned = "TASK_ABANDONED"

    // Search & Discovery
    case searchPerformed = "SEARCH_PERFORMED"
    case feedViewed = "FEED_VIEWED"
    case filterApplied = "FILTER_APPLIED"

    // Payment Events
    case paymentInitiated = "PAYMENT_INITIATED"
    case paymentCompleted = "PAYMENT_COMPLETED"
    case paymentFailed = "PAYMENT_FAILED"

    // Proof Events
    case proofSubmitted = "PROOF_SUBMITTED"
    case proofApproved = "PROOF_APPROVED"
    case proofRejected = "PROOF_REJECTED"

    // Profile Events
    case profileUpdated = "PROFILE_UPDATED"
    case skillAdded = "SKILL_ADDED"
    case licenseSubmitted = "LICENSE_SUBMITTED"

    // Engagement
    case messageSent = "MESSAGE_SENT"
    case ratingSubmitted = "RATING_SUBMITTED"
    case notificationTapped = "NOTIFICATION_TAPPED"

    // Errors
    case errorOccurred = "ERROR_OCCURRED"
}

/// A/B test assignment
struct ABTestAssignment: Codable {
    let testName: String
    let variant: String
    let converted: Bool?
}

// MARK: - Analytics Service

/// Manages analytics event tracking via tRPC
/// Fire-and-forget design: tracking failures are logged but never thrown
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let trpc = TRPCClient.shared

    /// Buffer for batching events
    private var eventBuffer: [AnalyticsEvent] = []
    private let batchSize = 10
    private var flushTask: Task<Void, Never>?
    
    /// Session ID for the current app session (required by backend)
    private let sessionId: String
    
    /// Device ID - uses identifierForVendor or generates a persistent UUID
    private let deviceId: String

    private init() {
        // Generate session ID for this app session
        self.sessionId = UUID().uuidString
        
        // Get or generate device ID
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            self.deviceId = vendorId
        } else if let savedDeviceId = UserDefaults.standard.string(forKey: "analytics_device_id") {
            self.deviceId = savedDeviceId
        } else {
            let newDeviceId = UUID().uuidString
            UserDefaults.standard.set(newDeviceId, forKey: "analytics_device_id")
            self.deviceId = newDeviceId
        }
        
        // Set up periodic flush every 30 seconds
        startPeriodicFlush()
    }

    // MARK: - Track Events

    /// Tracks a single analytics event (fire-and-forget)
    func track(_ eventType: AnalyticsEventType, properties: [String: String]? = nil, category: AnalyticsEventCategory? = nil) {
        let eventCategory = category ?? determineCategory(for: eventType)
        let event = AnalyticsEvent(eventType: eventType.rawValue, properties: properties, category: eventCategory)
        eventBuffer.append(event)

        // Flush if buffer is full
        if eventBuffer.count >= batchSize {
            Task { await flush() }
        }
    }

    /// Tracks a screen view
    func trackScreenView(_ screenName: String) {
        track(.screenView, properties: ["screen": screenName], category: .systemEvent)
    }

    /// Tracks a task interaction
    func trackTaskEvent(_ eventType: AnalyticsEventType, taskId: String, taskTitle: String? = nil) {
        var props: [String: String] = ["taskId": taskId]
        if let title = taskTitle { props["taskTitle"] = title }
        track(eventType, properties: props, category: .userAction)
    }

    /// Tracks an error
    func trackError(_ errorDescription: String, context: String? = nil) {
        var props: [String: String] = ["error": errorDescription]
        if let ctx = context { props["context"] = ctx }
        track(.errorOccurred, properties: props, category: .error)
    }
    
    /// Determines the appropriate category for an event type
    private func determineCategory(for eventType: AnalyticsEventType) -> AnalyticsEventCategory {
        switch eventType {
        case .errorOccurred:
            return .error
        case .screenView, .feedViewed:
            return .systemEvent
        default:
            return .userAction
        }
    }

    // MARK: - A/B Testing

    /// Tracks an A/B test assignment
    func trackABTest(testName: String, variant: String, converted: Bool? = nil) {
        Task {
            do {
                struct ABTestInput: Codable {
                    let testName: String
                    let variant: String
                    let converted: Bool?
                }

                struct EmptyResponse: Codable {}

                let _: EmptyResponse = try await trpc.call(
                    router: "analytics",
                    procedure: "trackABTest",
                    input: ABTestInput(testName: testName, variant: variant, converted: converted)
                )
            } catch {
                print("⚠️ AnalyticsService: Failed to track A/B test - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Batch Flush

    /// Flushes buffered events to the backend
    func flush() async {
        guard !eventBuffer.isEmpty else { return }

        let eventsToSend = eventBuffer
        eventBuffer.removeAll()

        do {
            // Convert to API format with sessionId—and deviceId on each event
            let apiEvents = eventsToSend.map { APIAnalyticsEvent(from: $0, sessionId: sessionId, deviceId: deviceId) }
            
            struct BatchInput: Codable {
                let events: [APIAnalyticsEvent]
            }

            struct EmptyResponse: Codable {}

            let _: EmptyResponse = try await trpc.call(
                router: "analytics",
                procedure: "trackBatch",
                input: BatchInput(events: apiEvents)
            )

            print("✅ AnalyticsService: Flushed \(eventsToSend.count) events")
        } catch {
            // Re-add failed events to buffer for retry
            eventBuffer.insert(contentsOf: eventsToSend, at: 0)
            // Cap buffer to prevent unbounded growth
            if eventBuffer.count > 100 {
                eventBuffer = Array(eventBuffer.suffix(100))
            }
            print("⚠️ AnalyticsService: Failed to flush events - \(error.localizedDescription)")
        }
    }

    /// Starts periodic flush timer
    private func startPeriodicFlush() {
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                await flush()
            }
        }
    }

    /// Gets user's own analytics events (for transparency)
    func getMyEvents(limit: Int = 50) async throws -> [AnalyticsEvent] {
        struct GetEventsInput: Codable {
            let limit: Int
        }

        let events: [AnalyticsEvent] = try await trpc.call(
            router: "analytics",
            procedure: "getUserEvents",
            type: .query,
            input: GetEventsInput(limit: limit)
        )

        return events
    }
}
