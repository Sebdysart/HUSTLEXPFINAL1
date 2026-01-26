/**
 * HustleXP Design Tokens
 * Single source of truth for all design values
 */

// Brand Colors
export const colors = {
  // Brand
  primary: '#5856D6',
  secondary: '#FF9500',
  accent: '#34C759',
  danger: '#FF3B30',
  
  // Brand namespace for Text component
  brand: {
    primary: '#5856D6',
    secondary: '#FF9500',
  },
  
  // Dark Surfaces
  surface: {
    primary: '#1C1C1E',
    secondary: '#2C2C2E',
    tertiary: '#3A3A3C',
  },
  
  // Text (Dark Mode)
  text: {
    primary: '#FFFFFF',
    secondary: '#8E8E93',
    tertiary: '#636366',
    disabled: '#48484A',
    inverse: '#000000',
  },
  
  // Gradients (as arrays for LinearGradient)
  gradients: {
    primary: ['#7B78FF', '#5856D6'],
    xp: ['#FFB347', '#FF9500'],
    money: ['#4CD964', '#34C759'],
  },
  
  // Semantic
  success: '#34C759',
  warning: '#FF9500',
  error: '#FF3B30',
  info: '#5856D6',
  
  // Semantic namespace (for screen compatibility)
  semantic: {
    success: '#34C759',
    warning: '#FF9500',
    error: '#FF3B30',
    info: '#5856D6',
  },
  
  // Utility
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// Border Radii
export const radii = {
  none: 0,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
} as const;

// Spacing (4px base) - named and numeric keys for flexibility
export const spacing = {
  // Named (semantic)
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  '4xl': 40,
  '5xl': 48,
  // Numeric (4-point scale)
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
} as const;

// Touch Targets
export const touchTargets = {
  min: 44,
  comfortable: 48,
  large: 56,
} as const;

// Typography Scale
export const typography = {
  hero: {
    fontSize: 48,
    lineHeight: 56,
    fontWeight: '800' as const,
    letterSpacing: -1,
  },
  title1: {
    fontSize: 34,
    lineHeight: 41,
    fontWeight: '700' as const,
    letterSpacing: 0.37,
  },
  title2: {
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700' as const,
    letterSpacing: 0.36,
  },
  title3: {
    fontSize: 22,
    lineHeight: 28,
    fontWeight: '600' as const,
    letterSpacing: 0.35,
  },
  headline: {
    fontSize: 17,
    lineHeight: 22,
    fontWeight: '600' as const,
    letterSpacing: -0.41,
  },
  body: {
    fontSize: 17,
    lineHeight: 22,
    fontWeight: '400' as const,
    letterSpacing: -0.41,
  },
  callout: {
    fontSize: 16,
    lineHeight: 21,
    fontWeight: '400' as const,
    letterSpacing: -0.32,
  },
  subhead: {
    fontSize: 15,
    lineHeight: 20,
    fontWeight: '400' as const,
    letterSpacing: -0.24,
  },
  footnote: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '400' as const,
    letterSpacing: -0.08,
  },
  caption: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
} as const;

// Shadows
export const shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.18,
    shadowRadius: 1,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.22,
    shadowRadius: 4,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 5,
  },
  glow: (color: string) => ({
    shadowColor: color,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 12,
    elevation: 8,
  }),
} as const;

// Animation Durations
export const durations = {
  fast: 150,
  normal: 250,
  slow: 400,
} as const;

// Z-Index Scale
export const zIndex = {
  base: 0,
  elevated: 1,
  dropdown: 10,
  sticky: 20,
  modal: 30,
  popover: 40,
  toast: 50,
} as const;

// Types
export type ColorKey = keyof typeof colors;
export type RadiiKey = keyof typeof radii;
export type SpacingKey = keyof typeof spacing;
export type TypographyKey = keyof typeof typography;
