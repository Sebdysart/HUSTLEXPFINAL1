/**
 * Integration tests for taskFeed adapter in LIVE mode.
 * Verifies adapter returns correct state with stubProps on network failures.
 */

import { validTaskFeedData, validTask } from '../adapters/_fixtures/validData';

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

import { getTaskFeedData } from '../../src/data/adapters/taskFeed.adapter';

const expectedStubProps = {
  tasks: [],
  hasMore: false,
  filters: {},
  systemStatus: null,
  lastUpdatedAt: '',
};

describe('taskFeed adapter (LIVE mode)', () => {
  beforeEach(() => {
    mockFetch.mockReset();
    mockLogError.mockReset();
  });

  describe('success responses', () => {
    it('returns success state with tasks', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskFeedData,
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('success');
      expect(result.props.tasks).toHaveLength(1);
      expect(result.props.tasks[0].id).toBe('task-1');
      expect(result.props.lastUpdatedAt).toBe('2025-01-30T12:00:00.000Z');
    });

    it('returns empty state when tasks array is empty', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskFeedData,
          tasks: [],
        }),
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });
  });

  describe('server errors', () => {
    it('returns error state with stubProps on 500', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on server failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      await getTaskFeedData();

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'SERVER_ERROR',
        expect.any(String),
        expect.objectContaining({
          meta: expect.objectContaining({
            endpoint: '/api/tasks',
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

      const result = await getTaskFeedData();

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

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('network error', () => {
    it('returns error state with stubProps on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      await getTaskFeedData();

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'NETWORK_ERROR',
        'Failed to fetch',
        expect.any(Object)
      );
    });
  });

  describe('missing required fields', () => {
    it('returns error state when lastUpdatedAt is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          tasks: [validTask],
          hasMore: false,
        }),
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when lastUpdatedAt is empty string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskFeedData,
          lastUpdatedAt: '',
        }),
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('wrong types', () => {
    it('coerces non-array tasks to empty array', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskFeedData,
          tasks: 'invalid',
        }),
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });

    it('returns error when lastUpdatedAt is not a string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskFeedData,
          lastUpdatedAt: 12345,
        }),
      });

      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
    });
  });
});
