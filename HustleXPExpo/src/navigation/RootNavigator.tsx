import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthStack } from './AuthStack';
import { OnboardingStack } from './OnboardingStack';
import MainTabs from './MainTabs';
import { useAppState } from '../app/state';
import TaskConversationScreen from '../screens/shared/TaskConversationScreen';

const RootStack = createNativeStackNavigator();

export default function RootNavigator() {
  const appState = useAppState();

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {appState.authState === 'unauthenticated' && (
          <RootStack.Screen name="AuthFlow" component={AuthStack} />
        )}
        {appState.authState === 'onboarding' && (
          <RootStack.Screen name="OnboardingFlow" component={OnboardingStack} />
        )}
        {appState.authState === 'authenticated' && (
          <RootStack.Screen name="MainTabs" component={MainTabs} />
        )}

        {/* Root-level modal destinations so nested stacks can open them */}
        <RootStack.Screen name="TaskConversation" component={TaskConversationScreen} />
      </RootStack.Navigator>
    </NavigationContainer>
  );
}
