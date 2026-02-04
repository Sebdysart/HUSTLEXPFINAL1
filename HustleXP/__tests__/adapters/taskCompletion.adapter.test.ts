/**
 * Adapter invariant tests for taskCompletion.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validTaskCompletionData } from './_fixtures/validData';

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
  jest.doMock('../../src/data/mocks/taskCompletion.mock', () => ({
    taskCompletionMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getTaskCompletionData } = require('../../src/data/adapters/taskCompletion.adapter');
  return getTaskCompletionData;
}

describe('getTaskCompletionData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success with correct earnings', async () => {
      const getTaskCompletionData = getAdapterWithMock(validTaskCompletionData);
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.earningsAmount).toBe(40);
      expect(result.props.xpAwarded).toBe(25);
      expect(result.props.submissionStatus).toBe('approved');
    });

    it('returns success with all valid submission statuses', async () => {
      const validStatuses = ['pending', 'submitted', 'approved', 'rejected'] as const;

      for (const status of validStatuses) {
        const getTaskCompletionData = getAdapterWithMock({
          ...validTaskCompletionData,
          submission: { status, rejectionReason: null },
        });
        const result = await getTaskCompletionData('task-1');

        expect(result.state).toBe('success');
        expect(result.props.submissionStatus).toBe(status);
      }
    });
  });

  describe('missing required fields', () => {
    it('returns error when task is missing', async () => {
      const getTaskCompletionData = getAdapterWithMock({ ...validTaskCompletionData, task: undefined });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error when task is null', async () => {
      const getTaskCompletionData = getAdapterWithMock({ ...validTaskCompletionData, task: null });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when earnings is missing', async () => {
      const getTaskCompletionData = getAdapterWithMock({ ...validTaskCompletionData, earnings: undefined });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('invalid enum values', () => {
    it('returns error when submission.status is invalid', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        submission: { status: 'accepted' },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when submission.status is capitalized', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        submission: { status: 'Approved' },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when submission.status is uppercase', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        submission: { status: 'APPROVED' },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when task.id is empty string', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        task: { ...validTaskCompletionData.task, id: '' },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when task.id is number', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        task: { ...validTaskCompletionData.task, id: 123 },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when earnings.amount is string', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        earnings: { ...validTaskCompletionData.earnings, amount: '40' },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('default status', () => {
    it('defaults to pending when submission is missing', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        submission: undefined,
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('pending');
    });

    it('defaults to pending when submission is null', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        submission: null,
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('success');
      expect(result.props.submissionStatus).toBe('pending');
    });
  });

  describe('null where forbidden', () => {
    it('returns error when task.id is null', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        task: { ...validTaskCompletionData.task, id: null },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });

    it('returns error when earnings.amount is null', async () => {
      const getTaskCompletionData = getAdapterWithMock({
        ...validTaskCompletionData,
        earnings: { ...validTaskCompletionData.earnings, amount: null },
      });
      const result = await getTaskCompletionData('task-1');

      expect(result.state).toBe('error');
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getTaskCompletionData = getAdapterWithMock({ task: null, earnings: undefined });
      const result = await getTaskCompletionData('task-1');

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
