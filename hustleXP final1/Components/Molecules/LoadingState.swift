//
//  LoadingState.swift
//  hustleXP final1
//
//  Molecule: LoadingState
//  Premium loading indicators with animations
//

import SwiftUI

enum LoadingStateVariant {
    case spinner
    case skeleton
    case pulse
    case dots
}

struct LoadingState: View {
    let variant: LoadingStateVariant
    let message: String?
    let accentColor: Color
    
    init(
        variant: LoadingStateVariant = .spinner,
        message: String? = nil,
        accentColor: Color = .brandPurple
    ) {
        self.variant = variant
        self.message = message
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch variant {
            case .spinner:
                spinnerView
            case .skeleton:
                skeletonContent
            case .pulse:
                pulseView
            case .dots:
                dotsView
            }
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    // MARK: - Spinner View
    
    private var spinnerView: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(accentColor.opacity(0.2), lineWidth: 4)
                .frame(width: 48, height: 48)
            
            // Spinning arc
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [accentColor, accentColor.opacity(0.3)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(spinnerRotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        spinnerRotation = 360
                    }
                }
        }
    }
    
    @State private var spinnerRotation: Double = 0
    
    // MARK: - Pulse View
    
    private var pulseView: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(accentColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseScales[index])
                    .opacity(pulseOpacities[index])
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(Double(index) * 0.5)) {
                            pulseScales[index] = 2.0
                            pulseOpacities[index] = 0
                        }
                    }
            }
            
            Circle()
                .fill(accentColor)
                .frame(width: 16, height: 16)
        }
        .frame(height: 80)
    }
    
    @State private var pulseScales: [CGFloat] = [1, 1, 1]
    @State private var pulseOpacities: [Double] = [0.6, 0.6, 0.6]
    
    // MARK: - Dots View
    
    private var dotsView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(accentColor)
                    .frame(width: 12, height: 12)
                    .scaleEffect(dotScales[index])
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(index) * 0.2)) {
                            dotScales[index] = 1.3
                        }
                    }
            }
        }
    }
    
    @State private var dotScales: [CGFloat] = [1, 1, 1]
    
    // MARK: - Skeleton Content
    
    private var skeletonContent: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                SkeletonRow()
                    .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: true)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Skeleton Row

struct SkeletonRow: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar skeleton
            Circle()
                .fill(Color.surfaceSecondary)
                .frame(width: 48, height: 48)
                .overlay(shimmerOverlay)
            
            VStack(alignment: .leading, spacing: 10) {
                // Title skeleton
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceSecondary)
                    .frame(height: 16)
                    .frame(maxWidth: 160)
                    .overlay(shimmerOverlay)
                
                // Subtitle skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(height: 12)
                    .frame(maxWidth: 100)
                    .overlay(shimmerOverlay)
            }
            
            Spacer()
            
            // Price skeleton
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.surfaceSecondary)
                .frame(width: 60, height: 24)
                .overlay(shimmerOverlay)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
    
    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100)
                .offset(x: shimmerOffset)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Inline Loading

struct InlineLoading: View {
    let message: String
    let color: Color
    
    @State private var rotation: Double = 0
    
    init(message: String = "Loading...", color: Color = .brandPurple) {
        self.message = message
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, lineWidth: 2)
                .frame(width: 16, height: 16)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 48) {
            LoadingState(variant: .spinner, message: "Loading tasks...")
            
            LoadingState(variant: .dots, message: "Please wait")
            
            LoadingState(variant: .skeleton)
        }
    }
}
