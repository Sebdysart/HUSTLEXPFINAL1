/**
 * Data Service Layer
 * SPEC: EXECUTION_QUEUE.md STEP 071, FRONTEND_ARCHITECTURE.md §6
 *
 * Wraps mock data access with async functions that simulate API calls.
 * Easy to swap for real API later by replacing this file.
 */

import {
  // Users
  MOCK_USERS,
  getCurrentUser as getCurrentUserMock,
  getAllUsers as getAllUsersMock,
  getUsersByMode as getUsersByModeMock,
  getUsersByTrustTier as getUsersByTrustTierMock,
  // Tasks
  getTask as getTaskMock,
  getAllTasks as getAllTasksMock,
  getTasksForFeed as getTasksForFeedMock,
  getTasksForUser as getTasksForUserMock,
  getActiveTasksForWorker as getActiveTasksForWorkerMock,
  getTasksByState as getTasksByStateMock,
  // Escrows
  getEscrow as getEscrowMock,
  getEscrowForTask as getEscrowForTaskMock,
  getAllEscrows as getAllEscrowsMock,
  getEscrowsByState as getEscrowsByStateMock,
  // Proofs
  getProof as getProofMock,
  getProofForTask as getProofForTaskMock,
  getAllProofs as getAllProofsMock,
  // XP Ledger
  getXPLedgerForUser as getXPLedgerForUserMock,
  getTotalXPForUser as getTotalXPForUserMock,
  getRecentXPEntries as getRecentXPEntriesMock,
  // Badges
  getBadgesForUser as getBadgesForUserMock,
  getAllBadgeDefinitions as getAllBadgeDefinitionsMock,
  getUnlockedBadgeIds as getUnlockedBadgeIdsMock,
  // Messages
  getMessagesForTask as getMessagesForTaskMock,
  addMockMessage,
  // Notifications
  getNotificationsForUser as getNotificationsForUserMock,
  getUnreadCount as getUnreadCountMock,
  markNotificationRead as markNotificationReadMock,
  // Utilities
  mockDelay,
  mockResponse,
} from '../mock-data/index.js';

// ============================================================================
// USER SERVICE
// ============================================================================

/**
 * Get current user by ID
 * @param {string} userId - User ID
 * @returns {Promise<Object>} User object
 */
export const getUser = async (userId) => {
  await mockDelay(300);
  const user = getCurrentUserMock(userId);
  if (!user) {
    return mockResponse(null, false, 'User not found');
  }
  return mockResponse(user);
};

/**
 * Get all users
 * @returns {Promise<Object>} Array of users
 */
export const getUsers = async () => {
  await mockDelay(200);
  const users = getAllUsersMock();
  return mockResponse(users);
};

/**
 * Get users by mode
 * @param {string} mode - 'worker' | 'poster'
 * @returns {Promise<Object>} Array of users
 */
export const getUsersByMode = async (mode) => {
  await mockDelay(200);
  const users = getUsersByModeMock(mode);
  return mockResponse(users);
};

/**
 * Get users by trust tier
 * @param {number} tier - Trust tier (1-4)
 * @returns {Promise<Object>} Array of users
 */
export const getUsersByTrustTier = async (tier) => {
  await mockDelay(200);
  const users = getUsersByTrustTierMock(tier);
  return mockResponse(users);
};

// ============================================================================
// TASK SERVICE
// ============================================================================

/**
 * Get task by ID
 * @param {string} taskId - Task ID
 * @returns {Promise<Object>} Task object
 */
export const getTask = async (taskId) => {
  await mockDelay(300);
  const task = getTaskMock(taskId);
  if (!task) {
    return mockResponse(null, false, 'Task not found');
  }
  return mockResponse(task);
};

/**
 * Get all tasks
 * @returns {Promise<Object>} Array of tasks
 */
export const getTasks = async () => {
  await mockDelay(400);
  const tasks = getAllTasksMock();
  return mockResponse(tasks);
};

/**
 * Get tasks for feed (OPEN tasks)
 * @param {Object} filters - Filter options
 * @param {string} filters.category - Category filter
 * @param {number} filters.minPrice - Minimum price
 * @param {number} filters.maxPrice - Maximum price
 * @param {string} filters.sortBy - 'newest' | 'highest' | 'closest'
 * @returns {Promise<Object>} Array of tasks
 */
export const getTasksForFeed = async (filters = {}) => {
  await mockDelay(500);
  const tasks = getTasksForFeedMock(filters);
  return mockResponse(tasks);
};

/**
 * Get tasks for a specific user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Array of tasks
 */
