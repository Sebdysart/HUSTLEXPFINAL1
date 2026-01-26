/**
 * useAuth - Hook for authentication
 */

import { useState, useCallback } from 'react';
import { useAuthStore } from '../store';
import { authApi } from '../api/auth';
import { mockApi, USE_MOCK_API } from '../api/mock';

interface User {
  id: string;
  email: string;
  name: string;
  role: 'hustler' | 'poster' | 'both';
  trustTier: 1 | 2 | 3 | 4 | 5;
  xp: number;
  onboardingComplete: boolean;
}

interface UseAuthReturn {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  signup: (email: string, password: string, name: string) => Promise<boolean>;
  logout: () => Promise<void>;
  forgotPassword: (email: string) => Promise<boolean>;
  clearError: () => void;
}

export function useAuth(): UseAuthReturn {
  const { user, isAuthenticated, setUser, setLoading, isLoading, logout: storeLogout } = useAuthStore();
  const [error, setError] = useState<string | null>(null);

  const login = useCallback(async (email: string, password: string): Promise<boolean> => {
    setLoading(true);
    setError(null);

    try {
      if (USE_MOCK_API) {
        const result = await mockApi.login(email, password);
        setUser(result.user);
        return true;
      } else {
        const response = await authApi.login({ email, password });
        if (response.ok) {
          setUser(response.data.user);
          return true;
        }
        setError(response.error || 'Login failed');
        return false;
      }
    } catch (e) {
      const message = e instanceof Error ? e.message : 'Login failed';
      setError(message);
      return false;
    } finally {
      setLoading(false);
    }
  }, [setUser, setLoading]);

  const signup = useCallback(async (email: string, password: string, name: string): Promise<boolean> => {
    setLoading(true);
    setError(null);

    try {
      if (USE_MOCK_API) {
        const result = await mockApi.signup(email, password, name);
        setUser(result.user);
        return true;
      } else {
        const response = await authApi.signup({ email, password, name });
        if (response.ok) {
          setUser(response.data.user);
          return true;
        }
        setError(response.error || 'Signup failed');
        return false;
      }
    } catch (e) {
      const message = e instanceof Error ? e.message : 'Signup failed';
      setError(message);
      return false;
    } finally {
      setLoading(false);
    }
  }, [setUser, setLoading]);

  const logout = useCallback(async (): Promise<void> => {
    setLoading(true);
    try {
      if (!USE_MOCK_API) {
        await authApi.logout();
      }
      storeLogout();
    } finally {
      setLoading(false);
    }
  }, [storeLogout, setLoading]);

  const forgotPassword = useCallback(async (email: string): Promise<boolean> => {
    setLoading(true);
    setError(null);

    try {
      if (USE_MOCK_API) {
        // Mock: just pretend it worked
        await new Promise<void>(resolve => setTimeout(resolve, 1000));
        return true;
      } else {
        const response = await authApi.forgotPassword(email);
        if (response.ok) {
          return true;
        }
        setError(response.error || 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      const message = e instanceof Error ? e.message : 'Failed to send reset email';
      setError(message);
      return false;
    } finally {
      setLoading(false);
    }
  }, [setLoading]);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    user,
    isAuthenticated,
    isLoading,
    error,
    login,
    signup,
    logout,
    forgotPassword,
    clearError,
  };
}
