import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SettingsMainScreen } from '../screens/settings/SettingsMainScreen';
import { AccountSettingsScreen } from '../screens/settings/AccountSettingsScreen';
import { NotificationSettingsScreen } from '../screens/settings/NotificationSettingsScreen';
import { PaymentSettingsScreen } from '../screens/settings/PaymentSettingsScreen';
import { PrivacySettingsScreen } from '../screens/settings/PrivacySettingsScreen';
import { VerificationScreen } from '../screens/settings/VerificationScreen';
import { SupportScreen } from '../screens/settings/SupportScreen';

const Stack = createNativeStackNavigator();

export function SettingsStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="S1" component={SettingsMainScreen} />
      <Stack.Screen name="S2" component={AccountSettingsScreen} />
      <Stack.Screen name="S3" component={NotificationSettingsScreen} />
      <Stack.Screen name="S4" component={PaymentSettingsScreen} />
      <Stack.Screen name="S5" component={PrivacySettingsScreen} />
      <Stack.Screen name="S6" component={VerificationScreen} />
      <Stack.Screen name="S7" component={SupportScreen} />
    </Stack.Navigator>
  );
}
