import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { TRPCClient, TRPCError } from '../network/trpcClient';
import type { HXUser } from './authTypes';
import { normalizeUserRole } from '../app/types';
import { useAppState } from '../app/state';

type AuthContextValue = {
  currentUser: HXUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: Error | null;

  signUp: (params: { email: string; password: string; fullName: string; defaultMode: 'hustler' | 'poster' }) => Promise<void>;
  signIn: (params: { email: string; password: string }) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
  refreshToken: () => Promise<void>;
  loadCurrentUser: (opts?: { silentFail?: boolean }) => Promise<void>;
  sendPasswordReset: (email: string) => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

type EmptyInput = Record<string, never>;

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const appState = useAppState();
  const [currentUser, setCurrentUser] = useState<HXUser | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const isAuthenticated = !!currentUser;

  useEffect(() => {
    // Best-effort: restore cached token and attempt /user.me if Firebase is already signed in.
    (async () => {
      await TRPCClient.shared.loadAuthToken();
      const fbUser = auth().currentUser;
      if (fbUser) {
        try {
          await refreshToken();
          await loadCurrentUser({ silentFail: true });
        } catch {
          // ignore: UI will show unauthenticated
        }
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function registerBackendUser(params: {
    firebaseUid: string;
    email: string;
    fullName: string;
    defaultMode: string;
  }) {
    const user = await TRPCClient.shared.call<typeof params, HXUser>('user', 'register', 'mutation', params);
    return user;
  }

  async function loadCurrentUser(opts?: { silentFail?: boolean }) {
    try {
      const user = await TRPCClient.shared.call<EmptyInput, HXUser>('user', 'me', 'query', {});
      const normalized: HXUser = {
        ...user,
        role: normalizeUserRole((user as any).role) as any,
      };
      setCurrentUser(normalized);
      appState.login(normalized.id, normalized.role);
      appState.setUserName(normalized.name ?? null);

      // SwiftUI parity: onboarding gating is controlled by backend onboarding status.
      // If onboarding isn't complete yet, RootNavigator should keep us in onboarding flow.
      try {
        const onboardingStatus = await TRPCClient.shared.call<
          EmptyInput,
          { hasCompletedOnboarding: boolean }
        >('user', 'getOnboardingStatus', 'query', {});
        appState.setOnboardingCompleted(!!onboardingStatus.hasCompletedOnboarding);
      } catch {
        // If the backend doesn't support this yet, keep existing behavior.
      }
    } catch (e) {
      if (opts?.silentFail) return;
      await signOut();
    }
  }

  async function refreshToken() {
    const fbUser = auth().currentUser;
    if (!fbUser) throw new Error('Not authenticated');
    const token = await fbUser.getIdToken(true);
    await TRPCClient.shared.setAuthToken(token);
  }

  async function signUp(params: {
    email: string;
    password: string;
    fullName: string;
    defaultMode: 'hustler' | 'poster';
  }) {
    setIsLoading(true);
    setError(null);
    try {
      const res = await auth().createUserWithEmailAndPassword(params.email, params.password);
      const fbUser = res.user;
      const token = await fbUser.getIdToken();
      await TRPCClient.shared.setAuthToken(token);

      const user = await registerBackendUser({
        firebaseUid: fbUser.uid,
        email: params.email,
        fullName: params.fullName,
        defaultMode: params.defaultMode,
      });

      const normalized: HXUser = { ...user, role: normalizeUserRole((user as any).role) as any };
      setCurrentUser(normalized);
      appState.login(normalized.id, normalized.role);
      appState.setUserName(normalized.name ?? null);
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Sign up failed'));
      throw e;
    } finally {
      setIsLoading(false);
    }
  }

  async function signIn(params: { email: string; password: string }) {
    setIsLoading(true);
    setError(null);
    try {
      await auth().signInWithEmailAndPassword(params.email, params.password);
      await refreshToken();
      await loadCurrentUser();
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Sign in failed'));
      throw e;
    } finally {
      setIsLoading(false);
    }
  }

  async function signInWithGoogle() {
    setIsLoading(true);
    setError(null);
    try {
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const result = await GoogleSignin.signIn();
      const idToken = result.data?.idToken;
      if (!idToken) throw new Error('Google Sign-In failed (missing idToken)');

      const googleCred = auth.GoogleAuthProvider.credential(idToken);
      const res = await auth().signInWithCredential(googleCred);
      const fbUser = res.user;

      await refreshToken();
      await loadCurrentUser({ silentFail: true });
      if (currentUser) return;

      // Backend user may not exist yet: register.
      const user = await registerBackendUser({
        firebaseUid: fbUser.uid,
        email: fbUser.email ?? '',
        fullName: fbUser.displayName ?? 'HustleXP User',
        defaultMode: 'hustler',
      });
      const normalized: HXUser = { ...user, role: normalizeUserRole((user as any).role) as any };
      setCurrentUser(normalized);
      appState.login(normalized.id, normalized.role);
      appState.setUserName(normalized.name ?? null);
    } catch (e) {
      // Don't mask useful backend errors
      if (e instanceof TRPCError) setError(e);
      else setError(e instanceof Error ? e : new Error('Google sign-in failed'));
      throw e;
    } finally {
      setIsLoading(false);
    }
  }

  async function signOut() {
    setIsLoading(true);
    setError(null);
    try {
      await auth().signOut();
    } catch {
      // ignore
    }
    await TRPCClient.shared.clearAuthToken();
    setCurrentUser(null);
    appState.logout();
    setIsLoading(false);
  }

  async function sendPasswordReset(email: string) {
    setIsLoading(true);
    setError(null);
    try {
      await auth().sendPasswordResetEmail(email);
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Password reset failed'));
      throw e;
    } finally {
      setIsLoading(false);
    }
  }

  const value = useMemo<AuthContextValue>(
    () => ({
      currentUser,
      isAuthenticated,
      isLoading,
      error,
      signUp,
      signIn,
      signInWithGoogle,
      signOut,
      refreshToken,
      loadCurrentUser,
      sendPasswordReset,
    }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [currentUser, isAuthenticated, isLoading, error]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}

