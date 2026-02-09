//
//  ActionBar.swift
//  hustleXP final1
//
//  Molecule: ActionBar
//  Primary and secondary action grouping
//

import SwiftUI

struct ActionBar: View {
    let primaryTitle: String
    let primaryAction: () -> Void
    let primaryVariant: HXButtonVariant
    let primaryDisabled: Bool
    let primaryLoading: Bool
    let secondaryTitle: String?
    let secondaryAction: (() -> Void)?
    
    init(
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        primaryVariant: HXButtonVariant = .primary,
        primaryDisabled: Bool = false,
        primaryLoading: Bool = false,
        secondaryTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.primaryTitle = primaryTitle
        self.primaryAction = primaryAction
        self.primaryVariant = primaryVariant
        self.primaryDisabled = primaryDisabled
        self.primaryLoading = primaryLoading
        self.secondaryTitle = secondaryTitle
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HXButton(
                primaryTitle,
                variant: primaryDisabled ? .secondary : primaryVariant,
                isLoading: primaryLoading,
                action: primaryAction
            )
            .disabled(primaryDisabled)
            
            if let secondaryTitle = secondaryTitle, let secondaryAction = secondaryAction {
                Button(action: secondaryAction) {
                    HXText(secondaryTitle, style: .subheadline, color: .textSecondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

#Preview {
    VStack {
        Spacer()
        
        ActionBar(
            primaryTitle: "Continue",
            primaryAction: {},
            secondaryTitle: "Skip for now",
            secondaryAction: {}
        )
        
        ActionBar(
            primaryTitle: "Submit",
            primaryAction: {},
            primaryVariant: .danger,
            primaryDisabled: true
        )
        
        ActionBar(
            primaryTitle: "Processing...",
            primaryAction: {},
            primaryLoading: true
        )
    }
}
