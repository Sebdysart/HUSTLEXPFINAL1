// NAVIGATION FROZEN — modify only via dedicated migration step
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { BootstrapScreen } from '../../screens/BootstrapScreen';
import { AuthStack } from './AuthStack';
import { OnboardingStack } from './OnboardingStack';
import HustlerStack from './HustlerStack';
import PosterTabs from './PosterTabs';
import SettingsStack from './SettingsStack';
import SharedModalStack from './SharedModalStack';

const Stack = createNativeStackNavigator();

export default function RootNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{ headerShown: false }}
        initialRouteName="Entry"
      >
        <Stack.Screen
          name="Entry"
          component={BootstrapScreen}
        />
        <Stack.Screen
          name="Auth"
          component={AuthStack}
        />
        <Stack.Screen
          name="Onboarding"
          component={OnboardingStack}
        />
        <Stack.Screen
          name="Hustler"
          component={HustlerStack}
        />
        <Stack.Screen
          name="Poster"
          component={PosterTabs}
        />
        <Stack.Screen
          name="Settings"
          component={SettingsStack}
        />
        <Stack.Screen
          name="SharedModal"
          component={SharedModalStack}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
