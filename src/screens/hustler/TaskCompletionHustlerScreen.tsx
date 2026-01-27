/**
 * TaskCompletionHustlerScreen - Task completed celebration
 */

import React, { useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, MoneyDisplay, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';
import { useTaskStore, useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type CompletionRouteProp = RouteProp<RootStackParamList, 'TaskCompletionHustler'>;

export function TaskCompletionHustlerScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<CompletionRouteProp>();
  const { taskId } = route.params;
  
  const { tasks, completeTask, setActiveTask } = useTaskStore();
  const { user, addXP } = useAuthStore();
  const task = tasks.find(t => t.id === taskId);

  useEffect(() => {
    if (task && task.status !== 'completed') {
      // Complete the task
      completeTask(taskId, task.maxPay);
      // Add XP to user
      const totalXP = task.baseXP + (task.bonusXP || 0);
      addXP(totalXP);
      // Clear active task
      setActiveTask(null);
    }
  }, [task, taskId, completeTask, addXP, setActiveTask]);

  const handleFindMore = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
    // Small delay then navigate to task feed
    setTimeout(() => navigation.navigate('TaskFeed'), 100);
  };

  const handleGoHome = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
  };

  if (!task) {
    return (
      <View style={[styles.container, styles.centered, { paddingTop: insets.top }]}>
        <Text variant="body" color="secondary">Task not found</Text>
      </View>
    );
  }

  const earnedXP = task.baseXP + (task.bonusXP || 0);
  const currentXP = user?.xp || 0;
  const nextTierXP = [500, 2000, 5000, 10000, Infinity][user?.trustTier || 0];
  const xpToNext = nextTierXP - currentXP;

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.celebration}>
          <Text variant="hero">🎉</Text>
          <Spacing size={16} />
          <Text variant="hero" color="primary" align="center">Task Complete!</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Great job! Your payment is being processed.
          </Text>
        </View>

        <Spacing size={32} />

        <Card variant="elevated" padding="lg">
          <View style={styles.earningsRow}>
            <Text variant="body" color="secondary">You earned</Text>
            <MoneyDisplay amount={task.finalPay || task.maxPay} size="lg" />
          </View>
          <Spacing size={16} />
          <View style={styles.xpRow}>
            <Text variant="body" color="secondary">XP Earned</Text>
            <Text variant="title2" color="brand">{`+${earnedXP} XP`}</Text>
          </View>
        </Card>

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">Level Progress</Text>
          <Spacing size={12} />
          <TrustBadge level={user?.trustTier || 1} xp={currentXP} size="md" />
          <Spacing size={12} />
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${Math.min((currentXP / nextTierXP) * 100, 100)}%` }]} />
          </View>
          <Spacing size={8} />
          {xpToNext < Infinity && (
            <Text variant="caption" color="secondary" align="center">
              {`${xpToNext} XP to Tier ${(user?.trustTier || 1) + 1}`}
            </Text>
          )}
        </Card>

        <Spacing size={24} />

        <Text variant="body" color="secondary" align="center">
          Your rating request has been sent to {task.posterName}.
        </Text>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={handleFindMore}>
          Find More Tasks
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={handleGoHome}>
          Go Home
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  centered: { justifyContent: 'center', alignItems: 'center' },
  content: { flex: 1, padding: theme.spacing[4], justifyContent: 'center' },
  celebration: { alignItems: 'center' },
  earningsRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  xpRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  progressBar: {
    height: 8,
    backgroundColor: theme.colors.surface.tertiary,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: theme.colors.brand.primary,
    borderRadius: 4,
  },
  footer: { padding: theme.spacing[4] },
});

export default TaskCompletionHustlerScreen;
