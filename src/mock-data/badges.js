/**
 * Mock Badge Data
 * SPEC: MOCK_DATA_SPEC.md §7
 * SCHEMA: schema.sql badges table
 */

export const BadgeTier = {
  BRONZE: 'bronze',
  SILVER: 'silver',
  GOLD: 'gold',
  PLATINUM: 'platinum',
};

export const BADGE_DEFINITIONS = {
  // First Task Badge
  'first-task': {
    id: 'first-task',
    name: 'First Steps',
    description: 'Complete your first task',
    icon: 'rocket',
    tier: BadgeTier.BRONZE,
    requirement_type: 'task_count',
    requirement_value: 1,
  },

  // Streak Badges
  'streak-3': {
    id: 'streak-3',
    name: 'Getting Started',
    description: 'Maintain a 3-day streak',
    icon: 'flame',
    tier: BadgeTier.BRONZE,
    requirement_type: 'streak',
    requirement_value: 3,
  },
  'streak-7': {
    id: 'streak-7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: 'flame',
    tier: BadgeTier.SILVER,
    requirement_type: 'streak',
    requirement_value: 7,
  },
  'streak-30': {
    id: 'streak-30',
    name: 'Monthly Master',
    description: 'Maintain a 30-day streak',
    icon: 'flame',
    tier: BadgeTier.GOLD,
    requirement_type: 'streak',
    requirement_value: 30,
  },

  // Trust Tier Badges
  'trust-tier-2': {
    id: 'trust-tier-2',
    name: 'Trusted Hustler',
    description: 'Reach Trust Tier 2',
    icon: 'shield',
    tier: BadgeTier.BRONZE,
    requirement_type: 'trust_tier',
    requirement_value: 2,
  },
  'trust-tier-3': {
    id: 'trust-tier-3',
    name: 'Reliable Pro',
    description: 'Reach Trust Tier 3',
    icon: 'shield-check',
    tier: BadgeTier.SILVER,
    requirement_type: 'trust_tier',
    requirement_value: 3,
  },
  'trust-tier-4': {
    id: 'trust-tier-4',
    name: 'Elite Status',
    description: 'Reach Trust Tier 4',
    icon: 'crown',
    tier: BadgeTier.GOLD,
    requirement_type: 'trust_tier',
    requirement_value: 4,
  },

  // Level Badges
  'level-3': {
    id: 'level-3',
    name: 'Apprentice',
    description: 'Reach Level 3',
    icon: 'trending-up',
    tier: BadgeTier.BRONZE,
    requirement_type: 'level',
    requirement_value: 3,
  },
  'level-5': {
    id: 'level-5',
    name: 'Rising Star',
    description: 'Reach Level 5',
    icon: 'star',
    tier: BadgeTier.SILVER,
    requirement_type: 'level',
    requirement_value: 5,
  },
  'level-8': {
    id: 'level-8',
    name: 'Expert',
    description: 'Reach Level 8',
    icon: 'zap',
    tier: BadgeTier.GOLD,
    requirement_type: 'level',
    requirement_value: 8,
  },
  'level-10': {
    id: 'level-10',
    name: 'Legend',
    description: 'Reach Level 10',
    icon: 'award',
    tier: BadgeTier.PLATINUM,
    requirement_type: 'level',
    requirement_value: 10,
  },

  // Task Count Badges
  'tasks-10': {
    id: 'tasks-10',
    name: 'Dedicated',
    description: 'Complete 10 tasks',
    icon: 'check-circle',
    tier: BadgeTier.BRONZE,
    requirement_type: 'task_count',
    requirement_value: 10,
  },
  'tasks-25': {
    id: 'tasks-25',
    name: 'Committed',
    description: 'Complete 25 tasks',
    icon: 'check-circle',
    tier: BadgeTier.SILVER,
    requirement_type: 'task_count',
    requirement_value: 25,
  },
  'tasks-50': {
    id: 'tasks-50',
    name: 'Veteran',
    description: 'Complete 50 tasks',
    icon: 'award',
    tier: BadgeTier.SILVER,
    requirement_type: 'task_count',
    requirement_value: 50,
  },
  'tasks-100': {
    id: 'tasks-100',
    name: 'Centurion',
    description: 'Complete 100 tasks',
    icon: 'award',
    tier: BadgeTier.GOLD,
    requirement_type: 'task_count',
    requirement_value: 100,
  },

  // Category Specialist Badges
  'specialist-cleaning': {
    id: 'specialist-cleaning',
    name: 'Clean Machine',
    description: 'Complete 10 cleaning tasks',
    icon: 'sparkles',
    tier: BadgeTier.BRONZE,
    requirement_type: 'category_count',
    requirement_category: 'cleaning',
    requirement_value: 10,
  },
  'specialist-delivery': {
    id: 'specialist-delivery',
    name: 'Speed Demon',
    description: 'Complete 10 delivery tasks',
    icon: 'truck',
    tier: BadgeTier.BRONZE,
    requirement_type: 'category_count',
    requirement_category: 'delivery',
    requirement_value: 10,
  },
  'specialist-moving': {
    id: 'specialist-moving',
    name: 'Heavy Lifter',
    description: 'Complete 10 moving tasks',
    icon: 'box',
    tier: BadgeTier.BRONZE,
    requirement_type: 'category_count',
    requirement_category: 'moving',
    requirement_value: 10,
  },

  // Special Badges
  'perfect-week': {
    id: 'perfect-week',
    name: 'Perfect Week',
    description: 'Complete 7 tasks in one week with 100% approval',
    icon: 'calendar-check',
    tier: BadgeTier.GOLD,
    requirement_type: 'special',
    requirement_value: 7,
  },
  'early-bird': {
    id: 'early-bird',
    name: 'Early Bird',
    description: 'Complete 5 tasks before 9 AM',
    icon: 'sun',
    tier: BadgeTier.SILVER,
    requirement_type: 'special',
    requirement_value: 5,
  },
};

