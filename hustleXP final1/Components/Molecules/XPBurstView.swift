//
//  XPBurstView.swift
//  hustleXP final1
//
//  XP gain celebration burst — full-screen overlay component.
//  Zero WKWebView. Pure SwiftUI Path + withAnimation.
//
//  Usage:
//    .overlay {
//        if showBurst {
//            XPBurstView(xpDelta: earnedXP) { showBurst = false }
//        }
//    }
//

import SwiftUI

// MARK: - XPBurstView

struct XPBurstView: View {
    let xpDelta: Int
    var onComplete: (() -> Void)? = nil

    // ── Stage ──
    @State private var stageOpacity: Double = 0

    // ── Rays ──
    @State private var raysOpacity: Double = 0

    // ── Orbit ring ──
    @State private var orbitOpacity: Double = 0

    // ── Burst rings ──
    @State private var ring1Radius: CGFloat = 1
    @State private var ring1Opacity: Double = 0
    @State private var ring2Radius: CGFloat = 1
    @State private var ring2Opacity: Double = 0
    @State private var ring3Radius: CGFloat = 1
    @State private var ring3Opacity: Double = 0

    // ── Success ring ──
    @State private var successRadius: CGFloat = 65
    @State private var successOpacity: Double = 0

    // ── Badge ──
    @State private var badgeScale: CGFloat = 0
    @State private var badgeOpacity: Double = 0
    @State private var badgeGlowGreen = false

    // ── XP Delta ──
    @State private var deltaOpacity: Double = 0
    @State private var deltaOffsetY: CGFloat = 6
    @State private var deltaScale: CGFloat = 0.78

    // ── Task Complete ──
    @State private var completeOpacity: Double = 0

    // ── Particles (16) & Sparkles (8) ──
    @State private var pProgress = [CGFloat](repeating: 0, count: 16)
    @State private var pOpacity  = [Double](repeating: 0, count: 16)
    @State private var sOpacity  = [Double](repeating: 0, count: 8)

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // ── Layer 0: Dark Stage ──
                Circle()
                    .fill(RadialGradient(
                        colors: [
                            Color(hex: "1C0A45").opacity(0.97),
                            Color(hex: "09051A").opacity(0.93),
                            Color(hex: "0B0B0F").opacity(0.86)
                        ],
                        center: .center, startRadius: 0, endRadius: 188
                    ))
                    .frame(width: 376, height: 376)
                    .opacity(stageOpacity)

                // ── Layer 1: Energy Rays ──
                XPEnergyRaysCanvas()
                    .frame(width: 376, height: 376)
                    .opacity(raysOpacity)

                // ── Layer 2: Orbit Ring ──
                Circle()
                    .stroke(
                        Color.brandPurple.opacity(0.35),
                        style: StrokeStyle(lineWidth: 0.75, dash: [3, 7])
                    )
                    .frame(width: 180, height: 180)
                    .opacity(orbitOpacity)

                // ── Layer 3: Burst Rings ──
                Circle()
                    .stroke(Color.brandPurple, lineWidth: 2.5)
                    .frame(width: ring1Radius * 2, height: ring1Radius * 2)
                    .opacity(ring1Opacity)

                Circle()
                    .stroke(Color(hex: "8B5CF6"), lineWidth: 1.5)
                    .frame(width: ring2Radius * 2, height: ring2Radius * 2)
                    .opacity(ring2Opacity)

                Circle()
                    .stroke(Color(hex: "8B5CF6"), lineWidth: 1)
                    .frame(width: ring3Radius * 2, height: ring3Radius * 2)
                    .opacity(ring3Opacity)

                // ── Layer 3b: Success Ring ──
                Circle()
                    .stroke(Color.successGreen, lineWidth: 3)
                    .frame(width: successRadius * 2, height: successRadius * 2)
                    .opacity(successOpacity)

                // ── Layer 4: Particles ──
                ForEach(0..<16, id: \.self) { i in
                    XPBurstParticle(isDiamond: i % 2 == 0, color: Self.particleColor(i))
                        .offset(
                            x: pProgress[i] * Self.particleOffsets[i].0,
                            y: pProgress[i] * Self.particleOffsets[i].1
                        )
                        .opacity(pOpacity[i])
                }

