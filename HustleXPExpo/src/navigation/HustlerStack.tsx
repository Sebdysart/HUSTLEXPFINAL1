import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HustlerTabs from './HustlerTabs';
import TaskDetailScreen from '../screens/shared/TaskDetailScreen';
import TaskInProgressScreen from '../screens/hustler/TaskInProgressScreen';
import TaskCompletionScreen from '../screens/hustler/TaskCompletionScreen';
import HustlerEnRouteMapScreen from '../screens/hustler/HustlerEnRouteMapScreen';
import XPBreakdownScreen from '../screens/hustler/XPBreakdownScreen';
import InstantInterruptCard from '../screens/hustler/InstantInterruptCard';

const Stack = createNativeStackNavigator();

export default function HustlerStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="HustlerTabs"
        component={HustlerTabs}
        options={{ headerShown: false }}
      />
      <Stack.Screen name="TaskDetail" component={TaskDetailScreen} />
      <Stack.Screen name="TaskInProgress" component={TaskInProgressScreen} />
      <Stack.Screen name="TaskCompletion" component={TaskCompletionScreen} />
      <Stack.Screen name="HustlerEnRouteMap" component={HustlerEnRouteMapScreen} />
      <Stack.Screen name="XPBreakdown" component={XPBreakdownScreen} />
      <Stack.Screen name="InstantInterrupt" component={InstantInterruptCard} />
    </Stack.Navigator>
  );
}
