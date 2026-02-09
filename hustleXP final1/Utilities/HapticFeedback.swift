import SwiftUI
import UIKit

/// Centralized haptic feedback utility for consistent tactile responses across the app
///
/// Purpose: Provides semantic haptic feedback patterns that enhance user interactions
/// with appropriate physical responses based on the action type.
///
/// Usage:
/// ```swift
/// // On button press
/// HapticFeedback.impact(.medium)
///
/// // On success
/// HapticFeedback.success()
///
/// // On error
/// HapticFeedback.error()
///
/// // On selection change
/// HapticFeedback.selection()
///
/// // Custom pattern
/// HapticFeedback.pattern(.success, delay: 0.1, .impact(.light))
/// ```
///
/// Design Principles:
/// - Use impact feedback for button presses and scrolling
/// - Use notification feedback for completion states (success/error/warning)
/// - Use selection feedback for picker/segment changes
/// - Avoid overuse - only on meaningful interactions
enum HapticFeedback {

    // MARK: - Impact Feedback

    /// Provides impact feedback with varying intensity
    /// - Parameter style: The intensity of the impact
    ///
    /// Use cases:
    /// - .light: Subtle interactions (hovering, small toggles)
    /// - .medium: Standard button presses, list selections
    /// - .heavy: Important actions, confirmations
    /// - .rigid: Strong confirmations, deletions
    /// - .soft: Gentle interactions, swipe gestures
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Indicates a successful operation completed
    ///
    /// Use cases:
    /// - Task completed successfully
    /// - Payment processed
    /// - Proof submitted
    /// - Form validation passed
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Indicates an error occurred
    ///
    /// Use cases:
    /// - Form validation failed
    /// - Network request failed
    /// - Payment declined
    /// - Invalid input
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    /// Indicates a warning or caution
    ///
    /// Use cases:
    /// - Low balance warning
    /// - Expiring timer
    /// - Approaching limit
    /// - Unverified action
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    // MARK: - Selection Feedback

    /// Indicates a selection changed
    ///
    /// Use cases:
    /// - Picker value changed
    /// - Segment control switched
    /// - Tab changed
    /// - Filter toggled
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Semantic Patterns

    /// Celebration pattern for major achievements
    ///
    /// Use cases:
    /// - First task completed
    /// - Level up
    /// - Trust tier increased
    /// - Verification unlocked
    static func celebration() {
        DispatchQueue.main.async {
            impact(.light)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impact(.heavy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            success()
        }
    }

    /// Confirmation pattern for important actions
    ///
    /// Use cases:
    /// - Delete confirmation
    /// - Cancel task
    /// - Dispute filed
    /// - Payment sent
    static func confirmation() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact(.rigid)
        }
    }

    /// Subtle pulse for background updates
    ///
    /// Use cases:
    /// - New message received
    /// - Task status changed
    /// - Timer tick
    /// - Progress update
    static func pulse() {
        impact(.light)
    }

    /// Bounce pattern for validation errors
    ///
    /// Use cases:
    /// - Form shake animation
    /// - Invalid input
    /// - Cannot proceed
    /// - Blocked action
    static func bounce() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            impact(.light)
        }
    }

    // MARK: - Advanced Patterns

    /// Creates a custom haptic pattern
    /// - Parameters:
    ///   - haptics: Variable number of HapticEvent tuples (feedback, delay)
    ///
    /// Example:
    /// ```swift
    /// HapticFeedback.pattern(
    ///     (.impact(.light), 0),
    ///     (.impact(.medium), 0.1),
    ///     (.success, 0.2)
    /// )
    /// ```
    static func pattern(_ haptics: HapticEvent...) {
        var cumulativeDelay: TimeInterval = 0

        for event in haptics {
            cumulativeDelay += event.delay

            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay) {
                switch event.type {
                case .impact(let style):
                    impact(style)
                case .success:
                    success()
                case .error:
                    error()
                case .warning:
                    warning()
                case .selection:
                    selection()
                }
            }
        }
    }

    /// Prepares the haptic engine for immediate feedback
    ///
    /// Use this before time-critical feedback (e.g., button press)
    /// to reduce latency. Call just before the action.
    static func prepare(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
    }
}

// MARK: - Supporting Types

/// Represents a single haptic event in a pattern
struct HapticEvent {
    enum EventType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case success
        case error
        case warning
        case selection
    }

    let type: EventType
    let delay: TimeInterval

    init(_ type: EventType, delay: TimeInterval = 0) {
        self.type = type
        self.delay = delay
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Adds haptic feedback to a view's tap gesture
    /// - Parameter style: The haptic style to use
    /// - Returns: A view with haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticFeedback.impact(style)
            }
        )
    }

    /// Adds success haptic feedback
    func hapticSuccess() -> some View {
        self.onAppear {
            HapticFeedback.success()
        }
    }

    /// Adds error haptic feedback
    func hapticError() -> some View {
        self.onAppear {
            HapticFeedback.error()
        }
    }
}

// MARK: - Preview Examples

#Preview("Impact Styles") {
    VStack(spacing: 20) {
        Button("Light Impact") {
            HapticFeedback.impact(.light)
        }
        .buttonStyle(.borderedProminent)

        Button("Medium Impact") {
            HapticFeedback.impact(.medium)
        }
        .buttonStyle(.borderedProminent)

        Button("Heavy Impact") {
            HapticFeedback.impact(.heavy)
        }
        .buttonStyle(.borderedProminent)

        Button("Rigid Impact") {
            HapticFeedback.impact(.rigid)
        }
        .buttonStyle(.borderedProminent)

        Button("Soft Impact") {
            HapticFeedback.impact(.soft)
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}

#Preview("Notification Styles") {
    VStack(spacing: 20) {
        Button("Success") {
            HapticFeedback.success()
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)

        Button("Error") {
            HapticFeedback.error()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)

        Button("Warning") {
            HapticFeedback.warning()
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)

        Button("Selection") {
            HapticFeedback.selection()
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }
    .padding()
}

#Preview("Semantic Patterns") {
    VStack(spacing: 20) {
        Button("Celebration 🎉") {
            HapticFeedback.celebration()
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)

        Button("Confirmation ✓") {
            HapticFeedback.confirmation()
        }
        .buttonStyle(.borderedProminent)

        Button("Pulse •") {
            HapticFeedback.pulse()
        }
        .buttonStyle(.borderedProminent)

        Button("Bounce ⟲") {
            HapticFeedback.bounce()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
    .padding()
}
