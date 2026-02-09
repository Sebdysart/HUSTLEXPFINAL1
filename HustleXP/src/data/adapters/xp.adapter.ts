/**
 * Adapter for XPBreakdownScreen — maps GET /api/hustler/xp to screen props.
 * State: missing totalXP/level/xpToNextLevel → error; history.length === 0 allowed (empty); else success.
 */

import { xpMock } from '../mocks/xp.mock';
import type { AdapterResult } from '../types';
import type { XPEntry } from '../types';

export interface XPBreakdownProps {
  totalXP: number;
  level: number;
  xpToNextLevel: number;
  xpProgress: number;
  history: XPEntry[];
  breakdown: Array<{ source: string; amount: number }>;
}

export async function getXPData(): Promise<AdapterResult<XPBreakdownProps>> {
  const data = xpMock;

  if (
    typeof data.totalXP !== 'number' ||
    typeof data.level !== 'number' ||
    typeof data.xpToNextLevel !== 'number'
  ) {
    return {
      state: 'error',
      props: {
        totalXP: 0,
        level: 0,
        xpToNextLevel: 0,
        xpProgress: 0,
        history: [],
        breakdown: [],
      },
    };
  }

  const history = Array.isArray(data.history) ? data.history : [];
  const breakdown = Array.isArray(data.breakdown) ? data.breakdown : [];
  const state = history.length === 0 && breakdown.length === 0 ? 'empty' : 'success';

  return {
    state,
    props: {
      totalXP: data.totalXP,
      level: data.level,
      xpToNextLevel: data.xpToNextLevel,
      xpProgress: typeof data.xpProgress === 'number' ? data.xpProgress : 0,
      history,
      breakdown,
    },
  };
}
