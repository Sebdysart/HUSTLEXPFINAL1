/**
 * TaskCompletionHustlerScreen - "Another one done"
 * 
 * Archetype C: Task Lifecycle (Completion)
 * - Celebratory but not over-the-top
 * - Money earned prominent
 * - Quick path to next task
 */

import React, { useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HScreen,
  HCard,
  HText,
  HMoney,
  HBadge,
  HButton,
  HTrustBadge,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore, useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type CompletionRouteProp = RouteProp<RootStackParamList, 'TaskCompletionHustler'>;

export function TaskCompletionHustlerScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<CompletionRouteProp>();
  const { taskId } = route.params;

  const { tasks, completeTask, setActiveTask } = useTaskStore();
  const { user, addXP } = useAuthStore();
  const task = tasks.find(t => t.id === taskId);

  useEffect(() => {
    if (task && task.status !== 'completed') {
      completeTask(taskId, task.maxPay);
      const totalXP = task.baseXP + (task.bonusXP || 0);
      addXP(totalXP);
      setActiveTask(null);
    }
  }, [task, taskId, completeTask, addXP, setActiveTask]);

  const handleFindMore = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
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
      <HScreen ambient scroll={false}>
        <View style={styles.centered}>
          <HText variant="body" color="secondary">Task not found</HText>
        </View>
      </HScreen>
    );
  }

  const earnedXP = task.baseXP + (task.bonusXP || 0);
  const currentXP = user?.xp || 0;
  const currentTier = user?.trustTier || 1;

  const footer = (
    <View style={styles.footerButtons}>
      <HButton variant="primary" size="lg" fullWidth onPress={handleFindMore}>
        Find More Tasks
      </HButton>
      <HButton variant="ghost" size="sm" onPress={handleGoHome}>
        Go Home
      </HButton>
    </View>
  );

  return (
    <HScreen ambient footer={footer}>
      {/* Celebration - simple, confident */}
      <View style={styles.celebration}>
        <HText variant="hero" center>✓</HText>
        <View style={styles.spacerMd} />
        <HText variant="title1" color="primary" center>
          Done
        </HText>
        <View style={styles.spacerSm} />
        <HBadge variant="success">Payment secured</HBadge>
      </View>

      <View style={styles.spacerXl} />

      {/* Earnings - prominent */}
      <HCard variant="success" padding="xl">
        <View style={styles.earningsCenter}>
          <HText variant="body" color="secondary">You earned</HText>
          <View style={styles.spacerSm} />
          <HMoney amount={task.finalPay || task.maxPay} size="hero" />
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* XP Earned */}
      <HCard variant="default" padding="lg">
        <View style={styles.xpRow}>
          <HText variant="body" color="secondary">XP Earned</HText>
          <HText variant="title3" color="warning">+{earnedXP} XP</HText>
        </View>
        <View style={styles.spacerMd} />
        <View style={styles.progressBar}>
          <View 
            style={[
              styles.progressFill, 
              { width: `${Math.min((currentXP / 2000) * 100, 100)}%` }
            ]} 
          />
        </View>
        <View style={styles.spacerSm} />
        <View style={styles.tierRow}>
          <HTrustBadge tier={currentTier} xp={currentXP} size="sm" />
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Simple confirmation */}
      <HText variant="body" color="tertiary" center>
        {task.posterName} will confirm shortly.
      </HText>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  celebration: {
    alignItems: 'center',
    paddingTop: hustleSpacing['4xl'],
  },
  earningsCenter: {
    alignItems: 'center',
  },
  xpRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  tierRow: {
    alignItems: 'center',
  },
  progressBar: {
    height: 6,
    backgroundColor: hustleColors.dark.surface,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: hustleColors.xp.primary,
    borderRadius: 3,
  },
  footerButtons: {
    gap: hustleSpacing.md,
  },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
  spacerXl: { height: hustleSpacing['3xl'] },
});

export default TaskCompletionHustlerScreen;
