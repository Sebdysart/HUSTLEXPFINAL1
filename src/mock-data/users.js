/**
 * Mock User Data
 * SPEC: MOCK_DATA_SPEC.md §2
 * SCHEMA: schema.sql users table
 */

export const MOCK_USERS = {
  'user-hustler-new': {
    id: 'user-hustler-new',
    email: 'alex.new@example.com',
    phone: '+1555000001',
    full_name: 'Alex Chen',
    avatar_url: null,
    default_mode: 'worker',
    onboarding_completed_at: '2025-01-15T10:00:00Z',
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    last_task_completed_at: null,
    is_verified: false,
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2025-01-15T09:00:00Z',
    updated_at: '2025-01-15T10:00:00Z',
  },

  'user-hustler-active': {
    id: 'user-hustler-active',
    email: 'jordan.active@example.com',
    phone: '+1555000002',
    full_name: 'Jordan Rivera',
    avatar_url: 'https://example.com/avatars/jordan.jpg',
    default_mode: 'worker',
    onboarding_completed_at: '2024-12-01T10:00:00Z',
    trust_tier: 2,
    xp_total: 450,
    current_level: 3,
    current_streak: 3,
    last_task_completed_at: '2025-01-14T16:00:00Z',
    is_verified: true,
    verified_at: '2024-12-05T14:00:00Z',
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: '2024-12-02T11:30:00Z',
    created_at: '2024-12-01T09:00:00Z',
    updated_at: '2025-01-14T16:00:00Z',
  },

  'user-hustler-elite': {
    id: 'user-hustler-elite',
    email: 'taylor.elite@example.com',
    phone: '+1555000003',
    full_name: 'Taylor Washington',
    avatar_url: 'https://example.com/avatars/taylor.jpg',
    default_mode: 'worker',
    onboarding_completed_at: '2024-06-01T10:00:00Z',
    trust_tier: 4,
    xp_total: 2500,
    current_level: 8,
    current_streak: 12,
    last_task_completed_at: '2025-01-15T09:00:00Z',
    is_verified: true,
    verified_at: '2024-06-05T14:00:00Z',
    student_id_verified: true,
    live_mode_state: 'ACTIVE',
    live_mode_session_started_at: '2025-01-15T08:00:00Z',
    xp_first_celebration_shown_at: '2024-06-02T11:30:00Z',
    created_at: '2024-06-01T09:00:00Z',
    updated_at: '2025-01-15T09:00:00Z',
  },

  'user-poster-new': {
    id: 'user-poster-new',
    email: 'sam.poster@example.com',
    phone: '+1555000004',
    full_name: 'Sam Miller',
    avatar_url: null,
    default_mode: 'poster',
    onboarding_completed_at: '2025-01-10T10:00:00Z',
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    is_verified: false,
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2025-01-10T09:00:00Z',
    updated_at: '2025-01-10T10:00:00Z',
  },

  'user-poster-active': {
    id: 'user-poster-active',
    email: 'casey.poster@example.com',
    phone: '+1555000005',
    full_name: 'Casey Thompson',
    avatar_url: 'https://example.com/avatars/casey.jpg',
    default_mode: 'poster',
    onboarding_completed_at: '2024-11-01T10:00:00Z',
    trust_tier: 2,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    is_verified: true,
    verified_at: '2024-11-05T14:00:00Z',
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2024-11-01T09:00:00Z',
    updated_at: '2025-01-12T10:00:00Z',
  },

  'user-both': {
    id: 'user-both',
    email: 'morgan.both@example.com',
    phone: '+1555000006',
    full_name: 'Morgan Davis',
    avatar_url: 'https://example.com/avatars/morgan.jpg',
    default_mode: 'worker',
    onboarding_completed_at: '2024-10-01T10:00:00Z',
    trust_tier: 2,
    xp_total: 200,
    current_level: 2,
    current_streak: 1,
    last_task_completed_at: '2025-01-10T14:00:00Z',
    is_verified: true,
    verified_at: '2024-10-05T14:00:00Z',
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: '2024-10-05T11:30:00Z',
    created_at: '2024-10-01T09:00:00Z',
    updated_at: '2025-01-10T14:00:00Z',
  },
};

/**
 * Get a user by ID
 * @param {string} userId
 * @returns {Object|null}
 */
export const getCurrentUser = (userId) => MOCK_USERS[userId] || null;

/**
 * Get all users
 * @returns {Object[]}
 */
export const getAllUsers = () => Object.values(MOCK_USERS);

/**
 * Get users by type (worker/poster)
 * @param {string} mode - 'worker' or 'poster'
 * @returns {Object[]}
 */
export const getUsersByMode = (mode) => {
  return Object.values(MOCK_USERS).filter(u => u.default_mode === mode);
};

/**
 * Get users by trust tier
 * @param {number} tier - 1-4
 * @returns {Object[]}
 */
export const getUsersByTrustTier = (tier) => {
  return Object.values(MOCK_USERS).filter(u => u.trust_tier === tier);
};

export default MOCK_USERS;
