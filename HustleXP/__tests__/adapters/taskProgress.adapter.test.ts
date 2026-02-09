/**
 * Adapter invariant tests for taskProgress.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validTaskProgressData } from './_fixtures/validData';

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
  jest.doMock('../../src/data/mocks/taskProgress.mock', () => ({
    taskProgressMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getTaskProgressData } = require('../../src/data/adapters/taskProgress.adapter');
  return getTaskProgressData;
}

describe('getTaskProgressData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success with WORKING state', async () => {
      const getTaskProgressData = getAdapterWithMock(validTaskProgressData);
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.taskState).toBe('WORKING');
      expect(result.props.task.id).toBe('task-1');
    });

    it('returns success with EN_ROUTE state', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, state: 'EN_ROUTE' });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.taskState).toBe('EN_ROUTE');
    });
  });

  describe('missing required fields', () => {
    it('returns error when task is missing', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, task: undefined });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error when task is null', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, task: null });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when destination is missing', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, destination: undefined });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when destination is null', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, destination: null });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('invalid enum values', () => {
    it('returns error when state is invalid enum', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, state: 'PAUSED' });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when state is lowercase working', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, state: 'working' });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when state is lowercase en_route', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, state: 'en_route' });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when state is empty string', async () => {
      const getTaskProgressData = getAdapterWithMock({ ...validTaskProgressData, state: '' });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when task.id is empty string', async () => {
      const getTaskProgressData = getAdapterWithMock({
        ...validTaskProgressData,
        task: { ...validTaskProgressData.task, id: '' },
      });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when task.id is number', async () => {
      const getTaskProgressData = getAdapterWithMock({
        ...validTaskProgressData,
        task: { ...validTaskProgressData.task, id: 123 },
      });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when destination.address is number', async () => {
      const getTaskProgressData = getAdapterWithMock({
        ...validTaskProgressData,
        destination: { ...validTaskProgressData.destination, address: 123 },
      });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('null where forbidden', () => {
    it('returns error when task.id is null', async () => {
      const getTaskProgressData = getAdapterWithMock({
        ...validTaskProgressData,
        task: { ...validTaskProgressData.task, id: null },
      });
      const result = await getTaskProgressData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getTaskProgressData = getAdapterWithMock({ task: null, destination: null, state: 'INVALID' });
      const result = await getTaskProgressData('task-1');

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
