/**
 * User Context
 * SPEC: EXECUTION_QUEUE.md STEP 072, FRONTEND_ARCHITECTURE.md §5
 *
 * React Context for current user state.
 * Defaults to 'user-hustler-active' for testing.
 */

import React, { createContext, useContext, useState, ReactNode } from 'react';
import { getUser } from '../services/dataService';

// User type based on mock data structure
export interface User {
  id: string;
  email: string;
  phone: string | null;
  full_name: string;
  avatar_url: string | null;
  default_mode: 'worker' | 'poster';
  onboarding_completed_at: string | null;
  trust_tier: number;
  xp_total: number;
  current_level: number;
  current_streak: number;
  last_task_completed_at: string | null;
  is_verified: boolean;
  verified_at?: string;
  live_mode_state: string;
  xp_first_celebration_shown_at: string | null;
  created_at: string;
  updated_at: string;
}

interface UserContextType {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  setUser: (user: User | null) => void;
  loadUser: (userId: string) => Promise<void>;
  clearUser: () => void;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

interface UserProviderProps {
  children: ReactNode;
  defaultUserId?: string;
}

export function UserProvider({ children, defaultUserId = 'user-hustler-active' }: UserProviderProps) {
  const [user, setUserState] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Load user on mount
  React.useEffect(() => {
    loadUser(defaultUserId);
  }, [defaultUserId]);

  const loadUser = async (userId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await getUser(userId) as { success: boolean; data: User | null; error: string | null };
      if (response.success && response.data) {
        setUserState(response.data);
      } else {
        setError(response.error || 'Failed to load user');
        setUserState(null);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
      setUserState(null);
    } finally {
      setIsLoading(false);
    }
  };

  const setUser = (newUser: User | null) => {
    setUserState(newUser);
    setError(null);
  };

  const clearUser = () => {
    setUserState(null);
    setError(null);
  };

  const value: UserContextType = {
    user,
    isLoading,
    error,
    setUser,
    loadUser,
    clearUser,
  };

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}

/**
 * Hook to access current user context
 * @returns {UserContextType} User context value
 * @throws {Error} If used outside UserProvider
 */
export function useCurrentUser(): UserContextType {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useCurrentUser must be used within a UserProvider');
  }
  return context;
}
