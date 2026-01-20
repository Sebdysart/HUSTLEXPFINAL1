import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthLoginScreen } from '../screens/auth/AuthLoginScreen';
import { AuthSignupScreen } from '../screens/auth/AuthSignupScreen';
import { AuthForgotPasswordScreen } from '../screens/auth/AuthForgotPasswordScreen';
import { AuthPhoneVerificationScreen } from '../screens/auth/AuthPhoneVerificationScreen';

const Stack = createNativeStackNavigator();

export function AuthStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="A1" component={AuthLoginScreen} />
      <Stack.Screen name="A2" component={AuthSignupScreen} />
      <Stack.Screen name="A3" component={AuthForgotPasswordScreen} />
      <Stack.Screen name="A4" component={AuthPhoneVerificationScreen} />
    </Stack.Navigator>
  );
}
