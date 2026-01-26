/**
 * HustleXP - Trust-based gig marketplace
 */

import React from 'react';
import { StatusBar } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { BootstrapScreen } from './src/screens';

function App() {
  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" />
      <BootstrapScreen />
    </SafeAreaProvider>
  );
}

export default App;
