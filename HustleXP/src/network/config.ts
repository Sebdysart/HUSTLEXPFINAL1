/**
 * Network configuration — API base URL and endpoints.
 */

/**
 * API base URL.
 * TODO: Replace with actual backend URL when available.
 */
export const API_BASE_URL = 'https://api.hustlexp.com';

/**
 * API endpoints.
 */
export const ENDPOINTS = {
  HUSTLER_HOME: '/api/hustler/home',
  TASK_FEED: '/api/tasks',
  TASK_DETAIL: '/api/tasks/:taskId',
  TASK_PROGRESS: '/api/tasks/:taskId/progress',
  TASK_COMPLETION: '/api/tasks/:taskId/completion',
  XP: '/api/hustler/xp',
} as const;

/**
 * Builds a full URL for an endpoint.
 */
export function buildUrl(endpoint: string, params?: Record<string, string>): string {
  let url = `${API_BASE_URL}${endpoint}`;
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      url = url.replace(`:${key}`, encodeURIComponent(value));
    }
  }
  return url;
}
