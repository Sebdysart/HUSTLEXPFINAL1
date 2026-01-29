/**
 * TaskFeedScreen - Browse available tasks
 * 
 * CHOSEN-STATE: Never empty, always alive
 * - HSignalStream shows activity when no tasks match
 * - Task cards use HCard + HMoney
 * - Soft colors for distance/time
 */

import React, { useState, useCallback } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HScreen,
  HText,
  HCard,
  HButton,
  HBadge,
  HMoney,
  HSearchInput,
  HSignalStream,
  HActivityIndicator,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTasks } from '../../hooks';
import { Task } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const FILTERS = ['All', 'Nearby', 'High Pay', 'Quick', 'New'];

// Activity signals - show these when list is empty to keep system alive
const ACTIVITY_SIGNALS = [
  { text: 'New task posted in your area', icon: '✨' },
  { text: 'Hustler completed a delivery', icon: '🚀' },
  { text: '$47 earned nearby', icon: '💰' },
  { text: 'High-pay task unlocked', icon: '⭐' },
  { text: 'Someone just got paid', icon: '✓' },
  { text: 'Task accepted in seconds', icon: '⚡' },
];

export function TaskFeedScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { tasks, isLoading, error, refresh } = useTasks();
  
  const [activeFilter, _setActiveFilter] = useState('All');
  const [search, setSearch] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await refresh();
    setRefreshing(false);
  }, [refresh]);

  const filteredTasks = tasks.filter(task => {
    // Search filter
    if (search && !task.title.toLowerCase().includes(search.toLowerCase())) {
      return false;
    }
    
    // Category filters
    switch (activeFilter) {
      case 'Nearby':
        return (task.distance || 0) < 3;
      case 'High Pay':
        return task.maxPay >= 50;
      case 'Quick':
        return task.estimatedMinutes <= 60;
      case 'New':
        return true;
      default:
        return true;
    }
  });

  const handleTaskPress = (taskId: string) => {
    navigation.navigate('TaskDetail', { taskId });
  };

  const header = (
    <View>
      <HText variant="title1">Find Tasks</HText>
      <View style={styles.spacer12} />
      <HSearchInput
        placeholder="Search tasks..."
        value={search}
        onChangeText={setSearch}
      />
    </View>
  );

  return (
    <HScreen header={header} scroll={false} ambient>
      {/* Filters */}
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false} 
        style={styles.filters}
        contentContainerStyle={styles.filtersContent}
      >
        {FILTERS.map(f => (
          <HBadge
            key={f}
            variant={activeFilter === f ? 'purple' : 'default'}
            size="md"
            style={styles.filterChip}
            pulsing={activeFilter === f}
          >
            {f}
          </HBadge>
        ))}
      </ScrollView>

      {/* Error State */}
      {error && (
        <View style={styles.centerContainer}>
          <HText variant="body" color="error">{error}</HText>
          <View style={styles.spacer12} />
          <HButton variant="secondary" size="sm" onPress={refresh}>
            Try Again
          </HButton>
        </View>
      )}

      {/* Loading State */}
      {isLoading && !refreshing && filteredTasks.length === 0 && (
        <View style={styles.centerContainer}>
          <HActivityIndicator active label="Finding tasks..." />
        </View>
      )}

      {/* Never show empty - show signals instead */}
      {!isLoading && filteredTasks.length === 0 && !error && (
        <View style={styles.signalContainer}>
          <HSignalStream 
            signals={ACTIVITY_SIGNALS}
            interval={2500}
            duration={2000}
          />
          <View style={styles.spacer20} />
          <HText variant="body" color="secondary" center>
            Waiting for the perfect task...
          </HText>
          <HText variant="footnote" color="tertiary" center>
            New opportunities appear every few minutes
          </HText>
        </View>
      )}

      {/* Task List */}
      <ScrollView 
        contentContainerStyle={styles.taskList}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={hustleColors.purple.soft}
          />
        }
      >
        {/* Floating activity signal at top when tasks exist */}
        {filteredTasks.length > 0 && (
          <View style={styles.floatingSignal}>
            <HSignalStream 
              signals={ACTIVITY_SIGNALS}
              interval={4000}
              duration={3000}
            />
          </View>
        )}
        
        {filteredTasks.map(task => (
          <View key={task.id} style={styles.taskCardWrapper}>
            <TaskCard task={task} onPress={() => handleTaskPress(task.id)} />
          </View>
        ))}
        <View style={styles.bottomSpacer} />
      </ScrollView>
    </HScreen>
  );
}

