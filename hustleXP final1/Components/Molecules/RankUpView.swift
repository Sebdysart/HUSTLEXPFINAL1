//
//  RankUpView.swift
//  hustleXP final1
//
//  Revolut-grade rank promotion overlay.
//  Pure SwiftUI — zero WKWebView. 5 elements, single focal point.
//  Matches the Revolut motion design language: ease-out only, no bounce,
//  one ring, one shine sweep, one breath pulse.
//
//  Usage:
//    .overlay {
//        if showRankUp {
//            RankUpView(tier: "ELITE") { showRankUp = false }
//        }
//    }
//

import SwiftUI

// MARK: - Private Shapes

private struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let s = min(rect.width / 120, rect.height / 136)
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: cx + x * s, y: cy + y * s)
        }
        var path = Path()
        path.move(to: pt(0, -68))
        path.addLine(to: pt(60, -44))
        path.addLine(to: pt(60, 8))
        path.addQuadCurve(to: pt(0, 68), control: pt(60, 54))
        path.addQuadCurve(to: pt(-60, 8), control: pt(-60, 54))
        path.addLine(to: pt(-60, -44))
        path.closeSubpath()
        return path
    }
}

private struct BevelShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let s = min(rect.width / 120, rect.height / 136)
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: cx + x * s, y: cy + y * s)
        }
        var path = Path()
        path.move(to: pt(0, -68))
        path.addLine(to: pt(-60, -44))
        path.addLine(to: pt(-53, -22))
        path.addQuadCurve(to: pt(0, 55), control: pt(-49, 18))
        path.closeSubpath()
        return path
    }
}

private struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: cx + x, y: cy + y)
        }
        var path = Path()
        path.move(to: pt(-28, 9.5))
        path.addLine(to: pt(-28, -6.5))
        path.addLine(to: pt(-18, 3.5))
        path.addLine(to: pt(-8, -22))
        path.addLine(to: pt(0, -10))
        path.addLine(to: pt(8, -22))
        path.addLine(to: pt(18, 3.5))
        path.addLine(to: pt(28, -6.5))
        path.addLine(to: pt(28, 9.5))
        path.closeSubpath()
        return path
    }
}

// MARK: - RankUpView

struct RankUpView: View {
    let tier: String
    var onComplete: (() -> Void)? = nil

    // ELEMENT 1: Overlay
    @State private var overlayOpacity: Double = 0

    // ELEMENT 2: Ambient glow
    @State private var glowOpacity: Double = 0

    // ELEMENT 3: Badge
    @State private var badgeScale: CGFloat = 0.85
    @State private var badgeOpacity: Double = 0
    @State private var badgeYOffset: CGFloat = 6      // 6px lift on entrance

    // ELEMENT 4: Ring
    @State private var ringDiameter: CGFloat = 128    // initial 2*r=64
    @State private var ringOpacity: Double = 0

    // Shine sweep (within badge clip)
    @State private var shineXOffset: CGFloat = -90
    @State private var shineOpacity: Double = 0

    // ELEMENT 5: Typography
    @State private var rankLabelOpacity: Double = 0
    @State private var tierLabelOpacity: Double = 0

