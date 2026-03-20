export type UserRole = 'hustler' | 'poster' | 'admin';

export type AuthState = 'unauthenticated' | 'onboarding' | 'authenticated';

export type TrustTier = 0 | 1 | 2 | 3 | 4 | 5;

export function normalizeUserRole(role: string | null | undefined): UserRole {
  if (role === 'poster' || role === 'admin' || role === 'hustler') return role;
  if (role === 'worker') return 'hustler';
  return 'hustler';
}

