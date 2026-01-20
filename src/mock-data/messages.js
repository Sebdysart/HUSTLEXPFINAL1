/**
 * Mock Message Data
 * SPEC: MOCK_DATA_SPEC.md §8
 * SCHEMA: schema.sql task_messages table
 */

export const MessageType = {
  TEXT: 'TEXT',
  PHOTO: 'PHOTO',
  LOCATION: 'LOCATION',
  AUTO_STATUS: 'AUTO_STATUS',
  SYSTEM: 'SYSTEM',
};

export const MOCK_MESSAGES = {
  'task-accepted': [
    {
      id: 'msg-acc-1',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "Hi! I just accepted your task. I'm on my way now and should be there in about 20 minutes.",
      read_at: '2025-01-15T12:06:00Z',
      created_at: '2025-01-15T12:05:00Z',
    },
    {
      id: 'msg-acc-2',
      task_id: 'task-accepted',
      sender_id: 'user-poster-active',
      message_type: MessageType.TEXT,
      content: "Great! I'll leave the back door unlocked. The kitchen is through the hallway on the left. Cleaning supplies are under the sink.",
      read_at: '2025-01-15T12:08:00Z',
      created_at: '2025-01-15T12:07:00Z',
    },
    {
      id: 'msg-acc-3',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "Perfect, thanks! I'll text when I arrive.",
      read_at: '2025-01-15T12:09:00Z',
      created_at: '2025-01-15T12:08:00Z',
    },
    {
      id: 'msg-acc-4',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: MessageType.AUTO_STATUS,
      content: 'Jordan Rivera is en route to the task location.',
      read_at: '2025-01-15T12:12:00Z',
      created_at: '2025-01-15T12:10:00Z',
    },
    {
      id: 'msg-acc-5',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "I've arrived! Starting the kitchen clean now.",
      read_at: null,
      created_at: '2025-01-15T12:35:00Z',
    },
  ],

  'task-proof-submitted': [
    {
      id: 'msg-proof-1',
      task_id: 'task-proof-submitted',
      sender_id: 'user-hustler-elite',
      message_type: MessageType.TEXT,
      content: "Hi! I'm here and ready to start assembling the bookshelf.",
      read_at: '2025-01-14T10:05:00Z',
      created_at: '2025-01-14T10:02:00Z',
    },
    {
      id: 'msg-proof-2',
      task_id: 'task-proof-submitted',
      sender_id: 'user-poster-active',
      message_type: MessageType.TEXT,
      content: "Great! The box is in the living room. Let me know if you need anything.",
      read_at: '2025-01-14T10:06:00Z',
      created_at: '2025-01-14T10:05:00Z',
    },
    {
      id: 'msg-proof-3',
      task_id: 'task-proof-submitted',
      sender_id: 'user-hustler-elite',
      message_type: MessageType.TEXT,
      content: "All done! I also secured it to the wall for safety. Submitting proof now.",
      read_at: '2025-01-14T12:32:00Z',
      created_at: '2025-01-14T12:28:00Z',
    },
    {
      id: 'msg-proof-4',
      task_id: 'task-proof-submitted',
      sender_id: 'user-hustler-elite',
      message_type: MessageType.SYSTEM,
      content: 'Taylor Washington submitted proof for review.',
      read_at: null,
      created_at: '2025-01-14T12:30:00Z',
    },
  ],

  'task-disputed': [
    {
      id: 'msg-disp-1',
      task_id: 'task-disputed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "Hi! I'm at your place. Max is excited to go!",
      read_at: '2025-01-13T14:05:00Z',
      created_at: '2025-01-13T14:02:00Z',
    },
    {
      id: 'msg-disp-2',
      task_id: 'task-disputed',
      sender_id: 'user-poster-new',
      message_type: MessageType.TEXT,
      content: "Awesome! His leash is by the door. He loves the park at the end of the street.",
      read_at: '2025-01-13T14:06:00Z',
      created_at: '2025-01-13T14:05:00Z',
    },
    {
      id: 'msg-disp-3',
      task_id: 'task-disputed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.PHOTO,
      content: '[Photo of Max at the park]',
      photo_url: 'https://example.com/photos/max-park.jpg',
      read_at: '2025-01-13T14:50:00Z',
      created_at: '2025-01-13T14:45:00Z',
    },
    {
      id: 'msg-disp-4',
      task_id: 'task-disputed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "Just finished walking Max! He was very well-behaved. Back at your place now.",
      read_at: '2025-01-13T15:32:00Z',
      created_at: '2025-01-13T15:25:00Z',
    },
    {
      id: 'msg-disp-5',
      task_id: 'task-disputed',
      sender_id: 'user-poster-new',
      message_type: MessageType.TEXT,
      content: "I'm looking at Max's GPS collar data and it only shows 20 minutes of walking, not an hour. What happened?",
      read_at: '2025-01-13T15:50:00Z',
      created_at: '2025-01-13T15:45:00Z',
    },
    {
      id: 'msg-disp-6',
      task_id: 'task-disputed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "We walked for the full hour. We stopped at the park bench for a while because he was tired. Maybe the GPS didn't track that?",
      read_at: '2025-01-13T15:55:00Z',
      created_at: '2025-01-13T15:52:00Z',
    },
  ],

  'task-completed': [
    {
      id: 'msg-comp-1',
      task_id: 'task-completed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "I've picked up the package and heading downtown now.",
      read_at: '2025-01-14T09:22:00Z',
      created_at: '2025-01-14T09:20:00Z',
    },
    {
      id: 'msg-comp-2',
      task_id: 'task-completed',
      sender_id: 'user-hustler-active',
      message_type: MessageType.TEXT,
      content: "Delivered! The receptionist at the front desk signed for it.",
      read_at: '2025-01-14T10:05:00Z',
      created_at: '2025-01-14T10:00:00Z',
    },
    {
      id: 'msg-comp-3',
      task_id: 'task-completed',
      sender_id: 'user-poster-active',
      message_type: MessageType.TEXT,
      content: "Perfect, thank you! Approving now.",
      read_at: '2025-01-14T10:12:00Z',
      created_at: '2025-01-14T10:10:00Z',
    },
  ],
};

