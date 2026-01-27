/**
 * HustleXP Design Tokens - WELCOMING INEVITABILITY
 * 
 * Not intimidating. Not chaotic. Not instructional.
 * "You've discovered something powerful — and it immediately feels 
 *  obvious, welcoming, and addictive."
 * 
 * Emotional Stack:
 * 1. Welcoming – "I belong here"
 * 2. Empowering – "This gives me leverage"
 * 3. Alive – "This system is active"
 * 4. Addictive – "One more step"
 */

// Core Palette - Purple is SIGNAL, not decoration
export const hustleColors = {
  // Purple spectrum - the living signal
  purple: {
    soft: '#8B7CF7',      // Welcoming, warm purple
    core: '#7C6AEF',      // Primary action color
    deep: '#6355E0',      // Pressed/active state
    glow: 'rgba(124, 106, 239, 0.4)', // Subtle glow
  },
  
  // Dark foundation - holds everything down
  dark: {
    void: '#0A0A0F',      // Deepest black (near-black)
    base: '#0F0F17',      // Primary background
    elevated: '#16162A',  // Cards, elevated surfaces
    surface: '#1E1E38',   // Tertiary surfaces
    border: 'rgba(255, 255, 255, 0.08)', // Subtle borders
  },
  
  // Text hierarchy - white used sparingly for clarity
  text: {
    primary: '#FFFFFF',
    secondary: 'rgba(255, 255, 255, 0.7)',
    tertiary: 'rgba(255, 255, 255, 0.5)',
    muted: 'rgba(255, 255, 255, 0.35)',
  },
  
  // Semantic - gentle, not alarming
  semantic: {
    success: '#6EE7B7',   // Soft mint green
    warning: '#FCD34D',   // Warm gold
    error: '#F87171',     // Soft coral
    info: '#93C5FD',      // Soft blue
  },
  
  // Money - this is where empowerment lives
  money: {
    primary: '#6EE7B7',   // Earnings green
    glow: 'rgba(110, 231, 183, 0.3)',
  },
  
  // Trust/XP - progression feeling
  xp: {
    primary: '#FCD34D',   // Warm gold
    glow: 'rgba(252, 211, 77, 0.3)',
  },
  
  // Glass effects - for depth and layering
  glass: {
    subtle: 'rgba(255, 255, 255, 0.03)',
    light: 'rgba(255, 255, 255, 0.05)',
    medium: 'rgba(255, 255, 255, 0.08)',
    border: 'rgba(255, 255, 255, 0.06)',
  },
  
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// Gradients - soft, hypnotic, not aggressive
export const hustleGradients = {
  // Background mesh - calm at first, mesmerizing after 2-3 seconds
  backgroundMesh: ['#0A0A0F', '#0F0F17', '#16162A'],
  
  // Soft purple glow for ambient effect
  purpleAmbient: ['rgba(124, 106, 239, 0.15)', 'transparent'],
  
  // Action gradient - where purple appears
  action: ['#8B7CF7', '#6355E0'],
  
  // Money/success feel
  earnings: ['#6EE7B7', '#34D399'],
  
  // Card shine overlay
  cardShine: [
    'rgba(255, 255, 255, 0.08)',
    'rgba(255, 255, 255, 0.02)',
    'transparent',
  ],
} as const;

// Shadows - subtle depth, not harsh glow
export const hustleShadows = {
  // Soft elevation
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 2,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.35,
    shadowRadius: 16,
    elevation: 8,
  },
  
  // Purple glow - used sparingly on active elements
  purpleGlow: {
    shadowColor: hustleColors.purple.core,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 10,
  },
  
  // Money glow - on earnings displays
  moneyGlow: {
    shadowColor: hustleColors.money.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 8,
  },
} as const;

