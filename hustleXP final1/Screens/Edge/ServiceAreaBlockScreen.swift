//
//  ServiceAreaBlockScreen.swift
//  hustleXP final1
//
//  Shown when the user is outside the launch region or must enable location.
//

import SwiftUI
import UIKit

struct ServiceAreaBlockScreen: View {
    enum Reason {
        case outsideRegion
        case needsLocationPermission
    }

    let reason: Reason
    var onRetry: () -> Void

    @State private var pulse = false

    var body: some View {
        GeometryReader { geometry in
            let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            let isCompact = safeHeight < 600

            ZStack {
                Color.brandBlack
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 20 : 28) {
                        Spacer(minLength: isCompact ? 24 : 48)

                        ZStack {
                            Circle()
                                .fill(Color.brandPurple.opacity(pulse ? 0.2 : 0.12))
                                .frame(width: isCompact ? 100 : 120, height: isCompact ? 100 : 120)
                                .blur(radius: 20)

                            Image(systemName: reason == .outsideRegion ? "mappin.slash.circle.fill" : "location.slash.fill")
                                .font(.system(size: isCompact ? 44 : 52))
                                .foregroundStyle(Color.brandPurple)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                                pulse = true
                            }
                        }

                        VStack(spacing: isCompact ? 8 : 12) {
                            HXText(
                                reason == .outsideRegion ? "Not available here yet" : "Location needed",
                                style: isCompact ? .headline : .title2
                            )

                            HXText(
                                reason == .outsideRegion
                                    ? "HustleXP is only available in \(AppConfig.serviceAreaDisplayName) right now. We’ll expand to more cities soon."
                                    : "Turn on location access so we can confirm you’re in \(AppConfig.serviceAreaDisplayName).",
                                style: isCompact ? .subheadline : .body,
                                color: .textSecondary
                            )
                            .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, isCompact ? 20 : 28)

                        VStack(spacing: 12) {
                            HXButton("Check again", variant: .primary) {
                                onRetry()
                            }

                            if reason == .needsLocationPermission {
                                HXButton("Open Settings", variant: .secondary) {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, isCompact ? 20 : 28)
                        .padding(.top, 8)

                        Spacer(minLength: 24)
                    }
                    .frame(minHeight: geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom)
                }
            }
        }
    }
}
