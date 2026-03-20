/**
 * Observability exports — clean, explicit.
 */

export { log, logInfo, logError } from './logger';
export type { LogLevel, LogEvent } from './logger';

export { ERROR_CODES } from './errorCodes';
export type { ErrorCode } from './errorCodes';

export { mapError } from './errorMapper';
export type { StatusBannerTone, ErrorAction, ErrorConfig } from './errorMapper';

export {
  logScreenTransition,
  logScreenMount,
  logScreenUnmount,
} from './screenEvents';
