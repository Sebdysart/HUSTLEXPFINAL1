//
//  ErrorState.swift
//  hustleXP final1
//
//  Molecule: ErrorState
//  Icon, message, retry functionality
//

import SwiftUI

struct ErrorState: View {
    let icon: String
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    init(
        icon: String = "exclamationmark.triangle.fill",
        title: String = "Something went wrong",
        message: String = "Please try again",
        retryAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HXIcon(icon, size: .xlarge, color: .red)
            
            HXText(title, style: .headline, alignment: .center)
            
            HXText(message, style: .subheadline, color: .secondary, alignment: .center)
                .padding(.horizontal, 32)
            
            if let retryAction = retryAction {
                HXButton("Try Again", variant: .primary, size: .medium, isFullWidth: false, action: retryAction)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

#Preview {
    VStack(spacing: 32) {
        ErrorState(
            title: "Connection Lost",
            message: "Please check your internet connection"
        ) {
            print("Retry tapped")
        }
        
        ErrorState(
            icon: "xmark.circle.fill",
            title: "Failed to Load",
            message: "Unable to load tasks at this time"
        )
    }
}
