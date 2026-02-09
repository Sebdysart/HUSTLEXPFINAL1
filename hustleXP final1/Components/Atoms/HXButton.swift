//
//  HXButton.swift
//  hustleXP final1
//
//  Atom: Button
//  Premium neon styling with gradients, glow effects, and press states
//

import SwiftUI

enum HXButtonVariant {
    case primary
    case secondary
    case ghost
    case danger
    case success
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .brandPurple
        case .secondary: return .surfaceElevated
        case .ghost: return .clear
        case .danger: return .errorRed
        case .success: return .successGreen
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .danger, .success: return .white
        case .secondary: return .textPrimary
        case .ghost: return .brandPurple
        }
    }
    
    var hasGradient: Bool {
        switch self {
        case .primary, .danger, .success: return true
        case .secondary, .ghost: return false
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .primary:
            return LinearGradient(
                colors: [Color.brandPurple, Color.aiPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .danger:
            return LinearGradient(
                colors: [Color.errorRed, Color.errorRed.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [Color.successGreen, Color.successGreen.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(colors: [backgroundColor], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var glowColor: Color {
        switch self {
        case .primary: return .brandPurple
        case .danger: return .errorRed
        case .success: return .successGreen
        case .secondary: return .clear
        case .ghost: return .brandPurple
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary: return .brandPurple.opacity(0.5)
        case .danger: return .errorRed.opacity(0.5)
        case .success: return .successGreen.opacity(0.5)
        case .secondary: return .black.opacity(0.25)
        case .ghost: return .clear
        }
    }
    
    var borderColor: Color {
        switch self {
        case .secondary: return Color.white.opacity(0.1)
        case .ghost: return .brandPurple.opacity(0.4)
        default: return .clear
        }
    }
}

enum HXButtonSize {
    case small
    case medium
    case large
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 14
        case .large: return 18
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 18
        case .medium: return 26
        case .large: return 32
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .subheadline.weight(.bold)
        case .medium: return .body.weight(.bold)
        case .large: return .headline.weight(.bold)
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 18
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 10
        case .large: return 15
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
}

struct HXButton: View {
    let title: String
    let icon: String?
    let variant: HXButtonVariant
    let size: HXButtonSize
    let isFullWidth: Bool
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        icon: String? = nil,
        variant: HXButtonVariant = .primary,
        size: HXButtonSize = .large,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(variant.foregroundColor)
                        .scaleEffect(0.9)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .bold))
                        .shadow(color: variant == .primary ? .white.opacity(0.3) : .clear, radius: 3)
                }
                
                Text(title)
                    .font(size.font)
                    .tracking(0.5)
            }
            .foregroundStyle(variant.foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                ZStack {
                    if variant.hasGradient {
                        variant.gradient
                    } else {
                        variant.backgroundColor
                    }
                    
                    // Shimmer overlay for primary
                    if variant == .primary {
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, Color.white.opacity(0.1), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(
                        variant == .ghost 
                            ? variant.borderColor 
                            : (variant == .secondary ? variant.borderColor : Color.white.opacity(0.15)),
                        lineWidth: variant == .ghost ? 1.5 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .shadow(
                color: isPressed ? variant.shadowColor.opacity(0.3) : variant.shadowColor,
                radius: isPressed ? size.shadowRadius / 2 : size.shadowRadius,
                x: 0,
                y: isPressed ? 3 : 6
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.85 : 1)
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

// Custom button style to track press state
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 20) {
            HXButton("Get Started", icon: "arrow.right", variant: .primary) {}
            
            HXButton("Complete Task", icon: "checkmark", variant: .success) {}
            
            HXButton("Browse Tasks", variant: .secondary) {}
            
            HXButton("Learn More", variant: .ghost, size: .medium) {}
            
            HXButton("Cancel Task", icon: "xmark", variant: .danger) {}
            
            HXButton("Processing...", variant: .primary, isLoading: true) {}
            
            HStack(spacing: 12) {
                HXButton("Accept", variant: .primary, size: .small, isFullWidth: false) {}
                HXButton("Decline", variant: .secondary, size: .small, isFullWidth: false) {}
            }
        }
        .padding(24)
    }
}
