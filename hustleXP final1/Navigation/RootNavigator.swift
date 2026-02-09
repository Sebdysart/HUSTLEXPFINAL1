//
//  RootNavigator.swift
//  hustleXP final1
//
//  Root navigation container that switches between auth states
//

import SwiftUI

struct RootNavigator: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router
    
    var body: some View {
        Group {
            switch appState.authState {
            case .unauthenticated:
                AuthStack()
                
            case .onboarding:
                OnboardingStack()
                
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.authState)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var state = appState
        
        TabView(selection: $state.selectedTab) {
            Group {
                if appState.userRole == .hustler {
                    HustlerStack()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    HustlerFeedScreen()
                        .tabItem {
                            Label("Feed", systemImage: "list.bullet")
                        }
                        .tag(1)
                    
                    HustlerHistoryScreen()
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
                        .tag(2)
                } else {
                    PosterStack()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    PosterActiveTasksScreen()
                        .tabItem {
                            Label("Active", systemImage: "list.bullet")
                        }
                        .tag(1)
                    
                    PosterHistoryScreen()
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
                        .tag(2)
                }
                
                SettingsStack()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    RootNavigator()
        .environment(AppState())
        .environment(Router())
}
