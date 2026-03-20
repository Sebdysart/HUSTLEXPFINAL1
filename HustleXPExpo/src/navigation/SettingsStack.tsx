import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import SettingsMainScreen from '../screens/settings/SettingsMainScreen';
import AccountSettingsScreen from '../screens/settings/AccountSettingsScreen';
import NotificationSettingsScreen from '../screens/settings/NotificationSettingsScreen';
import PaymentSettingsScreen from '../screens/settings/PaymentSettingsScreen';
import PrivacySettingsScreen from '../screens/settings/PrivacySettingsScreen';
import VerificationScreen from '../screens/settings/VerificationScreen';
import SupportScreen from '../screens/settings/SupportScreen';

const Stack = createNativeStackNavigator();

export default function SettingsStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="SettingsMain" component={SettingsMainScreen} />
      <Stack.Screen name="AccountSettings" component={AccountSettingsScreen} />
      <Stack.Screen name="NotificationSettings" component={NotificationSettingsScreen} />
      <Stack.Screen name="PaymentSettings" component={PaymentSettingsScreen} />
      <Stack.Screen name="PrivacySettings" component={PrivacySettingsScreen} />
      <Stack.Screen name="Verification" component={VerificationScreen} />
      <Stack.Screen name="Support" component={SupportScreen} />
    </Stack.Navigator>
  );
}
