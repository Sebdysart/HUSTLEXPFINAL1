// hustleXP final1/Components/Atoms/ErrorStateView.swift
import SwiftUI

enum AppError {
    case network
    case server
    case notFound(String)
    case authExpired
    case unknown(String)

    var title: String {
        switch self {
        case .network: return "No Internet Connection"
        case .server: return "Something Went Wrong"
        case .notFound(let item): return "\(item) Not Found"
        case .authExpired: return "Session Expired"
        case .unknown: return "Unexpected Error"
        }
    }

    var message: String {
        switch self {
        case .network: return "Check your connection and try again."
        case .server: return "We're working on it. Try again in a moment."
        case .notFound(let item): return "This \(item.lowercased()) is no longer available."
        case .authExpired: return "Please sign in again to continue."
        case .unknown(let msg): return msg
        }
    }

    var icon: String {
        switch self {
        case .network: return "wifi.slash"
        case .server: return "exclamationmark.triangle"
        case .notFound: return "questionmark.circle"
        case .authExpired: return "lock.rotation"
        case .unknown: return "exclamationmark.circle"
        }
    }
}

struct ErrorStateView: View {
    let error: AppError
    let onRetry: (() -> Void)?

    init(error: AppError, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: error.icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(error.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(error.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let onRetry = onRetry {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(error.title). \(error.message)")
    }
}

#Preview {
    ErrorStateView(error: .network, onRetry: { print("retry") })
}
