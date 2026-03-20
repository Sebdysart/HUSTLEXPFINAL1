/**
 * AppConfig — environment configuration matching the SwiftUI client.
 */

export type AppEnvironment = 'debug' | 'release';

export const ENV: AppEnvironment = __DEV__ ? 'debug' : 'release';

export const AppConfig = {
  backendBaseUrl:
    ENV === 'debug'
      ? 'https://hustlexp-ai-backend-staging-production.up.railway.app'
      : 'https://hustlexp-ai-backend-production.up.railway.app',

  // Stripe publishable key (safe to embed). Mirrors iOS behavior.
  stripePublishableKey:
    ENV === 'debug'
      ? 'pk_test_51SCTxI9oJYlVip5Z931pD73nICDzzkhjFrKZ1pED20fJWRgwLDrVqEhkfYuosQXrt8S56WIdnjBT9Nv5oJ4SXyvB009Ajm9uRv'
      : 'pk_live_REPLACE_WITH_LIVE_PUBLISHABLE_KEY',
} as const;

