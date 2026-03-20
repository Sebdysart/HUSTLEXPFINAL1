import type { ProcedureType } from './trpcClient';

type Key = `${string}:${ProcedureType}`;

// Minimal web-preview mocks to avoid CORS blockers when running Expo Web.
// Native iOS continues to use the real backend via TRPCClient.

export function webMockCall(path: string, type: ProcedureType, input: any): any | undefined {
  const key: Key = `${path}:${type}`;

  switch (key) {
    // Notifications
    case 'notification.getPreferences:query':
      return {
        pushEnabled: true,
        emailEnabled: true,
        taskUpdates: true,
        paymentUpdates: true,
        messageNotifications: true,
        marketingEmails: false,
      };
    case 'notification.updatePreferences:mutation':
      return {};

    // User onboarding status (so RootNavigator gating doesn't break on web)
    case 'user.getOnboardingStatus:query':
      return { hasCompletedOnboarding: true };

    // Messaging (basic)
    case 'messaging.getTaskMessages:query':
      return [];
    case 'messaging.sendMessage:mutation':
      return { id: `web-msg-${Date.now()}`, senderName: 'You', content: input?.content ?? '', timestamp: new Date().toISOString() };
    case 'messaging.markAllAsRead:mutation':
      return {};

    default:
      return undefined;
  }
}

