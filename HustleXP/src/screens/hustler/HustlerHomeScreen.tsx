/**
 * HustlerHomeScreen — B3.1 Assembly
 *
 * Archetype: A — Dashboard / Status
 * Composes: StatusBanner, TaskCard, EmptyState (molecule patterns)
 * Wired to: hustlerHome.adapter (mock data)
 */

import React, { useState, useEffect } from 'react';
import { View, ScrollView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBanner, TaskCard, EmptyState } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { getHustlerHomeData } from '../../data/adapters';
import type { HustlerHomeProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';

export default function HustlerHomeScreen() {
  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<HustlerHomeProps | null>(null);

  useEffect(() => {
    logScreenMount('HustlerHomeScreen');

    getHustlerHomeData().then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'HustlerHomeScreen',
          adapter: 'hustlerHome',
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

  // Success state — dashboard content from adapter
  const { activeTask, availableTasksCount, systemStatus } = data;

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      {/* StatusBanner from adapter systemStatus */}
      {systemStatus && (
        <View style={styles.bannerSection}>
          <StatusBanner tone={systemStatus.tone} text={systemStatus.message} />
        </View>
      )}

      {/* Default info banner when no systemStatus */}
      {!systemStatus && availableTasksCount > 0 && (
        <View style={styles.bannerSection}>
          <StatusBanner
            tone="info"
            text={`${availableTasksCount} tasks nearby`}
          />
        </View>
      )}

      <View style={styles.spacer} />

      <ScrollView
        style={styles.list}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Active task card if exists */}
        {activeTask && (
          <View style={styles.listItem}>
            <TaskCard
              title={activeTask.title}
              priceLabel={`$${activeTask.priceAmount}`}
              metaLabel={`${activeTask.location.distance ?? 0} mi · ${activeTask.estimatedDuration} min`}
              badge="ACTIVE"
              emphasis="highlighted"
            />
          </View>
        )}

        {/* Empty state when no active task and no available tasks */}
        {!activeTask && availableTasksCount === 0 && (
          <EmptyState
            icon="🕐"
            title="You're early"
            description="New tasks usually appear in the next few minutes"
          />
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
