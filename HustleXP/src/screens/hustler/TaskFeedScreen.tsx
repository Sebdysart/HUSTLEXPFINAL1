/**
 * TaskFeedScreen — B3.2 Assembly
 *
 * Archetype: A — Feed / Opportunity Discovery
 * Composes: StatusBanner, List, TaskCard, EmptyState (molecule patterns)
 * Intent: "What can I do right now?"
 * Wired to: taskFeed.adapter (mock data)
 */

import React, { useState, useEffect } from 'react';
import { View, ScrollView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBanner, TaskCard, EmptyState } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { getTaskFeedData } from '../../data/adapters';
import type { TaskFeedProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';

export default function TaskFeedScreen() {
  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<TaskFeedProps | null>(null);

  useEffect(() => {
    logScreenMount('TaskFeedScreen');

    getTaskFeedData().then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'TaskFeedScreen',
          adapter: 'taskFeed',
        });
      }
    });
  }, []);

  // Loading state — skeleton placeholder
  if (state === 'loading') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.bannerSection}>
          <View style={[styles.skeleton, { height: 48 }]} />
        </View>
        <View style={styles.spacer} />
        <View style={styles.listContent}>
          <View style={[styles.skeleton, styles.skeletonCard]} />
          <View style={[styles.skeleton, styles.skeletonCard]} />
          <View style={[styles.skeleton, styles.skeletonCard]} />
        </View>
      </SafeAreaView>
    );
  }

  // Error state — StatusBanner with danger tone
  if (state === 'error' || !data) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.bannerSection}>
          <StatusBanner tone="danger" text="Something went wrong. Pull to retry." />
        </View>
      </SafeAreaView>
    );
  }

  // Empty state — no tasks available
  if (state === 'empty' || data.tasks.length === 0) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <EmptyState
          icon="📋"
          title="No tasks available"
          description="Check back soon or adjust your filters."
        />
      </SafeAreaView>
    );
  }

  // Success state — task list from adapter
  const { tasks, hasMore, systemStatus } = data;

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      {/* StatusBanner from adapter systemStatus */}
      {systemStatus && (
        <View style={styles.bannerSection}>
          <StatusBanner tone={systemStatus.tone} text={systemStatus.message} />
        </View>
      )}

      {/* Default info banner when no systemStatus */}
      {!systemStatus && (
        <View style={styles.bannerSection}>
          <StatusBanner tone="info" text={`${tasks.length} tasks available`} />
        </View>
      )}

      <View style={styles.spacer} />

      <ScrollView
        style={styles.list}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      >
        {tasks.map((task) => (
          <View key={task.id} style={styles.listItem}>
            <TaskCard
              title={task.title}
              priceLabel={`$${task.priceAmount}`}
              metaLabel={`${task.location.distance ?? 0} mi · ${task.estimatedDuration} min`}
              emphasis="default"
            />
          </View>
        ))}

        {/* Pagination placeholder if hasMore */}
        {hasMore && (
          <View style={[styles.skeleton, styles.skeletonCard]} />
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  bannerSection: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[2],
  },
  spacer: {
    height: SPACING[4],
  },
  list: {
    flex: 1,
  },
  listContent: {
    paddingHorizontal: SPACING[4],
    paddingBottom: SPACING[8],
  },
  listItem: {
    marginBottom: SPACING[4],
  },
  skeleton: {
    backgroundColor: GRAY[200],
    borderRadius: 8,
  },
  skeletonCard: {
    height: 100,
    marginBottom: SPACING[4],
  },
});
