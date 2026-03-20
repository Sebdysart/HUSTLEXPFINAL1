/**
 * Data source configuration — controls mock vs live data.
 * Single source of truth for data layer switching.
 *
 * RULES:
 * - Default: MOCK (safe for development)
 * - LIVE requires explicit opt-in
 * - Per-endpoint overrides supported for incremental migration
 */

export type DataSource = 'MOCK' | 'LIVE';

/**
 * Global data source setting.
 * Set to 'LIVE' only when backend is ready and tested.
 */
export const DATA_SOURCE: DataSource = 'MOCK';

/**
 * Per-endpoint overrides.
 * Allows incremental migration: enable live data one endpoint at a time.
 * If an endpoint is listed here, it overrides the global DATA_SOURCE.
 */
export const ENDPOINT_OVERRIDES: Partial<Record<string, DataSource>> = {
  '/api/hustler/home': 'LIVE',
  '/api/tasks': 'LIVE',
  '/api/tasks/:taskId': 'LIVE',
  '/api/tasks/:taskId/progress': 'LIVE',
  '/api/tasks/:taskId/completion': 'LIVE',
};

/**
 * Determines the data source for a given endpoint.
 * Checks endpoint override first, falls back to global setting.
 */
export function getDataSource(endpoint: string): DataSource {
  return ENDPOINT_OVERRIDES[endpoint] ?? DATA_SOURCE;
}

/**
 * Checks if an endpoint should use live data.
 */
export function isLive(endpoint: string): boolean {
  return getDataSource(endpoint) === 'LIVE';
}

/**
 * Checks if an endpoint should use mock data.
 */
export function isMock(endpoint: string): boolean {
  return getDataSource(endpoint) === 'MOCK';
}
