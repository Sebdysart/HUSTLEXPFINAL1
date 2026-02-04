/**
 * Adapter invariant tests for taskDetail.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validTaskDetailData } from './_fixtures/validData';

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
  jest.doMock('../../src/data/mocks/taskDetail.mock', () => ({
    taskDetailMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getTaskDetailData } = require('../../src/data/adapters/taskDetail.adapter');
  return getTaskDetailData;
}

describe('getTaskDetailData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success with eligible status', async () => {
      const getTaskDetailData = getAdapterWithMock(validTaskDetailData);
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.task.id).toBe('task-1');
      expect(result.props.task.title).toBe('Help move couch');
      expect(result.props.poster.name).toBe('Alex P.');
    });

    it('returns blocked state when ineligible', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        eligibility: { status: 'ineligible', reason: 'Low trust tier' },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('blocked');
      expect(result.props.eligibilityReason).toBe('Low trust tier');
    });
  });

  describe('missing required fields', () => {
    it('returns error when task is missing', async () => {
      const getTaskDetailData = getAdapterWithMock({ ...validTaskDetailData, task: undefined });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error when task is null', async () => {
      const getTaskDetailData = getAdapterWithMock({ ...validTaskDetailData, task: null });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when poster is missing', async () => {
      const getTaskDetailData = getAdapterWithMock({ ...validTaskDetailData, poster: undefined });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when poster is null', async () => {
      const getTaskDetailData = getAdapterWithMock({ ...validTaskDetailData, poster: null });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when task.id is number', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        task: { ...validTaskDetailData.task, id: 123 },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when task.id is empty string', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        task: { ...validTaskDetailData.task, id: '' },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when task.title is number', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        task: { ...validTaskDetailData.task, title: 123 },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when poster.name is number', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        poster: { ...validTaskDetailData.poster, name: 123 },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('null where forbidden', () => {
    it('returns error when task.id is null', async () => {
      const getTaskDetailData = getAdapterWithMock({
        ...validTaskDetailData,
        task: { ...validTaskDetailData.task, id: null },
      });
      const result = await getTaskDetailData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getTaskDetailData = getAdapterWithMock({ task: null, poster: null });
      const result = await getTaskDetailData('task-1');

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