                // ── Layer 5: Sparkle Stars ──
                ForEach(0..<8, id: \.self) { i in
                    XPSparkleShape()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: Self.sparkleOffsets[i].0, y: Self.sparkleOffsets[i].1)
                        .opacity(sOpacity[i])
                }

                // ── Layer 6: Badge ──
                XPBadgeHexagon()
                    .scaleEffect(badgeScale)
                    .opacity(badgeOpacity)
                    .shadow(
                        color: badgeGlowGreen
                            ? Color.successGreen.opacity(0.85)
                            : Color.brandPurple.opacity(0.75),
                        radius: badgeGlowGreen ? 24 : 20
                    )

                // ── Layer 7: XP Delta Pill ──
                XPDeltaPill(xpDelta: xpDelta)
                    .offset(y: -97 + deltaOffsetY)
                    .scaleEffect(deltaScale)
                    .opacity(deltaOpacity)

                // ── Layer 8: TASK COMPLETE ──
                Text("TASK COMPLETE")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2.5)
                    .foregroundStyle(Color.successGreen)
                    .shadow(color: Color.successGreen.opacity(0.8), radius: 6)
                    .offset(y: 114)
                    .opacity(completeOpacity)
            }
            .frame(width: 400, height: 400)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .task { await runAnimation() }
    }

    // MARK: - Static Data

    // Particle offsets from center (SVG offset coords — same as SwiftUI .offset)
    static let particleOffsets: [(CGFloat, CGFloat)] = [
        ( 100.0,    0.0),   // 0°   r=100
        ( 101.6,   42.1),   // 22.5° r=110
        (  84.9,   84.9),   // 45°  r=120
        (  49.8,  120.1),   // 67.5° r=130
        (   0.0,  115.0),   // 90°  r=115
        ( -40.2,   97.0),   // 112.5° r=105
        ( -91.9,   91.9),   // 135° r=130
        (-110.9,   46.0),   // 157.5° r=120
        (-105.0,    0.0),   // 180° r=105
        (-129.4,  -53.6),   // 202.5° r=140
        ( -88.4,  -88.4),   // 225° r=125
        ( -44.1, -106.3),   // 247.5° r=115
        (   0.0, -110.0),   // 270° r=110
        (  47.8, -115.5),   // 292.5° r=125
        (  95.5,  -95.5),   // 315° r=135
        (  92.4,  -38.3)    // 337.5° r=100
    ]

    // Sparkle offsets from center
    static let sparkleOffsets: [(CGFloat, CGFloat)] = [
        ( 83.5,  16.2),
        ( 50.3,  74.6),
        (-16.3,  83.5),
        (-73.0,  49.2),
        (-90.4, -17.6),
        (-48.6, -72.1),
        ( 17.2, -88.4),
        ( 71.3, -48.1)
    ]

    // Particle color pattern: [purple, violet, white, gold] × 4
    static func particleColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0: return Color.brandPurple
        case 1: return Color(hex: "8B5CF6")
        case 2: return Color.white
        default: return Color(hex: "FFD900")
        }
    }

    // MARK: - Animation Sequencer

    func runAnimation() async {
        // t=0.00s  Stage + rays
        withAnimation(.linear(duration: 0.08)) { stageOpacity = 1 }
        withAnimation(.easeOut(duration: 0.10)) { raysOpacity = 1 }

        // t=0.10s  Badge springs in
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
            badgeScale = 1; badgeOpacity = 1
        }

        // t=0.12s  Ring 1
        try? await Task.sleep(for: .milliseconds(20))
        ring1Opacity = 0.95
        withAnimation(.timingCurve(0.2, 0.6, 0.4, 1.0, duration: 0.42)) {
            ring1Radius = 72; ring1Opacity = 0
        }

        // t=0.16s  Ring 2
        try? await Task.sleep(for: .milliseconds(40))
        ring2Opacity = 0.60
        withAnimation(.timingCurve(0.2, 0.6, 0.4, 1.0, duration: 0.55)) {
            ring2Radius = 105; ring2Opacity = 0
        }

        // t=0.18s  Orbit ring fades in
        try? await Task.sleep(for: .milliseconds(20))
        withAnimation(.easeOut(duration: 0.5)) { orbitOpacity = 0.35 }

        // t=0.20s  Ring 3
        try? await Task.sleep(for: .milliseconds(20))
        ring3Opacity = 0.35
        withAnimation(.timingCurve(0.2, 0.6, 0.4, 1.0, duration: 0.70)) {
            ring3Radius = 145; ring3Opacity = 0
        }

        // t=0.28s  Particle burst (16 concurrent tasks, 20ms stagger)
        try? await Task.sleep(for: .milliseconds(80))
        for i in 0..<16 {
            let delayMs = i * 20
            Task { @MainActor in
                if delayMs > 0 { try? await Task.sleep(for: .milliseconds(delayMs)) }
                withAnimation(.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.36)) {
                    pProgress[i] = 1
                }
                withAnimation(.easeOut(duration: 0.20)) { pOpacity[i] = 1 }
                try? await Task.sleep(for: .milliseconds(900))
                withAnimation(.easeIn(duration: 0.50)) { pOpacity[i] = 0 }
            }
        }

        // t=0.34s  Sparkles (8 concurrent tasks, 30ms stagger)
        try? await Task.sleep(for: .milliseconds(60))
        for i in 0..<8 {
            let delayMs = i * 30
            Task { @MainActor in
                if delayMs > 0 { try? await Task.sleep(for: .milliseconds(delayMs)) }
                withAnimation(.easeOut(duration: 0.30)) { sOpacity[i] = 0.9 }
                try? await Task.sleep(for: .milliseconds(900))
                withAnimation(.easeIn(duration: 0.50)) { sOpacity[i] = 0 }
            }
        }

        // t=0.62s  XP delta pill springs in
        try? await Task.sleep(for: .milliseconds(280))
        withAnimation(.spring(response: 0.28, dampingFraction: 0.50)) {
            deltaOpacity = 1; deltaOffsetY = 0; deltaScale = 1
        }

        // t=1.00s  Success ring + badge glow turns green
        try? await Task.sleep(for: .milliseconds(380))
        withAnimation(.easeIn(duration: 0.10)) { badgeGlowGreen = true }
        successOpacity = 0.95
        withAnimation(.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.45)) {
            successRadius = 112; successOpacity = 0
        }

        // t=1.05s  TASK COMPLETE fades in
        try? await Task.sleep(for: .milliseconds(50))
        withAnimation(.easeOut(duration: 0.28)) { completeOpacity = 1 }

        // t=1.38s  Rays fade out
        try? await Task.sleep(for: .milliseconds(330))
        withAnimation(.easeIn(duration: 0.30)) { raysOpacity = 0 }

        // t=1.45s  Badge glow back to purple
        try? await Task.sleep(for: .milliseconds(70))
        withAnimation(.easeIn(duration: 0.20)) { badgeGlowGreen = false }

        // t=1.65s  Fade out everything
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeIn(duration: 0.50)) {
            badgeOpacity = 0; badgeScale = 0.90
            deltaOpacity = 0; deltaOffsetY = -10
            completeOpacity = 0
            stageOpacity = 0; orbitOpacity = 0
        }

        // t=2.20s  Done
        try? await Task.sleep(for: .milliseconds(550))
        onComplete?()
    }
}

