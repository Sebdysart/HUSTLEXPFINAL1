import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import PosterHomeScreen from '../screens/poster/PosterHomeScreen';
import TaskCreationScreen from '../screens/poster/TaskCreationScreen';
import ActiveTasksScreen from '../screens/poster/ActiveTasksScreen';
import PosterProfileScreen from '../screens/poster/PosterProfileScreen';

const Tab = createBottomTabNavigator();

export default function PosterTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={PosterHomeScreen} />
      <Tab.Screen name="Create" component={TaskCreationScreen} />
      <Tab.Screen name="Active" component={ActiveTasksScreen} />
      <Tab.Screen name="Profile" component={PosterProfileScreen} />
    </Tab.Navigator>
  );
}
