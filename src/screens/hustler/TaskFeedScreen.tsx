/**
 * TaskFeedScreen - Browse available tasks
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, MoneyDisplay, Button, Input } from '../../components';
import { theme } from '../../theme';

const FILTERS = ['All', 'Nearby', 'High Pay', 'Quick', 'New'];

const MOCK_TASKS = [
  { id: '1', title: 'Help moving furniture', price: 75, distance: '0.8 mi', time: '2 hrs', category: 'Moving', urgent: true },
  { id: '2', title: 'Grocery delivery', price: 25, distance: '1.2 mi', time: '1 hr', category: 'Delivery', urgent: false },
  { id: '3', title: 'Yard cleanup', price: 120, distance: '2.1 mi', time: '4 hrs', category: 'Yard', urgent: false },
  { id: '4', title: 'IKEA furniture assembly', price: 60, distance: '3.0 mi', time: '2 hrs', category: 'Assembly', urgent: false },
  { id: '5', title: 'Dog walking (3 dogs)', price: 35, distance: '0.5 mi', time: '1 hr', category: 'Pet Care', urgent: true },
];

export function TaskFeedScreen() {
  const insets = useSafeAreaInsets();
  const [activeFilter, setActiveFilter] = useState('All');
  const [search, setSearch] = useState('');

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

      {/* Task List */}
      <ScrollView contentContainerStyle={styles.taskList}>
        {MOCK_TASKS.map(task => (
          <React.Fragment key={task.id}>
            <TaskCard {...task} />
            <Spacing size={12} />
          </React.Fragment>
        ))}
      </ScrollView>
    </View>
  );
}

function TaskCard({ title, price, distance, time, category, urgent }: {
  title: string; price: number; distance: string; time: string; category: string; urgent: boolean;
}) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.taskHeader}>
        <View style={styles.categoryBadge}>
          <Text variant="caption" color="secondary">{category}</Text>
        </View>
        {urgent && (
          <View style={styles.urgentBadge}>
            <Text variant="caption" color="inverse">⚡ Urgent</Text>
          </View>
        )}
      </View>
      <Spacing size={8} />
      <Text variant="headline" color="primary">{title}</Text>
      <Spacing size={4} />
      <Text variant="footnote" color="secondary">{distance} away • Est. {time}</Text>
      <Spacing size={12} />
      <View style={styles.taskFooter}>
        <MoneyDisplay amount={price} size="md" />
        <Button variant="primary" size="sm" onPress={() => console.log('View task')}>
          View Details
        </Button>
      </View>
    </Card>
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
  taskHeader: { flexDirection: 'row', gap: theme.spacing[2] },
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
  taskFooter: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
});

export default TaskFeedScreen;