/**
 * Get messages for a task
 * @param {string} taskId
 * @returns {Object[]}
 */
export const getMessagesForTask = (taskId) => {
  return (MOCK_MESSAGES[taskId] || []).sort(
    (a, b) => new Date(a.created_at) - new Date(b.created_at)
  );
};

/**
 * Add a mock message (for testing)
 * @param {string} taskId
 * @param {Object} message
 */
export const addMockMessage = (taskId, message) => {
  if (!MOCK_MESSAGES[taskId]) {
    MOCK_MESSAGES[taskId] = [];
  }
  MOCK_MESSAGES[taskId].push({
    id: `msg-${Date.now()}`,
    task_id: taskId,
    message_type: MessageType.TEXT,
    created_at: new Date().toISOString(),
    read_at: null,
    ...message,
  });
};

/**
 * Get unread message count for a task
 * @param {string} taskId
 * @param {string} userId - User to check unread for
 * @returns {number}
 */
export const getUnreadCountForTask = (taskId, userId) => {
  const messages = MOCK_MESSAGES[taskId] || [];
  return messages.filter(
    m => m.sender_id !== userId && m.read_at === null
  ).length;
};

/**
 * Mark messages as read
 * @param {string} taskId
 * @param {string} userId - User marking as read
 */
export const markMessagesRead = (taskId, userId) => {
  const messages = MOCK_MESSAGES[taskId] || [];
  messages.forEach(m => {
    if (m.sender_id !== userId && m.read_at === null) {
      m.read_at = new Date().toISOString();
    }
  });
};

export default MOCK_MESSAGES;
