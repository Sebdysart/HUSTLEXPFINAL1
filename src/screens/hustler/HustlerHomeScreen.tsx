/**
 * HustlerHomeScreen - Main dashboard for hustlers
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, TrustBadge, MoneyDisplay, Button } from '../../components';
import { theme } from '../../theme';

export function HustlerHomeScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text variant="body" color="secondary">Welcome back</Text>
            <Text variant="title1" color="primary">John</Text>
          </View>
          <TrustBadge level={3} xp={2450} size="md" />
        </View>

        <Spacing size={24} />

        {/* Earnings Card */}
        <Card variant="elevated" padding="lg">
          <Text variant="footnote" color="secondary">This Week's Earnings</Text>
          <Spacing size={4} />
          <MoneyDisplay amount={347.50} size="lg" />
          <Spacing size={12} />
          <View style={styles.statsRow}>
            <StatItem label="Tasks" value="5" />
            <StatItem label="Hours" value="12" />
            <StatItem label="Rating" value="4.9" />
          </View>
        </Card>

        <Spacing size={20} />

        {/* Quick Actions */}
        <Text variant="headline" color="primary">Quick Actions</Text>
        <Spacing size={12} />
        <View style={styles.actions}>
          <ActionCard emoji="🔍" label="Find Tasks" />
          <ActionCard emoji="📋" label="My Tasks" />
          <ActionCard emoji="💰" label="Earnings" />
          <ActionCard emoji="⭐" label="Reviews" />
        </View>

        <Spacing size={24} />

        {/* Nearby Tasks */}
        <View style={styles.sectionHeader}>
          <Text variant="headline" color="primary">Nearby Tasks</Text>
          <Button variant="ghost" size="sm" onPress={() => {}}>See all</Button>
        </View>
        <Spacing size={12} />
        
        <TaskPreview title="Help moving furniture" price={75} distance="0.8 mi" time="2 hrs" />
        <Spacing size={12} />
        <TaskPreview title="Grocery delivery" price={25} distance="1.2 mi" time="1 hr" />
        <Spacing size={12} />
        <TaskPreview title="Yard cleanup" price={120} distance="2.1 mi" time="4 hrs" />
      </ScrollView>
    </View>
  );
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.statItem}>
      <Text variant="title2" color="primary">{value}</Text>
      <Text variant="caption" color="secondary">{label}</Text>
    </View>
  );
}

function ActionCard({ emoji, label }: { emoji: string; label: string }) {
  return (
    <Card variant="default" padding="md" style={styles.actionCard}>
      <Text variant="title2">{emoji}</Text>
      <Spacing size={4} />
      <Text variant="caption" color="primary">{label}</Text>
    </Card>
  );
}

function TaskPreview({ title, price, distance, time }: { title: string; price: number; distance: string; time: string }) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.taskRow}>
        <View style={styles.taskInfo}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="footnote" color="secondary">{distance} • {time}</Text>
        </View>
        <MoneyDisplay amount={price} size="md" />
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  statItem: { alignItems: 'center' },
  actions: { flexDirection: 'row', justifyContent: 'space-between' },
  actionCard: { width: '23%', alignItems: 'center' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  taskRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  taskInfo: { flex: 1 },
});

export default HustlerHomeScreen;
