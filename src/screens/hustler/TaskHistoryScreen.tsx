import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskHistoryScreen() {
  const [dateRange, setDateRange] = useState<'week' | 'month' | 'all'>('all');

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.earningsSummary}>
        <Text style={styles.summaryLabel}>Total Earnings</Text>
        <Text style={styles.summaryValue}>$0.00</Text>
      </View>

      <View style={styles.filterContainer}>
        <Text style={styles.sectionTitle}>Filter By Date</Text>
        <View style={styles.filterRow}>
          <TouchableOpacity
            style={[styles.filterButton, dateRange === 'week' && styles.filterButtonActive]}
            onPress={() => setDateRange('week')}
          >
            <Text style={[styles.filterText, dateRange === 'week' && styles.filterTextActive]}>Week</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, dateRange === 'month' && styles.filterButtonActive]}
            onPress={() => setDateRange('month')}
          >
            <Text style={[styles.filterText, dateRange === 'month' && styles.filterTextActive]}>Month</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, dateRange === 'all' && styles.filterButtonActive]}
            onPress={() => setDateRange('all')}
          >
            <Text style={[styles.filterText, dateRange === 'all' && styles.filterTextActive]}>All</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.emptyState}>
        <Text style={styles.emptyText}>No completed tasks</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  contentContainer: {
    padding: SPACING[4],
  },
  earningsSummary: {
    padding: SPACING[5],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  summaryLabel: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  summaryValue: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  filterContainer: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  filterRow: {
    flexDirection: 'row',
    gap: SPACING[2],
  },
  filterButton: {
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[2],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    marginRight: SPACING[2],
  },
  filterButtonActive: {
    backgroundColor: NEUTRAL.TEXT,
  },
  filterText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT,
  },
  filterTextActive: {
    color: NEUTRAL.TEXT_INVERSE,
  },
  emptyState: {
    flex: 1,
    padding: SPACING[8],
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 300,
  },
  emptyText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
});
