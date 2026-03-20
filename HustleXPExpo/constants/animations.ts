/**
 * Animation Constants - UAP Compliant
 *
 * Duration constraints enforced by runtime guards (UI_SPEC §3.3)
 */

export const DURATION = {
  instant: 0,
  fast: 150,
  normal: 300,
  slow: 500,
  slower: 800,
} as const;

export const EASING = {
  standard: [0.4, 0, 0.2, 1],
  decelerate: [0, 0, 0.2, 1],
  accelerate: [0.4, 0, 1, 1],
  sharp: [0.4, 0, 0.6, 1],
} as const;

export const FORBIDDEN_PATTERNS = [
  'bounce',
  'elastic',
  'spring',
  'overshoot',
] as const;

export const MAX_QUEUED_ANIMATIONS = 3;