import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { FramingScreen } from '../../screens/onboarding/FramingScreen';
import { CalibrationScreen } from '../../screens/onboarding/CalibrationScreen';
import { RoleConfirmationScreen } from '../../screens/onboarding/RoleConfirmationScreen';
import { PreferenceLockScreen } from '../../screens/onboarding/PreferenceLockScreen';
import { CapabilityIntroScreen } from '../../screens/onboarding/capability/CapabilityIntroScreen';
import { LocationSetupScreen } from '../../screens/onboarding/capability/LocationSetupScreen';

const Stack = createNativeStackNavigator();

export function OnboardingStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Framing" component={FramingScreen} />
      <Stack.Screen name="Calibration" component={CalibrationScreen} />
      <Stack.Screen name="RoleConfirmation" component={RoleConfirmationScreen} />
      <Stack.Screen name="PreferenceLock" component={PreferenceLockScreen} />
      <Stack.Screen name="CapabilityIntro" component={CapabilityIntroScreen} />
      <Stack.Screen name="LocationSetup" component={LocationSetupScreen} />
    </Stack.Navigator>
  );
}
