/**
 * TaskHistoryScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - Cards for each task
 * - Most recent first
 * - Money earned visible
 * - Empty: "Your history starts here" + example card
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useTaskStore, useAuthStore, Task } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HMoney, HBadge, HButton } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

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

  const handleFindTasks = () => {
    navigation.navigate('TaskFeed');
  };

  const isEmpty = filteredTasks.length === 0;

  return (
    <HScreen ambient>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.md }]}>
        <TouchableOpacity onPress={handleBack} style={styles.backBtn}>
          <HText variant="body" color="primary">←</HText>
        </TouchableOpacity>
        <HText variant="title2" color="primary">History</HText>
        <View style={styles.headerSpacer} />
      </View>

      {/* Summary - "You've earned" framing */}
      <View style={styles.summary}>
        <View style={styles.summaryItem}>
          <HMoney amount={totalEarned || 203} size="md" label="You've earned" align="center" />
        </View>
        <View style={styles.summaryDivider} />
        <View style={styles.summaryItem}>
          <HText variant="title2" color={hustleColors.xp.primary} bold>
            {totalXP || 575}
          </HText>
          <HText variant="caption" color="tertiary">XP earned</HText>
        </View>
        <View style={styles.summaryDivider} />
        <View style={styles.summaryItem}>
          <HText variant="title2" color="primary" bold>
            {completedTasks.length || 4}
          </HText>
          <HText variant="caption" color="tertiary">Completed</HText>
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
            <HText 
              variant="body" 
              color={activeTab === tab ? hustleColors.purple.soft : 'tertiary'}
            >
              {tab}
            </HText>
          </TouchableOpacity>
        ))}
      </View>

      {/* Task List */}
      <ScrollView 
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl 
            refreshing={refreshing} 
            onRefresh={handleRefresh} 
            tintColor={hustleColors.purple.core} 
          />
        }
        showsVerticalScrollIndicator={false}
      >
        {isEmpty && activeTab === 'Completed' ? (
          /* Empty State - "Your history starts here" */
          <View style={styles.empty}>
            <HText variant="title2" color="primary" align="center">
              Your history starts here
            </HText>
            <HText variant="body" color="secondary" align="center" style={styles.emptySubtext}>
              Complete your first task to see it appear here
            </HText>
            
            {/* Example card (grayed) */}
            <ExampleHistoryCard />
            
            <HButton variant="primary" size="md" onPress={handleFindTasks}>
              Find your first task
            </HButton>
          </View>
        ) : isEmpty ? (
          <View style={styles.empty}>
            <HText variant="body" color="secondary" align="center">
              No {activeTab.toLowerCase()} tasks
            </HText>
          </View>
        ) : (
          filteredTasks.map(task => (
            <HistoryCard 
              key={task.id} 
              task={task} 
              onPress={() => handleTaskPress(task.id)} 
            />
          ))
        )}
      </ScrollView>
    </HScreen>
  );
}

interface HistoryCardProps {
  task: Task;
  onPress: () => void;
}

function HistoryCard({ task, onPress }: HistoryCardProps) {
  return (
    <HCard variant="default" padding="lg" onPress={onPress} style={styles.card}>
      <View style={styles.cardRow}>
        <View style={styles.cardInfo}>
          <HText variant="headline" color="primary">{task.title}</HText>
          <HText variant="footnote" color="tertiary">
            {task.completedAt 
              ? new Date(task.completedAt).toLocaleDateString() 
              : task.category}
          </HText>
        </View>
        <View style={styles.cardRight}>
          <HMoney amount={task.finalPay || task.maxPay} size="sm" />
          <HBadge variant="success" size="sm">+{task.baseXP} XP</HBadge>
          {task.hustlerRating && (
            <HText variant="caption" color="tertiary">⭐ {task.hustlerRating}</HText>
          )}
        </View>
      </View>
    </HCard>
  );
}

function ExampleHistoryCard() {
  return (
    <HCard variant="default" padding="lg" style={styles.exampleCard}>
      <View style={styles.cardRow}>
        <View style={styles.cardInfo}>
          <HText variant="headline" color="muted">Furniture assembly</HText>
          <HText variant="footnote" color="muted">Your first task</HText>
        </View>
        <View style={styles.cardRight}>
          <HText variant="headline" color="muted">$65</HText>
          <HText variant="caption" color="muted">+130 XP</HText>
          <HText variant="caption" color="muted">⭐ 5.0</HText>
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
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  backBtn: {
    width: 44,
    height: 44,
    justifyContent: 'center',
  },
  headerSpacer: { width: 44 },
  summary: { 
    flexDirection: 'row', 
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.xl,
  },
  summaryItem: { 
    flex: 1, 
    alignItems: 'center',
  },
  summaryDivider: { 
    width: 1, 
    backgroundColor: hustleColors.glass.border,
  },
  tabs: { 
    flexDirection: 'row', 
    paddingHorizontal: hustleSpacing.lg, 
    borderBottomWidth: 1, 
    borderBottomColor: hustleColors.glass.border,
  },
  tab: { 
    paddingVertical: hustleSpacing.md, 
    paddingHorizontal: hustleSpacing.md, 
    marginRight: hustleSpacing.sm,
  },
  tabActive: { 
    borderBottomWidth: 2, 
    borderBottomColor: hustleColors.purple.core,
  },
  list: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing['4xl'],
  },
  empty: { 
    alignItems: 'center', 
    paddingVertical: hustleSpacing['3xl'],
  },
  emptySubtext: {
    marginTop: hustleSpacing.sm,
    marginBottom: hustleSpacing.xl,
  },
  card: { 
    marginBottom: hustleSpacing.md,
  },
  exampleCard: {
    opacity: 0.4,
    marginBottom: hustleSpacing.xl,
    width: '100%',
  },
  cardRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
  },
  cardInfo: { 
    flex: 1,
  },
  cardRight: { 
    alignItems: 'flex-end',
    gap: hustleSpacing.xs,
  },
});

export default TaskHistoryScreen;
