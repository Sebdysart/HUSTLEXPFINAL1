/**
 * HustleXP - Trust-based gig marketplace
 */

import React from 'react';
import { StatusBar, LogBox } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { AppProviders } from './src/providers/AppProviders';
import { RootNavigator } from './src/navigation';

if (__DEV__) {
  LogBox.ignoreLogs([
    'Non-serializable values were found in the navigation state',
  ]);
}

const DarkTheme = {
  dark: true,
  colors: {
    primary: '#5856D6',
    background: '#1C1C1E',
    card: '#2C2C2E',
    text: '#FFFFFF',
    border: '#3A3A3C',
    notification: '#5856D6',
  },
  fonts: {
    regular: { fontFamily: 'System', fontWeight: '400' as const },
    medium: { fontFamily: 'System', fontWeight: '500' as const },
    bold: { fontFamily: 'System', fontWeight: '700' as const },
    heavy: { fontFamily: 'System', fontWeight: '900' as const },
  },
};

function App() {
  return (
    <AppProviders>
      <StatusBar barStyle="light-content" backgroundColor="#1C1C1E" />
      <NavigationContainer theme={DarkTheme}>
        <RootNavigator />
      </NavigationContainer>
    </AppProviders>
  );
}

export default App;
