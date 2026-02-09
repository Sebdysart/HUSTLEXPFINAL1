/**
 * Network client tests — verifies handling of live failure scenarios.
 * Tests: 500 response, invalid JSON, timeout, network error.
 */

import { request, get, post } from '../../src/network/client';

// Mock fetch globally
const mockFetch = jest.fn();
// @ts-expect-error Jest test environment provides global
global.fetch = mockFetch;

describe('Network Client', () => {
  beforeEach(() => {
    mockFetch.mockReset();
  });

  describe('successful responses', () => {
    it('returns ok: true with parsed data on 200', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({ user: { xp: 100 } }),
      });

      const result = await get<{ user: { xp: number } }>('https://api.test.com/data');

      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.user.xp).toBe(100);
      }
    });

    it('sends POST body as JSON', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 201,
        json: async () => ({ id: 'new-task' }),
      });

      await post('https://api.test.com/tasks', { title: 'Test' });

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.test.com/tasks',
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify({ title: 'Test' }),
        })
      );
    });
  });

  describe('server error (500)', () => {
    it('returns SERVER_ERROR on 500 response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('SERVER_ERROR');
        expect(result.error.statusCode).toBe(500);
      }
    });

    it('returns SERVER_ERROR on 502 response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 502,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('SERVER_ERROR');
        expect(result.error.statusCode).toBe(502);
      }
    });

    it('returns SERVER_ERROR on 503 response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 503,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('SERVER_ERROR');
        expect(result.error.statusCode).toBe(503);
      }
    });
  });

  describe('invalid JSON response', () => {
    it('returns INVALID_JSON when response is not valid JSON', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => {
          throw new SyntaxError('Unexpected token');
        },
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('INVALID_JSON');
        expect(result.error.statusCode).toBe(200);
      }
    });
  });

  describe('timeout', () => {
    it('returns TIMEOUT when request exceeds timeout', async () => {
      mockFetch.mockImplementationOnce(async () => {
        // Simulate a request that takes longer than timeout
        const error = new Error('Aborted');
        error.name = 'AbortError';
        throw error;
      });

      const result = await request('https://api.test.com/data', { timeout: 10 });

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('TIMEOUT');
      }
    });
  });

  describe('network error', () => {
    it('returns NETWORK_ERROR when fetch fails', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('NETWORK_ERROR');
        expect(result.error.message).toBe('Failed to fetch');
      }
    });

    it('returns NETWORK_ERROR when offline', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network request failed'));

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('NETWORK_ERROR');
      }
    });
  });

  describe('HTTP status codes', () => {
    it('returns UNAUTHORIZED on 401', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('UNAUTHORIZED');
        expect(result.error.statusCode).toBe(401);
      }
    });

    it('returns FORBIDDEN on 403', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 403,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('FORBIDDEN');
        expect(result.error.statusCode).toBe(403);
      }
    });

    it('returns NOT_FOUND on 404', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
      });

      const result = await get('https://api.test.com/data');

      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error.code).toBe('NOT_FOUND');
        expect(result.error.statusCode).toBe(404);
      }
    });
  });
});
