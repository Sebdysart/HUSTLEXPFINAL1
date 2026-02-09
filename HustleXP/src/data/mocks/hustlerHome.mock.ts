/**
 * Mock for GET /api/hustler/home — BACKEND_CONTRACT.md B2.
 * Single object matching endpoint exactly.
 */

export const hustlerHomeMock = {
  user: {
    xp: 1200,
    level: 4,
    trustTier: 2,
  },
  activeTask: null,
  availableTasksCount: 12,
  recentEarnings: 240,
  weeklyTaskCount: 6,
  currentStreak: 3,
  systemStatus: null,
};
