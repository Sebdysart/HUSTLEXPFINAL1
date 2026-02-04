/**
 * Valid test data fixtures for adapter invariant tests.
 * Matches mock shapes exactly.
 */

export const validTask = {
  id: 'task-1',
  title: 'Help move couch',
  description: 'Move a couch from living room to second floor.',
  status: 'open' as const,
  priceAmount: 40,
  priceCurrency: 'USD' as const,
  estimatedDuration: 25,
  requiredTrustTier: 1,
  location: {
    address: '123 Main St',
    lat: 37.7749,
    lng: -122.4194,
    distance: 0.4,
  },
  category: 'moving',
  createdAt: '2025-01-30T10:00:00.000Z',
  expiresAt: '2025-01-30T18:00:00.000Z',
};

export const validHustlerHomeData = {
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

export const validTaskFeedData = {
  tasks: [validTask],
  hasMore: true,
  cursor: 'cursor-abc',
  lastUpdatedAt: '2025-01-30T12:00:00.000Z',
  systemStatus: null,
};

export const validTaskDetailData = {
  task: validTask,
  eligibility: {
    status: 'eligible' as const,
    reason: null,
    missingRequirements: [] as string[],
  },
  poster: {
    name: 'Alex P.',
    rating: 4.8,
    taskCount: 24,
  },
};

export const validTaskProgressData = {
  task: { ...validTask, status: 'in_progress' as const },
  state: 'WORKING' as const,
  elapsedTime: 420,
  destination: {
    lat: 37.7749,
    lng: -122.4194,
    address: '123 Main St',
  },
};

export const validTaskCompletionData = {
  task: { ...validTask, status: 'completed' as const },
  submission: {
    status: 'approved' as const,
    rejectionReason: null,
    submittedAt: '2025-01-30T14:30:00.000Z',
  },
  earnings: {
    amount: 40,
    xpAwarded: 25,
  },
};

export const validXPData = {
  totalXP: 1200,
  level: 4,
  xpToNextLevel: 300,
  xpProgress: 0.4,
  history: [
    {
      id: 'xp-1',
      amount: 25,
      source: 'Task completion',
      earnedAt: '2025-01-30T14:30:00.000Z',
      taskTitle: 'Help move couch',
    },
  ],
  breakdown: [{ source: 'Task completion', amount: 1200 }],
};