export const getTasksForUser = async (userId) => {
  await mockDelay(300);
  const tasks = getTasksForUserMock(userId);
  return mockResponse(tasks);
};

/**
 * Get active tasks for a worker
 * @param {string} workerId - Worker ID
 * @returns {Promise<Object>} Array of tasks
 */
export const getActiveTasksForWorker = async (workerId) => {
  await mockDelay(300);
  const tasks = getActiveTasksForWorkerMock(workerId);
  return mockResponse(tasks);
};

/**
 * Get tasks by state
 * @param {string} state - Task state
 * @returns {Promise<Object>} Array of tasks
 */
export const getTasksByState = async (state) => {
  await mockDelay(300);
  const tasks = getTasksByStateMock(state);
  return mockResponse(tasks);
};

/**
 * Accept a task (mock - updates local state)
 * @param {string} taskId - Task ID
 * @param {string} workerId - Worker ID
 * @returns {Promise<Object>} Updated task
 */
export const acceptTask = async (taskId, workerId) => {
  await mockDelay(600);
  const task = getTaskMock(taskId);
  if (!task) {
    return mockResponse(null, false, 'Task not found');
  }
  // Mock state update - in real API this would be a mutation
  const updatedTask = {
    ...task,
    state: 'ACCEPTED',
    worker_id: workerId,
    accepted_at: new Date().toISOString(),
  };
  return mockResponse(updatedTask);
};

// ============================================================================
// ESCROW SERVICE
// ============================================================================

/**
 * Get escrow by ID
 * @param {string} escrowId - Escrow ID
 * @returns {Promise<Object>} Escrow object
 */
export const getEscrow = async (escrowId) => {
  await mockDelay(300);
  const escrow = getEscrowMock(escrowId);
  if (!escrow) {
    return mockResponse(null, false, 'Escrow not found');
  }
  return mockResponse(escrow);
};

/**
 * Get escrow for a task
 * @param {string} taskId - Task ID
 * @returns {Promise<Object>} Escrow object
 */
export const getEscrowForTask = async (taskId) => {
  await mockDelay(300);
  const escrow = getEscrowForTaskMock(taskId);
  return mockResponse(escrow);
};

/**
 * Get all escrows
 * @returns {Promise<Object>} Array of escrows
 */
export const getEscrows = async () => {
  await mockDelay(300);
  const escrows = getAllEscrowsMock();
  return mockResponse(escrows);
};

/**
 * Get escrows by state
 * @param {string} state - Escrow state
 * @returns {Promise<Object>} Array of escrows
 */
export const getEscrowsByState = async (state) => {
  await mockDelay(300);
  const escrows = getEscrowsByStateMock(state);
  return mockResponse(escrows);
};

// ============================================================================
// PROOF SERVICE
// ============================================================================

/**
 * Get proof by ID
 * @param {string} proofId - Proof ID
 * @returns {Promise<Object>} Proof object
 */
export const getProof = async (proofId) => {
  await mockDelay(300);
  const proof = getProofMock(proofId);
  if (!proof) {
    return mockResponse(null, false, 'Proof not found');
  }
  return mockResponse(proof);
};

/**
 * Get proof for a task
 * @param {string} taskId - Task ID
 * @returns {Promise<Object>} Proof object
 */
export const getProofForTask = async (taskId) => {
  await mockDelay(300);
  const proof = getProofForTaskMock(taskId);
  return mockResponse(proof);
};

/**
 * Get all proofs
 * @returns {Promise<Object>} Array of proofs
 */
export const getProofs = async () => {
  await mockDelay(300);
  const proofs = getAllProofsMock();
  return mockResponse(proofs);
};

/**
 * Submit proof (mock - creates proof)
 * @param {string} taskId - Task ID
 * @param {Object} proofData - Proof data
 * @param {string} proofData.description - Proof description
 * @param {Array<string>} proofData.photo_urls - Array of photo URLs
 * @returns {Promise<Object>} Created proof
 */
