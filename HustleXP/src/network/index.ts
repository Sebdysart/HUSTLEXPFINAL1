/**
 * Network layer — barrel export.
 */

export { request, get, post } from './client';
export type { NetworkResult, RequestConfig } from './client';

export { toObservabilityErrorCode, errorFromStatus } from './errors';
export type { NetworkError, NetworkErrorCode } from './errors';

export { API_BASE_URL, ENDPOINTS, buildUrl } from './config';
