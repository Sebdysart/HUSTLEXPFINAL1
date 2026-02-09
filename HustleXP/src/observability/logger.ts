/**
 * Core logging utility — pure side-effect isolation.
 * No async. No throwing. Ever.
 */

export type LogLevel = 'info' | 'warn' | 'error';

export interface LogEvent {
  level: LogLevel;
  scope: 'adapter' | 'screen' | 'navigation' | 'system' | 'network';
  code?: string;
  message: string;
  screen?: string;
  adapter?: string;
  recoverable?: boolean;
  action?: 'retry' | 'back' | 'navigate' | 'none';
  meta?: Record<string, unknown>;
  timestamp: string; // ISO
}

/**
 * Log an event. Console in dev, stub for prod sink (Sentry/Datadog later).
 */
export function log(event: LogEvent): void {
  if (__DEV__) {
    const prefix = `[HUSTLEXP:${event.level.toUpperCase()}]`;
    console.log(prefix, JSON.stringify(event, null, 2));
  }
  // Production sink stub - integrate Sentry/Datadog later
}

/**
 * Convenience helpers
 */
export function logInfo(
  scope: LogEvent['scope'],
  message: string,
  meta?: Record<string, unknown>
): void {
  log({
    level: 'info',
    scope,
    message,
    meta,
    timestamp: new Date().toISOString(),
  });
}

export function logError(
  scope: LogEvent['scope'],
  code: string,
  message: string,
  options?: {
    screen?: string;
    adapter?: string;
    recoverable?: boolean;
    action?: LogEvent['action'];
    meta?: Record<string, unknown>;
  }
): void {
  log({
    level: 'error',
    scope,
    code,
    message,
    ...options,
    timestamp: new Date().toISOString(),
  });
}
