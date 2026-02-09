//
//  BootstrapScreen.swift
//  hustleXP final1
//
//  Bootstrap Phase - Step 001-003
//  Validates: App launches, screen renders, button logs to console
//

import SwiftUI

struct BootstrapScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App identity
            Text("HustleXP")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Bootstrap Mode")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            
            Spacer()
            
            // Bootstrap validation button
            Button(action: {
                print("[BOOTSTRAP] Button tapped at \(Date())")
                print("[BOOTSTRAP] App is stable and responsive")
            }) {
                Text("Verify Bootstrap")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brandPurple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .onAppear {
            print("[BOOTSTRAP] BootstrapScreen rendered at \(Date())")
        }
    }
}

#Preview {
    BootstrapScreen()
}
