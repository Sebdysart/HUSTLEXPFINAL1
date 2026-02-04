/**
 * Network client — fetch wrapper with Result-style output.
 * Handles timeouts, non-2xx responses, and invalid JSON.
 * Never throws; all failures normalized to NetworkError.
 */

import type { NetworkError } from './errors';
import { errorFromStatus } from './errors';

export type NetworkResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: NetworkError };

export interface RequestConfig {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  headers?: Record<string, string>;
  body?: unknown;
  timeout?: number;
}

const DEFAULT_TIMEOUT = 10000; // 10 seconds

/**
 * C7 REHEARSAL: Failure injection switch.
 * Set to null for normal operation.
 * REMOVE AFTER REHEARSAL.
 */
type ForceErrorType = null | 'NETWORK' | 'INVALID_BODY' | 'SERVER_500' | 'FORBIDDEN';
const FORCE_ERROR: ForceErrorType = null;

/**
 * Makes a network request with automatic JSON parsing.
 * Returns Result-style output; never throws.
 */
export async function request<T>(
  url: string,
  config: RequestConfig = {}
): Promise<NetworkResult<T>> {
  // C7 REHEARSAL: Force failure if configured
  if (FORCE_ERROR === 'NETWORK') {
    return {
      ok: false,
      error: { code: 'NETWORK_ERROR', message: '[C7] Forced network error' },
    };
  }
  if (FORCE_ERROR === 'INVALID_BODY') {
    return {
      ok: false,
      error: { code: 'INVALID_JSON', message: '[C7] Forced invalid JSON', statusCode: 200 },
    };
  }
  if (FORCE_ERROR === 'SERVER_500') {
    return {
      ok: false,
      error: { code: 'SERVER_ERROR', message: '[C7] Forced server error', statusCode: 500 },
    };
  }
  if (FORCE_ERROR === 'FORBIDDEN') {
    return {
      ok: false,
      error: { code: 'FORBIDDEN', message: '[C7] Forced forbidden', statusCode: 403 },
    };
  }

  const { method = 'GET', headers = {}, body, timeout = DEFAULT_TIMEOUT } = config;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...headers,
      },
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      return {
        ok: false,
        error: errorFromStatus(response.status),
      };
    }

    // Parse JSON
    let data: T;
    try {
      data = await response.json();
    } catch (parseError) {
      return {
        ok: false,
        error: {
          code: 'INVALID_JSON',
          message: 'Failed to parse response as JSON',
          statusCode: response.status,
          raw: parseError,
        },
      };
    }

    return { ok: true, data };
  } catch (error) {
    clearTimeout(timeoutId);

    // Timeout (AbortError)
    if (error instanceof Error && error.name === 'AbortError') {
      return {
        ok: false,
        error: {
          code: 'TIMEOUT',
          message: `Request timed out after ${timeout}ms`,
          raw: error,
        },
      };
    }

    // Network failure (offline, DNS, etc.)
    return {
      ok: false,
      error: {
        code: 'NETWORK_ERROR',
        message: error instanceof Error ? error.message : 'Network request failed',
        raw: error,
      },
    };
  }
}

/**
 * GET request helper.
 */
export function get<T>(url: string, config?: Omit<RequestConfig, 'method' | 'body'>): Promise<NetworkResult<T>> {
  return request<T>(url, { ...config, method: 'GET' });
}

/**
 * POST request helper.
 */
export function post<T>(url: string, body?: unknown, config?: Omit<RequestConfig, 'method' | 'body'>): Promise<NetworkResult<T>> {
  return request<T>(url, { ...config, method: 'POST', body });
}