// MARK: - Badge Hexagon

private struct XPBadgeHexagon: View {
    var body: some View {
        ZStack {
            // Fill
            hexPath
                .fill(LinearGradient(
                    colors: [Color(hex: "6E3FFF"), Color(hex: "4A1FD6")],
                    startPoint: .top, endPoint: .bottom
                ))
            // Stroke
            hexPath
                .stroke(Color(hex: "8B5CF6"), lineWidth: 1.5)
            // Bevel highlight (top two faces)
            bevelPath
                .fill(Color.white.opacity(0.14))
            // XP label
            Text("XP")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.white)
        }
        .frame(width: 160, height: 160)
    }

    // Hexagon: circumradius=80, vertices at (80,0),(149,40),(149,120),(80,160),(11,120),(11,40)
    private var hexPath: Path {
        Path { p in
            p.move(to:     CGPoint(x:  80, y:   0))
            p.addLine(to:  CGPoint(x: 149, y:  40))
            p.addLine(to:  CGPoint(x: 149, y: 120))
            p.addLine(to:  CGPoint(x:  80, y: 160))
            p.addLine(to:  CGPoint(x:  11, y: 120))
            p.addLine(to:  CGPoint(x:  11, y:  40))
            p.closeSubpath()
        }
    }

    // Bevel: thin highlight strip across top two faces
    private var bevelPath: Path {
        Path { p in
            p.move(to:     CGPoint(x:  11, y:  40))
            p.addLine(to:  CGPoint(x:  80, y:   0))
            p.addLine(to:  CGPoint(x: 149, y:  40))
            p.addLine(to:  CGPoint(x: 136, y:  44))
            p.addLine(to:  CGPoint(x:  80, y:   8))
            p.addLine(to:  CGPoint(x:  24, y:  44))
            p.closeSubpath()
        }
    }
}

