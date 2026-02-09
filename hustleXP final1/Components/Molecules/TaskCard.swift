//
//  TaskCard.swift
//  hustleXP final1
//
//  Molecule: TaskCard
//  Premium card with neon aesthetics, glassmorphism, and elegant typography
//

import SwiftUI

enum TaskCardVariant {
    case compact
    case expanded
    case featured  // Premium variant with enhanced effects
}

struct TaskCard: View {
    let title: String
    let payment: Double
    let location: String
    let duration: String
    let status: HXBadgeVariant.StatusType?
    let variant: TaskCardVariant
    let posterName: String?
    let category: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        payment: Double,
        location: String,
        duration: String,
        status: HXBadgeVariant.StatusType? = nil,
        variant: TaskCardVariant = .compact,
        posterName: String? = nil,
        category: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.payment = payment
        self.location = location
        self.duration = duration
        self.status = status
        self.variant = variant
        self.posterName = posterName
        self.category = category
        self.action = action
    }
    
    private var cornerRadius: CGFloat {
        switch variant {
        case .compact: return 18
        case .expanded: return 20
        case .featured: return 24
        }
    }
    
    private var accentColor: Color {
        switch variant {
        case .featured: return .aiPurple
        default: return .brandPurple
        }
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Category tag (for featured)
                if variant == .featured, let category = category {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .bold))
                            
                            Text(category.uppercased())
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(1.5)
                        }
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(accentColor.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        Spacer()
                    }
                    .padding(.bottom, 14)
                }
                
                // Header
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: variant == .featured ? 20 : (variant == .expanded ? 18 : 17), weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if let posterName = posterName {
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textMuted)
                                
                                Text("Posted by \(posterName)")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if let status = status {
                        NeonStatusBadge(status: status)
                    }
                }
                
                Spacer().frame(height: variant == .compact ? 14 : 18)
                
                // Payment highlight with glow
                HStack(spacing: 10) {
                    ZStack {
                        // Glow
                        Circle()
                            .fill(Color.moneyGreen.opacity(0.2))
                            .frame(width: 42, height: 42)
                            .blur(radius: 6)
                        
                        Circle()
                            .fill(Color.moneyGreen.opacity(0.15))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "dollarsign")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.moneyGreen)
                            .shadow(color: Color.moneyGreen.opacity(0.5), radius: 3)
                    }
                    
                    Text("$\(String(format: "%.0f", payment))")
                        .font(.system(size: variant == .featured ? 30 : 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.moneyGreen)
                        .shadow(color: Color.moneyGreen.opacity(0.3), radius: 5)
                    
                    Spacer()
                    
                    // Quick action hint
                    if variant == .featured {
                        HStack(spacing: 6) {
                            Text("View Details")
                                .font(.caption.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                
                if variant != .compact {
                    Spacer().frame(height: 18)
                    
                    // Neon divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, accentColor.opacity(0.3), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    Spacer().frame(height: 18)
                }
                
                // Details row
                HStack(spacing: 0) {
                    // Location
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.infoBlue.opacity(0.1))
                                .frame(width: 26, height: 26)
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.infoBlue)
                        }
                        
                        Text(location)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Duration
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.warningOrange.opacity(0.1))
                                .frame(width: 26, height: 26)
                            
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.warningOrange)
                        }
                        
                        Text(duration)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.top, variant == .compact ? 14 : 0)
            }
            .padding(variant == .featured ? 22 : (variant == .expanded ? 18 : 16))
            .background(
                ZStack {
                    // Base glass effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.surfaceElevated)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.06),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Neon border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: variant == .featured 
                                    ? [accentColor.opacity(0.4), accentColor.opacity(0.1)]
                                    : [Color.white.opacity(0.1), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: variant == .featured ? 1.5 : 1
                        )
                }
            )
            .shadow(
                color: variant == .featured ? accentColor.opacity(0.25) : Color.black.opacity(0.3),
                radius: variant == .featured ? 20 : 12,
                x: 0,
                y: variant == .featured ? 10 : 6
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(CardPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Neon Status Badge

struct NeonStatusBadge: View {
    let status: HXBadgeVariant.StatusType
    
    private var statusColor: Color {
        switch status {
        case .active: return .infoBlue
        case .pending: return .warningOrange
        case .completed: return .successGreen
        case .cancelled: return .errorRed
        case .inProgress: return .warningOrange
        case .live: return .liveRed
        case .instant: return .instantYellow
        }
    }
    
    private var statusText: String {
        switch status {
        case .active: return "Active"
        case .pending: return "Pending"
        case .completed: return "Done"
        case .cancelled: return "Cancelled"
        case .inProgress: return "In Progress"
        case .live: return "Live"
        case .instant: return "Instant"
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)
                .shadow(color: statusColor.opacity(0.8), radius: 3)
            
            Text(statusText.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CardPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            TaskCard(
                title: "Deliver Package Downtown",
                payment: 25,
                location: "Downtown",
                duration: "30 min",
                status: .active,
                variant: .compact
            ) {}
            
            TaskCard(
                title: "Help with Moving Heavy Furniture",
                payment: 75,
                location: "Westside",
                duration: "2 hrs",
                status: .pending,
                variant: .expanded,
                posterName: "John D."
            ) {}
            
            TaskCard(
                title: "Premium Task: Event Setup",
                payment: 150,
                location: "Convention Center",
                duration: "4 hrs",
                variant: .featured,
                posterName: "Sarah M.",
                category: "Top Pick"
            ) {}
        }
        .padding(20)
    }
    .background(Color.brandBlack)
}
