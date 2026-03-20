/**
 * Maps error codes to UI configuration.
 * Guarantees UI + logging consistency.
 */

import { ERROR_CODES, type ErrorCode } from './errorCodes';

export type StatusBannerTone = 'info' | 'warning' | 'danger' | 'success';
export type ErrorAction = 'retry' | 'back' | 'navigate' | 'none';

export interface ErrorConfig {
  tone: StatusBannerTone;
  recoverable: boolean;
  action: ErrorAction;
  navigateTo?: string;
}

/**
 * Map an error code to its UI configuration.
 * Per BACKEND_CONTRACT.md B3 Error Code Mapping.
 */
export function mapError(code: ErrorCode | string): ErrorConfig {
  switch (code) {
    case ERROR_CODES.NETWORK_ERROR:
    case ERROR_CODES.SERVER_ERROR:
      return { tone: 'danger', recoverable: true, action: 'retry' };

    case ERROR_CODES.NOT_FOUND:
      return { tone: 'danger', recoverable: false, action: 'back' };

    case ERROR_CODES.UNAUTHORIZED:
      return { tone: 'danger', recoverable: false, action: 'navigate', navigateTo: 'Login' };

    case ERROR_CODES.FORBIDDEN:
      return { tone: 'danger', recoverable: false, action: 'navigate', navigateTo: 'Eligibility' };

    case ERROR_CODES.ELIGIBILITY_FAILED:
    case ERROR_CODES.TRUST_TIER_REQUIRED:
      return { tone: 'warning', recoverable: false, action: 'navigate', navigateTo: 'TrustLadder' };

    case ERROR_CODES.TASK_EXPIRED:
    case ERROR_CODES.TASK_TAKEN:
      return { tone: 'info', recoverable: false, action: 'back' };

    case ERROR_CODES.MAINTENANCE:
      return { tone: 'warning', recoverable: false, action: 'none' };

    case ERROR_CODES.INVALID_RESPONSE:
    case ERROR_CODES.MISSING_REQUIRED_FIELD:
      return { tone: 'danger', recoverable: true, action: 'retry' };

    default:
      return { tone: 'danger', recoverable: false, action: 'none' };
  }
}
