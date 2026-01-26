/**
 * Navigation types for HustleXP
 */

export type RootStackParamList = {
  // Bootstrap & Auth
  Bootstrap: undefined;
  Login: undefined;
  Signup: undefined;
  ForgotPassword: undefined;
  
  // Onboarding flow
  Framing: undefined;
  RoleConfirmation: { role?: 'hustler' | 'poster' };
  CapabilityLocation: undefined;
  CapabilityVehicle: undefined;
  CapabilitySkills: undefined;
  CapabilityTrades: undefined;
  CapabilityTools: undefined;
  CapabilityInsurance: undefined;
  CapabilityBackground: undefined;
  CapabilityAvailability: undefined;
  PreferenceLock: undefined;
  Calibration: undefined;
  OnboardingComplete: undefined;
  
  // Main tabs
  MainTabs: undefined;
  
  // Hustler screens
  HustlerHome: undefined;
  TaskFeed: undefined;
  TaskDetail: { taskId: string };
  TaskInProgress: { taskId: string };
  TaskCompletionHustler: { taskId: string };
  HustlerEnRouteMap: { taskId: string };
  Earnings: undefined;
  XPBreakdown: undefined;
  Profile: undefined;
  TaskHistory: undefined;
  
  // Poster screens
  PosterHome: undefined;
  TaskCreation: undefined;
  TaskReview: { taskId: string };
  HustlerOnWay: { taskId: string };
  TaskCompletionPoster: { taskId: string };
  Feedback: { taskId: string };
  
  // Shared screens
  Chat: { conversationId: string };
  TaskConversation: { taskId: string };
  Notifications: undefined;
  TrustTierLadder: undefined;
  TrustChangeExplanation: { change: 'up' | 'down'; reason: string };
  TrustTierLocked: { feature: string };
  EligibilityMismatch: { taskId: string };
  DisputeEntry: { taskId: string };
  NoTasksAvailable: undefined;
  
  // Settings
  Settings: undefined;
  Wallet: undefined;
  WorkEligibility: undefined;
};

export type MainTabParamList = {
  HustlerTab: undefined;
  PosterTab: undefined;
  EarningsTab: undefined;
  ProfileTab: undefined;
};

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
