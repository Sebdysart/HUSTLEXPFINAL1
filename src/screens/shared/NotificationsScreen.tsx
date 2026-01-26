/**
 * NotificationsScreen - Notification center
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';

const MOCK_NOTIFICATIONS = [
  { id: '1', type: 'task', title: 'New task nearby', body: 'Help moving furniture - $75', time: '5m ago', read: false },
  { id: '2', type: 'payment', title: 'Payment received', body: '$65 for Furniture assembly', time: '2h ago', read: false },
  { id: '3', type: 'rating', title: 'New 5-star review', body: '"Great job! Very careful..."', time: '1d ago', read: true },
  { id: '4', type: 'system', title: 'Level up!', body: 'You reached Level 3', time: '2d ago', read: true },
  { id: '5', type: 'task', title: 'Task accepted', body: 'Sarah accepted your task', time: '3d ago', read: true },
];

export function NotificationsScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text variant="title1" color="primary">Notifications</Text>
        <TouchableOpacity>
          <Text variant="body" color="brand">Mark all read</Text>
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scroll}>
        {MOCK_NOTIFICATIONS.map(notif => (
          <NotificationItem key={notif.id} {...notif} />
        ))}
      </ScrollView>
    </View>
  );
}

function NotificationItem({ type, title, body, time, read }: {
  type: string; title: string; body: string; time: string; read: boolean;
}) {
  const icons: Record<string, string> = {
    task: '📋',
    payment: '💰',
    rating: '⭐',
    system: '🎉',
  };

  return (
    <TouchableOpacity style={[styles.notif, !read && styles.notifUnread]}>
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
  scroll: { paddingHorizontal: theme.spacing[4] },
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
