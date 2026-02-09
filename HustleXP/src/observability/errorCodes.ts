/**
 * Error codes — single source of truth.
 * Mirrors BACKEND_CONTRACT.md B3.
 */

export const ERROR_CODES = {
  // Network & Server
  NETWORK_ERROR: 'NETWORK_ERROR',
  SERVER_ERROR: 'SERVER_ERROR',

  // Resource
  NOT_FOUND: 'NOT_FOUND',

  // Auth & Permission
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',

  // Eligibility
  ELIGIBILITY_FAILED: 'ELIGIBILITY_FAILED',
  TRUST_TIER_REQUIRED: 'TRUST_TIER_REQUIRED',

  // Task State
  TASK_EXPIRED: 'TASK_EXPIRED',
  TASK_TAKEN: 'TASK_TAKEN',

  // System
  MAINTENANCE: 'MAINTENANCE',

  // Adapter-specific
  INVALID_RESPONSE: 'INVALID_RESPONSE',
  MISSING_REQUIRED_FIELD: 'MISSING_REQUIRED_FIELD',
} as const;

export type ErrorCode = typeof ERROR_CODES[keyof typeof ERROR_CODES];
