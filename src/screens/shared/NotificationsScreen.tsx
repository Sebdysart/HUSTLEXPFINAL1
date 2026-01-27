/**
 * NotificationsScreen - Notification center
 * 
 * Archetype: Interrupt
 * Emotion: "The system has this under control"
 * - Grouped by type/time
 * - Read/unread subtle (not alarming)
 * - Tap to navigate to source
 * - Clear all available
 * - Calm, organized, neutral
 */

import React, { useState, useCallback } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HCard, HText, HButton } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

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
  { id: '4', type: 'system', title: 'You reached Trust Tier 3', body: 'New opportunities unlocked', time: '2d ago', read: true },
  { id: '5', type: 'task', title: 'Task accepted', body: 'Sarah accepted your task', time: '3d ago', read: true, taskId: 'task_2' },
  { id: '6', type: 'message', title: 'New message', body: 'John: "On my way now"', time: '3d ago', read: true, taskId: 'task_2' },
];

const ICONS: Record<string, string> = {
  task: '📋',
  payment: '💵',
  rating: '⭐',
  system: '✨',
  message: '💬',
};

export function NotificationsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);
  const [refreshing, setRefreshing] = useState(false);

  const handleBack = () => navigation.goBack();

  const handleMarkAllRead = useCallback(() => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  }, []);

  const handleNotificationPress = useCallback((notif: Notification) => {
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
  }, [navigation]);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 500));
    setRefreshing(false);
  }, []);

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <HScreen ambient={false}>
      {/* Header - calm, organized */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.sm }]}>
        <HButton variant="ghost" size="sm" onPress={handleBack}>
          ← Back
        </HButton>
        <HText variant="title2" color="primary">Notifications</HText>
        <HButton 
          variant="ghost" 
          size="sm" 
          onPress={handleMarkAllRead}
          disabled={unreadCount === 0}
        >
          {unreadCount > 0 ? 'Mark read' : ''}
        </HButton>
      </View>

      {/* Unread indicator - subtle, not alarming */}
      {unreadCount > 0 && (
        <View style={styles.unreadBanner}>
          <HText variant="caption" color="secondary">
            {unreadCount} new {unreadCount === 1 ? 'notification' : 'notifications'}
          </HText>
        </View>
      )}

      <ScrollView 
        style={styles.scrollContainer}
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl 
            refreshing={refreshing} 
            onRefresh={handleRefresh} 
            tintColor={hustleColors.purple.soft} 
          />
        }
      >
        {notifications.length === 0 ? (
          <View style={styles.empty}>
            <HText variant="title2" center>🔔</HText>
            <HText variant="body" color="secondary" center style={styles.emptyText}>
              All caught up
            </HText>
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
    </HScreen>
  );
}

interface NotificationItemProps {
  notification: Notification;
  onPress: () => void;
}

function NotificationItem({ notification, onPress }: NotificationItemProps) {
  const { type, title, body, time, read } = notification;

  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
      <HCard 
        variant={read ? 'default' : 'elevated'} 
        padding="md" 
        style={styles.notifCard}
      >
        <View style={styles.notifRow}>
          <View style={styles.notifIcon}>
            <HText variant="title3">{ICONS[type] || '📢'}</HText>
          </View>
          <View style={styles.notifContent}>
            <View style={styles.notifHeader}>
              <HText variant="headline" color="primary">{title}</HText>
              <HText variant="caption" color="tertiary">{time}</HText>
            </View>
            <HText variant="body" color="secondary" numberOfLines={1}>
              {body}
            </HText>
          </View>
          {!read && <View style={styles.unreadDot} />}
        </View>
      </HCard>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  unreadBanner: {
    paddingVertical: hustleSpacing.sm,
    paddingHorizontal: hustleSpacing.lg,
  },
  scrollContainer: {
    flex: 1,
  },
  scroll: { 
    paddingHorizontal: hustleSpacing.lg, 
    paddingBottom: hustleSpacing['2xl'],
  },
  empty: { 
    alignItems: 'center', 
    paddingTop: 100,
  },
  emptyText: {
    marginTop: hustleSpacing.md,
  },
  notifCard: {
    marginBottom: hustleSpacing.sm,
  },
  notifRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  notifIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  notifContent: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  notifHeader: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
    marginBottom: hustleSpacing.xs,
  },
  unreadDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: hustleColors.purple.soft,
    marginLeft: hustleSpacing.sm,
  },
});

export default NotificationsScreen;
