/**
 * Integration tests for taskCompletion adapter in LIVE mode.
 * Verifies adapter returns correct state with stubProps on network failures.
 */

import { validTaskCompletionData } from '../adapters/_fixtures/validData';

// Mock fetch globally
const mockFetch = jest.fn();
// @ts-expect-error Jest test environment provides global
global.fetch = mockFetch;

// Mock source to return LIVE
jest.mock('../../src/data/source', () => ({
  isLive: () => true,
  isMock: () => false,
  getDataSource: () => 'LIVE',
  DATA_SOURCE: 'LIVE',
}));

// Mock observability to capture logs
const mockLogError = jest.fn();
jest.mock('../../src/observability/logger', () => ({
  logError: (...args: unknown[]) => mockLogError(...args),
  logInfo: jest.fn(),
  log: jest.fn(),
}));

jest.mock('../../src/observability/screenEvents', () => ({
  logScreenMount: jest.fn(),
  logScreenUnmount: jest.fn(),
  logScreenTransition: jest.fn(),
}));

import { getTaskCompletionData } from '../../src/data/adapters/taskCompletion.adapter';

const expectedStubTask = {
  id: '',
  title: '',
  description: '',
  status: 'completed',
  priceAmount: 0,
  priceCurrency: 'USD',
  estimatedDuration: 0,
  requiredTrustTier: 0,
  location: { address: '', lat: 0, lng: 0 },
  category: '',
  createdAt: '',
  expiresAt: null,
};

const expectedStubProps = {
  task: expectedStubTask,
  submissionStatus: 'pending',
  rejectionReason: null,
  xpAwarded: null,
  earningsAmount: 0,
};

describe('taskCompletion adapter (LIVE mode)', () => {
  beforeEach(() => {
    mockFetch.mockReset();
    mockLogError.mockReset();
  });

  describe('success responses - all submission statuses', () => {
    it('returns success with pending status', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: { status: 'pending', rejectionReason: null },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('pending');
      expect(result.props.rejectionReason).toBeNull();
    });

    it('returns success with submitted status', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: { status: 'submitted', rejectionReason: null },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('submitted');
    });

    it('returns success with approved status', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskCompletionData,
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('approved');
      expect(result.props.earningsAmount).toBe(40);
      expect(result.props.xpAwarded).toBe(25);
    });

    it('returns success with rejected status and reason', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: {
            status: 'rejected',
            rejectionReason: 'Task not completed properly',
          },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('rejected');
      expect(result.props.rejectionReason).toBe('Task not completed properly');
    });

    it('defaults to pending when submission is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          task: validTaskCompletionData.task,
          earnings: validTaskCompletionData.earnings,
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('pending');
    });
  });

  describe('server errors', () => {
    it('returns error state with stubProps on 500', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on server failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      await getTaskCompletionData('task-1');

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'SERVER_ERROR',
        expect.any(String),
        expect.objectContaining({
          meta: expect.objectContaining({
            endpoint: '/api/tasks/:taskId/completion',
            taskId: 'task-1',
            statusCode: 500,
          }),
        })
      );
    });
  });

  describe('invalid JSON', () => {
    it('returns error state with stubProps on invalid JSON', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => {
          throw new SyntaxError('Unexpected token');
        },
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('timeout', () => {
    it('returns error state with stubProps on timeout', async () => {
      mockFetch.mockImplementationOnce(async () => {
        const error = new Error('Aborted');
        error.name = 'AbortError';
        throw error;
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('network error', () => {
    it('returns error state with stubProps on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      await getTaskCompletionData('task-1');

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'NETWORK_ERROR',
        'Failed to fetch',
        expect.any(Object)
      );
    });
  });

  describe('missing required fields', () => {
    it('returns error state when task is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          earnings: validTaskCompletionData.earnings,
          submission: validTaskCompletionData.submission,
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when task is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          task: null,
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when earnings is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          task: validTaskCompletionData.task,
          submission: validTaskCompletionData.submission,
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when earnings.amount is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          earnings: { xpAwarded: 25 },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('invalid enum values', () => {
    it('returns error state when submission.status is invalid', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: { status: 'accepted' },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when submission.status is capitalized', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: { status: 'Approved' },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when submission.status is uppercase', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          submission: { status: 'APPROVED' },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong types', () => {
    it('returns error state when task.id is empty string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          task: { ...validTaskCompletionData.task, id: '' },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when task.id is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          task: { ...validTaskCompletionData.task, id: 123 },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when earnings.amount is string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          earnings: { ...validTaskCompletionData.earnings, amount: '40' },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('xpAwarded nullable handling', () => {
    it('handles null xpAwarded', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          earnings: { amount: 40, xpAwarded: null },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.xpAwarded).toBeNull();
    });

    it('handles undefined xpAwarded', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskCompletionData,
          earnings: { amount: 40 },
        }),
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.xpAwarded).toBeNull();
    });

    it('handles valid xpAwarded number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskCompletionData,
      });

      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.xpAwarded).toBe(25);
    });
  });
});
