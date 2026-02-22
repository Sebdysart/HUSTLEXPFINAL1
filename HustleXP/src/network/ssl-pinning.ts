/**
 * SSL Certificate Pinning — infrastructure for transport-layer security.
 *
 * ============================================================================
 * THREE-PHASE SSL PINNING PLAN
 * ============================================================================
 *
 * PHASE 1 (CURRENT): Server-side certificate validation via HTTPS
 * --------------------------------------------------------------------------
 * React Native's fetch() already validates server certificates against the
 * device trust store. This is the baseline: HTTPS ensures the connection is
 * encrypted and the server certificate chains to a trusted CA.
 *
 * What this file provides today:
 *   - Pin configuration (public key hashes) ready for Phase 2.
 *   - A runtime validation stub that logs warnings in __DEV__ mode.
 *   - An SSL_PINNING_FAILURE error code wired into the network error layer.
 *   - A pre-request hook (`applySSLPinningHeaders`) the client calls to add
 *     an integrity header, preparing for server-side pin verification.
 *
 * PHASE 2: Native SSL pinning with react-native-ssl-pinning
 * --------------------------------------------------------------------------
 * When the native build pipeline is stable, install and link the library:
 *
 *   npm install react-native-ssl-pinning
 *   cd ios && pod install
 *
 * Then replace the fetch() call in client.ts with:
 *
 *   import { fetch as pinnedFetch } from 'react-native-ssl-pinning';
 *
 *   const response = await pinnedFetch(url, {
 *     method,
 *     headers,
 *     body: body ? JSON.stringify(body) : undefined,
 *     sslPinning: {
 *       certs: ['api_hustlexp_com'],   // .cer file in native bundle
 *     },
 *     // -- OR use public key hashes (preferred, survives cert renewal): --
 *     // sslPinning: {
 *     //   certs: SSL_PINS.map(p => p.hash),
 *     // },
 *   });
 *
 * The .cer file goes in:
 *   iOS:     ios/HustleXP/api_hustlexp_com.cer
 *   Android: android/app/src/main/assets/api_hustlexp_com.cer
 *
 * Extract it with:
 *   openssl s_client -connect api.hustlexp.com:443 </dev/null 2>/dev/null \
 *     | openssl x509 -outform DER -out api_hustlexp_com.cer
 *
 * PHASE 3: Certificate rotation with backup pins
 * --------------------------------------------------------------------------
 * To avoid bricking the app when the server certificate rotates:
 *   1. Always pin at least TWO hashes: the current cert and a backup/next cert.
 *   2. Use SPKI (Subject Public Key Info) hashes, not full cert hashes.
 *      SPKI pins survive cert renewal as long as the public key stays the same.
 *   3. Add a remote config endpoint that can push new pin hashes to the app
 *      (fetched over a separately-pinned or CA-validated channel).
 *   4. Set an expiry on pins; if all pins are expired, fall back to normal
 *      CA validation and alert the backend monitoring.
 *   5. Test rotation in staging before every production cert renewal.
 *
 * ============================================================================
 */

import { API_BASE_URL } from './config';

// ---------------------------------------------------------------------------
// Pin Definitions
// ---------------------------------------------------------------------------

export interface SSLPin {
  /** Human-readable label (e.g. "primary-2025", "backup-2026"). */
  label: string;

  /**
   * Base64-encoded SHA-256 hash of the Subject Public Key Info (SPKI).
   *
   * Generate with:
   *   openssl s_client -connect api.hustlexp.com:443 </dev/null 2>/dev/null \
   *     | openssl x509 -pubkey -noout \
   *     | openssl pkey -pubin -outform DER \
   *     | openssl dgst -sha256 -binary \
   *     | openssl enc -base64
   */
  hash: string;

  /** ISO-8601 date after which this pin should be considered stale. */
  expiresAt: string;
}

/**
 * Public key pins for api.hustlexp.com.
 *
 * IMPORTANT: Replace the placeholder hashes below with real SPKI hashes
 * extracted from the production certificate before enabling Phase 2.
 *
 * Always keep at least two pins (primary + backup) to survive rotation.
 */
export const SSL_PINS: readonly SSLPin[] = [
  {
    label: 'primary-placeholder',
    hash: 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    expiresAt: '2026-12-31T23:59:59Z',
  },
  {
    label: 'backup-placeholder',
    hash: 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
    expiresAt: '2027-06-30T23:59:59Z',
  },
] as const;

/**
 * The hostname(s) that SSL pinning applies to.
 * Extracted from API_BASE_URL so it stays in sync with config.ts.
 */