    // Cubic bezier matching SVG keySplines="0.22 0 0.36 1"
    private static func easeOut(_ duration: Double) -> Animation {
        .timingCurve(0.22, 0, 0.36, 1, duration: duration)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ELEMENT 1: Dark radial overlay — deeper at center, pure black at edges
                RadialGradient(
                    colors: [Color(hex: "13082C"), Color(hex: "0B0B0F")],
                    center: UnitPoint(x: 0.5, y: 0.46),
                    startRadius: 0,
                    endRadius: min(geo.size.width, geo.size.height) * 0.49
                )
                .opacity(overlayOpacity)
                .ignoresSafeArea()

                // Animation stage — shifted 15pt up to match SVG badge center at y=185 in 400px canvas
                ZStack {
                    // ELEMENT 2: Ambient glow
                    Circle()
                        .fill(Color(hex: "5B2DFF"))
                        .frame(width: 176, height: 176)
                        .blur(radius: 32)
                        .opacity(glowOpacity)

                    // ELEMENT 4: Single white expansion ring
                    Circle()
                        .stroke(Color.white, lineWidth: 1.1)
                        .frame(width: ringDiameter, height: ringDiameter)
                        .opacity(ringOpacity)

                    // ELEMENT 3: Shield badge + shine (clipped together to shield shape)
                    ZStack {
                        ShieldShape()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "5B2DFF"), Color(hex: "3A18CC")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(0.6)

                        ShieldShape()
                            .stroke(Color(hex: "7A4DFF"), lineWidth: 1)
                            .opacity(0.6)

                        BevelShape()
                            .fill(Color.white.opacity(0.07))

                        CrownShape()
                            .fill(Color.xpGold)

                        // Shine sweep — clipped to shield by .clipShape below
                        Rectangle()
                            .fill(Color.white.opacity(0.185))
                            .frame(width: 36, height: 178)
                            .rotationEffect(.degrees(-20))
                            .offset(x: shineXOffset)
                            .opacity(shineOpacity)
                    }
                    .frame(width: 120, height: 136)
                    .clipShape(ShieldShape())
                    .scaleEffect(badgeScale)
                    .offset(y: badgeYOffset)
                    .opacity(badgeOpacity)

                    // ELEMENT 5: Typography
                    VStack(spacing: 8) {
                        Text("RANK ACHIEVED")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(4)
                            .foregroundColor(.white)
                            .opacity(rankLabelOpacity)

                        Text(tier)
                            .font(.system(size: 32, weight: .bold))
                            .tracking(8)
                            .foregroundColor(Color.xpGold)
                            .opacity(tierLabelOpacity)
                    }
                    .offset(y: 116)
                }
                .offset(y: -15)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task { @MainActor in
                await runAnimation()
            }
        }
    }

    // MARK: - Animation Sequencer
    //
    // Absolute timing (matches SVG begin= attributes exactly):
    //   t=0ms    overlay in
    //   t=200ms  glow in
    //   t=300ms  badge entrance (scale + Y-lift + opacity)
    //   t=550ms  ring burst
    //   t=650ms  "RANK ACHIEVED" label
    //   t=750ms  shine sweep begins
    //   t=780ms  tier label
    //   t=1250ms shine out
    //   t=1250ms glow breath (0.28→0.315→0.28, 1050ms)
    //   t=2300ms all elements fade out
    //   t=2400ms overlay out
    //   t=2800ms onComplete

    private func runAnimation() async {
        // t=0ms
        withAnimation(Self.easeOut(0.25)) { overlayOpacity = 0.96 }

        // t=200ms: glow in
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(Self.easeOut(0.45)) { glowOpacity = 0.28 }

        // t=300ms: badge entrance — scale from 0.85→1.0, Y-lift 6→0, fade in
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(Self.easeOut(0.45)) {
            badgeScale = 1.0
            badgeYOffset = 0
        }
        withAnimation(Self.easeOut(0.35)) { badgeOpacity = 1.0 }

        // t=550ms: ring — instant flash at 0.35 opacity, then expand+fade
        try? await Task.sleep(for: .milliseconds(250))
        ringOpacity = 0.35
        withAnimation(Self.easeOut(0.6)) {
            ringDiameter = 210    // r=64 → r=105
            ringOpacity = 0
        }

        // t=650ms: "RANK ACHIEVED"
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(Self.easeOut(0.3)) { rankLabelOpacity = 0.45 }

        // t=750ms: shine sweep (badge fully at scale=1.0 by now)
        try? await Task.sleep(for: .milliseconds(100))
        shineXOffset = -90
        withAnimation(.linear(duration: 0.04)) { shineOpacity = 1.0 }
        withAnimation(Self.easeOut(0.5)) { shineXOffset = 90 }

        // t=780ms: tier label
        try? await Task.sleep(for: .milliseconds(30))
        withAnimation(Self.easeOut(0.35)) { tierLabelOpacity = 1.0 }

        // t=1250ms: shine out + glow breath begins
        // (750ms start + 500ms sweep = 1250ms; currently at 780ms, wait 470ms)
        try? await Task.sleep(for: .milliseconds(470))
        withAnimation(Self.easeOut(0.12)) { shineOpacity = 0.0 }

        // Glow breath: 0.28 → 0.315 → 0.28 (imperceptible life, not a bounce)
        withAnimation(.timingCurve(0.42, 0, 0.58, 1, duration: 0.525)) { glowOpacity = 0.315 }
        try? await Task.sleep(for: .milliseconds(525))
        withAnimation(.timingCurve(0.42, 0, 0.58, 1, duration: 0.525)) { glowOpacity = 0.28 }

        // t=2300ms: fade out all elements (1250 + 525 + 525 = 2300ms ✓)
        withAnimation(Self.easeOut(0.4)) {
            badgeOpacity = 0
            glowOpacity = 0
            rankLabelOpacity = 0
            tierLabelOpacity = 0
        }

        // t=2400ms: overlay out
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(Self.easeOut(0.4)) { overlayOpacity = 0 }

        // t=2800ms: complete
        try? await Task.sleep(for: .milliseconds(400))
        onComplete?()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RankUpView(tier: "ELITE")
    }
}