export const submitProof = async (taskId, proofData) => {
  await mockDelay(800);
  // Mock proof creation
  const proof = {
    id: `proof-${Date.now()}`,
    task_id: taskId,
    state: 'PENDING',
    description: proofData.description || '',
    photo_urls: proofData.photo_urls || [],
    submitted_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
  return mockResponse(proof);
};

// ============================================================================
// XP LEDGER SERVICE
// ============================================================================

/**
 * Get XP ledger for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Array of XP entries
 */
export const getXPLedgerForUser = async (userId) => {
  await mockDelay(300);
  const ledger = getXPLedgerForUserMock(userId);
  return mockResponse(ledger);
};

/**
 * Get total XP for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Total XP number
 */
export const getTotalXPForUser = async (userId) => {
  await mockDelay(200);
  const total = getTotalXPForUserMock(userId);
  return mockResponse(total);
};

/**
 * Get recent XP entries for user
 * @param {string} userId - User ID
 * @param {number} limit - Number of entries to return
 * @returns {Promise<Object>} Array of XP entries
 */
export const getRecentXPEntries = async (userId, limit = 10) => {
  await mockDelay(300);
  const entries = getRecentXPEntriesMock(userId, limit);
  return mockResponse(entries);
};

// ============================================================================
// BADGE SERVICE
// ============================================================================

/**
 * Get badges for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Array of badges
 */
export const getBadgesForUser = async (userId) => {
  await mockDelay(300);
  const badges = getBadgesForUserMock(userId);
  return mockResponse(badges);
};

/**
 * Get all badge definitions
 * @returns {Promise<Object>} Array of badge definitions
 */
export const getAllBadgeDefinitions = async () => {
  await mockDelay(200);
  const badges = getAllBadgeDefinitionsMock();
  return mockResponse(badges);
};

/**
 * Get unlocked badge IDs for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Array of badge IDs
 */
export const getUnlockedBadgeIds = async (userId) => {
  await mockDelay(200);
  const badgeIds = getUnlockedBadgeIdsMock(userId);
  return mockResponse(badgeIds);
};

// ============================================================================
// MESSAGE SERVICE
// ============================================================================

/**
 * Get messages for task
 * @param {string} taskId - Task ID
 * @returns {Promise<Object>} Array of messages
 */
export const getMessagesForTask = async (taskId) => {
  await mockDelay(300);
  const messages = getMessagesForTaskMock(taskId);
  return mockResponse(messages);
};

/**
 * Send message (mock - adds message)
 * @param {string} taskId - Task ID
 * @param {string} userId - User ID
 * @param {string} content - Message content
 * @returns {Promise<Object>} Created message
 */
export const sendMessage = async (taskId, userId, content) => {
  await mockDelay(400);
  const message = addMockMessage(taskId, userId, content);
  return mockResponse(message);
};

// ============================================================================
// NOTIFICATION SERVICE
// ============================================================================

/**
 * Get notifications for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Array of notifications
 */
export const getNotificationsForUser = async (userId) => {
  await mockDelay(300);
  const notifications = getNotificationsForUserMock(userId);
  return mockResponse(notifications);
};

/**
 * Get unread notification count
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Unread count number
 */
export const getUnreadCount = async (userId) => {
  await mockDelay(200);
  const count = getUnreadCountMock(userId);
  return mockResponse(count);
};

/**
 * Mark notification as read
 * @param {string} notificationId - Notification ID
 * @returns {Promise<Object>} Success response
 */
export const markNotificationRead = async (notificationId) => {
  await mockDelay(300);
  markNotificationReadMock(notificationId);
  return mockResponse({ success: true });
};

// ============================================================================
// AUTH SERVICE (Mock)
// ============================================================================

/**
 * Login user (mock)
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise<Object>} User object if successful
 */
export const login = async (email, password) => {
  await mockDelay(800);
  // Mock login - find user by email
  const user = Object.values(MOCK_USERS).find((u) => u.email === email);
  if (!user || password !== 'password123') {
    return mockResponse(null, false, 'Invalid email or password');
  }
  return mockResponse(user);
};

/**
 * Signup user (mock)
 * @param {Object} userData - User data
 * @returns {Promise<Object>} Created user object
 */
export const signup = async (userData) => {
  await mockDelay(1000);
  // Mock signup - create new user
  const newUser = {
    id: `user-${Date.now()}`,
    email: userData.email,
    phone: userData.phone || null,
    full_name: userData.fullName || '',
    avatar_url: null,
    default_mode: userData.defaultMode || 'worker',
    onboarding_completed_at: null,
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    last_task_completed_at: null,
    is_verified: false,
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
  return mockResponse(newUser);
};

/**
 * Request password reset (mock)
 * @param {string} email - User email
 * @returns {Promise<Object>} Success response
 */
export const requestPasswordReset = async (email) => {
  await mockDelay(600);
  // Mock - always succeeds
  return mockResponse({ success: true, message: 'Password reset email sent' });
};

/**
 * Verify phone number (mock)
 * @param {string} phone - Phone number
 * @param {string} code - Verification code
 * @returns {Promise<Object>} Success response
 */
export const verifyPhone = async (phone, code) => {
  await mockDelay(600);
  // Mock - accept any code
  if (code === '123456') {
    return mockResponse({ success: true, verified: true });
  }
  return mockResponse(null, false, 'Invalid verification code');
};
