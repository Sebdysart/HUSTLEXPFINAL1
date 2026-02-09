//
//  HXInput.swift
//  hustleXP final1
//
//  Atom: Input
//  Types: text, password, number, multiline
//

import SwiftUI

enum HXInputType {
    case text
    case email
    case password
    case number
    case phone
    case multiline
}

struct HXInput: View {
    let placeholder: String
    let type: HXInputType
    @Binding var text: String
    let error: String?
    
    init(
        _ placeholder: String,
        type: HXInputType = .text,
        text: Binding<String>,
        error: String? = nil
    ) {
        self.placeholder = placeholder
        self.type = type
        self._text = text
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                switch type {
                case .text:
                    TextField(placeholder, text: $text)
                        .textContentType(.name)
                    
                case .email:
                    TextField(placeholder, text: $text)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                case .password:
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                    
                case .number:
                    TextField(placeholder, text: $text)
                        .keyboardType(.decimalPad)
                    
                case .phone:
                    TextField(placeholder, text: $text)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                case .multiline:
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = error {
                HXText(error, style: .caption, color: .red)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HXInput("Email", type: .email, text: .constant(""))
        HXInput("Password", type: .password, text: .constant(""))
        HXInput("Phone", type: .phone, text: .constant(""))
        HXInput("With error", text: .constant(""), error: "This field is required")
    }
    .padding()
}