interface TaskCardProps {
  task: Task;
  onPress: () => void;
}

function TaskCard({ task, onPress }: TaskCardProps) {
  const isUrgent = task.scheduledFor && 
    new Date(task.scheduledFor).getTime() - Date.now() < 2 * 60 * 60 * 1000;
  
  const formatDistance = (miles?: number) => {
    if (!miles) return 'Nearby';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft` : `${miles.toFixed(1)} mi`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `~${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return mins > 0 ? `~${hours}h ${mins}m` : `~${hours} hr${hours > 1 ? 's' : ''}`;
  };

  return (
    <HCard variant="default" padding="lg" onPress={onPress}>
      {/* Badges row */}
      <View style={styles.taskHeader}>
        <HBadge variant="default" size="sm">{task.category}</HBadge>
        {isUrgent && (
          <HBadge variant="warning" size="sm">⚡ Soon</HBadge>
        )}
        {task.requiredTrustTier > 1 && (
          <HBadge variant="purple" size="sm">Tier {task.requiredTrustTier}+</HBadge>
        )}
      </View>
      
      <View style={styles.spacer8} />
      
      {/* Title */}
      <HText variant="headline">{task.title}</HText>
      
      <View style={styles.spacer4} />
      
      {/* Meta - soft colors, not alarming */}
      <HText variant="footnote" color="tertiary">
        {formatDistance(task.distance)} away • {formatTime(task.estimatedMinutes)}
      </HText>
      
      <View style={styles.spacer4} />
      
      {/* Description */}
      <HText variant="footnote" color="muted" numberOfLines={2}>
        {task.description}
      </HText>
      
      <View style={styles.spacer12} />
      
      {/* Footer: Price + XP */}
      <View style={styles.taskFooter}>
        <View>
          <HMoney amount={task.maxPay} size="md" />
          {task.minPay !== task.maxPay && (
            <HText variant="caption" color="muted">
              ${task.minPay} – ${task.maxPay}
            </HText>
          )}
        </View>
        <HBadge variant="success" size="sm">
          +{task.baseXP} XP
        </HBadge>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  filters: { 
    maxHeight: 50,
    marginBottom: hustleSpacing.md,
  },
  filtersContent: {
    paddingHorizontal: hustleSpacing.lg,
    gap: hustleSpacing.sm,
  },
  filterChip: {
    marginRight: hustleSpacing.sm,
  },
  taskList: { 
    paddingHorizontal: hustleSpacing.lg,
    paddingTop: hustleSpacing.sm,
  },
  taskCardWrapper: {
    marginBottom: hustleSpacing.md,
  },
  taskHeader: { 
    flexDirection: 'row', 
    gap: hustleSpacing.sm, 
    flexWrap: 'wrap',
  },
  taskFooter: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  centerContainer: { 
    flex: 1, 
    justifyContent: 'center', 
    alignItems: 'center', 
    paddingTop: 100,
  },
  signalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.xl,
  },
  floatingSignal: {
    marginBottom: hustleSpacing.md,
    alignItems: 'center',
  },
  spacer4: { height: 4 },
  spacer8: { height: 8 },
  spacer12: { height: 12 },
  spacer20: { height: 20 },
  bottomSpacer: { height: 100 },
});

export default TaskFeedScreen;
