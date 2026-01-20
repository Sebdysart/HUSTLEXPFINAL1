import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { HustlerTabs } from './HustlerTabs';
import { PosterTabs } from './PosterTabs';
import { SettingsStack } from './SettingsStack';

const Tab = createBottomTabNavigator();

export function MainTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Hustler" component={HustlerTabs} />
      <Tab.Screen name="Poster" component={PosterTabs} />
      <Tab.Screen name="Settings" component={SettingsStack} />
    </Tab.Navigator>
  );
}
