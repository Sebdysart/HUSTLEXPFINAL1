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
import { useNavigation, useRoute } from '@react-navigation/native';
import { StatusBanner, TaskCard, ActionBar } from '../../components/molecules';
import { SPACING } from '../../../constants';
import { BRAND, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';
import { getTaskProgressData } from '../../data/adapters';
import type { TaskProgressProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';
import { TRPCClient } from '../../network/trpcClient';

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

// --- TaskInProgressScreen ---
export default function TaskInProgressScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const taskId: string = route.params?.taskId ?? 'task-1';

  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<TaskProgressProps | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [isActing, setIsActing] = useState(false);

  useEffect(() => {
    logScreenMount('TaskInProgressScreen');

    getTaskProgressData(taskId).then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'TaskInProgressScreen',
          adapter: 'taskProgress',
        });
      }
    });
  }, [taskId]);

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

  const handlePrimary = async () => {
    if (isActing) return;
    setIsActing(true);
    setActionError(null);
    try {
      if (isEnRoute) {
        await TRPCClient.shared.call<{ taskId: string }, any>('task', 'start', 'mutation', { taskId });
        // Refresh state from REST adapter
        const result = await getTaskProgressData(taskId);
        setState(result.state);
        if (result.state === 'success') setData(result.props);
      } else {
        navigation.navigate('ProofSubmission', { taskId });
      }
    } catch (e) {
      setActionError(e instanceof Error ? e.message : 'Failed to update task');
    } finally {
      setIsActing(false);
    }
  };

  const handleCancel = async () => {
    if (isActing) return;
    setIsActing(true);
    setActionError(null);
    try {
      await TRPCClient.shared.call<{ taskId: string; reason: string | null }, any>(
        'task',
        'cancel',
        'mutation',
        { taskId, reason: null }
      );
      navigation.goBack();
    } catch (e) {
      setActionError(e instanceof Error ? e.message : 'Failed to cancel task');
    } finally {
      setIsActing(false);
    }
  };

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      {actionError ? (
        <View style={styles.errorBanner}>
          <StatusBanner tone="danger" text={actionError} />
        </View>
      ) : null}
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

      <ActionBar
        primary={{ label: primaryLabel, loading: isActing, disabled: false }}
        secondary={{ label: 'Cancel', disabled: false }}
        onPrimary={handlePrimary}
        onSecondary={handleCancel}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  errorBanner: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[2],
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
