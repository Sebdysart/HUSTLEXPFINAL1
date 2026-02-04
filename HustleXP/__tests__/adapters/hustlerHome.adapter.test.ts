/**
 * Adapter invariant tests for hustlerHome.adapter.
 * Validates guard behavior against malformed backend responses.
 */

import { validHustlerHomeData } from './_fixtures/validData';

const expectedStubProps = {
  user: { xp: 0, level: 0, trustTier: 0 },
  activeTask: null,
  availableTasksCount: 0,
  recentEarnings: 0,
  weeklyTaskCount: 0,
  currentStreak: 0,
  systemStatus: null,
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
  jest.doMock('../../src/data/mocks/hustlerHome.mock', () => ({
    hustlerHomeMock: mockData,
  }));
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { getHustlerHomeData } = require('../../src/data/adapters/hustlerHome.adapter');
  return getHustlerHomeData;
}

describe('getHustlerHomeData', () => {
  afterEach(() => {
    jest.resetModules();
  });

  describe('valid response', () => {
    it('returns success state with correct props shape', async () => {
      const getHustlerHomeData = getAdapterWithMock(validHustlerHomeData);
      const result = await getHustlerHomeData();

      expect(result).toStrictEqual({
        state: 'success',
        props: {
          user: { xp: 1200, level: 4, trustTier: 2 },
          activeTask: null,
          availableTasksCount: 12,
          recentEarnings: 240,
          weeklyTaskCount: 6,
          currentStreak: 3,
          systemStatus: null,
        },
      });
    });
  });

  describe('missing required fields', () => {
    it('returns error when user is missing', async () => {
      const getHustlerHomeData = getAdapterWithMock({ ...validHustlerHomeData, user: undefined });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });

    it('returns error when user is null', async () => {
      const getHustlerHomeData = getAdapterWithMock({ ...validHustlerHomeData, user: null });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
      expect(result.props).toStrictEqual(expectedStubProps);
    });
  });

  describe('wrong primitive types', () => {
    it('returns error when user.xp is string', async () => {
      const getHustlerHomeData = getAdapterWithMock({
        ...validHustlerHomeData,
        user: { ...validHustlerHomeData.user, xp: '1200' },
      });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });

    it('returns error when user.level is string', async () => {
      const getHustlerHomeData = getAdapterWithMock({
        ...validHustlerHomeData,
        user: { ...validHustlerHomeData.user, level: '4' },
      });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });

    it('returns error when user.trustTier is boolean', async () => {
      const getHustlerHomeData = getAdapterWithMock({
        ...validHustlerHomeData,
        user: { ...validHustlerHomeData.user, trustTier: true },
      });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });

    it('returns error when user is not an object', async () => {
      const getHustlerHomeData = getAdapterWithMock({ ...validHustlerHomeData, user: 'invalid' });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });
  });

  describe('null where forbidden', () => {
    it('returns error when user.xp is null', async () => {
      const getHustlerHomeData = getAdapterWithMock({
        ...validHustlerHomeData,
        user: { ...validHustlerHomeData.user, xp: null },
      });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });

    it('returns error when user.level is null', async () => {
      const getHustlerHomeData = getAdapterWithMock({
        ...validHustlerHomeData,
        user: { ...validHustlerHomeData.user, level: null },
      });
      const result = await getHustlerHomeData();

      expect(result.state).toBe('error');
    });
  });

  describe('stub props on error', () => {
    it('returns correct stub props when validation fails', async () => {
      const getHustlerHomeData = getAdapterWithMock({ user: null });
      const result = await getHustlerHomeData();

      expect(result).toStrictEqual({
        state: 'error',
        props: expectedStubProps,
      });
    });
  });
});
