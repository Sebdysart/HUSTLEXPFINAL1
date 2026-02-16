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
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600
            
            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()
                
                VStack(spacing: isCompact ? 20 : 32) {
                    Spacer()
                    
                    // Animated wifi icon
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(Color.errorRed.opacity(0.15))
                            .frame(width: isCompact ? 100 : 140, height: isCompact ? 100 : 140)
                        
                        // Wave animation circles
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(Color.errorRed.opacity(0.3), lineWidth: 2)
                                .frame(width: CGFloat((isCompact ? 60 : 80) + index * (isCompact ? 20 : 30)), height: CGFloat((isCompact ? 60 : 80) + index * (isCompact ? 20 : 30)))
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
                            "wifi.exclamationmark",
                            size: .custom(isCompact ? 36 : 48),
                            color: .errorRed
                        )
                    }
                    
                    // Content
                    VStack(spacing: isCompact ? 8 : 12) {
                        HXText("Connection Lost", style: isCompact ? .headline : .title2)
                        
                        HXText(
                            "We couldn't reach our servers.\nPlease check your internet connection.",
                            style: isCompact ? .subheadline : .body,
                            color: .textSecondary
                        )
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, isCompact ? 20 : 24)
                    
                    // Troubleshooting tips
                    VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
                        HXText("Try these steps:", style: .caption, color: .textSecondary)
                        
                        TroubleshootRow(number: 1, text: "Check your WiFi or cellular connection", isCompact: isCompact)
                        TroubleshootRow(number: 2, text: "Toggle airplane mode on and off", isCompact: isCompact)
                        TroubleshootRow(number: 3, text: "Restart the app", isCompact: isCompact)
                    }
                    .padding(isCompact ? 16 : 20)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(isCompact ? 14 : 16)
                    .padding(.horizontal, isCompact ? 20 : 24)
                    
                    Spacer()
                    
                    // Retry button
                    VStack(spacing: isCompact ? 12 : 16) {
                        HXButton(
                            isRetrying ? "Connecting..." : "Try Again",
                            variant: .primary,
                            size: isCompact ? .medium : .large,
                            isLoading: isRetrying
                        ) {
                            isRetrying = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isRetrying = false
                                onRetry()
                            }
                        }
                        .accessibilityLabel("Try connecting again")
                        
                        HXText(
                            "Error Code: NET_TIMEOUT",
                            style: .caption,
                            color: .textTertiary
                        )
                    }
                    .padding(.horizontal, isCompact ? 20 : 24)
                    .padding(.bottom, isCompact ? 20 : 32)
                }
            }
        }
    }
}

// MARK: - Troubleshoot Row
private struct TroubleshootRow: View {
    let number: Int
    let text: String
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            Text("\(number)")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.brandBlack)
                .frame(width: isCompact ? 20 : 24, height: isCompact ? 20 : 24)
                .background(Color.textSecondary)
                .clipShape(Circle())
            
            HXText(text, style: isCompact ? .footnote : .subheadline, color: .textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    NetworkErrorScreen(onRetry: {})
}
