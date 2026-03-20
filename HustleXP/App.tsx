import React, { useEffect } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import RootNavigator from './src/navigation/RootNavigator';
import { AppStateProvider } from './src/app/state';
import { AuthProvider } from './src/auth/AuthProvider';
import { initStripe } from '@stripe/stripe-react-native';
import { AppConfig } from './src/app/config';

export default function App() {
  useEffect(() => {
    // Stripe needs initialization before PaymentSheet is presented.
    initStripe({
      publishableKey: AppConfig.stripePublishableKey,
    }).catch(() => {
      // Best-effort; UI will surface errors when attempting payment.
    });
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

