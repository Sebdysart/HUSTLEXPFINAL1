import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAppState } from '../app/state';

import SettingsStack from './SettingsStack';

import HustlerHomeScreen from '../screens/hustler/HustlerHomeScreen';
import TaskFeedScreen from '../screens/hustler/TaskFeedScreen';
import TaskHistoryScreen from '../screens/hustler/TaskHistoryScreen';
import TaskDetailScreen from '../screens/shared/TaskDetailScreen';
import TaskInProgressScreen from '../screens/hustler/TaskInProgressScreen';
import ProofSubmissionScreen from '../screens/shared/ProofSubmissionScreen';
import TaskCompletionScreen from '../screens/hustler/TaskCompletionScreen';

import PosterHomeScreen from '../screens/poster/PosterHomeScreen';
import ActiveTasksScreen from '../screens/poster/ActiveTasksScreen';
import PosterHistoryScreen from '../screens/poster/PosterHistoryScreen';
import TaskCreationScreen from '../screens/poster/TaskCreationScreen';

const Tab = createBottomTabNavigator();

const Stack = createNativeStackNavigator();

function HustlerFeedStack() {
  return (
    <Stack.Navigator initialRouteName="TaskFeed" screenOptions={{ headerShown: false }}>
      <Stack.Screen name="TaskFeed" component={TaskFeedScreen} />
      <Stack.Screen name="TaskDetail" component={TaskDetailScreen} />
      <Stack.Screen name="TaskInProgress" component={TaskInProgressScreen} />
      <Stack.Screen name="ProofSubmission" component={ProofSubmissionScreen} />
      <Stack.Screen name="TaskCompletion" component={TaskCompletionScreen} />
    </Stack.Navigator>
  );
}

function PosterHomeStack() {
  return (
    <Stack.Navigator initialRouteName="PosterHome" screenOptions={{ headerShown: false }}>
      <Stack.Screen name="PosterHome" component={PosterHomeScreen} />
      {/* Only wiring create-task entrypoint for now */}
      <Stack.Screen name="TaskCreation" component={TaskCreationScreen} />
    </Stack.Navigator>
  );
}

export default function MainTabs() {
  const { userRole } = useAppState();

  const role = userRole ?? 'hustler';

  if (role === 'poster') {
    return (
      <Tab.Navigator screenOptions={{ headerShown: false }}>
        <Tab.Screen name="Home" component={PosterHomeStack} />
        <Tab.Screen name="Active" component={ActiveTasksScreen} />
        <Tab.Screen name="History" component={PosterHistoryScreen} />
        <Tab.Screen name="Settings" component={SettingsStack} />
      </Tab.Navigator>
    );
  }

  return (
    <Tab.Navigator screenOptions={{ headerShown: false }}>
      <Tab.Screen name="Home" component={HustlerHomeScreen} />
      <Tab.Screen name="Feed" component={HustlerFeedStack} />
      <Tab.Screen name="History" component={TaskHistoryScreen} />
      <Tab.Screen name="Settings" component={SettingsStack} />
    </Tab.Navigator>
  );
}

