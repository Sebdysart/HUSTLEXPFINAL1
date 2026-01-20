import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { AuthStack } from './AuthStack';
import { OnboardingStack } from './OnboardingStack';
import { MainTabs } from './MainTabs';
import { useCurrentUser } from '../contexts/UserContext';
import { NEUTRAL } from '../constants';

export function RootNavigator() {
  const { user, isLoading } = useCurrentUser();
  
  // Determine auth state from user context
  const isAuthenticated = !!user;
  const isOnboarded = !!user?.onboarding_completed_at;

  // Show loading indicator while user state is being loaded
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={NEUTRAL.TEXT} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      {!isAuthenticated ? (
        <AuthStack />
      ) : !isOnboarded ? (
        <OnboardingStack />
      ) : (
        <MainTabs />
      )}
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: NEUTRAL.BACKGROUND,
  },
});
