/**
 * TaskFeedScreen - Browse available tasks
 */

import React, { useState, useCallback } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, MoneyDisplay, Button, Input } from '../../components';
import { theme } from '../../theme';
import { useTasks } from '../../hooks';
import { Task } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const FILTERS = ['All', 'Nearby', 'High Pay', 'Quick', 'New'];

export function TaskFeedScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { tasks, isLoading, error, refresh } = useTasks();
  
  const [activeFilter, setActiveFilter] = useState('All');
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
        return true; // Would check createdAt in real implementation
      default:
        return true;
    }
  });

  const handleTaskPress = (taskId: string) => {
    navigation.navigate('TaskDetail', { taskId });
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text variant="title1" color="primary">Find Tasks</Text>
        <Spacing size={12} />
        <Input
          placeholder="Search tasks..."
          value={search}
          onChangeText={setSearch}
        />
      </View>

      {/* Filters */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.filters}>
        {FILTERS.map(f => (
          <TouchableOpacity
            key={f}
            style={[styles.filterChip, activeFilter === f && styles.filterChipActive]}
            onPress={() => setActiveFilter(f)}
          >
            <Text variant="caption" color={activeFilter === f ? 'inverse' : 'primary'}>{f}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Error State */}
      {error && (
        <View style={styles.errorContainer}>
          <Text variant="body" color="error">{error}</Text>
          <Spacing size={8} />
          <Button variant="secondary" size="sm" onPress={refresh}>
            Try Again
          </Button>
        </View>
      )}

      {/* Loading State */}
      {isLoading && !refreshing && filteredTasks.length === 0 && (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.brand.primary} />
          <Spacing size={12} />
          <Text variant="body" color="secondary">Loading tasks...</Text>
        </View>
      )}

      {/* Empty State */}
      {!isLoading && filteredTasks.length === 0 && !error && (
        <View style={styles.emptyContainer}>
          <Text variant="title2" color="secondary" align="center">No tasks found</Text>
          <Spacing size={8} />
          <Text variant="body" color="tertiary" align="center">
            Try adjusting your filters or check back later
          </Text>
        </View>
      )}

      {/* Task List */}
      <ScrollView 
        contentContainerStyle={styles.taskList}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={theme.colors.brand.primary}
          />
        }
      >
        {filteredTasks.map(task => (
          <React.Fragment key={task.id}>
            <TaskCard task={task} onPress={() => handleTaskPress(task.id)} />
            <Spacing size={12} />
          </React.Fragment>
        ))}
      </ScrollView>
    </View>
  );
}

interface TaskCardProps {
  task: Task;
  onPress: () => void;
}

function TaskCard({ task, onPress }: TaskCardProps) {
  const isUrgent = task.scheduledFor && new Date(task.scheduledFor).getTime() - Date.now() < 2 * 60 * 60 * 1000;
  
  const formatDistance = (miles?: number) => {
    if (!miles) return 'Unknown distance';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft` : `${miles.toFixed(1)} mi`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return mins > 0 ? `${hours}h ${mins}m` : `${hours} hr${hours > 1 ? 's' : ''}`;
  };

  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.8}>
      <Card variant="default" padding="md">
        <View style={styles.taskHeader}>
          <View style={styles.categoryBadge}>
            <Text variant="caption" color="secondary">{task.category}</Text>
          </View>
          {isUrgent && (
            <View style={styles.urgentBadge}>
              <Text variant="caption" color="inverse">⚡ Urgent</Text>
            </View>
          )}
          {task.requiredTrustTier > 1 && (
            <View style={styles.tierBadge}>
              <Text variant="caption" color="primary">Tier {task.requiredTrustTier}+</Text>
            </View>
          )}
        </View>
        <Spacing size={8} />
        <Text variant="headline" color="primary">{task.title}</Text>
        <Spacing size={4} />
        <Text variant="footnote" color="secondary">
          {formatDistance(task.distance)} away • Est. {formatTime(task.estimatedMinutes)}
        </Text>
        <Spacing size={4} />
        <Text variant="footnote" color="tertiary" numberOfLines={2}>
          {task.description}
        </Text>
        <Spacing size={12} />
        <View style={styles.taskFooter}>
          <View>
            <MoneyDisplay amount={task.maxPay} size="md" />
            {task.minPay !== task.maxPay && (
              <Text variant="caption" color="tertiary">
                ${task.minPay} - ${task.maxPay}
              </Text>
            )}
          </View>
          <View style={styles.xpBadge}>
            <Text variant="caption" color="success">+{task.baseXP} XP</Text>
          </View>
        </View>
      </Card>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { padding: theme.spacing[4] },
  filters: { paddingHorizontal: theme.spacing[4], maxHeight: 50 },
  filterChip: {
    paddingHorizontal: theme.spacing[4],
    paddingVertical: theme.spacing[2],
    backgroundColor: theme.colors.surface.secondary,
    borderRadius: theme.radii.full,
    marginRight: theme.spacing[2],
  },
  filterChipActive: { backgroundColor: theme.colors.brand.primary },
  taskList: { padding: theme.spacing[4] },
  taskHeader: { flexDirection: 'row', gap: theme.spacing[2], flexWrap: 'wrap' },
  categoryBadge: {
    backgroundColor: theme.colors.surface.tertiary,
    paddingHorizontal: theme.spacing[2],
    paddingVertical: 2,
    borderRadius: theme.radii.xs,
  },
  urgentBadge: {
    backgroundColor: theme.colors.semantic.warning,
    paddingHorizontal: theme.spacing[2],
    paddingVertical: 2,
    borderRadius: theme.radii.xs,
  },
  tierBadge: {
    backgroundColor: theme.colors.surface.secondary,
    paddingHorizontal: theme.spacing[2],
    paddingVertical: 2,
    borderRadius: theme.radii.xs,
    borderWidth: 1,
    borderColor: theme.colors.brand.primary,
  },
  xpBadge: {
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    paddingHorizontal: theme.spacing[2],
    paddingVertical: theme.spacing[1],
    borderRadius: theme.radii.xs,
  },
  taskFooter: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingTop: 100 },
  errorContainer: { padding: theme.spacing[4], alignItems: 'center' },
  emptyContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingTop: 100 },
});

export default TaskFeedScreen;
