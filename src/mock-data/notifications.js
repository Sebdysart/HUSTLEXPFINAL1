/**
 * Mock Notification Data
 * SPEC: MOCK_DATA_SPEC.md §9
 * SCHEMA: schema.sql notifications table
 */

export const NotificationType = {
  // Task lifecycle
  TASK_CREATED: 'TASK_CREATED',
  TASK_ACCEPTED: 'TASK_ACCEPTED',
  TASK_WORKER_ASSIGNED: 'TASK_WORKER_ASSIGNED',
  TASK_CANCELLED: 'TASK_CANCELLED',
  TASK_EXPIRED: 'TASK_EXPIRED',

  // Proof lifecycle
  PROOF_SUBMITTED: 'PROOF_SUBMITTED',
  PROOF_ACCEPTED: 'PROOF_ACCEPTED',
  PROOF_REJECTED: 'PROOF_REJECTED',

  // Dispute
  DISPUTE_OPENED: 'DISPUTE_OPENED',
  DISPUTE_RESOLVED: 'DISPUTE_RESOLVED',

  // XP & Badges
  XP_EARNED: 'XP_EARNED',
  LEVEL_UP: 'LEVEL_UP',
  BADGE_EARNED: 'BADGE_EARNED',

  // Escrow
  ESCROW_FUNDED: 'ESCROW_FUNDED',
  ESCROW_RELEASED: 'ESCROW_RELEASED',
  ESCROW_REFUNDED: 'ESCROW_REFUNDED',

  // Trust
  TRUST_TIER_UP: 'TRUST_TIER_UP',
  TRUST_TIER_DOWN: 'TRUST_TIER_DOWN',

  // Live Mode
  LIVE_TASK_MATCH: 'LIVE_TASK_MATCH',

  // Messages
  NEW_MESSAGE: 'NEW_MESSAGE',

  // System
  SYSTEM_ANNOUNCEMENT: 'SYSTEM_ANNOUNCEMENT',
};

export const NotificationPriority = {
  HIGH: 'HIGH',
  NORMAL: 'NORMAL',
  LOW: 'LOW',
};

