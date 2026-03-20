import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import TaskConversationScreen from '../screens/shared/TaskConversationScreen';
import TaskDetailScreen from '../screens/shared/TaskDetailScreen';
import ProofSubmissionScreen from '../screens/shared/ProofSubmissionScreen';
import DisputeScreen from '../screens/shared/DisputeScreen';
import NoTasksAvailableScreen from '../screens/edge/NoTasksAvailableScreen';
import EligibilityMismatchScreen from '../screens/edge/EligibilityMismatchScreen';
import NetworkErrorScreen from '../screens/edge/NetworkErrorScreen';
import MaintenanceScreen from '../screens/edge/MaintenanceScreen';
import ForceUpdateScreen from '../screens/edge/ForceUpdateScreen';

const Stack = createNativeStackNavigator();

export default function SharedModalStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="TaskConversation" component={TaskConversationScreen} />
      <Stack.Screen name="TaskDetail" component={TaskDetailScreen} />
      <Stack.Screen name="ProofSubmission" component={ProofSubmissionScreen} />
      <Stack.Screen name="Dispute" component={DisputeScreen} />
      <Stack.Screen name="NoTasksAvailable" component={NoTasksAvailableScreen} />
      <Stack.Screen name="EligibilityMismatch" component={EligibilityMismatchScreen} />
      <Stack.Screen name="NetworkError" component={NetworkErrorScreen} />
      <Stack.Screen name="Maintenance" component={MaintenanceScreen} />
      <Stack.Screen name="ForceUpdate" component={ForceUpdateScreen} />
    </Stack.Navigator>
  );
}
