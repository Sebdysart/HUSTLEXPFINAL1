import { Platform } from 'react-native';

// Centralized Firebase imports so web preview doesn't crash:
// - On web, we export `null` stubs (Expo Web can't use @react-native-firebase).
// - On native (iOS), we lazy-require the real modules.

export type FirebaseAuthModule = {
  (): {
    currentUser: { uid: string; getIdToken: (forceRefresh?: boolean) => Promise<string> } | null;
    createUserWithEmailAndPassword: (email: string, password: string) => Promise<{ user: any }>;
    signInWithEmailAndPassword: (email: string, password: string) => Promise<any>;
    sendPasswordResetEmail: (email: string) => Promise<void>;
    signOut: () => Promise<void>;
  };
  GoogleAuthProvider: { credential: (idToken: string) => any };
  signInWithCredential: (cred: any) => Promise<{ user: any }>;
};

export type GoogleSigninModule = {
  hasPlayServices: (opts?: { showPlayServicesUpdateDialog?: boolean }) => Promise<boolean>;
  signIn: () => Promise<{ data?: { idToken?: string | null } | null }>;
};

export function getNativeAuth(): FirebaseAuthModule | null {
  if (Platform.OS === 'web') return null;
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const auth = require('@react-native-firebase/auth').default as FirebaseAuthModule;
  return auth;
}

export function getNativeGoogleSignin(): GoogleSigninModule | null {
  if (Platform.OS === 'web') return null;
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { GoogleSignin } = require('@react-native-google-signin/google-signin') as { GoogleSignin: GoogleSigninModule };
  return GoogleSignin;
}

