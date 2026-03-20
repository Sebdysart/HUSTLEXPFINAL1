/**
 * EntryScreen Component v8.0.0 — NEON NEXUS FINTECH V2
 *
 * AUTHORITY: NEON_NEXUS_FINTECH_V2.md
 *
 * ═══════════════════════════════════════════════════════════════════════════
 * PREMIUM FINTECH — Stripe/Linear/Vercel tier quality
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * BACKGROUND: Premium mesh gradient (10+ small points, heavy blur, seamless blend)
 * NOISE: Grain texture overlay (2-5% opacity)
 * PARTICLES: Tiny (1-3pt), sparse (15-20), slow upward drift
 * CTA GLOW: Tight (20-40pt blur), focused, not cartoonish
 * BASE: Deep black (#050507) for atmospheric depth
 */

import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
  Easing,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE COLORS (Premium Fintech)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  brand: {
    black: '#050507', // Deeper black base
    purple: '#5B2DFF',
    purpleBright: '#7B4DFF',
    purpleLight: '#8B6DFF',
  },
  text: {
    primary: '#FFFFFF',
    secondary: '#FFFFFF',
    muted: '#8E8E93',
  },
  background: {
    ambient: '#1a0a2e',
    ambientDark: '#0d0615',
  },
};

const { height: SCREEN_HEIGHT, width: SCREEN_WIDTH } = Dimensions.get('window');

// ═══════════════════════════════════════════════════════════════════════════
// PARTICLE DATA STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════

interface Particle {
  x: number;
  startY: number;
  size: number; // 1-3pt
  opacity: number;
  speed: number; // 25-35 seconds
  seed: number; // For golden angle distribution
}

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SCREEN COMPONENT — PREMIUM FINTECH V2
// ═══════════════════════════════════════════════════════════════════════════

