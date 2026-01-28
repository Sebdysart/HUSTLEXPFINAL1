/**
 * useNotifications Hook
 * 
 * React hook for managing push notifications
 */

import { useEffect, useState, useCallback } from 'react';
import {
  notificationService,
  Notification,
  NotificationPermission,
} from '../services/notifications';

interface UseNotificationsResult {
  /** Push token for backend registration */
  token: string | null;
  /** Current permission status */
  permission: NotificationPermission | null;
  /** Unread notifications */
  notifications: Notification[];
  /** Unread count */
  unreadCount: number;
  /** Request notification permissions */
  requestPermission: () => Promise<NotificationPermission>;
  /** Clear a notification */
  clearNotification: (id: string) => void;
  /** Clear all notifications */
  clearAllNotifications: () => void;
  /** Mark notification as read */
  markAsRead: (id: string) => void;
  /** Show a local notification */
  showNotification: (title: string, body: string, data?: Record<string, unknown>) => void;
}

export function useNotifications(): UseNotificationsResult {
  const [token, setToken] = useState<string | null>(null);
  const [permission, setPermission] = useState<NotificationPermission | null>(null);
  const [notifications, setNotifications] = useState<Notification[]>([]);

  // Initialize and subscribe to notifications
  useEffect(() => {
    // Initialize service
    notificationService.initialize();

    // Subscribe to token updates
    const unsubToken = notificationService.onTokenRefresh((newToken) => {
      setToken(newToken);
    });

    // Subscribe to notifications
    const unsubNotif = notificationService.onNotification((notification) => {
      setNotifications((prev) => [notification, ...prev].slice(0, 50)); // Keep last 50
    });

    // Check initial permission
    notificationService.checkPermission().then(setPermission);

    return () => {
      unsubToken();
      unsubNotif();
    };
  }, []);

  const requestPermission = useCallback(async () => {
    const result = await notificationService.requestPermission();
    setPermission(result);
    return result;
  }, []);

  const clearNotification = useCallback((id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  }, []);

  const clearAllNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  const markAsRead = useCallback((id: string) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  }, []);

  const showNotification = useCallback(
    (title: string, body: string, data?: Record<string, unknown>) => {
      notificationService.showLocalNotification(title, body, data);
    },
    []
  );

  const unreadCount = notifications.filter((n) => !n.read).length;

  return {
    token,
    permission,
    notifications,
    unreadCount,
    requestPermission,
    clearNotification,
    clearAllNotifications,
    markAsRead,
    showNotification,
  };
}

export default useNotifications;
