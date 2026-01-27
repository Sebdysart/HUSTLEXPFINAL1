/**
 * TaskHistoryScreen - Past completed tasks
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, MoneyDisplay } from '../../components';
import { theme } from '../../theme';

const TABS = ['Completed', 'Cancelled'];

const MOCK_HISTORY = [
  { id: '1', title: 'Furniture assembly', price: 65, date: 'Jan 24', rating: 5, status: 'completed' },
  { id: '2', title: 'Grocery run', price: 28, date: 'Jan 23', rating: 5, status: 'completed' },
  { id: '3', title: 'Dog walking', price: 20, date: 'Jan 22', rating: 4, status: 'completed' },
  { id: '4', title: 'Moving help', price: 90, date: 'Jan 20', rating: 5, status: 'completed' },
  { id: '5', title: 'Tech support', price: 45, date: 'Jan 18', rating: null, status: 'cancelled' },
];

export function TaskHistoryScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [activeTab, setActiveTab] = useState('Completed');

  const filteredTasks = MOCK_HISTORY.filter(t => 
    activeTab === 'Completed' ? t.status === 'completed' : t.status === 'cancelled'
  );

  const totalEarned = MOCK_HISTORY
    .filter(t => t.status === 'completed')
    .reduce((sum, t) => sum + t.price, 0);

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text variant="title1" color="primary">Task History</Text>
        <Spacing size={8} />
        <View style={styles.summary}>
          <Text variant="body" color="secondary">Total Earned: </Text>
          <MoneyDisplay amount={totalEarned} size="md" />
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
            <Text variant="body" color={activeTab === tab ? 'primary' : 'secondary'}>{tab}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Task List */}
      <ScrollView contentContainerStyle={styles.list}>
        {filteredTasks.length === 0 ? (
          <View style={styles.empty}>
            <Text variant="body" color="secondary">No {activeTab.toLowerCase()} tasks</Text>
          </View>
        ) : (
          filteredTasks.map(task => (
            <React.Fragment key={task.id}>
              <HistoryCard {...task} />
              <Spacing size={12} />
            </React.Fragment>
          ))
        )}
      </ScrollView>
    </View>
  );
}

function HistoryCard({ title, price, date, rating, status }: {
  title: string; price: number; date: string; rating: number | null; status: string;
}) {
  return (
    <Card variant="default" padding="md">
      <View style={styles.cardRow}>
        <View style={styles.cardInfo}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="footnote" color="secondary">{date}</Text>
        </View>
        <View style={styles.cardRight}>
          <MoneyDisplay amount={price} size="sm" />
          {rating && (
            <Text variant="caption" color="secondary">⭐ {rating}.0</Text>
          )}
          {status === 'cancelled' && (
            <Text variant="caption" color="danger">Cancelled</Text>
          )}
        </View>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { padding: theme.spacing[4] },
  summary: { flexDirection: 'row', alignItems: 'center' },
  tabs: { flexDirection: 'row', paddingHorizontal: theme.spacing[4], borderBottomWidth: 1, borderBottomColor: theme.colors.surface.secondary },
  tab: { paddingVertical: theme.spacing[3], paddingHorizontal: theme.spacing[4], marginRight: theme.spacing[4] },
  tabActive: { borderBottomWidth: 2, borderBottomColor: theme.colors.brand.primary },
  list: { padding: theme.spacing[4] },
  empty: { alignItems: 'center', paddingVertical: theme.spacing[8] },
  cardRow: { flexDirection: 'row', justifyContent: 'space-between' },
  cardInfo: { flex: 1 },
  cardRight: { alignItems: 'flex-end' },
});

export default TaskHistoryScreen;
