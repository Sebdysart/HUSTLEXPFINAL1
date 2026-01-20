/**
 * Mock XP Ledger Data
 * SPEC: MOCK_DATA_SPEC.md §6
 * SCHEMA: schema.sql xp_ledger table
 */

export const MOCK_XP_LEDGER = [
  // user-hustler-active XP history
  {
    id: 'xp-active-1',
    user_id: 'user-hustler-active',
    task_id: 'task-completed',
    escrow_id: 'escrow-completed',
    base_xp: 50,
    streak_multiplier: 1.15,
    decay_factor: 1.0,
    effective_xp: 58,
    reason: 'task_completion',
    user_xp_before: 392,
    user_xp_after: 450,
    user_level_before: 3,
    user_level_after: 3,
    user_streak_at_award: 3,
    awarded_at: '2025-01-14T10:15:00Z',
  },
  {
    id: 'xp-active-2',
    user_id: 'user-hustler-active',
    task_id: 'task-old-2',
    escrow_id: 'escrow-old-2',
    base_xp: 100,
    streak_multiplier: 1.10,
    decay_factor: 1.0,
    effective_xp: 110,
    reason: 'task_completion',
    user_xp_before: 282,
    user_xp_after: 392,
    user_level_before: 2,
    user_level_after: 3,
    user_streak_at_award: 2,
    awarded_at: '2025-01-13T14:00:00Z',
  },
  {
    id: 'xp-active-3',
    user_id: 'user-hustler-active',
    task_id: 'task-old-3',
    escrow_id: 'escrow-old-3',
    base_xp: 75,
    streak_multiplier: 1.05,
    decay_factor: 1.0,
    effective_xp: 79,
    reason: 'task_completion',
    user_xp_before: 203,
    user_xp_after: 282,
    user_level_before: 2,
    user_level_after: 2,
    user_streak_at_award: 1,
    awarded_at: '2025-01-12T16:00:00Z',
  },
  {
    id: 'xp-active-4',
    user_id: 'user-hustler-active',
    task_id: 'task-old-4',
    escrow_id: 'escrow-old-4',
    base_xp: 60,
    streak_multiplier: 1.0,
    decay_factor: 1.0,
    effective_xp: 60,
    reason: 'task_completion',
    user_xp_before: 143,
    user_xp_after: 203,
    user_level_before: 1,
    user_level_after: 2,
    user_streak_at_award: 0,
    awarded_at: '2025-01-10T12:00:00Z',
  },
  {
    id: 'xp-active-5',
    user_id: 'user-hustler-active',
    task_id: 'task-first',
    escrow_id: 'escrow-first',
    base_xp: 100,
    streak_multiplier: 1.0,
    decay_factor: 1.0,
    effective_xp: 100,
    reason: 'first_task_bonus',
    user_xp_before: 0,
    user_xp_after: 100,
    user_level_before: 1,
    user_level_after: 1,
    user_streak_at_award: 0,
    awarded_at: '2024-12-02T11:30:00Z',
  },

  // user-hustler-elite XP history (recent entries)
  {
    id: 'xp-elite-1',
    user_id: 'user-hustler-elite',
    task_id: 'task-elite-recent',
    escrow_id: 'escrow-elite-recent',
    base_xp: 75,
    streak_multiplier: 1.60,
    decay_factor: 1.0,
    effective_xp: 120,
    reason: 'task_completion',
    user_xp_before: 2380,
    user_xp_after: 2500,
    user_level_before: 8,
    user_level_after: 8,
    user_streak_at_award: 12,
    awarded_at: '2025-01-15T09:00:00Z',
  },
  {
    id: 'xp-elite-2',
    user_id: 'user-hustler-elite',
    task_id: 'task-elite-2',
    escrow_id: 'escrow-elite-2',
    base_xp: 80,
    streak_multiplier: 1.55,
    decay_factor: 1.0,
    effective_xp: 124,
    reason: 'task_completion',
    user_xp_before: 2256,
    user_xp_after: 2380,
    user_level_before: 8,
    user_level_after: 8,
    user_streak_at_award: 11,
    awarded_at: '2025-01-14T15:00:00Z',
  },

  // user-both XP history
  {
    id: 'xp-both-1',
    user_id: 'user-both',
    task_id: 'task-both-1',
    escrow_id: 'escrow-both-1',
    base_xp: 50,
    streak_multiplier: 1.05,
    decay_factor: 1.0,
    effective_xp: 53,
    reason: 'task_completion',
    user_xp_before: 147,
    user_xp_after: 200,
    user_level_before: 1,
    user_level_after: 2,
    user_streak_at_award: 1,
    awarded_at: '2025-01-10T14:00:00Z',
  },
];

/**
 * Get XP ledger entries for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getXPLedgerForUser = (userId) => {
  return MOCK_XP_LEDGER
    .filter(entry => entry.user_id === userId)
    .sort((a, b) => new Date(b.awarded_at) - new Date(a.awarded_at));
};

/**
 * Get total XP for a user
 * @param {string} userId
 * @returns {number}
 */
export const getTotalXPForUser = (userId) => {
  const entries = getXPLedgerForUser(userId);
  if (entries.length === 0) return 0;
  return entries[0].user_xp_after;
};

/**
 * Get recent XP entries (last N)
 * @param {string} userId
 * @param {number} limit
 * @returns {Object[]}
 */
export const getRecentXPEntries = (userId, limit = 5) => {
  return getXPLedgerForUser(userId).slice(0, limit);
};

/**
 * Calculate level from XP
 * Based on PRODUCT_SPEC §5.2
 * @param {number} xp
 * @returns {number}
 */
export const calculateLevel = (xp) => {
  const thresholds = [0, 100, 250, 500, 1000, 1750, 2750, 4000, 5500, 7500];
  for (let i = thresholds.length - 1; i >= 0; i--) {
    if (xp >= thresholds[i]) {
      return i + 1;
    }
  }
  return 1;
};

/**
 * Get XP needed for next level
 * @param {number} currentXP
 * @returns {Object}
 */
export const getNextLevelProgress = (currentXP) => {
  const thresholds = [0, 100, 250, 500, 1000, 1750, 2750, 4000, 5500, 7500];
  const currentLevel = calculateLevel(currentXP);

  if (currentLevel >= 10) {
    return {
      currentLevel: 10,
      nextLevel: 10,
      currentXP,
      nextThreshold: 7500,
      progress: 1.0,
      xpToNextLevel: 0,
    };
  }

  const currentThreshold = thresholds[currentLevel - 1];
  const nextThreshold = thresholds[currentLevel];
  const xpInLevel = currentXP - currentThreshold;
  const xpNeededForLevel = nextThreshold - currentThreshold;

  return {
    currentLevel,
    nextLevel: currentLevel + 1,
    currentXP,
    nextThreshold,
    progress: xpInLevel / xpNeededForLevel,
    xpToNextLevel: nextThreshold - currentXP,
  };
};

export default MOCK_XP_LEDGER;
