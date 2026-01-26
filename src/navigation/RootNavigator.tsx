/**
 * Root Navigator - Main navigation structure for HustleXP
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View, StyleSheet } from 'react-native';
import { RootStackParamList, MainTabParamList } from './types';

// Auth screens
import { BootstrapScreen } from '../screens/BootstrapScreen';
import { LoginScreen } from '../screens/LoginScreen';
import { SignupScreen } from '../screens/SignupScreen';
import { ForgotPasswordScreen } from '../screens/ForgotPasswordScreen';

// Onboarding screens
import { FramingScreen } from '../screens/onboarding/FramingScreen';
import { RoleConfirmationScreen } from '../screens/onboarding/RoleConfirmationScreen';
import { CapabilityLocationScreen } from '../screens/onboarding/CapabilityLocationScreen';
import { CapabilityVehicleScreen } from '../screens/onboarding/CapabilityVehicleScreen';
import { CapabilitySkillsScreen } from '../screens/onboarding/CapabilitySkillsScreen';
import { CapabilityTradesScreen } from '../screens/onboarding/CapabilityTradesScreen';
import { CapabilityToolsScreen } from '../screens/onboarding/CapabilityToolsScreen';
import { CapabilityInsuranceScreen } from '../screens/onboarding/CapabilityInsuranceScreen';
import { CapabilityBackgroundScreen } from '../screens/onboarding/CapabilityBackgroundScreen';
import { CapabilityAvailabilityScreen } from '../screens/onboarding/CapabilityAvailabilityScreen';
import { PreferenceLockScreen } from '../screens/onboarding/PreferenceLockScreen';
import { CalibrationScreen } from '../screens/onboarding/CalibrationScreen';
import { OnboardingCompleteScreen } from '../screens/onboarding/OnboardingCompleteScreen';

// Hustler screens
import { HustlerHomeScreen } from '../screens/hustler/HustlerHomeScreen';
import { TaskFeedScreen } from '../screens/hustler/TaskFeedScreen';
import { TaskDetailScreen } from '../screens/hustler/TaskDetailScreen';
import { TaskInProgressScreen } from '../screens/hustler/TaskInProgressScreen';
import { TaskCompletionHustlerScreen } from '../screens/hustler/TaskCompletionHustlerScreen';
import { HustlerEnRouteMapScreen } from '../screens/hustler/HustlerEnRouteMapScreen';
import { EarningsScreen } from '../screens/hustler/EarningsScreen';
import { XPBreakdownScreen } from '../screens/hustler/XPBreakdownScreen';
import { ProfileScreen } from '../screens/hustler/ProfileScreen';
import { TaskHistoryScreen } from '../screens/hustler/TaskHistoryScreen';
// InstantInterruptCard is a modal component, used inline not as a screen

// Poster screens
import { PosterHomeScreen } from '../screens/poster/PosterHomeScreen';
import { TaskCreationScreen } from '../screens/poster/TaskCreationScreen';
import { TaskReviewScreen } from '../screens/poster/TaskReviewScreen';
import { HustlerOnWayScreen } from '../screens/poster/HustlerOnWayScreen';
import { TaskCompletionPosterScreen } from '../screens/poster/TaskCompletionPosterScreen';
import { FeedbackScreen } from '../screens/poster/FeedbackScreen';

// Shared screens
import { ChatScreen } from '../screens/shared/ChatScreen';
import { TaskConversationScreen } from '../screens/shared/TaskConversationScreen';
import { NotificationsScreen } from '../screens/shared/NotificationsScreen';
import { TrustTierLadderScreen } from '../screens/shared/TrustTierLadderScreen';
import { TrustChangeExplanationScreen } from '../screens/shared/TrustChangeExplanationScreen';
import { TrustTierLockedScreen } from '../screens/shared/TrustTierLockedScreen';
import { EligibilityMismatchScreen } from '../screens/shared/EligibilityMismatchScreen';
import { DisputeEntryScreen } from '../screens/shared/DisputeEntryScreen';
import { NoTasksAvailableScreen } from '../screens/shared/NoTasksAvailableScreen';

// Settings screens
import { SettingsScreen } from '../screens/settings/SettingsScreen';
import { WalletScreen } from '../screens/settings/WalletScreen';
import { WorkEligibilityScreen } from '../screens/settings/WorkEligibilityScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

// Tab icon component
const TabIcon: React.FC<{ name: string; focused: boolean }> = ({ name, focused }) => (
  <View style={[styles.tabIcon, focused && styles.tabIconFocused]}>
    <Text style={[styles.tabIconText, focused && styles.tabIconTextFocused]}>
      {name.charAt(0)}
    </Text>
  </View>
);

// Main tab navigator
function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: styles.tabBar,
        tabBarActiveTintColor: '#FACC15',
        tabBarInactiveTintColor: '#6B7280',
        tabBarLabelStyle: styles.tabLabel,
      }}
    >
      <Tab.Screen
        name="HustlerTab"
        component={HustlerHomeScreen}
        options={{
          tabBarLabel: 'Hustle',
          tabBarIcon: ({ focused }) => <TabIcon name="Hustle" focused={focused} />,
        }}
      />
      <Tab.Screen
        name="PosterTab"
        component={PosterHomeScreen}
        options={{
          tabBarLabel: 'Post',
          tabBarIcon: ({ focused }) => <TabIcon name="Post" focused={focused} />,
        }}
      />
      <Tab.Screen
        name="EarningsTab"
        component={EarningsScreen}
        options={{
          tabBarLabel: 'Earnings',
          tabBarIcon: ({ focused }) => <TabIcon name="Earnings" focused={focused} />,
        }}
      />
      <Tab.Screen
        name="ProfileTab"
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
          tabBarIcon: ({ focused }) => <TabIcon name="Profile" focused={focused} />,
        }}
      />
    </Tab.Navigator>
  );
}

// Root navigator with all screens
export function RootNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#0F0F0F' },
        animation: 'slide_from_right',
      }}
    >
      {/* Auth flow */}
      <Stack.Screen name="Bootstrap" component={BootstrapScreen} />
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Signup" component={SignupScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />

      {/* Onboarding flow */}
      <Stack.Screen name="Framing" component={FramingScreen} />
      <Stack.Screen name="RoleConfirmation" component={RoleConfirmationScreen} />
      <Stack.Screen name="CapabilityLocation" component={CapabilityLocationScreen} />
      <Stack.Screen name="CapabilityVehicle" component={CapabilityVehicleScreen} />
      <Stack.Screen name="CapabilitySkills" component={CapabilitySkillsScreen} />
      <Stack.Screen name="CapabilityTrades" component={CapabilityTradesScreen} />
      <Stack.Screen name="CapabilityTools" component={CapabilityToolsScreen} />
      <Stack.Screen name="CapabilityInsurance" component={CapabilityInsuranceScreen} />
      <Stack.Screen name="CapabilityBackground" component={CapabilityBackgroundScreen} />
      <Stack.Screen name="CapabilityAvailability" component={CapabilityAvailabilityScreen} />
      <Stack.Screen name="PreferenceLock" component={PreferenceLockScreen} />
      <Stack.Screen name="Calibration" component={CalibrationScreen} />
      <Stack.Screen name="OnboardingComplete" component={OnboardingCompleteScreen} />

      {/* Main tabs */}
      <Stack.Screen name="MainTabs" component={MainTabs} />

      {/* Hustler screens */}
      <Stack.Screen name="HustlerHome" component={HustlerHomeScreen} />
      <Stack.Screen name="TaskFeed" component={TaskFeedScreen} />
      <Stack.Screen name="TaskDetail" component={TaskDetailScreen} />
      <Stack.Screen name="TaskInProgress" component={TaskInProgressScreen} />
      <Stack.Screen name="TaskCompletionHustler" component={TaskCompletionHustlerScreen} />
      <Stack.Screen name="HustlerEnRouteMap" component={HustlerEnRouteMapScreen} />
      <Stack.Screen name="Earnings" component={EarningsScreen} />
      <Stack.Screen name="XPBreakdown" component={XPBreakdownScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
      <Stack.Screen name="TaskHistory" component={TaskHistoryScreen} />
      {/* InstantInterruptCard is rendered as a modal overlay, not a screen */}

      {/* Poster screens */}
      <Stack.Screen name="PosterHome" component={PosterHomeScreen} />
      <Stack.Screen name="TaskCreation" component={TaskCreationScreen} />
      <Stack.Screen name="TaskReview" component={TaskReviewScreen} />
      <Stack.Screen name="HustlerOnWay" component={HustlerOnWayScreen} />
      <Stack.Screen name="TaskCompletionPoster" component={TaskCompletionPosterScreen} />
      <Stack.Screen name="Feedback" component={FeedbackScreen} />

      {/* Shared screens */}
      <Stack.Screen name="Chat" component={ChatScreen} />
      <Stack.Screen name="TaskConversation" component={TaskConversationScreen} />
      <Stack.Screen name="Notifications" component={NotificationsScreen} />
      <Stack.Screen name="TrustTierLadder" component={TrustTierLadderScreen} />
      <Stack.Screen name="TrustChangeExplanation" component={TrustChangeExplanationScreen} />
      <Stack.Screen name="TrustTierLocked" component={TrustTierLockedScreen} />
      <Stack.Screen name="EligibilityMismatch" component={EligibilityMismatchScreen} />
      <Stack.Screen name="DisputeEntry" component={DisputeEntryScreen} />
      <Stack.Screen name="NoTasksAvailable" component={NoTasksAvailableScreen} />

      {/* Settings screens */}
      <Stack.Screen name="Settings" component={SettingsScreen} />
      <Stack.Screen name="Wallet" component={WalletScreen} />
      <Stack.Screen name="WorkEligibility" component={WorkEligibilityScreen} />
    </Stack.Navigator>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: '#1A1A1A',
    borderTopColor: '#2A2A2A',
    borderTopWidth: 1,
    paddingTop: 8,
    height: 80,
  },
  tabLabel: {
    fontSize: 12,
    fontWeight: '600',
    marginTop: 4,
  },
  tabIcon: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#2A2A2A',
    alignItems: 'center',
    justifyContent: 'center',
  },
  tabIconFocused: {
    backgroundColor: '#FACC15',
  },
  tabIconText: {
    color: '#6B7280',
    fontSize: 14,
    fontWeight: '700',
  },
  tabIconTextFocused: {
    color: '#0F0F0F',
  },
});
