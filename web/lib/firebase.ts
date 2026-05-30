/**
 * Firebase Web SDK init. Browser-only and lazy — the SDK is never touched
 * during SSR or build-time prerender, so missing env vars don't break the
 * Next.js build. Consumers call `firebaseAuth()` from inside an effect or a
 * client-side handler.
 *
 * Same Firebase project as the iOS app (NEXT_PUBLIC_FIREBASE_* env vars).
 */

import { getApps, initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { env } from "./env";

let cachedApp: FirebaseApp | null = null;
let cachedAuth: Auth | null = null;

function ensureApp(): FirebaseApp {
  if (cachedApp) return cachedApp;
  const existing = getApps();
  cachedApp =
    existing.length > 0
      ? existing[0]!
      : initializeApp({
          apiKey: env.firebase.apiKey,
          authDomain: env.firebase.authDomain,
          projectId: env.firebase.projectId,
          appId: env.firebase.appId,
        });
  return cachedApp;
}

export function firebaseAuth(): Auth {
  if (cachedAuth) return cachedAuth;
  cachedAuth = getAuth(ensureApp());
  return cachedAuth;
}

export async function getIdToken(forceRefresh = false): Promise<string | null> {
  if (typeof window === "undefined") return null;
  const user = firebaseAuth().currentUser;
  if (!user) return null;
  try {
    return await user.getIdToken(forceRefresh);
  } catch {
    return null;
  }
}
