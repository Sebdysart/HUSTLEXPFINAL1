//
//  FormField.swift
//  hustleXP final1
//
//  Molecule: FormField
//  Label, input, and error messaging
//

import SwiftUI

struct FormField: View {
    let label: String
    let placeholder: String
    let type: HXInputType
    @Binding var text: String
    let error: String?
    let isRequired: Bool
    let helperText: String?
    
    init(
        label: String,
        placeholder: String,
        type: HXInputType = .text,
        text: Binding<String>,
        error: String? = nil,
        isRequired: Bool = false,
        helperText: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.type = type
        self._text = text
        self.error = error
        self.isRequired = isRequired
        self.helperText = helperText
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                HXText(label, style: .subheadline, color: .textSecondary)
                
                if isRequired {
                    HXText("*", style: .subheadline, color: .errorRed)
                }
            }
            
            HXInput(placeholder, type: type, text: $text, error: error)
            
            if let helperText = helperText, error == nil {
                HXText(helperText, style: .caption, color: .textSecondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        FormField(
            label: "Email",
            placeholder: "Enter your email",
            type: .email,
            text: .constant(""),
            isRequired: true
        )
        
        FormField(
            label: "Password",
            placeholder: "Enter your password",
            type: .password,
            text: .constant(""),
            error: "Password must be at least 8 characters",
            isRequired: true
        )
        
        FormField(
            label: "Bio",
            placeholder: "Tell us about yourself",
            type: .multiline,
            text: .constant(""),
            helperText: "Maximum 200 characters"
        )
    }
    .padding()
}
