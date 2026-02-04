/**
 * Adapter invariant tests for taskFeed.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validTaskFeedData } from './_fixtures/validData';

const expectedStubProps = {
  tasks: [],
  hasMore: false,
  filters: {},
  systemStatus: null,
  lastUpdatedAt: '',
};

// Helper to get adapter with specific mock data
function getAdapterWithMock(mockData: unknown) {
  jest.resetModules();
  // Force MOCK mode for tests
  jest.doMock('../../src/data/source', () => ({
    isLive: () => false,
    isMock: () => true,
    getDataSource: () => 'MOCK',
    DATA_SOURCE: 'MOCK',
  }));
  jest.doMock('../../src/data/mocks/taskFeed.mock', () => ({
    taskFeedMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getTaskFeedData } = require('../../src/data/adapters/taskFeed.adapter');
  return getTaskFeedData;
}

describe('getTaskFeedData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success when tasks exist', async () => {
      const getTaskFeedData = getAdapterWithMock(validTaskFeedData);
      const result = await getTaskFeedData();

      expect(result.state).toBe('success');
      expect(result.props.tasks).toHaveLength(1);
      expect(result.props.tasks[0].id).toBe('task-1');
      expect(result.props.lastUpdatedAt).toBe('2025-01-30T12:00:00.000Z');
    });

    it('returns empty state when tasks array is empty', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, tasks: [] });
      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });
  });

  describe('missing required fields', () => {
    it('returns error when lastUpdatedAt is missing', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, lastUpdatedAt: undefined });
      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when lastUpdatedAt is number', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, lastUpdatedAt: 12345 });
      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
    });

    it('returns error when lastUpdatedAt is empty string', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, lastUpdatedAt: '' });
      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
    });

    it('returns error when lastUpdatedAt is null', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, lastUpdatedAt: null });
      const result = await getTaskFeedData();

      expect(result.state).toBe('error');
    });
  });

  describe('graceful degradation', () => {
    it('coerces non-array tasks to empty array (returns empty state)', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, tasks: 'not-array' });
      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });

    it('coerces null tasks to empty array (returns empty state)', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, tasks: null });
      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });

    it('coerces undefined tasks to empty array (returns empty state)', async () => {
      const getTaskFeedData = getAdapterWithMock({ ...validTaskFeedData, tasks: undefined });
      const result = await getTaskFeedData();

      expect(result.state).toBe('empty');
      expect(result.props.tasks).toStrictEqual([]);
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getTaskFeedData = getAdapterWithMock({ lastUpdatedAt: null });
      const result = await getTaskFeedData();

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
