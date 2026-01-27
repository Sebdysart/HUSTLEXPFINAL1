/**
 * PosterHomeScreen - Dashboard for task posters
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useAuthStore, useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, Button, MoneyDisplay, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function PosterHomeScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  const { tasks } = useTaskStore();
  const [refreshing, setRefreshing] = React.useState(false);
  
  // Filter tasks posted by current user
  const myTasks = tasks.filter(t => t.posterId === user?.id || t.posterName === user?.name);
  const activeTasks = myTasks.filter(t => ['open', 'claimed', 'in_progress'].includes(t.status));
  const completedTasks = myTasks.filter(t => t.status === 'completed');
  const totalSpent = completedTasks.reduce((sum, t) => sum + (t.finalPay || t.maxPay), 0);
  
  const handlePostTask = () => navigation.navigate('TaskCreation');
  const handleRefresh = async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 500));
    setRefreshing(false);
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView 
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} tintColor={theme.colors.brand.primary} />
        }
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text variant="body" color="secondary">Welcome back</Text>
            <Text variant="title1" color="primary">{user?.name || 'Poster'}</Text>
          </View>
          <TrustBadge level={user?.trustTier || 1} xp={user?.xp || 0} size="md" />
        </View>

        <Spacing size={24} />

        {/* Quick Post */}
        <Card variant="elevated" padding="lg">
          <Text variant="headline" color="primary">Need help with something?</Text>
          <Spacing size={12} />
          <Button variant="primary" size="lg" onPress={handlePostTask}>
            + Post a Task
          </Button>
        </Card>

        <Spacing size={20} />

        {/* Active Tasks */}
        <View style={styles.sectionHeader}>
          <Text variant="headline" color="primary">Your Active Tasks</Text>
          <Button variant="ghost" size="sm" onPress={() => {}}>See all</Button>
        </View>
        <Spacing size={12} />

        <ActiveTaskCard
          title="Help moving furniture"
          status="in_progress"
          hustler="John D."
          price={75}
        />
        <Spacing size={12} />
        <ActiveTaskCard
          title="Grocery shopping"
          status="pending"
          hustler={null}
          price={30}
        />

        <Spacing size={24} />

        {/* Spending Summary */}
        <Text variant="headline" color="primary">This Month</Text>
        <Spacing size={12} />
        <Card variant="default" padding="md">
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <MoneyDisplay amount={totalSpent || 245} size="md" />
              <Text variant="caption" color="secondary">Spent</Text>
            </View>
            <View style={styles.stat}>
              <Text variant="title2" color="primary">{myTasks.length || 4}</Text>
              <Text variant="caption" color="secondary">Tasks Posted</Text>
            </View>
            <View style={styles.stat}>
              <Text variant="title2" color="primary">{completedTasks.length || 3}</Text>
              <Text variant="caption" color="secondary">Completed</Text>
            </View>
          </View>
        </Card>
      </ScrollView>
    </View>
  );
}

function ActiveTaskCard({ title, status, hustler, price }: {
  title: string;
  status: 'pending' | 'in_progress' | 'completed';
  hustler: string | null;
  price: number;
}) {
  const statusText = {
    pending: '🔍 Finding hustler...',
    in_progress: '🔨 In progress',
    completed: '✅ Completed',
  };

  return (
    <Card variant="default" padding="md">
      <View style={styles.taskHeader}>
        <Text variant="headline" color="primary">{title}</Text>
        <MoneyDisplay amount={price} size="sm" />
      </View>
      <Spacing size={8} />
      <Text variant="footnote" color="secondary">{statusText[status]}</Text>
      {hustler && (
        <>
          <Spacing size={4} />
          <Text variant="footnote" color="secondary">Hustler: {hustler}</Text>
        </>
      )}
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  stat: { alignItems: 'center' },
  taskHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
});

export default PosterHomeScreen;
