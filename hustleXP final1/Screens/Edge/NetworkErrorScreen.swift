//
//  NetworkErrorScreen.swift
//  hustleXP final1
//
//  Archetype: F (System/Interrupt)
//

import SwiftUI

struct NetworkErrorScreen: View {
    let onRetry: () -> Void
    
    @State private var isRetrying = false
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.brandBlack
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated wifi icon
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.errorRed.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    // Wave animation circles
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.errorRed.opacity(0.3), lineWidth: 2)
                            .frame(width: CGFloat(80 + index * 30), height: CGFloat(80 + index * 30))
                            .opacity(isRetrying ? 1 : 0.3)
                            .scaleEffect(isRetrying ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isRetrying
                            )
                    }
                    
                    HXIcon(
                        name: "wifi.exclamationmark",
                        size: .custom(48),
                        color: .errorRed
                    )
                }
                
                // Content
                VStack(spacing: 12) {
                    HXText("Connection Lost", style: .title2)
                    
                    HXText(
                        "We couldn't reach our servers.\nPlease check your internet connection.",
                        style: .body,
                        color: .textSecondary
                    )
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Troubleshooting tips
                VStack(alignment: .leading, spacing: 16) {
                    HXText("Try these steps:", style: .caption, color: .textSecondary)
                    
                    TroubleshootRow(number: 1, text: "Check your WiFi or cellular connection")
                    TroubleshootRow(number: 2, text: "Toggle airplane mode on and off")
                    TroubleshootRow(number: 3, text: "Restart the app")
                }
                .padding(20)
                .background(Color.surfaceSecondary)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Retry button
                VStack(spacing: 16) {
                    HXButton(
                        title: isRetrying ? "Connecting..." : "Try Again",
                        variant: .primary,
                        isLoading: isRetrying
                    ) {
                        isRetrying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isRetrying = false
                            onRetry()
                        }
                    }
                    
                    HXText(
                        "Error Code: NET_TIMEOUT",
                        style: .caption,
                        color: .textTertiary
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Troubleshoot Row
private struct TroubleshootRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.brandBlack)
                .frame(width: 24, height: 24)
                .background(Color.textSecondary)
                .clipShape(Circle())
            
            HXText(text, style: .subheadline, color: .textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    NetworkErrorScreen(onRetry: {})
}
