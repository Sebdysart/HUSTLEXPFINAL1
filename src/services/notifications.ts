/**
 * Push Notification Service
 * 
 * Handles local and remote push notifications
 * Ready for Firebase Cloud Messaging integration
 */

import { Platform, PermissionsAndroid, Alert } from 'react-native';

// Notification types
export type NotificationType = 
  | 'task_nearby'
  | 'task_claimed'
  | 'task_completed'
  | 'payment_received'
  | 'review_received'
  | 'message'
  | 'xp_milestone'
  | 'trust_tier_change';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  timestamp: Date;
  read: boolean;
}

export interface NotificationPermission {
  granted: boolean;
  canAsk: boolean;
}

// Notification handlers
type NotificationHandler = (notification: Notification) => void;
type TokenHandler = (token: string) => void;

class NotificationService {
  private handlers: NotificationHandler[] = [];
  private tokenHandlers: TokenHandler[] = [];
  private fcmToken: string | null = null;
  private isInitialized = false;

  /**
   * Initialize notification service
   * Call this early in app lifecycle
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) return;

    try {
      // Request permissions
      const permission = await this.requestPermission();
      
      if (!permission.granted) {
        console.log('Push notification permission not granted');
        return;
      }

      // TODO: Initialize Firebase Messaging here
      // import messaging from '@react-native-firebase/messaging';
      // await messaging().registerDeviceForRemoteMessages();
      // this.fcmToken = await messaging().getToken();

      // For now, generate a mock token for development
      this.fcmToken = `mock-fcm-token-${Date.now()}`;
      
      // Notify token handlers
      this.tokenHandlers.forEach(handler => {
        if (this.fcmToken) handler(this.fcmToken);
      });

      this.isInitialized = true;
      console.log('Notification service initialized');
    } catch (error) {
      console.error('Failed to initialize notifications:', error);
    }
  }

  /**
   * Request notification permissions
   */
  async requestPermission(): Promise<NotificationPermission> {
    if (Platform.OS === 'ios') {
      // iOS permissions handled by Firebase
      // TODO: Use @react-native-firebase/messaging
      return { granted: true, canAsk: true };
    }

    if (Platform.OS === 'android') {
      // Android 13+ requires explicit permission
      if (Platform.Version >= 33) {
        try {
          const result = await PermissionsAndroid.request(
            PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS
          );
          return {
            granted: result === PermissionsAndroid.RESULTS.GRANTED,
            canAsk: result !== PermissionsAndroid.RESULTS.NEVER_ASK_AGAIN,
          };
        } catch (error) {
          console.error('Permission request failed:', error);
          return { granted: false, canAsk: false };
        }
      }
      // Android < 13 doesn't need explicit permission
      return { granted: true, canAsk: true };
    }

    return { granted: false, canAsk: false };
  }

  /**
   * Check current permission status
   */
  async checkPermission(): Promise<NotificationPermission> {
    if (Platform.OS === 'android' && Platform.Version >= 33) {
      const result = await PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS
      );
      return { granted: result, canAsk: true };
    }
    return { granted: true, canAsk: true };
  }

  /**
   * Get the FCM token for sending push notifications
   */
  getToken(): string | null {
    return this.fcmToken;
  }

  /**
   * Subscribe to new notification events
   */
  onNotification(handler: NotificationHandler): () => void {
    this.handlers.push(handler);
    return () => {
      const index = this.handlers.indexOf(handler);
      if (index > -1) this.handlers.splice(index, 1);
    };
  }

  /**
   * Subscribe to token refresh events
   */
  onTokenRefresh(handler: TokenHandler): () => void {
    this.tokenHandlers.push(handler);
    // Call immediately if token exists
    if (this.fcmToken) handler(this.fcmToken);
    return () => {
      const index = this.tokenHandlers.indexOf(handler);
      if (index > -1) this.tokenHandlers.splice(index, 1);
    };
  }

  /**
   * Display a local notification
   */
  async showLocalNotification(
    title: string,
    body: string,
    data?: Record<string, unknown>
  ): Promise<void> {
    // TODO: Use @notifee/react-native for local notifications
    // For now, use Alert as fallback
    Alert.alert(title, body);

    // Create notification object
    const notification: Notification = {
      id: `local-${Date.now()}`,
      type: (data?.type as NotificationType) || 'message',
      title,
      body,
      data,
      timestamp: new Date(),
      read: false,
    };

    // Notify handlers
    this.handlers.forEach(handler => handler(notification));
  }

  /**
   * Schedule a local notification
   */
  async scheduleNotification(
    title: string,
    body: string,
    triggerDate: Date,
    _data?: Record<string, unknown>
  ): Promise<string> {
    // TODO: Use @notifee/react-native for scheduling
    const id = `scheduled-${Date.now()}`;
    console.log(`Scheduled notification ${id} for ${triggerDate.toISOString()}`);
    return id;
  }

  /**
   * Cancel a scheduled notification
   */
  async cancelNotification(notificationId: string): Promise<void> {
    // TODO: Implement with @notifee/react-native
    console.log(`Cancelled notification ${notificationId}`);
  }

  /**
   * Cancel all notifications
   */
  async cancelAllNotifications(): Promise<void> {
    // TODO: Implement with @notifee/react-native
    console.log('Cancelled all notifications');
  }

  /**
   * Get notification badge count (iOS)
   */
  async getBadgeCount(): Promise<number> {
    // TODO: Implement with @notifee/react-native
    return 0;
  }

  /**
   * Set notification badge count (iOS)
   */
  async setBadgeCount(count: number): Promise<void> {
    // TODO: Implement with @notifee/react-native
    console.log(`Set badge count to ${count}`);
  }

  /**
   * Process incoming remote notification
   * Called by Firebase message handler
   */
  handleRemoteNotification(message: {
    notification?: { title?: string; body?: string };
    data?: Record<string, string>;
  }): void {
    const notification: Notification = {
      id: `remote-${Date.now()}`,
      type: (message.data?.type as NotificationType) || 'message',
      title: message.notification?.title || 'New Notification',
      body: message.notification?.body || '',
      data: message.data,
      timestamp: new Date(),
      read: false,
    };

    this.handlers.forEach(handler => handler(notification));
  }
}

// Singleton instance
export const notificationService = new NotificationService();

// Helper to get notification display config by type
export function getNotificationConfig(type: NotificationType): { icon: string; color: string } {
  const configs: Record<NotificationType, { icon: string; color: string }> = {
    task_nearby: { icon: '📍', color: '#FF9500' },
    task_claimed: { icon: '✅', color: '#34C759' },
    task_completed: { icon: '🎉', color: '#5856D6' },
    payment_received: { icon: '💰', color: '#34C759' },
    review_received: { icon: '⭐', color: '#FFD60A' },
    message: { icon: '💬', color: '#5856D6' },
    xp_milestone: { icon: '🏆', color: '#FF9500' },
    trust_tier_change: { icon: '🛡️', color: '#5856D6' },
  };
  return configs[type] || { icon: '🔔', color: '#8E8E93' };
}