// Animation - slow, hypnotic, addictive
export const hustleAnimations = {
  // Background gradient drift (10+ seconds, infinite)
  ambientDrift: {
    duration: 12000,
    easing: 'ease-in-out',
  },
  
  // Gentle pulse for "alive" feeling
  gentlePulse: {
    duration: 3000,
    scale: [1, 1.02, 1],
  },
  
  // Micro-interaction on tap - light, obvious, safe
  tap: {
    scale: 0.98,
    duration: 100,
  },
  
  // Smooth spring for cards
  spring: {
    damping: 20,
    stiffness: 200,
    mass: 0.8,
  },
  
  // Enter animations - smooth continuation
  enter: {
    duration: 400,
    stagger: 80,
  },
} as const;

// Border Radii - soft, modern
export const hustleRadii = {
  none: 0,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  full: 9999,
} as const;

// Spacing - 4px base
export const hustleSpacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  '4xl': 40,
  '5xl': 48,
  '6xl': 64,
} as const;

// Typography - human, simple, slightly clever
export const hustleTypography = {
  // Hero - for "wow" moments
  hero: {
    fontSize: 48,
    lineHeight: 56,
    fontWeight: '700' as const,
    letterSpacing: -1.5,
  },
  // Large title
  title1: {
    fontSize: 32,
    lineHeight: 40,
    fontWeight: '700' as const,
    letterSpacing: -0.5,
  },
  // Section title
  title2: {
    fontSize: 24,
    lineHeight: 32,
    fontWeight: '600' as const,
    letterSpacing: -0.3,
  },
  // Card title
  title3: {
    fontSize: 20,
    lineHeight: 28,
    fontWeight: '600' as const,
    letterSpacing: -0.2,
  },
  // Headlines
  headline: {
    fontSize: 17,
    lineHeight: 24,
    fontWeight: '600' as const,
    letterSpacing: -0.2,
  },
  // Body text
  body: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  // Smaller body
  callout: {
    fontSize: 15,
    lineHeight: 22,
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  // Labels
  subhead: {
    fontSize: 14,
    lineHeight: 20,
    fontWeight: '500' as const,
    letterSpacing: 0.1,
  },
  // Small text
  footnote: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '400' as const,
    letterSpacing: 0.1,
  },
  // Tiny text
  caption: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '400' as const,
    letterSpacing: 0.2,
  },
} as const;

/**
 * Component Presets - Cursor-proof building blocks
 */
export const hustlePresets = {
  // Card - glass with subtle shine
  card: {
    backgroundColor: hustleColors.dark.elevated,
    borderRadius: hustleRadii.xl,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    ...hustleShadows.md,
  },
  
  // Elevated card with glow hint
  cardElevated: {
    backgroundColor: hustleColors.dark.surface,
    borderRadius: hustleRadii.xl,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    ...hustleShadows.lg,
  },
  
  // Primary button - inviting, not demanding
  buttonPrimary: {
    backgroundColor: hustleColors.purple.core,
    borderRadius: hustleRadii.full,
    paddingVertical: 16,
    paddingHorizontal: 32,
  },
  
  // Secondary button - glass feel
  buttonSecondary: {
    backgroundColor: hustleColors.glass.medium,
    borderRadius: hustleRadii.full,
    borderWidth: 1,
    borderColor: hustleColors.purple.soft,
    paddingVertical: 16,
    paddingHorizontal: 32,
  },
  
  // Input field
  input: {
    backgroundColor: hustleColors.dark.elevated,
    borderRadius: hustleRadii.lg,
    borderWidth: 1,
    borderColor: hustleColors.glass.border,
    paddingVertical: 14,
    paddingHorizontal: 16,
  },
} as const;

// Export unified theme
export const hustleTheme = {
  colors: hustleColors,
  gradients: hustleGradients,
  shadows: hustleShadows,
  animations: hustleAnimations,
  radii: hustleRadii,
  spacing: hustleSpacing,
  typography: hustleTypography,
  presets: hustlePresets,
} as const;

export type HustleTheme = typeof hustleTheme;
