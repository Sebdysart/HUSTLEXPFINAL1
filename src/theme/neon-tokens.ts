/**
 * NEON NEXUS Theme - Top 1% Cyberpunk Fintech
 * Electric, glowing, premium
 */

// Neon Color Palette
export const neonColors = {
  // Primary Neons
  cyan: '#00F5FF',
  magenta: '#FF00FF',
  electric: '#00D4FF',
  lime: '#39FF14',
  gold: '#FFD700',
  
  // Brand
  brand: {
    primary: '#00F5FF',     // Electric cyan
    secondary: '#FF00FF',   // Hot magenta
    accent: '#39FF14',      // Matrix green
  },
  
  // Glowing variants (with opacity for glow effects)
  glow: {
    cyan: 'rgba(0, 245, 255, 0.6)',
    magenta: 'rgba(255, 0, 255, 0.6)',
    electric: 'rgba(0, 212, 255, 0.6)',
    gold: 'rgba(255, 215, 0, 0.6)',
  },
  
  // Dark surfaces with slight color tint
  surface: {
    void: '#050508',        // Near black
    primary: '#0A0A12',     // Deep navy black
    secondary: '#12121F',   // Elevated surface
    tertiary: '#1A1A2E',    // Card background
    elevated: '#22223A',    // Modal/sheet
  },
  
  // Text with hierarchy
  text: {
    primary: '#FFFFFF',
    secondary: 'rgba(255, 255, 255, 0.7)',
    tertiary: 'rgba(255, 255, 255, 0.5)',
    disabled: 'rgba(255, 255, 255, 0.3)',
    neon: '#00F5FF',        // Highlighted text
  },
  
  // Semantic with neon twist
  success: '#39FF14',       // Matrix green
  warning: '#FFD700',       // Gold
  error: '#FF3366',         // Hot pink
  info: '#00D4FF',          // Electric blue
  
  // Gradients
  gradients: {
    neonPrimary: ['#00F5FF', '#0080FF'],
    neonHot: ['#FF00FF', '#FF3366'],
    neonMoney: ['#39FF14', '#00FF88'],
    neonGold: ['#FFD700', '#FF8C00'],
    mesh: ['#0A0A12', '#1A1A2E', '#12121F'],
    aurora: ['#00F5FF', '#FF00FF', '#FFD700'],
  },
  
  // Glass effects
  glass: {
    light: 'rgba(255, 255, 255, 0.05)',
    medium: 'rgba(255, 255, 255, 0.08)',
    heavy: 'rgba(255, 255, 255, 0.12)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  
  white: '#FFFFFF',
  black: '#000000',
  transparent: 'transparent',
} as const;

// Neon Shadows with Glow
export const neonShadows = {
  // Soft glow
  glow: (color: string, intensity: number = 0.6) => ({
    shadowColor: color,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: intensity,
    shadowRadius: 20,
    elevation: 15,
  }),
  
  // Card shadow with subtle glow
  card: {
    shadowColor: '#00F5FF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 8,
  },
  
  // Intense neon border glow
  neonBorder: (color: string) => ({
    shadowColor: color,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 8,
    elevation: 10,
  }),
  
  // Floating element
  float: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.4,
    shadowRadius: 16,
    elevation: 12,
  },
};

// Premium Border Radii
export const neonRadii = {
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

// Glass Card Styles
export const glassStyles = {
  card: {
    backgroundColor: neonColors.glass.medium,
    borderWidth: 1,
    borderColor: neonColors.glass.border,
    borderRadius: neonRadii.xl,
  },
  cardHeavy: {
    backgroundColor: neonColors.glass.heavy,
    borderWidth: 1,
    borderColor: neonColors.glass.border,
    borderRadius: neonRadii.xl,
  },
  pill: {
    backgroundColor: neonColors.glass.light,
    borderWidth: 1,
    borderColor: neonColors.glass.border,
    borderRadius: neonRadii.full,
  },
};

// Animation configs for Reanimated
export const neonAnimations = {
  // Pulse glow effect
  pulseGlow: {
    duration: 2000,
    easing: 'ease-in-out',
  },
  // Smooth spring
  spring: {
    damping: 15,
    stiffness: 150,
    mass: 1,
  },
  // Quick tap feedback
  tap: {
    duration: 100,
    scale: 0.97,
  },
  // Entrance animation
  enter: {
    duration: 400,
    delay: 50,
  },
};

export type NeonColorKey = keyof typeof neonColors;
