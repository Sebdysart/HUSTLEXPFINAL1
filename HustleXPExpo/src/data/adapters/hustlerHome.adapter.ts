/**
 * Adapter for HustlerHomeScreen — maps GET /api/hustler/home to screen props.
 * State derivation: missing required user fields → error; otherwise success.
 * Supports both mock and live data sources via source.ts configuration.
 */

import { hustlerHomeMock } from '../mocks/hustlerHome.mock';
import { isLive } from '../source';
import { get, ENDPOINTS, buildUrl, toObservabilityErrorCode } from '../../network';
import { logError } from '../../observability';
import type { AdapterResult } from '../types';

export interface HustlerHomeProps {
  user: { xp: number; level: number; trustTier: number };
  activeTask: import('../types').Task | null;
  availableTasksCount: number;
  recentEarnings: number;
  weeklyTaskCount: number;
  currentStreak: number;
  systemStatus: import('../types').SystemStatus | null;
}

const stubProps: HustlerHomeProps = {
  user: { xp: 0, level: 0, trustTier: 0 },
  activeTask: null,
  availableTasksCount: 0,
  recentEarnings: 0,
  weeklyTaskCount: 0,
  currentStreak: 0,
  systemStatus: null,
};

export async function getHustlerHomeData(): Promise<AdapterResult<HustlerHomeProps>> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let data: any;

  if (isLive(ENDPOINTS.HUSTLER_HOME)) {
    const url = buildUrl(ENDPOINTS.HUSTLER_HOME);
    const result = await get<unknown>(url);

    if (!result.ok) {
      logError('network', toObservabilityErrorCode(result.error.code), result.error.message, {
        meta: {
          endpoint: ENDPOINTS.HUSTLER_HOME,
          statusCode: result.error.statusCode,
        },
      });
      return { state: 'error', props: stubProps };
    }

    data = result.data;
  } else {
    data = hustlerHomeMock;
  }

  // Guard: user object must exist
  if (!data.user || typeof data.user !== 'object') {
    return { state: 'error', props: stubProps };
  }

  const user = data.user;
  if (
    typeof user.xp !== 'number' ||
    typeof user.level !== 'number' ||
    typeof user.trustTier !== 'number'
  ) {
    return { state: 'error', props: stubProps };
  }

  return {
    state: 'success',
    props: {
      user: { xp: user.xp, level: user.level, trustTier: user.trustTier },
      activeTask: data.activeTask ?? null,
      availableTasksCount: data.availableTasksCount ?? 0,
      recentEarnings: data.recentEarnings ?? 0,
      weeklyTaskCount: data.weeklyTaskCount ?? 0,
      currentStreak: data.currentStreak ?? 0,
      systemStatus: data.systemStatus ?? null,
    },
  };
}
