/**
 * PosterHomeScreen - Feed Archetype (B)
 * "Things are happening. You're next."
 */

import React from 'react';
import { View, StyleSheet, RefreshControl } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useAuthStore, useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';
import {
  HScreen,
  HText,
  HCard,
  HButton,
  HMoney,
  HTrustBadge,
  HSignalStream,
  HBadge,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

function getTimeGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  if (hour < 21) return 'Evening';
  return 'Night owl';
}

export function PosterHomeScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks } = useTaskStore();
  const [refreshing, setRefreshing] = React.useState(false);

  // Filter tasks posted by current user
  const myTasks = tasks.filter(t => t.posterId === user?.id || t.posterName === user?.name);
  const activeTasks = myTasks.filter(t => t.status !== 'completed');
  const completedTasks = myTasks.filter(t => t.status === 'completed');
  const totalSpent = completedTasks.reduce((sum, t) => sum + (t.finalPay || t.maxPay), 0);

  const handlePostTask = () => navigation.navigate('TaskCreation');
  const handleRefresh = async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 500));
    setRefreshing(false);
  };

  const greeting = getTimeGreeting();
  const firstName = user?.name?.split(' ')[0] || 'Boss';

  return (
    <HScreen
      ambient
      scroll
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={handleRefresh}
          tintColor={hustleColors.purple.core}
        />
      }
    >
      {/* Floating Activity Signals */}
      <HSignalStream
        signals={[
          { text: '3 hustlers browsing your area', icon: '👀' },
          { text: 'Task completed nearby', icon: '✓' },
          { text: '$127 paid out this hour', icon: '💸' },
        ]}
      />

      {/* Header */}
      <View style={styles.header}>
        <View>
          <HText variant="body" color="secondary">{greeting},</HText>
          <HText variant="title1" color="primary">{firstName}</HText>
        </View>
        <HTrustBadge tier={user?.trustTier || 1} xp={user?.xp || 0} size="md" />
      </View>

      {/* Quick Post CTA */}
      <HCard variant="elevated" padding="lg" style={styles.ctaCard}>
        <HText variant="headline" color="primary">Ready to get help?</HText>
        <HText variant="body" color="secondary" style={styles.ctaSubtext}>
          Hustlers are active around you
        </HText>
        <HButton variant="primary" size="lg" onPress={handlePostTask}>
          Let's go
        </HButton>
      </HCard>

      {/* Active Tasks */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <HText variant="headline" color="primary">Your Tasks</HText>
          <HBadge variant="info">{`${activeTasks.length || 2} active`}</HBadge>
        </View>

        <ActiveTaskCard
          title="Help moving furniture"
          status="in_progress"
          hustler="John D."
          price={75}
        />
        <ActiveTaskCard
          title="Grocery shopping"
          status="pending"
          hustler={null}
          price={30}
        />
      </View>

      {/* Stats - Proof of Life */}
      <HCard variant="default" padding="md" style={styles.statsCard}>
        <HText variant="caption" color="secondary" style={styles.statsLabel}>This Month</HText>
        <View style={styles.statsRow}>
          <View style={styles.stat}>
            <HMoney amount={totalSpent || 245} size="md" />
            <HText variant="caption" color="secondary">Spent</HText>
          </View>
          <View style={styles.stat}>
            <HText variant="title2" color="primary">{myTasks.length || 4}</HText>
            <HText variant="caption" color="secondary">Posted</HText>
          </View>
          <View style={styles.stat}>
            <HText variant="title2" color="primary">{completedTasks.length || 3}</HText>
            <HText variant="caption" color="secondary">Done</HText>
          </View>
        </View>
      </HCard>

      {/* Browse CTA */}
      <HButton variant="secondary" size="md" onPress={() => navigation.navigate('TaskFeed')}>
        Browse what's out there
      </HButton>
    </HScreen>
  );
}

function ActiveTaskCard({ title, status, hustler, price }: {
  title: string;
  status: 'pending' | 'in_progress' | 'completed';
  hustler: string | null;
  price: number;
}) {
  const statusConfig = {
    pending: { label: 'Finding hustler...', variant: 'warning' as const },
    in_progress: { label: 'In progress', variant: 'info' as const },
    completed: { label: 'Done', variant: 'success' as const },
  };

  return (
    <HCard variant="default" padding="md" style={styles.taskCard}>
      <View style={styles.taskHeader}>
        <View style={styles.taskInfo}>
          <HText variant="headline" color="primary">{title}</HText>
          {hustler && <HText variant="footnote" color="secondary">{hustler}</HText>}
        </View>
        <View style={styles.taskMeta}>
          <HMoney amount={price} size="sm" glow />
          <HBadge variant={statusConfig[status].variant}>{statusConfig[status].label}</HBadge>
        </View>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: hustleSpacing.lg,
  },
  ctaCard: {
    marginBottom: hustleSpacing.xl,
  },
  ctaSubtext: {
    marginTop: hustleSpacing.xs,
    marginBottom: hustleSpacing.lg,
  },
  section: {
    marginBottom: hustleSpacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: hustleSpacing.md,
  },
  statsCard: {
    marginBottom: hustleSpacing.lg,
  },
  statsLabel: {
    marginBottom: hustleSpacing.sm,
    textAlign: 'center',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  stat: {
    alignItems: 'center',
  },
  taskCard: {
    marginBottom: hustleSpacing.md,
  },
  taskHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  taskInfo: {
    flex: 1,
  },
  taskMeta: {
    alignItems: 'flex-end',
    gap: hustleSpacing.sm,
  },
});

export default PosterHomeScreen;