export const PINNED_HOSTNAMES: readonly string[] = (() => {
  try {
    const { hostname } = new URL(API_BASE_URL);
    return [hostname];
  } catch {
    return ['api.hustlexp.com'];
  }
})();

// ---------------------------------------------------------------------------
// Pinning Status
// ---------------------------------------------------------------------------

export type SSLPinningPhase = 'phase1-https-only' | 'phase2-native-pinning' | 'phase3-rotation';

/**
 * Current pinning phase. Bump this when you integrate
 * react-native-ssl-pinning in the native layer.
 */
export const CURRENT_PINNING_PHASE: SSLPinningPhase = 'phase1-https-only';

/**
 * Master kill-switch. Set to false to disable all pinning checks
 * (e.g. if a bad pin ships and you need an emergency bypass via CodePush).
 */
export const SSL_PINNING_ENABLED = true;

// ---------------------------------------------------------------------------
// Validation (Phase 1 stub)
// ---------------------------------------------------------------------------

export interface SSLValidationResult {
  valid: boolean;
  phase: SSLPinningPhase;
  reason?: string;
}

/**
 * Validates the request URL against the pinning policy.
 *
 * Phase 1: Always returns valid (HTTPS CA validation is handled by the OS).
 * Phase 2+: This function will call into the native pinning layer.
 *
 * Call this BEFORE making a fetch() to surface configuration issues early.
 */
export function validateCertificate(url: string): SSLValidationResult {
  if (!SSL_PINNING_ENABLED) {
    return { valid: true, phase: CURRENT_PINNING_PHASE, reason: 'SSL pinning disabled (kill-switch)' };
  }

  // Ensure we are always using HTTPS for pinned hosts.
  try {
    const parsed = new URL(url);

    if (PINNED_HOSTNAMES.includes(parsed.hostname) && parsed.protocol !== 'https:') {
      return {
        valid: false,
        phase: CURRENT_PINNING_PHASE,
        reason: `Pinned host "${parsed.hostname}" must use HTTPS, got ${parsed.protocol}`,
      };
    }
  } catch {
    return {
      valid: false,
      phase: CURRENT_PINNING_PHASE,
      reason: `Invalid URL: ${url}`,
    };
  }

  // Check for expired pins (informational in Phase 1, blocking in Phase 2+).
  const now = new Date();
  const activePins = SSL_PINS.filter((pin) => new Date(pin.expiresAt) > now);

  if (activePins.length === 0 && __DEV__) {
    console.warn(
      '[SSL Pinning] All pins are expired. Certificate rotation is overdue. ' +
      'Update SSL_PINS in ssl-pinning.ts with fresh SPKI hashes.'
    );
  }

  // Phase 1: Delegate to OS-level HTTPS validation.
  return { valid: true, phase: CURRENT_PINNING_PHASE };
}

// ---------------------------------------------------------------------------
// Request Header Hook
// ---------------------------------------------------------------------------

/**
 * Header name used for request integrity tracking.
 * The server can log this to verify that pinned clients are reaching it.
 */
const PIN_INTEGRITY_HEADER = 'X-SSL-Pin-Phase';

/**
 * Returns extra headers the network client should attach to every request
 * to a pinned hostname. In Phase 1 this is informational; in Phase 2+
 * the server can enforce that only pinned clients are accepted.
 */
export function getSSLPinningHeaders(url: string): Record<string, string> {
  if (!SSL_PINNING_ENABLED) {
    return {};
  }

  try {
    const { hostname } = new URL(url);
    if (!PINNED_HOSTNAMES.includes(hostname)) {
      return {};
    }
  } catch {
    return {};
  }

  return {
    [PIN_INTEGRITY_HEADER]: CURRENT_PINNING_PHASE,
  };
}

// ---------------------------------------------------------------------------
// Dev-mode helpers
// ---------------------------------------------------------------------------

declare const __DEV__: boolean;

/**
 * Logs the current SSL pinning configuration to the console.
 * Only runs in __DEV__ mode. Call once at app startup (e.g. in App.tsx).
 */
export function logSSLPinningStatus(): void {
  if (typeof __DEV__ !== 'undefined' && __DEV__) {
    const now = new Date();
    const activePins = SSL_PINS.filter((p) => new Date(p.expiresAt) > now);
    console.log(
      `[SSL Pinning] Phase: ${CURRENT_PINNING_PHASE} | ` +
      `Enabled: ${SSL_PINNING_ENABLED} | ` +
      `Pinned hosts: ${PINNED_HOSTNAMES.join(', ')} | ` +
      `Active pins: ${activePins.length}/${SSL_PINS.length}`
    );
  }
}
