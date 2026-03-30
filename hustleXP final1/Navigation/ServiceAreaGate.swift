//
//  ServiceAreaGate.swift
//  hustleXP final1
//
//  Wraps post-auth UI with geographic launch limits from AppConfig.
//

import SwiftUI

struct ServiceAreaGate<Content: View>: View {
    @Environment(ServiceAreaManager.self) private var serviceArea
    @Environment(\.scenePhase) private var scenePhase

    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            switch serviceArea.phase {
            case .allowed:
                content()
            case .checking:
                ZStack {
                    Color.brandBlack
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.brandPurple)
                        HXText("Checking service area…", style: .subheadline, color: .textSecondary)
                    }
                }
            case .outsideRegion:
                ServiceAreaBlockScreen(reason: .outsideRegion) {
                    Task { await serviceArea.refresh() }
                }
            case .needsLocationPermission:
                ServiceAreaBlockScreen(reason: .needsLocationPermission) {
                    Task { await serviceArea.refresh() }
                }
            }
        }
        .task {
            await serviceArea.refresh()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await serviceArea.refresh() }
            }
        }
    }
}
