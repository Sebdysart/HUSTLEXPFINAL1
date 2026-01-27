/**
 * tRPC Client for HustleXP Backend
 * 
 * Connects to the HustleXP backend tRPC API
 */

import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';

// Import the router type from backend (we'll create a local type for now)
// In production, this would be: import type { AppRouter } from 'hustlexp-ai-backend';

// API URL configuration
const API_URL = __DEV__ 
  ? 'http://localhost:3000/trpc'
  : 'https://api.hustlexp.com/trpc';

// Auth token storage
let authToken: string | null = null;

export function setAuthToken(token: string | null) {
  authToken = token;
}

// Create tRPC client
// Note: Type will be 'any' until we properly share types with backend
export const trpc = createTRPCProxyClient<any>({
  links: [
    httpBatchLink({
      url: API_URL,
      headers() {
        return authToken 
          ? { Authorization: `Bearer ${authToken}` }
          : {};
      },
    }),
  ],
});

/**
 * Helper to make tRPC calls with error handling
 */
export async function trpcCall<T>(
  call: () => Promise<T>,
  fallback?: T
): Promise<{ data: T | null; error: string | null }> {
  try {
    const data = await call();
    return { data, error: null };
  } catch (err) {
    console.error('tRPC call failed:', err);
    return { 
      data: fallback ?? null, 
      error: err instanceof Error ? err.message : 'Unknown error' 
    };
  }
}

/**
 * Type definitions for backend responses
 * These mirror the backend types for type safety
 */
export interface Task {
  id: string;
  title: string;
  description: string;
  category: string;
  status: 'OPEN' | 'CLAIMED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'EXPIRED';
  posterId: string;
  posterName?: string;
  hustlerId?: string;
  hustlerName?: string;
  address: string;
  latitude: number;
  longitude: number;
  price: number;
  baseXp: number;
  estimatedMinutes: number;
  requiredTrustTier: number;
  createdAt: string;
  claimedAt?: string;
  completedAt?: string;
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'hustler' | 'poster' | 'both';
  trustTier: number;
  xp: number;
  createdAt: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}
