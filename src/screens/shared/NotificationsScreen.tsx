/**
 * NotificationsScreen - Notification center
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing } from '../../components';
import { theme } from '../../theme';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface Notification {
  id: string;
  type: 'task' | 'payment' | 'rating' | 'system' | 'message';
  title: string;
  body: string;
  time: string;
  read: boolean;
  taskId?: string;
}

const MOCK_NOTIFICATIONS: Notification[] = [
  { id: '1', type: 'task', title: 'New task nearby', body: 'Help moving furniture - $75', time: '5m ago', read: false, taskId: 'task_1' },
  { id: '2', type: 'payment', title: 'Payment received', body: '$65 for Furniture assembly', time: '2h ago', read: false },
  { id: '3', type: 'rating', title: 'New 5-star review', body: '"Great job! Very careful..."', time: '1d ago', read: true },
  { id: '4', type: 'system', title: 'Level up!', body: 'You reached Trust Tier 3', time: '2d ago', read: true },
  { id: '5', type: 'task', title: 'Task accepted', body: 'Sarah accepted your task', time: '3d ago', read: true, taskId: 'task_2' },
  { id: '6', type: 'message', title: 'New message', body: 'John: "On my way now!"', time: '3d ago', read: true, taskId: 'task_2' },
];

export function NotificationsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);
  const [refreshing, setRefreshing] = useState(false);

  const handleBack = () => navigation.goBack();

  const handleMarkAllRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  const handleNotificationPress = (notif: Notification) => {
    // Mark as read
    setNotifications(prev => prev.map(n => 
      n.id === notif.id ? { ...n, read: true } : n
    ));

    // Navigate based on type
    switch (notif.type) {
      case 'task':
        if (notif.taskId) {
          navigation.navigate('TaskDetail', { taskId: notif.taskId });
        } else {
          navigation.navigate('TaskFeed');
        }
        break;
      case 'payment':
        navigation.navigate('Earnings');
        break;
      case 'rating':
        navigation.navigate('Profile');
        break;
      case 'system':
        navigation.navigate('XPBreakdown');
        break;
      case 'message':
        if (notif.taskId) {
          navigation.navigate('TaskConversation', { taskId: notif.taskId });
        }
        break;
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 500));
    setRefreshing(false);
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleBack}>
          <Text variant="body" color="primary">← Back</Text>
        </TouchableOpacity>
        <Text variant="title2" color="primary">Notifications</Text>
        <TouchableOpacity onPress={handleMarkAllRead} disabled={unreadCount === 0}>
          <Text variant="body" color={unreadCount > 0 ? 'brand' : 'tertiary'}>
            Mark all read
          </Text>
        </TouchableOpacity>
      </View>

      {unreadCount > 0 && (
        <View style={styles.unreadBanner}>
          <Text variant="caption" color="inverse">{unreadCount} unread</Text>
        </View>
      )}

      <ScrollView 
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} tintColor={theme.colors.brand.primary} />
        }
      >
        {notifications.length === 0 ? (
          <View style={styles.empty}>
            <Text variant="title2">🔔</Text>
            <Spacing size={12} />
            <Text variant="body" color="secondary" align="center">No notifications yet</Text>
          </View>
        ) : (
          notifications.map(notif => (
            <NotificationItem 
              key={notif.id} 
              notification={notif}
              onPress={() => handleNotificationPress(notif)}
            />
          ))
        )}
      </ScrollView>
    </View>
  );
}

interface NotificationItemProps {
  notification: Notification;
  onPress: () => void;
}

function NotificationItem({ notification, onPress }: NotificationItemProps) {
  const { type, title, body, time, read } = notification;
  
  const icons: Record<string, string> = {
    task: '📋',
    payment: '💰',
    rating: '⭐',
    system: '🎉',
    message: '💬',
  };

  return (
    <TouchableOpacity 
      style={[styles.notif, !read && styles.notifUnread]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.notifIcon}>
        <Text variant="title2">{icons[type] || '📢'}</Text>
      </View>
      <View style={styles.notifContent}>
        <View style={styles.notifHeader}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="caption" color="tertiary">{time}</Text>
        </View>
        <Text variant="body" color="secondary" numberOfLines={1}>{body}</Text>
      </View>
      {!read && <View style={styles.unreadDot} />}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    padding: theme.spacing[4],
  },
  unreadBanner: {
    backgroundColor: theme.colors.brand.primary,
    paddingVertical: theme.spacing[1],
    alignItems: 'center',
  },
  scroll: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
  empty: { 
    alignItems: 'center', 
    paddingTop: 100,
  },
  notif: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: theme.spacing[4],
    backgroundColor: theme.colors.surface.primary,
    borderRadius: theme.radii.md,
    marginBottom: theme.spacing[2],
  },
  notifUnread: {
    backgroundColor: theme.colors.surface.secondary,
  },
  notifIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: theme.colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  notifContent: { flex: 1, marginLeft: theme.spacing[3] },
  notifHeader: { flexDirection: 'row', justifyContent: 'space-between' },
  unreadDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: theme.colors.brand.primary,
  },
});

export default NotificationsScreen;
