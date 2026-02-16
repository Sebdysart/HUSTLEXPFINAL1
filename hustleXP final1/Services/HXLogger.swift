//
//  HXLogger.swift
//  hustleXP final1
//
//  Centralized logging — only outputs in DEBUG builds
//

import Foundation
import os.log

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
        #endif
    }

    /// Info level
    static func info(_ message: String, category: String = "General") {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.info("\(message, privacy: .public)")
    }

    /// Error level — always logs
    static func error(_ message: String, category: String = "General") {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.error("\(message, privacy: .public)")
    }
}