export function BootstrapScreen() {
  const insets = useSafeAreaInsets();

  // ═══ PREMIUM MESH GRADIENT (10+ small points) ═══
  // Ambient layer (4 points, very subtle)
  const ambient1X = useRef(new Animated.Value(SCREEN_WIDTH * 0.2)).current;
  const ambient1Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.1)).current;
  const ambient2X = useRef(new Animated.Value(SCREEN_WIDTH * 0.8)).current;
  const ambient2Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.3)).current;
  const ambient3X = useRef(new Animated.Value(SCREEN_WIDTH * 0.5)).current;
  const ambient3Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.7)).current;
  const ambient4X = useRef(new Animated.Value(SCREEN_WIDTH * 0.1)).current;
  const ambient4Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.9)).current;

  // Accent mesh layer (16 points, purple glow - more points for seamless blend)
  const accentPoints = useRef(
    Array.from({ length: 16 }, (_, i) => {
      const xPos = SCREEN_WIDTH * (0.15 + ((i % 4) * 0.2) + Math.random() * 0.1);
      const yPos = SCREEN_HEIGHT * (0.1 + (Math.floor(i / 4) * 0.25) + Math.random() * 0.1);
      return {
        x: new Animated.Value(xPos),
        y: new Animated.Value(yPos),
        phase: i * 0.3,
        amplitude: 20 + (i % 3) * 8, // Smaller amplitude
      };
    })
  ).current;

  // Highlight points (2 bright accents)
  const highlight1X = useRef(new Animated.Value(SCREEN_WIDTH * 0.35)).current;
  const highlight1Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.25)).current;
  const highlight2X = useRef(new Animated.Value(SCREEN_WIDTH * 0.5)).current;
  const highlight2Y = useRef(new Animated.Value(SCREEN_HEIGHT * 0.88)).current;

  // ═══ FLOATING PARTICLES (tiny, sparse) ═══
  const [particles] = useState<Particle[]>(() => {
    const count = 18; // Sparse (15-20)
    return Array.from({ length: count }, (_, i) => {
      const seed = i * 137.508; // Golden angle distribution
      const x = (Math.sin(seed) * 0.5 + 0.5) * SCREEN_WIDTH;
      const startY = (Math.cos(seed * 0.7) * 0.5 + 0.5) * SCREEN_HEIGHT;
      return {
        x,
        startY,
        size: 1 + (i % 3), // 1-3pt (tiny)
        opacity: 0.2 + (i % 3) * 0.05,
        speed: 25 + (i % 5) * 5, // 25-35 seconds
        seed,
      };
    });
  });
  const particleAnimations = useRef(
    particles.map(() => new Animated.Value(0))
  ).current;

  // ═══ LOGO EMERGENCE ═══
  const logoScale = useRef(new Animated.Value(0.8)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;

  // ═══ BRAND NAME ═══
  const brandNameOpacity = useRef(new Animated.Value(0)).current;

  // ═══ HEADLINE ═══
  const headlineOpacity = useRef(new Animated.Value(0)).current;
  const headlineY = useRef(new Animated.Value(10)).current;

  // ═══ SUBHEAD ═══
  const subheadOpacity = useRef(new Animated.Value(0)).current;

  // ═══ CTA ═══
  const ctaOpacity = useRef(new Animated.Value(0)).current;
  const ctaScale = useRef(new Animated.Value(0.95)).current;
  const ctaY = useRef(new Animated.Value(20)).current;
  const ctaPulse = useRef(new Animated.Value(1)).current;
  const ctaGlowOpacity = useRef(new Animated.Value(0.15)).current; // Tight glow

  useEffect(() => {
    // ═══ AMBIENT LAYER (very slow drift) ═══
    const animateAmbient = (animX: Animated.Value, animY: Animated.Value, baseX: number, baseY: number) => {
      const animate = () => {
        Animated.parallel([
          Animated.timing(animX, {
            toValue: baseX + (Math.random() - 0.5) * 60,
            duration: 15000 + Math.random() * 5000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(animY, {
            toValue: baseY + (Math.random() - 0.5) * 50,
            duration: 15000 + Math.random() * 5000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]).start(() => animate());
      };
      animate();
    };

    animateAmbient(ambient1X, ambient1Y, SCREEN_WIDTH * 0.2, SCREEN_HEIGHT * 0.1);
    setTimeout(() => animateAmbient(ambient2X, ambient2Y, SCREEN_WIDTH * 0.8, SCREEN_HEIGHT * 0.3), 2000);
    setTimeout(() => animateAmbient(ambient3X, ambient3Y, SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.7), 4000);
    setTimeout(() => animateAmbient(ambient4X, ambient4Y, SCREEN_WIDTH * 0.1, SCREEN_HEIGHT * 0.9), 6000);

    // ═══ ACCENT MESH (10 points, slow drift) ═══
    accentPoints.forEach((point, i) => {
      const animate = () => {
        Animated.parallel([
          Animated.timing(point.x, {
            toValue: SCREEN_WIDTH * (0.2 + (i * 0.07)) + Math.sin(i * 0.5) * point.amplitude,
            duration: 12000 + i * 500,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(point.y, {
            toValue: SCREEN_HEIGHT * (0.15 + (i * 0.08)) + Math.cos(i * 0.5 * 0.7) * point.amplitude * 0.8,
            duration: 12000 + i * 500,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]).start(() => {
          // Reverse direction
          Animated.parallel([
            Animated.timing(point.x, {
              toValue: SCREEN_WIDTH * (0.2 + (i * 0.07)) - Math.sin(i * 0.5) * point.amplitude,
              duration: 12000 + i * 500,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(point.y, {
              toValue: SCREEN_HEIGHT * (0.15 + (i * 0.08)) - Math.cos(i * 0.5 * 0.7) * point.amplitude * 0.8,
              duration: 12000 + i * 500,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
          ]).start(() => animate());
        });
      };
      setTimeout(() => animate(), i * 300);
    });

    // ═══ HIGHLIGHT POINTS (bright accents) ═══
    const animateHighlight1 = () => {
      Animated.parallel([
        Animated.timing(highlight1X, {
          toValue: SCREEN_WIDTH * 0.35 + 30,
          duration: 15000,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(highlight1Y, {
          toValue: SCREEN_HEIGHT * 0.25 + 25,
          duration: 15000,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]).start(() => {
        Animated.parallel([
          Animated.timing(highlight1X, {
            toValue: SCREEN_WIDTH * 0.35 - 30,
            duration: 15000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(highlight1Y, {
            toValue: SCREEN_HEIGHT * 0.25 - 25,
            duration: 15000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]).start(() => animateHighlight1());
      });
    };

    const animateHighlight2 = () => {
      Animated.parallel([
        Animated.timing(highlight2X, {
          toValue: SCREEN_WIDTH * 0.5 + 20,
          duration: 18000,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(highlight2Y, {
          toValue: SCREEN_HEIGHT * 0.88 + 15,
          duration: 18000,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]).start(() => {
        Animated.parallel([
          Animated.timing(highlight2X, {
            toValue: SCREEN_WIDTH * 0.5 - 20,
            duration: 18000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(highlight2Y, {
            toValue: SCREEN_HEIGHT * 0.88 - 15,
            duration: 18000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]).start(() => animateHighlight2());
      });
    };

    animateHighlight1();
    setTimeout(() => animateHighlight2(), 3000);

    // ═══ FLOATING PARTICLES (tiny, sparse, slow) ═══
    particles.forEach((particle, index) => {
      const anim = particleAnimations[index];
      Animated.loop(
        Animated.timing(anim, {
          toValue: 1,
          duration: particle.speed * 1000, // 25-35 seconds
          easing: Easing.linear,
          useNativeDriver: true,
        })
      ).start();
    });

    // ═══ CTA GLOW (tight, focused) ═══
    Animated.loop(
      Animated.sequence([
        Animated.timing(ctaGlowOpacity, {
          toValue: 0.25,
          duration: 2500,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(ctaGlowOpacity, {
          toValue: 0.15,
          duration: 2500,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ])
    ).start();

    // ═══ ENTRANCE SEQUENCE (1.5s narrative) ═══
    // 300-600ms: Logo EMERGES
    setTimeout(() => {
      Animated.parallel([
        Animated.timing(logoScale, {
          toValue: 1.0,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(logoOpacity, {
          toValue: 1,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]).start();
    }, 300);

    // 600-900ms: Brand name fades in
    setTimeout(() => {
      Animated.timing(brandNameOpacity, {
        toValue: 1,
        duration: 300,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }).start();
    }, 600);

    // 900-1200ms: Headline animates in
    setTimeout(() => {
      Animated.parallel([
        Animated.timing(headlineOpacity, {
          toValue: 1,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(headlineY, {
          toValue: 0,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]).start();
    }, 900);

    // 1200-1500ms: Subhead fades in
    setTimeout(() => {
      Animated.timing(subheadOpacity, {
        toValue: 1,
        duration: 250,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }).start();
    }, 1200);

    // 1500ms+: CTA becomes active
    setTimeout(() => {
      Animated.parallel([
        Animated.timing(ctaOpacity, {
          toValue: 1,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(ctaScale, {
          toValue: 1.0,
          duration: 300,
          easing: Easing.out(Easing.back(1.2)),
          useNativeDriver: true,
        }),
        Animated.timing(ctaY, {
          toValue: 0,
          duration: 300,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]).start(() => {
        // CTA pulse
        Animated.loop(
          Animated.sequence([
            Animated.timing(ctaPulse, {
              toValue: 1.02,
              duration: 2000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(ctaPulse, {
              toValue: 1.0,
              duration: 2000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
          ])
        ).start();
      });
    }, 1500);
  }, []);

  const handleGetStarted = () => {
    console.log('Button pressed');
  };

  const handleSignIn = () => {
    console.log('Sign in pressed');
  };

  return (
    <View style={styles.container}>
      {/* ═══ BASE: Deep black ═══ */}
      <View style={[StyleSheet.absoluteFill, { backgroundColor: COLORS.brand.black }]} />

      {/* ═══ LAYER 1: Ambient mesh (4 points, very subtle, heavy blur) ═══ */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none">
        <Animated.View
          style={[
            styles.ambientBlob,
            styles.ambientBlobLarge,
            {
              transform: [
                { translateX: ambient1X },
                { translateY: ambient1Y },
              ],
            },
          ]}
        />
        <Animated.View
          style={[
            styles.ambientBlob,
            styles.ambientBlobMedium,
            {
              transform: [
                { translateX: ambient2X },
                { translateY: ambient2Y },
              ],
            },
          ]}
        />
        <Animated.View
          style={[
            styles.ambientBlob,
            styles.ambientBlobLarge,
            {
              transform: [
                { translateX: ambient3X },
                { translateY: ambient3Y },
              ],
            },
          ]}
        />
        <Animated.View
          style={[
            styles.ambientBlob,
            styles.ambientBlobMedium,
            {
              transform: [
                { translateX: ambient4X },
                { translateY: ambient4Y },
              ],
            },
          ]}
        />
      </View>

      {/* ═══ LAYER 2: Accent mesh (10 points, purple glow, heavy blur) ═══ */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none">
        {accentPoints.map((point, i) => {
          const size = 50 + (i % 4) * 20; // Even smaller (50-110)
          const opacity = 0.08 + (i % 5) * 0.02; // Very low opacities (0.08-0.16)
          return (
            <Animated.View
              key={`accent-${i}`}
              style={[
                styles.accentBlob,
                {
                  width: size,
                  height: size,
                  borderRadius: size / 2,
                  backgroundColor: COLORS.brand.purple,
                  opacity: opacity,
                  transform: [
                    { translateX: point.x },
                    { translateY: point.y },
                  ],
                },
              ]}
            />
          );
        })}
      </View>

      {/* ═══ LAYER 3: Bright highlights (2 points, sharp) ═══ */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none">
        <Animated.View
          style={[
            styles.highlightBlob,
            {
              transform: [
                { translateX: highlight1X },
                { translateY: highlight1Y },
              ],
            },
          ]}
        />
        <Animated.View
          style={[
            styles.highlightBlob,
            styles.highlightBlobElliptical,
            {
              transform: [
                { translateX: highlight2X },
                { translateY: highlight2Y },
              ],
            },
          ]}
        />
      </View>

      {/* ═══ LAYER 4: Floating particles (tiny, sparse) ═══ */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none">
        {particles.map((particle, index) => {
          const anim = particleAnimations[index];
          const translateY = anim.interpolate({
            inputRange: [0, 1],
            outputRange: [particle.startY, particle.startY - SCREEN_HEIGHT - 100],
          });
          const opacity = anim.interpolate({
            inputRange: [0, 0.2, 0.8, 1],
            outputRange: [0, particle.opacity, particle.opacity, 0],
          });

          return (
            <Animated.View
              key={`particle-${index}`}
              style={[
                styles.particle,
                {
                  left: particle.x,
                  width: particle.size,
                  height: particle.size,
                  borderRadius: particle.size / 2,
                  opacity: opacity,
                  transform: [{ translateY }],
                },
              ]}
            />
          );
        })}
      </View>

      {/* ═══ LAYER 5: Noise overlay (grain texture) ═══ */}
      <View style={styles.noiseOverlay} pointerEvents="none">
        {Array.from({ length: Math.floor(SCREEN_WIDTH * SCREEN_HEIGHT * 0.015) }).map((_, i) => (
          <View
            key={`noise-${i}`}
            style={[
              styles.noiseDot,
              {
                left: Math.random() * SCREEN_WIDTH,
                top: Math.random() * SCREEN_HEIGHT,
                opacity: 0.03 + Math.random() * 0.05, // 3-8% opacity (more visible)
              },
            ]}
          />
        ))}
      </View>

      {/* ═══ CONTENT ═══ */}
      <View style={[styles.content, { paddingTop: insets.top + 40 }]}>
        {/* BRAND SECTION ═══ */}
        <View style={styles.brandSection}>
          <Animated.View
            style={[
              styles.logoContainer,
              {
                opacity: logoOpacity,
                transform: [{ scale: logoScale }],
              },
            ]}
          >
            <Text style={styles.logoText}>H</Text>
          </Animated.View>
          <Animated.Text
            style={[
              styles.brandName,
              {
                opacity: brandNameOpacity,
              },
            ]}
          >
            HustleXP
          </Animated.Text>
        </View>

        {/* HEADLINE ═══ */}
        <Animated.View
          style={[
            styles.headlineSection,
            {
              opacity: headlineOpacity,
              transform: [{ translateY: headlineY }],
            },
          ]}
        >
          <Text style={styles.headline}>Turn time into money.</Text>
        </Animated.View>

        {/* SUBHEAD ═══ */}
        <Animated.View
          style={[
            styles.subheadSection,
            {
              opacity: subheadOpacity,
            },
          ]}
        >
          <Text style={styles.subheadline}>
            Post tasks and find help in minutes.{'\n'}
            Or earn money completing tasks nearby.
          </Text>
        </Animated.View>

        {/* SPACER ═══ */}
        <View style={styles.spacer} />

        {/* CTA SECTION (with tight glow) ═══ */}
        <Animated.View
          style={[
            styles.ctaSection,
            {
              paddingBottom: insets.bottom + 34,
              opacity: ctaOpacity,
              transform: [
                { scale: Animated.multiply(ctaScale, ctaPulse) },
                { translateY: ctaY },
              ],
            },
          ]}
        >
          {/* Tight glow (20-40pt blur, elliptical) ═══ */}
          <Animated.View
            style={[
              styles.ctaGlow,
              {
                opacity: ctaGlowOpacity,
              },
            ]}
            pointerEvents="none"
          />

          <TouchableOpacity
            style={styles.primaryButton}
            onPress={handleGetStarted}
            activeOpacity={0.85}
          >
            <Text style={styles.primaryButtonText}>Enter the market</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={handleSignIn}
            activeOpacity={0.7}
          >
            <Text style={styles.secondaryButtonText}>
              Already have an account?{' '}
              <Text style={styles.signInLink}>Sign in</Text>
            </Text>
          </TouchableOpacity>
        </Animated.View>
      </View>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES — PREMIUM FINTECH V2 (Stripe/Linear/Vercel tier)
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.brand.black,
    overflow: 'hidden',
  },

  // ═══ AMBIENT MESH (heavy blur, seamless blend) ═══
  ambientBlob: {
    position: 'absolute',
    borderRadius: 1000,
  },
  ambientBlobLarge: {
    width: 500,
    height: 500,
    backgroundColor: COLORS.background.ambient,
    opacity: 0.25, // Reduced for subtlety
    marginLeft: -250,
    marginTop: -250,
    shadowColor: COLORS.background.ambient,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 250, // Maximum blur (React Native limit)
  },
  ambientBlobMedium: {
    width: 400,
    height: 400,
    backgroundColor: COLORS.background.ambientDark,
    opacity: 0.3, // Reduced
    marginLeft: -200,
    marginTop: -200,
    shadowColor: COLORS.background.ambientDark,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 250, // Maximum blur
  },

  // ═══ ACCENT MESH (purple glow, heavy blur) ═══
  accentBlob: {
    position: 'absolute',
    marginLeft: -25, // Center offset
    marginTop: -25,
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 180, // Maximum blur for seamless blend
  },

  // ═══ HIGHLIGHT BLOBS (bright accents) ═══
  highlightBlob: {
    position: 'absolute',
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: COLORS.brand.purpleBright,
    opacity: 0.15, // Lower opacity
    marginLeft: -60,
    marginTop: -60,
    shadowColor: COLORS.brand.purpleBright,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 100, // Heavier blur
  },
  highlightBlobElliptical: {
    width: 160,
    height: 80,
    borderRadius: 40,
    marginLeft: -80,
    marginTop: -40,
  },

  // ═══ FLOATING PARTICLES (tiny, sparse) ═══
  particle: {
    position: 'absolute',
    backgroundColor: COLORS.brand.purpleLight,
  },

  // ═══ NOISE OVERLAY (grain texture) ═══
  noiseOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'transparent',
  },
  noiseDot: {
    position: 'absolute',
    width: 1,
    height: 1,
    backgroundColor: '#FFFFFF',
  },

  // ═══ CONTENT ═══
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },

  // ═══ BRAND SECTION ═══
  brandSection: {
    alignItems: 'flex-start',
    marginBottom: 32,
  },
  logoContainer: {
    width: 72,
    height: 72,
    borderRadius: 18,
    backgroundColor: COLORS.brand.purple,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.3,
    shadowRadius: 20,
  },
  logoText: {
    fontSize: 36,
    fontWeight: '700',
    color: COLORS.text.primary,
  },
  brandName: {
    fontSize: 26,
    fontWeight: '700',
    color: COLORS.text.primary,
    letterSpacing: -0.5,
    marginTop: 16,
  },

  // ═══ HEADLINE SECTION ═══
  headlineSection: {
    marginBottom: 16,
    alignSelf: 'flex-start',
  },
  headline: {
    fontSize: 34,
    fontWeight: '700',
    color: COLORS.text.primary,
    lineHeight: 40,
    letterSpacing: -0.5,
  },

  // ═══ SUBHEAD SECTION ═══
  subheadSection: {
    alignSelf: 'flex-start',
    marginBottom: 0,
  },
  subheadline: {
    fontSize: 17,
    fontWeight: '400',
    color: COLORS.text.secondary,
    opacity: 0.6, // Slightly more muted
    lineHeight: 24,
  },

  // ═══ SPACER ═══
  spacer: {
    flex: 1,
    minHeight: 40,
  },

  // ═══ CTA SECTION (with tight glow) ═══
  ctaSection: {
    width: '100%',
    position: 'relative',
  },
  ctaGlow: {
    position: 'absolute',
    width: 200,
    height: 30,
    borderRadius: 15,
    backgroundColor: COLORS.brand.purple,
    bottom: 56 + 10, // Positioned under button
    alignSelf: 'center',
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 25, // Tight blur (20-40pt range)
  },
  primaryButton: {
    backgroundColor: COLORS.brand.purple,
    height: 56,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
  },
  primaryButtonText: {
    fontSize: 17,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  secondaryButton: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  secondaryButtonText: {
    fontSize: 15,
    color: COLORS.text.muted,
  },
  signInLink: {
    color: COLORS.brand.purpleLight,
    fontWeight: '600',
    textDecorationLine: 'underline',
  },
});
