import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { FramingScreen } from '../screens/onboarding/FramingScreen';
import { CalibrationScreen } from '../screens/onboarding/CalibrationScreen';
import { RoleConfirmationScreen } from '../screens/onboarding/RoleConfirmationScreen';
import { PreferenceLockScreen } from '../screens/onboarding/PreferenceLockScreen';
import { CapabilityIntroScreen } from '../screens/onboarding/CapabilityIntroScreen';
import { LocationSetupScreen } from '../screens/onboarding/LocationSetupScreen';
import { TradeVerificationScreen } from '../screens/onboarding/capability/TradeVerificationScreen';
import { InsuranceUploadScreen } from '../screens/onboarding/capability/InsuranceUploadScreen';
import { BackgroundCheckScreen } from '../screens/onboarding/capability/BackgroundCheckScreen';
import { VehicleSetupScreen } from '../screens/onboarding/capability/VehicleSetupScreen';
import { AvailabilityScreen } from '../screens/onboarding/capability/AvailabilityScreen';
import { CapabilitySummaryScreen } from '../screens/onboarding/capability/CapabilitySummaryScreen';

const Stack = createNativeStackNavigator();

export function OnboardingStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="O1" component={FramingScreen} />
      <Stack.Screen name="O2" component={CalibrationScreen} />
      <Stack.Screen name="O3" component={RoleConfirmationScreen} />
      <Stack.Screen name="O4" component={PreferenceLockScreen} />
      <Stack.Screen name="O5" component={CapabilityIntroScreen} />
      <Stack.Screen name="O6" component={LocationSetupScreen} />
      <Stack.Screen name="O7" component={TradeVerificationScreen} />
      <Stack.Screen name="O8" component={InsuranceUploadScreen} />
      <Stack.Screen name="O9" component={BackgroundCheckScreen} />
      <Stack.Screen name="O10" component={VehicleSetupScreen} />
      <Stack.Screen name="O11" component={AvailabilityScreen} />
      <Stack.Screen name="O12" component={CapabilitySummaryScreen} />
    </Stack.Navigator>
  );
}