export const MOCK_USER_BADGES = {
  'user-hustler-new': [],

  'user-hustler-active': [
    { badge_id: 'first-task', awarded_at: '2024-12-02T11:30:00Z' },
    { badge_id: 'streak-3', awarded_at: '2024-12-05T14:00:00Z' },
    { badge_id: 'trust-tier-2', awarded_at: '2024-12-15T14:00:00Z' },
    { badge_id: 'tasks-10', awarded_at: '2025-01-10T12:00:00Z' },
    { badge_id: 'level-3', awarded_at: '2025-01-13T14:00:00Z' },
  ],

  'user-hustler-elite': [
    { badge_id: 'first-task', awarded_at: '2024-06-02T11:30:00Z' },
    { badge_id: 'streak-3', awarded_at: '2024-06-05T14:00:00Z' },
    { badge_id: 'streak-7', awarded_at: '2024-06-10T12:00:00Z' },
    { badge_id: 'streak-30', awarded_at: '2024-07-05T12:00:00Z' },
    { badge_id: 'trust-tier-2', awarded_at: '2024-06-15T14:00:00Z' },
    { badge_id: 'trust-tier-3', awarded_at: '2024-07-20T14:00:00Z' },
    { badge_id: 'trust-tier-4', awarded_at: '2024-09-01T10:00:00Z' },
    { badge_id: 'level-3', awarded_at: '2024-06-20T12:00:00Z' },
    { badge_id: 'level-5', awarded_at: '2024-08-15T12:00:00Z' },
    { badge_id: 'level-8', awarded_at: '2024-11-10T12:00:00Z' },
    { badge_id: 'tasks-10', awarded_at: '2024-06-20T12:00:00Z' },
    { badge_id: 'tasks-25', awarded_at: '2024-07-25T12:00:00Z' },
    { badge_id: 'tasks-50', awarded_at: '2024-10-01T12:00:00Z' },
    { badge_id: 'tasks-100', awarded_at: '2025-01-05T12:00:00Z' },
    { badge_id: 'specialist-delivery', awarded_at: '2024-08-01T12:00:00Z' },
    { badge_id: 'perfect-week', awarded_at: '2024-09-15T12:00:00Z' },
  ],

  'user-both': [
    { badge_id: 'first-task', awarded_at: '2024-10-05T11:30:00Z' },
    { badge_id: 'trust-tier-2', awarded_at: '2024-11-15T14:00:00Z' },
  ],

  'user-poster-new': [],
  'user-poster-active': [],
};

/**
 * Get badges for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getBadgesForUser = (userId) => {
  const userBadges = MOCK_USER_BADGES[userId] || [];
  return userBadges.map(ub => ({
    ...BADGE_DEFINITIONS[ub.badge_id],
    awarded_at: ub.awarded_at,
  }));
};

/**
 * Get all badge definitions
 * @returns {Object[]}
 */
export const getAllBadgeDefinitions = () => Object.values(BADGE_DEFINITIONS);

/**
 * Get badge IDs unlocked by a user
 * @param {string} userId
 * @returns {string[]}
 */
export const getUnlockedBadgeIds = (userId) => {
  const userBadges = MOCK_USER_BADGES[userId] || [];
  return userBadges.map(ub => ub.badge_id);
};

/**
 * Check if a user has a specific badge
 * @param {string} userId
 * @param {string} badgeId
 * @returns {boolean}
 */
export const userHasBadge = (userId, badgeId) => {
  const unlockedBadges = getUnlockedBadgeIds(userId);
  return unlockedBadges.includes(badgeId);
};

/**
 * Get badges by tier
 * @param {string} tier
 * @returns {Object[]}
 */
export const getBadgesByTier = (tier) => {
  return Object.values(BADGE_DEFINITIONS).filter(b => b.tier === tier);
};

export default BADGE_DEFINITIONS;
