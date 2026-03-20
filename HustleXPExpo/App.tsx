import React, { useEffect } from 'react';
import { Platform } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import RootNavigator from './src/navigation/RootNavigator';
import { AppStateProvider } from './src/app/state';
import { AuthProvider } from './src/auth/AuthProvider';
import { AppConfig } from './src/app/config';

export default function App() {
  useEffect(() => {
    // Stripe is native-only; avoid importing it on web (it breaks bundling).
    if (Platform.OS === 'web') return;

    (async () => {
      try {
        const stripe = await import('@stripe/stripe-react-native');
        await stripe.initStripe({
          publishableKey: AppConfig.stripePublishableKey,
        });
      } catch {
        // Best-effort; UI will surface errors when attempting payment.
      }
    })();
  }, []);

  return (
    <SafeAreaProvider>
      <AppStateProvider>
        <AuthProvider>
          <RootNavigator />
        </AuthProvider>
      </AppStateProvider>
    </SafeAreaProvider>
  );
}

