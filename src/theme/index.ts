/**
 * HustleXP Theme
 * Unified theme object for easy consumption
 */

import {
  colors,
  radii,
  spacing,
  touchTargets,
  typography,
  shadows,
  durations,
  zIndex,
} from './tokens';

export const theme = {
  colors,
  radii,
  spacing,
  touchTargets,
  typography,
  shadows,
  durations,
  zIndex,
} as const;

export type Theme = typeof theme;

// Re-export everything for convenience
export * from './tokens';

// Default export
export default theme;
