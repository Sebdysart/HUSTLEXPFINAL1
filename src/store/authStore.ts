/**
 * Auth Store - Global authentication state
 */

import { create } from 'zustand';

interface User {
  id: string;
  email: string;
  name: string;
  role: 'hustler' | 'poster' | 'both';
  trustTier: 1 | 2 | 3 | 4 | 5;
  xp: number;
  onboardingComplete: boolean;
}

interface AuthState {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  
  // Actions
  setUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  updateOnboarding: (complete: boolean) => void;
  updateTrustTier: (tier: 1 | 2 | 3 | 4 | 5) => void;
  addXP: (amount: number) => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isLoading: true,
  isAuthenticated: false,

  setUser: (user) => set({ 
    user, 
    isAuthenticated: !!user,
    isLoading: false 
  }),

  setLoading: (isLoading) => set({ isLoading }),

  login: async (email, _password) => {
    set({ isLoading: true });
    
    // TODO: Replace with real API call
    await new Promise<void>(resolve => setTimeout(resolve, 1000));
    
    // Mock successful login
    const mockUser: User = {
      id: '1',
      email,
      name: email.split('@')[0],
      role: 'hustler',
      trustTier: 1,
      xp: 0,
      onboardingComplete: false,
    };
    
    set({ 
      user: mockUser, 
      isAuthenticated: true, 
      isLoading: false 
    });
    
    return true;
  },

  logout: () => set({ 
    user: null, 
    isAuthenticated: false,
    isLoading: false 
  }),

  updateOnboarding: (complete) => {
    const { user } = get();
    if (user) {
      set({ user: { ...user, onboardingComplete: complete } });
    }
  },

  updateTrustTier: (tier) => {
    const { user } = get();
    if (user) {
      set({ user: { ...user, trustTier: tier } });
    }
  },

  addXP: (amount) => {
    const { user } = get();
    if (user) {
      const newXP = user.xp + amount;
      // Auto-tier up based on XP thresholds
      let newTier = user.trustTier;
      if (newXP >= 10000 && newTier < 5) newTier = 5;
      else if (newXP >= 5000 && newTier < 4) newTier = 4;
      else if (newXP >= 2000 && newTier < 3) newTier = 3;
      else if (newXP >= 500 && newTier < 2) newTier = 2;
      
      set({ user: { ...user, xp: newXP, trustTier: newTier } });
    }
  },
}));
