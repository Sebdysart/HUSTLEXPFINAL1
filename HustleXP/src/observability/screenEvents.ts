/**
 * Screen state transition logging helpers.
 * Log transitions only, never props or PII.
 */

import { log } from './logger';
import type { AdapterState } from '../data/types';

/**
 * Log a screen state transition.
 */
export function logScreenTransition(
  screen: string,
  from: AdapterState | 'initial',
  to: AdapterState
): void {
  log({
    level: 'info',
    scope: 'screen',
    screen,
    message: 'state_transition',
    meta: { from, to },
    timestamp: new Date().toISOString(),
  });
}

/**
 * Log a screen mount.
 */
export function logScreenMount(screen: string): void {
  log({
    level: 'info',
    scope: 'screen',
    screen,
    message: 'mounted',
    timestamp: new Date().toISOString(),
  });
}

/**
 * Log a screen unmount.
 */
export function logScreenUnmount(screen: string): void {
  log({
    level: 'info',
    scope: 'screen',
    screen,
    message: 'unmounted',
    timestamp: new Date().toISOString(),
  });
}
