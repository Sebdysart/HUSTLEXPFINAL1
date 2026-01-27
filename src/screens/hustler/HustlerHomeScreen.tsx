/**
 * HustlerHomeScreen - Main dashboard for hustlers
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, TrustBadge, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';
import { useAuthStore, useTaskStore, Task } from '../../store';
import { useTasks } from '../../hooks';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function HustlerHomeScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks, isLoading, refresh } = useTasks();
  
  const [refreshing, setRefreshing] = React.useState(false);

  const onRefresh = React.useCallback(async () => {
    setRefreshing(true);
    await refresh();
    setRefreshing(false);
  }, [refresh]);

  // Get 3 nearest tasks
  const nearbyTasks = [...tasks]
    .filter(t => t.status === 'open')
    .sort((a, b) => (a.distance || 0) - (b.distance || 0))
    .slice(0, 3);

  const handleFindTasks = () => navigation.navigate('TaskFeed');
  const handleMyTasks = () => navigation.navigate('TaskHistory');
  const handleEarnings = () => navigation.navigate('Earnings');
  const handleProfile = () => navigation.navigate('Profile');
  const handleTaskPress = (taskId: string) => navigation.navigate('TaskDetail', { taskId });
  const handleSeeAllTasks = () => navigation.navigate('TaskFeed');
  const handleNotifications = () => navigation.navigate('Notifications');

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView 
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={theme.colors.brand.primary}
          />
        }
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text variant="body" color="secondary">Welcome back</Text>
            <Text variant="title1" color="primary">{user?.name || 'Hustler'}</Text>
          </View>
          <TouchableOpacity onPress={() => navigation.navigate('TrustTierLadder')}>
            <TrustBadge level={user?.trustTier || 1} xp={user?.xp || 0} size="md" />
          </TouchableOpacity>
        </View>

        <Spacing size={24} />

        {/* Earnings Card */}
        <TouchableOpacity onPress={handleEarnings}>
          <Card variant="elevated" padding="lg">
            <Text variant="footnote" color="secondary">This Week's Earnings</Text>
            <Spacing size={4} />
            <MoneyDisplay amount={347.50} size="lg" />
            <Spacing size={12} />
            <View style={styles.statsRow}>
              <StatItem label="Tasks" value="5" />
              <StatItem label="Hours" value="12" />
              <StatItem label="Rating" value="4.9" />
            </View>
          </Card>
        </TouchableOpacity>

        <Spacing size={20} />

        {/* Quick Actions */}
        <Text variant="headline" color="primary">Quick Actions</Text>
        <Spacing size={12} />
        <View style={styles.actions}>
          <ActionCard emoji="🔍" label="Find Tasks" onPress={handleFindTasks} />
          <ActionCard emoji="📋" label="My Tasks" onPress={handleMyTasks} />
          <ActionCard emoji="💰" label="Earnings" onPress={handleEarnings} />
          <ActionCard emoji="👤" label="Profile" onPress={handleProfile} />
        </View>

        <Spacing size={24} />

        {/* Nearby Tasks */}
        <View style={styles.sectionHeader}>
          <Text variant="headline" color="primary">Nearby Tasks</Text>
          <Button variant="ghost" size="sm" onPress={handleSeeAllTasks}>See all</Button>
        </View>
        <Spacing size={12} />
        
        {nearbyTasks.length === 0 ? (
          <Card variant="default" padding="lg">
            <Text variant="body" color="secondary" align="center">
              No tasks nearby right now
            </Text>
            <Spacing size={12} />
            <Button variant="secondary" size="sm" onPress={handleFindTasks}>
              Browse All Tasks
            </Button>
          </Card>
        ) : (
          nearbyTasks.map((task, i) => (
            <React.Fragment key={task.id}>
              <TaskPreview task={task} onPress={() => handleTaskPress(task.id)} />
              {i < nearbyTasks.length - 1 && <Spacing size={12} />}
            </React.Fragment>
          ))
        )}

        <Spacing size={24} />

        {/* XP Progress */}
        <TouchableOpacity onPress={() => navigation.navigate('XPBreakdown')}>
          <Card variant="default" padding="md">
            <View style={styles.xpHeader}>
              <Text variant="headline" color="primary">XP Progress</Text>
              <Text variant="caption" color="success">+{user?.xp || 0} XP</Text>
            </View>
            <Spacing size={8} />
            <View style={styles.xpBar}>
              <View style={[styles.xpFill, { width: `${Math.min((user?.xp || 0) / 50, 100)}%` }]} />
            </View>
            <Spacing size={4} />
            <Text variant="caption" color="secondary">
              {500 - ((user?.xp || 0) % 500)} XP to next tier
            </Text>
          </Card>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.statItem}>
      <Text variant="title2" color="primary">{value}</Text>
      <Text variant="caption" color="secondary">{label}</Text>
    </View>
  );
}

function ActionCard({ emoji, label, onPress }: { emoji: string; label: string; onPress: () => void }) {
  return (
    <TouchableOpacity onPress={onPress} style={styles.actionCard}>
      <Card variant="default" padding="md" style={styles.actionCardInner}>
        <Text variant="title2">{emoji}</Text>
        <Spacing size={4} />
        <Text variant="caption" color="primary" align="center">{label}</Text>
      </Card>
    </TouchableOpacity>
  );
}

interface TaskPreviewProps {
  task: Task;
  onPress: () => void;
}

function TaskPreview({ task, onPress }: TaskPreviewProps) {
  const formatDistance = (miles?: number) => {
    if (!miles) return '';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft` : `${miles.toFixed(1)} mi`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `${minutes} min`;
    return `${Math.floor(minutes / 60)}h`;
  };

  return (
    <TouchableOpacity onPress={onPress}>
      <Card variant="default" padding="md">
        <View style={styles.taskRow}>
          <View style={styles.taskInfo}>
            <Text variant="headline" color="primary">{task.title}</Text>
            <Text variant="footnote" color="secondary">
              {formatDistance(task.distance)} • {formatTime(task.estimatedMinutes)}
            </Text>
          </View>
          <View style={styles.taskRight}>
            <MoneyDisplay amount={task.maxPay} size="md" />
            <Text variant="caption" color="success">+{task.baseXP} XP</Text>
          </View>
        </View>
      </Card>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  statItem: { alignItems: 'center' },
  actions: { flexDirection: 'row', justifyContent: 'space-between' },
  actionCard: { width: '23%' },
  actionCardInner: { alignItems: 'center' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  taskRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  taskInfo: { flex: 1 },
  taskRight: { alignItems: 'flex-end' },
  xpHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  xpBar: { 
    height: 8, 
    backgroundColor: theme.colors.surface.tertiary, 
    borderRadius: 4,
    overflow: 'hidden',
  },
  xpFill: { 
    height: '100%', 
    backgroundColor: theme.colors.brand.primary,
    borderRadius: 4,
  },
});

export default HustlerHomeScreen;