export const MOCK_NOTIFICATIONS = {
  'user-hustler-new': [
    {
      id: 'notif-new-1',
      user_id: 'user-hustler-new',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      title: 'Welcome to HustleXP!',
      body: 'Complete your first task to start earning XP and unlock badges.',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-15T10:00:00Z',
    },
  ],

  'user-hustler-active': [
    {
      id: 'notif-active-1',
      user_id: 'user-hustler-active',
      type: NotificationType.TASK_ACCEPTED,
      title: 'Task Accepted!',
      body: 'You accepted "Deep clean kitchen". Head to the location to get started.',
      task_id: 'task-accepted',
      priority: NotificationPriority.HIGH,
      read: false,
      created_at: '2025-01-15T12:00:00Z',
    },
    {
      id: 'notif-active-2',
      user_id: 'user-hustler-active',
      type: NotificationType.XP_EARNED,
      title: '+58 XP',
      body: 'You earned XP for completing "Package delivery to downtown"',
      task_id: 'task-completed',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-14T10:15:00Z',
    },
    {
      id: 'notif-active-3',
      user_id: 'user-hustler-active',
      type: NotificationType.ESCROW_RELEASED,
      title: 'Payment Released',
      body: '$12.75 has been released to your account for "Package delivery to downtown"',
      task_id: 'task-completed',
      priority: NotificationPriority.HIGH,
      read: true,
      created_at: '2025-01-14T10:15:00Z',
    },
    {
      id: 'notif-active-4',
      user_id: 'user-hustler-active',
      type: NotificationType.DISPUTE_OPENED,
      title: 'Dispute Opened',
      body: 'The poster has disputed your proof for "Dog walking (1 hour)"',
      task_id: 'task-disputed',
      priority: NotificationPriority.HIGH,
      read: true,
      created_at: '2025-01-13T16:00:00Z',
    },
    {
      id: 'notif-active-5',
      user_id: 'user-hustler-active',
      type: NotificationType.BADGE_EARNED,
      title: 'Badge Earned!',
      body: "You earned the 'Dedicated' badge for completing 10 tasks",
      badge_id: 'tasks-10',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-10T12:00:00Z',
    },
    {
      id: 'notif-active-6',
      user_id: 'user-hustler-active',
      type: NotificationType.LEVEL_UP,
      title: 'Level Up!',
      body: 'Congratulations! You reached Level 3',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-13T14:00:00Z',
    },
  ],

  'user-hustler-elite': [
    {
      id: 'notif-elite-1',
      user_id: 'user-hustler-elite',
      type: NotificationType.XP_EARNED,
      title: '+120 XP',
      body: 'You earned XP for completing a task. Streak bonus: 60%!',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-15T09:00:00Z',
    },
    {
      id: 'notif-elite-2',
      user_id: 'user-hustler-elite',
      type: NotificationType.LIVE_TASK_MATCH,
      title: 'Live Task Available!',
      body: '"Urgent: Flat tire help needed" - $35.00, 0.8 miles away',
      task_id: 'task-open-live',
      priority: NotificationPriority.HIGH,
      read: false,
      created_at: '2025-01-15T14:30:00Z',
    },
  ],

  'user-poster-new': [
    {
      id: 'notif-pnew-1',
      user_id: 'user-poster-new',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      title: 'Welcome to HustleXP!',
      body: 'Post your first task to get help with anything you need.',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-10T10:00:00Z',
    },
    {
      id: 'notif-pnew-2',
      user_id: 'user-poster-new',
      type: NotificationType.PROOF_SUBMITTED,
      title: 'Proof Submitted',
      body: 'Jordan Rivera submitted proof for "Dog walking (1 hour)". Review it now.',
      task_id: 'task-disputed',
      priority: NotificationPriority.HIGH,
      read: true,
      created_at: '2025-01-13T15:30:00Z',
    },
  ],

  'user-poster-active': [
    {
      id: 'notif-pact-1',
      user_id: 'user-poster-active',
      type: NotificationType.TASK_WORKER_ASSIGNED,
      title: 'Worker Found',
      body: 'Jordan Rivera accepted your task "Deep clean kitchen"',
      task_id: 'task-accepted',
      priority: NotificationPriority.HIGH,
      read: false,
      created_at: '2025-01-15T12:00:00Z',
    },
    {
      id: 'notif-pact-2',
      user_id: 'user-poster-active',
      type: NotificationType.PROOF_SUBMITTED,
      title: 'Proof Submitted',
      body: 'Taylor Washington submitted proof for "Assemble IKEA bookshelf". Review it now.',
      task_id: 'task-proof-submitted',
      priority: NotificationPriority.HIGH,
      read: false,
      created_at: '2025-01-14T12:30:00Z',
    },
    {
      id: 'notif-pact-3',
      user_id: 'user-poster-active',
      type: NotificationType.PROOF_ACCEPTED,
      title: 'Task Completed',
      body: 'You approved the proof for "Package delivery to downtown". Payment released.',
      task_id: 'task-completed',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2025-01-14T10:15:00Z',
    },
    {
      id: 'notif-pact-4',
      user_id: 'user-poster-active',
      type: NotificationType.NEW_MESSAGE,
      title: 'New Message',
      body: 'Jordan Rivera: "I\'ve arrived! Starting the kitchen clean now."',
      task_id: 'task-accepted',
      priority: NotificationPriority.NORMAL,
      read: false,
      created_at: '2025-01-15T12:35:00Z',
    },
  ],

  'user-both': [
    {
      id: 'notif-both-1',
      user_id: 'user-both',
      type: NotificationType.TRUST_TIER_UP,
      title: 'Trust Tier Increased!',
      body: 'You reached Trust Tier 2. You can now access more task types.',
      priority: NotificationPriority.NORMAL,
      read: true,
      created_at: '2024-11-15T14:00:00Z',
    },
  ],
};

/**
 * Get notifications for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getNotificationsForUser = (userId) => {
  return (MOCK_NOTIFICATIONS[userId] || []).sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );
};

/**
 * Get unread notification count
 * @param {string} userId
 * @returns {number}
 */
export const getUnreadCount = (userId) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  return notifications.filter(n => !n.read).length;
};

/**
 * Mark notification as read
 * @param {string} userId
 * @param {string} notificationId
 */
export const markNotificationRead = (userId, notificationId) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  const notification = notifications.find(n => n.id === notificationId);
  if (notification) {
    notification.read = true;
  }
};

/**
 * Mark all notifications as read
 * @param {string} userId
 */
export const markAllNotificationsRead = (userId) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  notifications.forEach(n => {
    n.read = true;
  });
};

/**
 * Get notifications by type
 * @param {string} userId
 * @param {string} type
 * @returns {Object[]}
 */
export const getNotificationsByType = (userId, type) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  return notifications.filter(n => n.type === type);
};

/**
 * Get high priority notifications
 * @param {string} userId
 * @returns {Object[]}
 */
export const getHighPriorityNotifications = (userId) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  return notifications.filter(n => n.priority === NotificationPriority.HIGH && !n.read);
};

export default MOCK_NOTIFICATIONS;
