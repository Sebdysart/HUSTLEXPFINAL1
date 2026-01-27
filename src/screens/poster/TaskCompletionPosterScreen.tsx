/**
 * TaskCompletionPosterScreen - Task done, payment released
 * 
 * Archetype C: Task Lifecycle (Completion)
 * - "Payment secured" - confident
 * - Simple confirmation
 * - Path to post another
 */

import React from 'react';
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
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type RouteProps = RouteProp<RootStackParamList, 'TaskCompletionPoster'>;

export function TaskCompletionPosterScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { taskId } = route.params || {};

  const { tasks } = useTaskStore();
  const task = taskId ? tasks.find(t => t.id === taskId) : null;

  const handlePostAnother = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
    setTimeout(() => navigation.navigate('TaskCreation'), 100);
  };

  const handleGoHome = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
  };

  // Mock data - would come from task in real app
  const hustler = {
    name: 'John D.',
    tier: 3,
    xp: 2600,
  };
  const amount = task?.maxPay || 75;
  const taskTitle = task?.title || 'Help moving furniture';

  const footer = (
    <View style={styles.footerButtons}>
      <HButton variant="primary" size="lg" fullWidth onPress={handlePostAnother}>
        Post Another Task
      </HButton>
      <HButton variant="ghost" size="sm" onPress={handleGoHome}>
        Go Home
      </HButton>
    </View>
  );

  return (
    <HScreen ambient footer={footer}>
      {/* Completion - simple, confident */}
      <View style={styles.celebration}>
        <HText variant="hero" center>✓</HText>
        <View style={styles.spacerMd} />
        <HText variant="title1" color="primary" center>
          All done
        </HText>
        <View style={styles.spacerSm} />
        <HBadge variant="success">Payment released</HBadge>
      </View>

      <View style={styles.spacerXl} />

      {/* Summary */}
      <HCard variant="default" padding="lg">
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Task</HText>
          <HText variant="body" color="primary">{taskTitle}</HText>
        </View>
        <View style={styles.spacerMd} />
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Paid</HText>
          <HMoney amount={amount} size="md" />
        </View>
        <View style={styles.spacerMd} />
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Your rating</HText>
          <HText variant="body" color="warning">⭐⭐⭐⭐⭐</HText>
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Hustler */}
      <HCard variant="elevated" padding="lg">
        <View style={styles.hustlerCenter}>
          <View style={styles.avatar}>
            <HText variant="title2">👤</HText>
          </View>
          <View style={styles.spacerMd} />
          <HText variant="headline" color="primary">{hustler.name}</HText>
          <View style={styles.spacerSm} />
          <HTrustBadge tier={hustler.tier} xp={hustler.xp} size="sm" />
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      <HText variant="body" color="tertiary" center>
        Thanks for using HustleXP
      </HText>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  celebration: {
    alignItems: 'center',
    paddingTop: hustleSpacing['4xl'],
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  hustlerCenter: {
    alignItems: 'center',
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: hustleColors.dark.surface,
    justifyContent: 'center',
    alignItems: 'center',
  },
  footerButtons: {
    gap: hustleSpacing.md,
  },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
  spacerXl: { height: hustleSpacing['3xl'] },
});

export default TaskCompletionPosterScreen;
