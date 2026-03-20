import React, { createContext, useContext, useMemo, useState } from 'react';
import type { AuthState, UserRole, TrustTier } from './types';

export interface AppStateValue {
  authState: AuthState;
  isLoggedIn: boolean;
  userRole: UserRole | null;
  trustTier: TrustTier;
  userId: string | null;
  userName: string | null;
  hasCompletedOnboarding: boolean;
  selectedTab: number;

  login: (userId: string, role: UserRole) => void;
  logout: () => void;
  completeOnboarding: () => void;
  setOnboardingCompleted: (completed: boolean) => void;
  setRole: (role: UserRole) => void;
  setUserName: (name: string | null) => void;
  setTrustTier: (tier: TrustTier) => void;
  setSelectedTab: (tab: number) => void;
}

const AppStateContext = createContext<AppStateValue | undefined>(undefined);

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [authState, setAuthState] = useState<AuthState>('unauthenticated');
  const [userRole, setUserRole] = useState<UserRole | null>(null);
  const [trustTier, setTrustTier] = useState<TrustTier>(1);
  const [userId, setUserId] = useState<string | null>(null);
  const [userName, setUserName] = useState<string | null>(null);
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [selectedTab, setSelectedTab] = useState(0);

  const value = useMemo<AppStateValue>(() => {
    return {
      authState,
      isLoggedIn: !!userId,
      userRole,
      trustTier,
      userId,
      userName,
      hasCompletedOnboarding,
      selectedTab,

      login: (id, role) => {
        setUserId(id);
        setUserRole(role);
        setAuthState(hasCompletedOnboarding ? 'authenticated' : 'onboarding');
      },
      logout: () => {
        setUserId(null);
        setUserRole(null);
        setSelectedTab(0);
        setAuthState('unauthenticated');
      },
      completeOnboarding: () => {
        setHasCompletedOnboarding(true);
        setAuthState('authenticated');
      },
      setOnboardingCompleted: (completed: boolean) => {
        setHasCompletedOnboarding(completed);
        if (idOrNull(userId)) {
          setAuthState(completed ? 'authenticated' : 'onboarding');
        }
      },
      setRole: (role) => setUserRole(role),
      setUserName: (name) => setUserName(name),
      setTrustTier: (tier) => setTrustTier(tier),
      setSelectedTab: (tab) => setSelectedTab(tab),
    };
  }, [authState, hasCompletedOnboarding, selectedTab, trustTier, userId, userName, userRole]);

  return <AppStateContext.Provider value={value}>{children}</AppStateContext.Provider>;
}

export function useAppState(): AppStateValue {
  const ctx = useContext(AppStateContext);
  if (!ctx) throw new Error('useAppState must be used within AppStateProvider');
  return ctx;
}

function idOrNull(id: string | null): boolean {
  return !!id;
}

