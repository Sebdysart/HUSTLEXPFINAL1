//
//  ContentView.swift
//  hustleXP final1
//
//  Created by Sebastian Dysart on 2/5/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Preview helper - shows onboarding flow
        OnboardingStack()
            .environment(Router())
    }
}

#Preview("Onboarding Flow") {
    ContentView()
}
#Preview("Welcome Screen") {
    NavigationStack {
        WelcomeScreen()
    }
    .environment(Router())
}

