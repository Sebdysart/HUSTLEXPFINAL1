/**
 * Mock for GET /api/hustler/xp — BACKEND_CONTRACT.md B2.
 * Single object matching endpoint exactly.
 */

import type { XPEntry } from '../types';

const sampleHistory: XPEntry[] = [
  {
    id: 'xp-1',
    amount: 25,
    source: 'Task completion',
    earnedAt: '2025-01-30T14:30:00.000Z',
    taskTitle: 'Help move couch',
  },
  {
    id: 'xp-2',
    amount: 30,
    source: 'Task completion',
    earnedAt: '2025-01-29T11:00:00.000Z',
    taskTitle: 'Assemble IKEA furniture',
  },
];

export const xpMock = {
  totalXP: 1200,
  level: 4,
  xpToNextLevel: 300,
  xpProgress: 0.4,
  history: sampleHistory,
  breakdown: [
    { source: 'Task completion', amount: 1200 },
  ],
};
