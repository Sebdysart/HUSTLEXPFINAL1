/**
 * Network layer — barrel export.
 */

export { request, get, post } from './client';
export type { NetworkResult, RequestConfig } from './client';

export { toObservabilityErrorCode, errorFromStatus } from './errors';
export type { NetworkError, NetworkErrorCode } from './errors';

export { API_BASE_URL, ENDPOINTS, buildUrl } from './config';

export {
  validateCertificate,
  getSSLPinningHeaders,
  logSSLPinningStatus,
  SSL_PINS,
  PINNED_HOSTNAMES,
  CURRENT_PINNING_PHASE,
  SSL_PINNING_ENABLED,
} from './ssl-pinning';
export type { SSLPin, SSLPinningPhase, SSLValidationResult } from './ssl-pinning';
