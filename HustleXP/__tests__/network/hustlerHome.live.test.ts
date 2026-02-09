/**
 * Integration tests for hustlerHome adapter in LIVE mode.
 * Verifies adapter returns error state with stubProps on network failures.
 */

// Mock fetch globally
const mockFetch = jest.fn();
// @ts-expect-error Jest test environment provides global
global.fetch = mockFetch;

// Mock source to return LIVE
jest.mock('../../src/data/source', () => ({
  isLive: () => true,
  isMock: () => false,
  getDataSource: () => 'LIVE',
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

import { getHustlerHomeData } from '../../src/data/adapters/hustlerHome.adapter';

const expectedStubProps = {
  user: { xp: 0, level: 0, trustTier: 0 },
  activeTask: null,
  availableTasksCount: 0,
  recentEarnings: 0,
  weeklyTaskCount: 0,
  currentStreak: 0,
  systemStatus: null,
};

describe('hustlerHome adapter (LIVE mode)', () => {
  beforeEach(() => {
    mockFetch.mockReset();
    mockLogError.mockReset();
  });

  describe('server errors', () => {
    it('returns error state with stubProps on 500', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on server failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      await getHustlerHomeData();

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'SERVER_ERROR',
        expect.any(String),
        expect.objectContaining({
          meta: expect.objectContaining({
            endpoint: '/api/hustler/home',
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

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('missing required field', () => {
    it('returns error state when user is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ activeTask: null }),
      });

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when user is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ user: null }),
      });

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when user.xp is not a number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          user: { xp: 'invalid', level: 1, trustTier: 1 },
        }),
      });

      const result = await getHustlerHomeData();

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

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('network error', () => {
    it('returns error state with stubProps on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      await getHustlerHomeData();

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'NETWORK_ERROR',
        'Failed to fetch',
        expect.any(Object)
      );
    });
  });

  describe('successful response', () => {
    it('returns success state with data on valid response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          user: { xp: 100, level: 2, trustTier: 1 },
          activeTask: null,
          availableTasksCount: 5,
          recentEarnings: 50,
          weeklyTaskCount: 3,
          currentStreak: 2,
          systemStatus: null,
        }),
      });

      const result = await getHustlerHomeData();

      expect(result.state).toBe('success');
      expect(result.props.user.xp).toBe(100);
      expect(result.props.user.level).toBe(2);
      expect(result.props.availableTasksCount).toBe(5);
    });
  });
});
