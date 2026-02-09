/**
 * Network error types — normalized errors from fetch operations.
 * Maps to ERROR_CODES from observability layer.
 */

import { ERROR_CODES, type ErrorCode } from '../observability/errorCodes';

export type NetworkErrorCode =
  | 'NETWORK_ERROR'
  | 'TIMEOUT'
  | 'SERVER_ERROR'
  | 'INVALID_JSON'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND';

export interface NetworkError {
  code: NetworkErrorCode;
  message: string;
  statusCode?: number;
  raw?: unknown;
}

/**
 * Maps network error codes to observability ERROR_CODES.
 * Enables consistent logging across network and adapter layers.
 */
export function toObservabilityErrorCode(networkCode: NetworkErrorCode): ErrorCode {
  const mapping: Record<NetworkErrorCode, ErrorCode> = {
    NETWORK_ERROR: ERROR_CODES.NETWORK_ERROR,
    TIMEOUT: ERROR_CODES.NETWORK_ERROR,
    SERVER_ERROR: ERROR_CODES.SERVER_ERROR,
    INVALID_JSON: ERROR_CODES.INVALID_RESPONSE,
    UNAUTHORIZED: ERROR_CODES.UNAUTHORIZED,
    FORBIDDEN: ERROR_CODES.FORBIDDEN,
    NOT_FOUND: ERROR_CODES.NOT_FOUND,
  };
  return mapping[networkCode];
}

/**
 * Creates a network error from HTTP status code.
 */
export function errorFromStatus(status: number, message?: string): NetworkError {
  if (status === 401) {
    return { code: 'UNAUTHORIZED', message: message ?? 'Unauthorized', statusCode: status };
  }
  if (status === 403) {
    return { code: 'FORBIDDEN', message: message ?? 'Forbidden', statusCode: status };
  }
  if (status === 404) {
    return { code: 'NOT_FOUND', message: message ?? 'Not found', statusCode: status };
  }
  if (status >= 500) {
    return { code: 'SERVER_ERROR', message: message ?? 'Server error', statusCode: status };
  }
  return { code: 'SERVER_ERROR', message: message ?? `HTTP ${status}`, statusCode: status };
}
