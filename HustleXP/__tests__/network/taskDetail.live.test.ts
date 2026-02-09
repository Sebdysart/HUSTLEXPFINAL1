/**
 * Integration tests for taskDetail adapter in LIVE mode.
 * Verifies adapter returns correct state with stubProps on network failures.
 */

import { validTaskDetailData, validTask } from '../adapters/_fixtures/validData';

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

import { getTaskDetailData } from '../../src/data/adapters/taskDetail.adapter';

const expectedStubTask = {
  id: '',
  title: '',
  description: '',
  status: 'open',
  priceAmount: 0,
  priceCurrency: 'USD',
  estimatedDuration: 0,
  requiredTrustTier: 0,
  location: { address: '', lat: 0, lng: 0 },
  category: '',
  createdAt: '',
  expiresAt: null,
};

const expectedStubPoster = { name: '', rating: 0, taskCount: 0 };

const expectedStubProps = {
  task: expectedStubTask,
  eligibilityStatus: 'checking',
  eligibilityReason: null,
  poster: expectedStubPoster,
};

describe('taskDetail adapter (LIVE mode)', () => {
  beforeEach(() => {
    mockFetch.mockReset();
    mockLogError.mockReset();
  });

  describe('success responses', () => {
    it('returns success state when eligible', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskDetailData,
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.task.id).toBe('task-1');
      expect(result.props.task.title).toBe('Help move couch');
      expect(result.props.poster.name).toBe('Alex P.');
    });

    it('returns blocked state when ineligible', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          eligibility: {
            status: 'ineligible',
            reason: 'Trust tier too low',
          },
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('blocked');
      expect(result.props.eligibilityStatus).toBe('ineligible');
      expect(result.props.eligibilityReason).toBe('Trust tier too low');
    });
  });

  describe('server errors', () => {
    it('returns error state with stubProps on 500', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on server failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      await getTaskDetailData('task-1');

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'SERVER_ERROR',
        expect.any(String),
        expect.objectContaining({
          meta: expect.objectContaining({
            endpoint: '/api/tasks/:taskId',
            taskId: 'task-1',
            statusCode: 500,
          }),
        })
      );
    });

    it('returns error state on 403 forbidden', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 403,
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
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

      const result = await getTaskDetailData('task-1');

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

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('network error', () => {
    it('returns error state with stubProps on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      await getTaskDetailData('task-1');

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
          poster: validTaskDetailData.poster,
          eligibility: validTaskDetailData.eligibility,
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when task is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          task: null,
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when poster is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          task: validTask,
          eligibility: validTaskDetailData.eligibility,
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when poster is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          poster: null,
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong types', () => {
    it('returns error state when task.id is empty string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          task: { ...validTask, id: '' },
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when task.id is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          task: { ...validTask, id: 123 },
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when task.title is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          task: { ...validTask, title: 123 },
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when poster.name is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskDetailData,
          poster: { ...validTaskDetailData.poster, name: 123 },
        }),
      });

      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });
  });
});
