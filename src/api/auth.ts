/**
 * Auth API - Authentication endpoints
 */

import { api } from './client';

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'hustler' | 'poster' | 'both';
  trustTier: 1 | 2 | 3 | 4 | 5;
  xp: number;
  onboardingComplete: boolean;
  createdAt: string;
  avatarUrl?: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface SignupRequest {
  email: string;
  password: string;
  name: string;
}

export interface LoginResponse {
  user: User;
  tokens: AuthTokens;
}

export interface SignupResponse {
  user: User;
  tokens: AuthTokens;
}

export const authApi = {
  /**
   * Login with email and password
   */
  async login(credentials: LoginRequest) {
    const response = await api.post<LoginResponse>('/auth/login', credentials);
    
    if (response.ok && response.data.tokens) {
      api.setAuthToken(response.data.tokens.accessToken);
    }
    
    return response;
  },

  /**
   * Create a new account
   */
  async signup(data: SignupRequest) {
    const response = await api.post<SignupResponse>('/auth/signup', data);
    
    if (response.ok && response.data.tokens) {
      api.setAuthToken(response.data.tokens.accessToken);
    }
    
    return response;
  },

  /**
   * Request password reset email
   */
  async forgotPassword(email: string) {
    return api.post<{ message: string }>('/auth/forgot-password', { email });
  },

  /**
   * Reset password with token
   */
  async resetPassword(token: string, newPassword: string) {
    return api.post<{ message: string }>('/auth/reset-password', {
      token,
      newPassword,
    });
  },

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string) {
    const response = await api.post<AuthTokens>('/auth/refresh', { refreshToken });
    
    if (response.ok && response.data.accessToken) {
      api.setAuthToken(response.data.accessToken);
    }
    
    return response;
  },

  /**
   * Logout and invalidate tokens
   */
  async logout() {
    const response = await api.post<{ message: string }>('/auth/logout');
    api.setAuthToken(null);
    return response;
  },

  /**
   * Get current user profile
   */
  async getProfile() {
    return api.get<User>('/auth/me');
  },

  /**
   * Update user profile
   */
  async updateProfile(updates: Partial<User>) {
    return api.patch<User>('/auth/me', updates);
  },

  /**
   * Complete onboarding
   */
  async completeOnboarding(data: {
    role: 'hustler' | 'poster' | 'both';
    capabilities?: {
      hasVehicle?: boolean;
      vehicleType?: string;
      skills?: string[];
      trades?: string[];
      tools?: string[];
      hasInsurance?: boolean;
      backgroundCheckConsent?: boolean;
      availability?: Record<string, string[]>;
      location?: {
        latitude: number;
        longitude: number;
        radius: number;
      };
    };
  }) {
    return api.post<User>('/auth/onboarding/complete', data);
  },
};
