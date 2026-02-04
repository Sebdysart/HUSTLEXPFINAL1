/**
 * Integration tests for taskProgress adapter in LIVE mode.
 * Verifies adapter returns correct state with stubProps on network failures.
 */

import { validTaskProgressData } from '../adapters/_fixtures/validData';

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

import { getTaskProgressData } from '../../src/data/adapters/taskProgress.adapter';

const expectedStubTask = {
  id: '',
  title: '',
  description: '',
  status: 'in_progress',
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
  taskState: 'WORKING',
  elapsedTime: 0,
  destination: { lat: 0, lng: 0, address: '' },
};

describe('taskProgress adapter (LIVE mode)', () => {
  beforeEach(() => {
    mockFetch.mockReset();
    mockLogError.mockReset();
  });

  describe('success responses', () => {
    it('returns success state with WORKING state', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskProgressData,
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.taskState).toBe('WORKING');
      expect(result.props.task.id).toBe('task-1');
      expect(result.props.elapsedTime).toBe(420);
    });

    it('returns success state with EN_ROUTE state', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          state: 'EN_ROUTE',
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.taskState).toBe('EN_ROUTE');
    });

    it('returns success with valid destination', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => validTaskProgressData,
      });

      const result = await getTaskProgressData('task-1');

      expect(result.props.destination.address).toBe('123 Main St');
      expect(result.props.destination.lat).toBe(37.7749);
      expect(result.props.destination.lng).toBe(-122.4194);
    });
  });

  describe('server errors', () => {
    it('returns error state with stubProps on 500', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on server failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      await getTaskProgressData('task-1');

      expect(mockLogError).toHaveBeenCalledWith(
        'network',
        'SERVER_ERROR',
        expect.any(String),
        expect.objectContaining({
          meta: expect.objectContaining({
            endpoint: '/api/tasks/:taskId/progress',
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

      const result = await getTaskProgressData('task-1');

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

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('network error', () => {
    it('returns error state with stubProps on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('logs error on network failure', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      await getTaskProgressData('task-1');

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
          state: 'WORKING',
          elapsedTime: 420,
          destination: validTaskProgressData.destination,
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error state when task is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          task: null,
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when destination is missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          task: validTaskProgressData.task,
          state: 'WORKING',
          elapsedTime: 420,
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when destination is null', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          destination: null,
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('invalid enum values', () => {
    it('returns error state when state is PAUSED (invalid)', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          state: 'PAUSED',
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when state is lowercase working', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          state: 'working',
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when state is empty string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          state: '',
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong types', () => {
    it('returns error state when task.id is empty string', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          task: { ...validTaskProgressData.task, id: '' },
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when task.id is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          task: { ...validTaskProgressData.task, id: 123 },
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error state when destination.address is number', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          destination: { ...validTaskProgressData.destination, address: 123 },
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('elapsedTime handling', () => {
    it('defaults elapsedTime to 0 when missing', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          ...validTaskProgressData,
          elapsedTime: undefined,
        }),
      });

      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.elapsedTime).toBe(0);
    });
  });
});
