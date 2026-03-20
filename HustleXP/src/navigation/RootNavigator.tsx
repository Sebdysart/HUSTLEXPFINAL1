import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { AuthStack } from './AuthStack';
import { OnboardingStack } from './OnboardingStack';
import MainTabs from './MainTabs';
import { useAppState } from '../app/state';

export default function RootNavigator() {
  const appState = useAppState();

  return (
    <NavigationContainer>
      {appState.authState === 'unauthenticated' && <AuthStack />}
      {appState.authState === 'onboarding' && <OnboardingStack />}
      {appState.authState === 'authenticated' && <MainTabs />}
    </NavigationContainer>
  );
}
