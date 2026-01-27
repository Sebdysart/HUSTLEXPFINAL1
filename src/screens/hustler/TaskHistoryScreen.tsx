/**
 * TaskHistoryScreen - Past completed tasks
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, MoneyDisplay } from '../../components';
import { theme } from '../../theme';
import { useTaskStore, useAuthStore, Task } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const TABS = ['Completed', 'In Progress', 'Cancelled'];

export function TaskHistoryScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { tasks } = useTaskStore();
  const { user } = useAuthStore();
  const [activeTab, setActiveTab] = useState('Completed');
  const [refreshing, setRefreshing] = useState(false);

  // Filter tasks by user and status
  const myTasks = tasks.filter(t => t.hustlerId === user?.id || t.hustlerName === user?.name);
  
  const filteredTasks = myTasks.filter(t => {
    switch (activeTab) {
      case 'Completed':
        return t.status === 'completed';
      case 'In Progress':
        return ['claimed', 'in_progress', 'en_route', 'arrived'].includes(t.status);
      case 'Cancelled':
        return t.status === 'cancelled';
      default:
        return true;
    }
  });

  // Stats
  const completedTasks = myTasks.filter(t => t.status === 'completed');
  const totalEarned = completedTasks.reduce((sum, t) => sum + (t.finalPay || t.maxPay), 0);
  const totalXP = completedTasks.reduce((sum, t) => sum + t.baseXP + (t.bonusXP || 0), 0);

  const handleBack = () => navigation.goBack();
  const handleRefresh = async () => {
    setRefreshing(true);
    await new Promise<void>(r => setTimeout(r, 500));
    setRefreshing(false);
  };

  const handleTaskPress = (taskId: string) => {
    navigation.navigate('TaskDetail', { taskId });
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleBack}>
          <Text variant="body" color="primary">← Back</Text>
        </TouchableOpacity>
        <Text variant="title2" color="primary">Task History</Text>
        <View style={styles.headerSpacer} />
      </View>

      {/* Summary */}
      <View style={styles.summary}>
        <View style={styles.summaryItem}>
          <MoneyDisplay amount={totalEarned || 203} size="md" />
          <Text variant="caption" color="secondary">Total Earned</Text>
        </View>
        <View style={styles.summaryDivider} />
        <View style={styles.summaryItem}>
          <Text variant="title2" color="success">{totalXP || 575}</Text>
          <Text variant="caption" color="secondary">XP Earned</Text>
        </View>
        <View style={styles.summaryDivider} />
        <View style={styles.summaryItem}>
          <Text variant="title2" color="primary">{completedTasks.length || 4}</Text>
          <Text variant="caption" color="secondary">Completed</Text>
        </View>
      </View>

      {/* Tabs */}
      <View style={styles.tabs}>
        {TABS.map(tab => (
          <TouchableOpacity
            key={tab}
            style={[styles.tab, activeTab === tab && styles.tabActive]}
            onPress={() => setActiveTab(tab)}
          >
            <Text variant="body" color={activeTab === tab ? 'brand' : 'secondary'}>{tab}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Task List */}
      <ScrollView 
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} tintColor={theme.colors.brand.primary} />
        }
      >
        {filteredTasks.length === 0 ? (
          <View style={styles.empty}>
            <Text variant="title2">📋</Text>
            <Spacing size={12} />
            <Text variant="body" color="secondary" align="center">
              {`No ${activeTab.toLowerCase()} tasks yet`}
            </Text>
            {activeTab === 'Completed' && (
              <>
                <Spacing size={12} />
                <TouchableOpacity onPress={() => navigation.navigate('TaskFeed')}>
                  <Text variant="body" color="brand">Find tasks →</Text>
                </TouchableOpacity>
              </>
            )}
          </View>
        ) : (
          filteredTasks.map(task => (
            <React.Fragment key={task.id}>
              <HistoryCard task={task} onPress={() => handleTaskPress(task.id)} />
              <Spacing size={12} />
            </React.Fragment>
          ))
        )}

        {/* Mock data if no real tasks */}
        {filteredTasks.length === 0 && activeTab === 'Completed' && (
          <>
            <Spacing size={24} />
            <Text variant="caption" color="tertiary" align="center">Sample completed tasks:</Text>
            <Spacing size={12} />
            <MockHistoryCard title="Furniture assembly" price={65} date="Jan 24" rating={5} xp={130} />
            <MockHistoryCard title="Grocery run" price={28} date="Jan 23" rating={5} xp={56} />
            <MockHistoryCard title="Moving help" price={90} date="Jan 20" rating={5} xp={180} />
          </>
        )}
      </ScrollView>
    </View>
  );
}

interface HistoryCardProps {
  task: Task;
  onPress: () => void;
}

function HistoryCard({ task, onPress }: HistoryCardProps) {
  return (
    <TouchableOpacity onPress={onPress}>
      <Card variant="default" padding="md">
        <View style={styles.cardRow}>
          <View style={styles.cardInfo}>
            <Text variant="headline" color="primary">{task.title}</Text>
            <Text variant="footnote" color="secondary">
              {task.completedAt ? new Date(task.completedAt).toLocaleDateString() : task.category}
            </Text>
          </View>
          <View style={styles.cardRight}>
            <MoneyDisplay amount={task.finalPay || task.maxPay} size="sm" />
            <Text variant="caption" color="success">{`+${task.baseXP} XP`}</Text>
            {task.hustlerRating && (
              <Text variant="caption" color="secondary">{`⭐ ${task.hustlerRating}`}</Text>
            )}
          </View>
        </View>
      </Card>
    </TouchableOpacity>
  );
}

function MockHistoryCard({ title, price, date, rating, xp }: {
  title: string; price: number; date: string; rating: number; xp: number;
}) {
  return (
    <>
      <Card variant="default" padding="md" style={styles.mockCard}>
        <View style={styles.cardRow}>
          <View style={styles.cardInfo}>
            <Text variant="headline" color="primary">{title}</Text>
            <Text variant="footnote" color="secondary">{date}</Text>
          </View>
          <View style={styles.cardRight}>
            <MoneyDisplay amount={price} size="sm" />
            <Text variant="caption" color="success">{`+${xp} XP`}</Text>
            <Text variant="caption" color="secondary">{`⭐ ${rating}`}</Text>
          </View>
        </View>
      </Card>
      <Spacing size={12} />
    </>
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
  summary: { 
    flexDirection: 'row', 
    paddingHorizontal: theme.spacing[4],
    paddingBottom: theme.spacing[4],
  },
  summaryItem: { flex: 1, alignItems: 'center' },
  summaryDivider: { width: 1, backgroundColor: theme.colors.surface.tertiary },
  tabs: { 
    flexDirection: 'row', 
    paddingHorizontal: theme.spacing[4], 
    borderBottomWidth: 1, 
    borderBottomColor: theme.colors.surface.secondary,
  },
  tab: { 
    paddingVertical: theme.spacing[3], 
    paddingHorizontal: theme.spacing[3], 
    marginRight: theme.spacing[2],
  },
  tabActive: { borderBottomWidth: 2, borderBottomColor: theme.colors.brand.primary },
  list: { padding: theme.spacing[4] },
  empty: { alignItems: 'center', paddingVertical: theme.spacing[8] },
  cardRow: { flexDirection: 'row', justifyContent: 'space-between' },
  cardInfo: { flex: 1 },
  cardRight: { alignItems: 'flex-end' },
  mockCard: { opacity: 0.7 },
  headerSpacer: { width: 50 },
});

export default TaskHistoryScreen;
