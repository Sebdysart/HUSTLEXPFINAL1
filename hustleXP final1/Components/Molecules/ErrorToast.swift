//
//  ErrorToast.swift
//  hustleXP final1
//
//  Global error toast overlay. Attach to root view via .errorToast() modifier.
//  Any screen can trigger via ErrorToastManager.shared.show("message")
//

import SwiftUI

// MARK: - Toast Manager

@MainActor
@Observable
final class ErrorToastManager {
    static let shared = ErrorToastManager()

    var currentToast: ToastItem?

    private init() {}

    func show(_ message: String, style: ToastStyle = .error) {
        let toast = ToastItem(message: message, style: style)
        withAnimation(.spring(response: 0.35)) {
            currentToast = toast
        }
        // Auto-dismiss after 4 seconds
        let id = toast.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            guard let self, self.currentToast?.id == id else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                self.currentToast = nil
            }
        }
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            currentToast = nil
        }
    }
}

// MARK: - Toast Item

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let style: ToastStyle

    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum ToastStyle {
    case error
    case warning
    case info

    var icon: String {
        switch self {
        case .error: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .error: return .errorRed
        case .warning: return .warningOrange
        case .info: return .infoBlue
        }
    }
}

// MARK: - Toast View

struct ErrorToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.style.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(toast.style.color)

            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 4)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surfaceElevated)
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - View Modifier

struct ErrorToastModifier: ViewModifier {
    let manager = ErrorToastManager.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = manager.currentToast {
                    ErrorToastView(toast: toast) {
                        manager.dismiss()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                    .zIndex(999)
                }
            }
    }
}

extension View {
    func errorToast() -> some View {
        modifier(ErrorToastModifier())
    }
}
