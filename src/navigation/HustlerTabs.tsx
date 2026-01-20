import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { HustlerHomeScreen } from '../screens/hustler/HustlerHomeScreen';
import { TaskFeedScreen } from '../screens/hustler/TaskFeedScreen';
import { TaskHistoryScreen } from '../screens/hustler/TaskHistoryScreen';
import { HustlerProfileScreen } from '../screens/hustler/HustlerProfileScreen';

const Tab = createBottomTabNavigator();

export function HustlerTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HustlerHomeScreen} />
      <Tab.Screen name="Feed" component={TaskFeedScreen} />
      <Tab.Screen name="History" component={TaskHistoryScreen} />
      <Tab.Screen name="Profile" component={HustlerProfileScreen} />
    </Tab.Navigator>
  );
}
