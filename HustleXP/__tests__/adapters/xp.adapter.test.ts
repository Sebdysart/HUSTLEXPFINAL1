/**
 * Adapter invariant tests for xp.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validXPData } from './_fixtures/validData';

const expectedStubProps = {
  totalXP: 0,
  level: 0,
  xpToNextLevel: 0,
  xpProgress: 0,
  history: [],
  breakdown: [],
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
  jest.doMock('../../src/data/mocks/xp.mock', () => ({
    xpMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getXPData } = require('../../src/data/adapters/xp.adapter');
  return getXPData;
}

describe('getXPData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success with XP data', async () => {
      const getXPData = getAdapterWithMock(validXPData);
      const result = await getXPData();

      expect(result.state).toBe('success');
      expect(result.props.totalXP).toBe(1200);
      expect(result.props.level).toBe(4);
      expect(result.props.xpToNextLevel).toBe(300);
      expect(result.props.xpProgress).toBe(0.4);
      expect(result.props.history).toHaveLength(1);
    });

    it('returns empty when history and breakdown are empty', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, history: [], breakdown: [] });
      const result = await getXPData();

      expect(result.state).toBe('empty');
      expect(result.props.history).toStrictEqual([]);
      expect(result.props.breakdown).toStrictEqual([]);
    });

    it('returns success when only history has data', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, breakdown: [] });
      const result = await getXPData();

      expect(result.state).toBe('success');
    });

    it('returns success when only breakdown has data', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, history: [] });
      const result = await getXPData();

      expect(result.state).toBe('success');
    });
  });

  describe('missing required fields', () => {
    it('returns error when totalXP is missing', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, totalXP: undefined });
      const result = await getXPData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error when level is missing', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, level: undefined });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when xpToNextLevel is missing', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, xpToNextLevel: undefined });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when totalXP is string', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, totalXP: '1200' });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when level is string', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, level: '4' });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when xpToNextLevel is string', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, xpToNextLevel: '300' });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when totalXP is boolean', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, totalXP: true });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });
  });

  describe('null where forbidden', () => {
    it('returns error when totalXP is null', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, totalXP: null });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when level is null', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, level: null });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });

    it('returns error when xpToNextLevel is null', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, xpToNextLevel: null });
      const result = await getXPData();

      expect(result.state).toBe('error');
    });
  });

  describe('graceful degradation', () => {
    it('coerces non-array history to empty array', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, history: 'invalid', breakdown: validXPData.breakdown });
      const result = await getXPData();

      expect(result.state).toBe('success');
      expect(result.props.history).toStrictEqual([]);
    });

    it('coerces non-array breakdown to empty array', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, breakdown: 'invalid', history: validXPData.history });
      const result = await getXPData();

      expect(result.state).toBe('success');
      expect(result.props.breakdown).toStrictEqual([]);
    });

    it('coerces null history to empty array', async () => {
      const getXPData = getAdapterWithMock({ ...validXPData, history: null, breakdown: validXPData.breakdown });
      const result = await getXPData();

      expect(result.state).toBe('success');
      expect(result.props.history).toStrictEqual([]);
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getXPData = getAdapterWithMock({ totalXP: null });
      const result = await getXPData();

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