// MARK: - XP Delta Pill

private struct XPDeltaPill: View {
    let xpDelta: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 19)
                .fill(LinearGradient(
                    colors: [
                        Color(hex: "FFD900").opacity(0.18),
                        Color(hex: "FFE550").opacity(0.26),
                        Color(hex: "FFB800").opacity(0.18)
                    ],
                    startPoint: .leading, endPoint: .trailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color(hex: "FFD900").opacity(0.40), lineWidth: 0.75)
                )
                .frame(width: 130, height: 38)

            Text("+\(xpDelta) XP")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color(hex: "FFD900"))
                .shadow(color: Color(hex: "FFD900").opacity(0.70), radius: 4)
        }
    }
}

// MARK: - Energy Rays (Canvas)

private struct XPEnergyRaysCanvas: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let length: CGFloat = 152
            let hw: CGFloat = 1.5   // half-width of each ray

            for deg in stride(from: 0.0, to: 360.0, by: 45.0) {
                let rad = deg * .pi / 180.0
                let tip = CGPoint(
                    x: center.x + length * sin(rad),
                    y: center.y - length * cos(rad)
                )
                // Perpendicular unit vector for ray width
                let px = cos(rad) * hw
                let py = sin(rad) * hw

                var path = Path()
                path.move(to:    CGPoint(x: center.x - px, y: center.y - py))
                path.addLine(to: CGPoint(x: center.x + px, y: center.y + py))
                path.addLine(to: CGPoint(x: tip.x + px,   y: tip.y + py))
                path.addLine(to: CGPoint(x: tip.x - px,   y: tip.y - py))
                path.closeSubpath()

                context.fill(path, with: .linearGradient(
                    Gradient(colors: [
                        Color(hex: "7A4DFF").opacity(0),
                        Color(hex: "7A4DFF").opacity(0.42)
                    ]),
                    startPoint: tip,
                    endPoint: center
                ))
            }
        }
    }
}

// MARK: - Burst Particle

private struct XPBurstParticle: View {
    let isDiamond: Bool
    let color: Color

    var body: some View {
        if isDiamond {
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(45))
        } else {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        }
    }
}

// MARK: - Sparkle Star Shape

private struct XPSparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let arm   = rect.width / 2      // 10 in a 20×20 frame
        let waist = arm * 0.28          // 2.8

        return Path { p in
            p.move(to:     CGPoint(x: cx,         y: cy - arm))
            p.addLine(to:  CGPoint(x: cx + waist,  y: cy - waist))
            p.addLine(to:  CGPoint(x: cx + arm,    y: cy))
            p.addLine(to:  CGPoint(x: cx + waist,  y: cy + waist))
            p.addLine(to:  CGPoint(x: cx,          y: cy + arm))
            p.addLine(to:  CGPoint(x: cx - waist,  y: cy + waist))
            p.addLine(to:  CGPoint(x: cx - arm,    y: cy))
            p.addLine(to:  CGPoint(x: cx - waist,  y: cy - waist))
            p.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        XPBurstView(xpDelta: 147)
    }
}
