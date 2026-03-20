/**
 * Mock for GET /api/tasks/:id/completion — BACKEND_CONTRACT.md B2.
 * Single object matching endpoint exactly.
 */

import type { Task } from '../types';

const sampleTask: Task = {
  id: 'task-1',
  title: 'Help move couch',
  description: 'Move a couch from living room to second floor.',
  status: 'completed',
  priceAmount: 40,
  priceCurrency: 'USD',
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

export const taskCompletionMock = {
  task: sampleTask,
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
