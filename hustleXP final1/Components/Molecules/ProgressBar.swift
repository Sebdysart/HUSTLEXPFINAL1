//
//  ProgressBar.swift
//  hustleXP final1
//
//  Molecule: ProgressBar
//  Premium progress indicators with animations and gradients
//

import SwiftUI

enum ProgressBarVariant {
    case linear
    case circular
    case steps
}

enum ProgressBarSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
    
    var circularLineWidth: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
}

struct HXProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let variant: ProgressBarVariant
    let color: Color
    let showLabel: Bool
    let label: String?
    let size: ProgressBarSize
    let animated: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        variant: ProgressBarVariant = .linear,
        color: Color = .brandPurple,
        showLabel: Bool = false,
        label: String? = nil,
        size: ProgressBarSize = .medium,
        animated: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.variant = variant
        self.color = color
        self.showLabel = showLabel
        self.label = label
        self.size = size
        self.animated = animated
    }
    
    var body: some View {
        Group {
            switch variant {
            case .linear:
                linearProgress
            case .circular:
                circularProgress
            case .steps:
                stepsProgress
            }
        }
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            if animated {
                withAnimation(.easeOut(duration: 0.4)) {
                    animatedProgress = newValue
                }
            } else {
                animatedProgress = newValue
            }
        }
    }
    
    // MARK: - Linear Progress
    
    private var linearProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            if label != nil || showLabel {
                HStack {
                    if let label = label {
                        Text(label)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                    if showLabel {
                        Text("\(Int(animatedProgress * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(color)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .fill(Color.surfaceSecondary)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * animatedProgress, size.height))
                    
                    // Glow highlight on the fill
                    if animatedProgress > 0.05 {
                        RoundedRectangle(cornerRadius: size.height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: max(geometry.size.width * animatedProgress, size.height), height: size.height / 2)
                            .offset(y: -size.height / 4)
                    }
                }
            }
            .frame(height: size.height)
        }
    }
    
    // MARK: - Circular Progress
    
    private var circularProgress: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.surfaceSecondary, lineWidth: size.circularLineWidth)
            
            // Progress ring with gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.6), color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: size.circularLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Glow effect at the end
            if animatedProgress > 0.1 {
                Circle()
                    .fill(color)
                    .frame(width: size.circularLineWidth + 4, height: size.circularLineWidth + 4)
                    .shadow(color: color.opacity(0.6), radius: 6, x: 0, y: 0)
                    .offset(y: -50) // Assuming 100x100 frame, adjust as needed
                    .rotationEffect(.degrees(-90 + (360 * animatedProgress)))
            }
            
            // Center content
            if showLabel {
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress * 100))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    
                    if let label = label {
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(Color.textSecondary)
                    } else {
                        Text("%")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Steps Progress
    
    private var stepsProgress: some View {
        let totalSteps = 5
        let completedSteps = Int(ceil(progress * Double(totalSteps)))
        
        return VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    let isCompleted = index < completedSteps
                    let isCurrent = index == completedSteps - 1 && progress < 1.0
                    
                    ZStack {
                        // Step circle
                        Circle()
                            .fill(isCompleted ? color : Color.surfaceSecondary)
                            .frame(width: 32, height: 32)
                        
                        // Glow for current
                        if isCurrent {
                            Circle()
                                .fill(color.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .blur(radius: 4)
                        }
                        
                        // Checkmark or number
                        if isCompleted && !isCurrent {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(isCompleted ? .white : Color.textMuted)
                        }
                    }
                    
                    // Connector line
                    if index < totalSteps - 1 {
                        Rectangle()
                            .fill(index < completedSteps - 1 ? color : Color.surfaceSecondary)
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            if let label = label {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Linear variants
            VStack(spacing: 16) {
                HXProgressBar(progress: 0.7, variant: .linear, showLabel: true, label: "XP Progress")
                HXProgressBar(progress: 0.45, variant: .linear, color: .successGreen, showLabel: true, label: "Completion", size: .small)
                HXProgressBar(progress: 0.9, variant: .linear, color: .warningOrange, showLabel: true, size: .large)
            }
            .padding(.horizontal)
            
            // Circular variant
            HStack(spacing: 32) {
                HXProgressBar(progress: 0.65, variant: .circular, showLabel: true, label: "Level")
                    .frame(width: 100, height: 100)
                
                HXProgressBar(progress: 0.85, variant: .circular, color: .moneyGreen, showLabel: true)
                    .frame(width: 80, height: 80)
            }
            
            // Steps variant
            HXProgressBar(progress: 0.6, variant: .steps, label: "Task Progress")
                .padding(.horizontal)
        }
        .padding()
    }
}
