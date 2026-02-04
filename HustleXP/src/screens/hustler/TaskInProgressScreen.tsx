/**
 * TaskInProgressScreen — B3.4 Assembly
 *
 * Archetype: C — Task Lifecycle
 * Composes: StatusBanner, TaskCard, Progress, ActionBar (molecule patterns)
 * Intent: "I'm working. The system knows. Progress is visible."
 * Wired to: taskProgress.adapter (mock data)
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBanner, TaskCard, ActionBar } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { BRAND, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';
import { getTaskProgressData } from '../../data/adapters';
import type { TaskProgressProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';

// --- Progress (local atom, not a molecule) ---
function Progress({ value }: { value: number }) {
  return (
    <View style={progressStyles.track}>
      <View
        style={[
          progressStyles.fill,
          {
            width: `${Math.max(0, Math.min(1, value)) * 100}%`,
          },
        ]}
      />
    </View>
  );
}

const progressStyles = StyleSheet.create({
  track: {
    height: 6,
    backgroundColor: GRAY[200],
    borderRadius: 3,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    backgroundColor: BRAND.PRIMARY,
    borderRadius: 3,
  },
});

// Hardcoded task ID for now (no navigation changes allowed)
const TASK_ID = 'task-1';

// --- TaskInProgressScreen ---
export default function TaskInProgressScreen() {
  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<TaskProgressProps | null>(null);

  useEffect(() => {
    logScreenMount('TaskInProgressScreen');

    getTaskProgressData(TASK_ID).then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'TaskInProgressScreen',
          adapter: 'taskProgress',
        });
      }
    });
  }, []);

  // Loading state — skeleton placeholder
  if (state === 'loading') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.scrollContent}>
          <StatusBanner tone="info" text="Loading task status" />
          <View style={styles.spacer} />
          <View style={[styles.skeleton, { height: 120 }]} />
          <View style={styles.spacer} />
          <View style={[styles.skeleton, { height: 6 }]} />
        </View>
      </SafeAreaView>
    );
  }

  // Error state — StatusBanner with danger tone
  if (state === 'error' || !data) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.scrollContent}>
          <StatusBanner tone="danger" text="Something went wrong. Pull to retry." />
        </View>
      </SafeAreaView>
    );
  }

  // Success state — UI varies by taskState
  const { task, taskState, elapsedTime } = data;

  // Derive UI from taskState
  const isEnRoute = taskState === 'EN_ROUTE';
  const bannerTone = isEnRoute ? 'info' : 'success';
  const bannerText = isEnRoute ? 'On the way to task location' : 'Task in progress';
  const primaryLabel = isEnRoute ? 'Mark arrived' : 'Mark complete';

  // Progress value: elapsedTime / estimatedDuration (seconds vs minutes)
  const progressValue = task.estimatedDuration > 0
    ? elapsedTime / (task.estimatedDuration * 60)
    : 0;

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <StatusBanner tone={bannerTone} text={bannerText} />

        <View style={styles.spacer} />

        <TaskCard
          title={task.title}
          priceLabel={`$${task.priceAmount}`}
          metaLabel={`${task.location.distance ?? 0} mi · ${task.estimatedDuration} min`}
          emphasis="default"
        />

        <View style={styles.spacer} />

        <Progress value={progressValue} />

        <View style={styles.spacer} />
        <View style={styles.divider} />
        <View style={styles.spacer} />

        <Text style={styles.statusText}>
          {isEnRoute
            ? `Heading to ${data.destination.address}`
            : 'You are currently working on this task.'}
        </Text>

        <View style={styles.spacer} />
      </ScrollView>

      <ActionBar primaryLabel={primaryLabel} secondaryLabel="Cancel" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  scroll: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[2],
  },
  spacer: {
    height: SPACING[4],
  },
  divider: {
    height: 1,
    backgroundColor: GRAY[200],
  },
  statusText: {
    fontSize: FONT_SIZE.base,
    color: GRAY[600],
    lineHeight: 22,
  },
  skeleton: {
    backgroundColor: GRAY[200],
    borderRadius: 8,
  },
});
