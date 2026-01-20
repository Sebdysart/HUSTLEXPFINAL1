import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, TouchableOpacity } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TaskFeedScreen() {
  const [refreshing, setRefreshing] = useState(false);
  const [sortBy, setSortBy] = useState<'newest' | 'highest' | 'closest'>('newest');

  const onRefresh = () => {
    setRefreshing(true);
    console.log('Pull-to-refresh triggered');
    setTimeout(() => setRefreshing(false), 1000);
  };

  return (
    <ScrollView
      style={styles.container}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
    >
      <View style={styles.filtersContainer}>
        <Text style={styles.sectionTitle}>Filters</Text>
        <View style={styles.filterRow}>
          <TouchableOpacity style={styles.filterButton}>
            <Text style={styles.filterText}>Category</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.filterButton}>
            <Text style={styles.filterText}>Distance</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.filterButton}>
            <Text style={styles.filterText}>Pay Range</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.sortContainer}>
        <Text style={styles.sectionTitle}>Sort By</Text>
        <View style={styles.sortRow}>
          <TouchableOpacity
            style={[styles.sortButton, sortBy === 'newest' && styles.sortButtonActive]}
            onPress={() => setSortBy('newest')}
          >
            <Text style={[styles.sortText, sortBy === 'newest' && styles.sortTextActive]}>Newest</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.sortButton, sortBy === 'highest' && styles.sortButtonActive]}
            onPress={() => setSortBy('highest')}
          >
            <Text style={[styles.sortText, sortBy === 'highest' && styles.sortTextActive]}>Highest Pay</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.sortButton, sortBy === 'closest' && styles.sortButtonActive]}
            onPress={() => setSortBy('closest')}
          >
            <Text style={[styles.sortText, sortBy === 'closest' && styles.sortTextActive]}>Closest</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.emptyState}>
        <Text style={styles.emptyText}>No tasks available</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  filtersContainer: {
    padding: SPACING[4],
    borderBottomWidth: 1,
    borderBottomColor: NEUTRAL.BORDER,
  },
  sectionTitle: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  filterRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: SPACING[2],
  },
  filterButton: {
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    marginRight: SPACING[2],
    marginBottom: SPACING[2],
  },
  filterText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT,
  },
  sortContainer: {
    padding: SPACING[4],
    borderBottomWidth: 1,
    borderBottomColor: NEUTRAL.BORDER,
  },
  sortRow: {
    flexDirection: 'row',
    gap: SPACING[2],
  },
  sortButton: {
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    borderRadius: RADIUS.md,
    marginRight: SPACING[2],
  },
  sortButtonActive: {
    backgroundColor: NEUTRAL.TEXT,
  },
  sortText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT,
  },
  sortTextActive: {
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
