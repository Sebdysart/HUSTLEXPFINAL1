import React from 'react';
import { RootNavigator } from './src/navigation/RootNavigator';
import { UserProvider } from './src/contexts/UserContext';

export default function App() {
  return (
    <UserProvider>
      <RootNavigator />
    </UserProvider>
  );
}
