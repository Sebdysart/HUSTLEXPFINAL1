/**
 * TaskDetailScreen — B3.3 Assembly
 *
 * Archetype: B — Detail / Decision Point
 * Composes: StatusBanner, TaskCard, ActionBar (molecule patterns)
 * Intent: "I tapped a task. I expect clarity and an obvious next action."
 * Wired to: taskDetail.adapter (mock data)
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
import { GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';
import { getTaskDetailData } from '../../data/adapters';
import type { TaskDetailProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';
import { TRPCClient } from '../../network/trpcClient';

export default function TaskDetailScreen() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const taskId: string = route.params?.taskId ?? 'task-1';

  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<TaskDetailProps | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [isActing, setIsActing] = useState(false);

  useEffect(() => {
    logScreenMount('TaskDetailScreen');

    getTaskDetailData(taskId).then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'TaskDetailScreen',
          adapter: 'taskDetail',
        });
      }
    });
  }, [taskId]);

  // Loading state — skeleton placeholder
  if (state === 'loading') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.scrollContent}>
          <View style={[styles.skeleton, { height: 48 }]} />
          <View style={styles.spacer} />
          <View style={[styles.skeleton, { height: 120 }]} />
          <View style={styles.spacer} />
          <View style={[styles.skeleton, { height: 80 }]} />
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

  // Blocked state — eligibility failure
  if (state === 'blocked') {
    const { task, eligibilityReason } = data;
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <ScrollView
          style={styles.scroll}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <StatusBanner
            tone="warning"
            text={eligibilityReason || 'You are not eligible for this task.'}
          />

          <View style={styles.spacer} />

          <TaskCard
            title={task.title}
            priceLabel={`$${task.priceAmount}`}
            metaLabel={`${task.location.distance ?? 0} mi · ${task.estimatedDuration} min`}
            emphasis="default"
          />

          <View style={styles.spacer} />
          <View style={styles.divider} />
          <View style={styles.spacer} />

          <Text style={styles.detailsTitle}>Task details</Text>
          <View style={styles.detailsSpacer} />
          <Text style={styles.detailsBody}>{task.description}</Text>

          <View style={styles.spacer} />
        </ScrollView>
        {/* ActionBar omitted in blocked state — CTAs disabled */}
      </SafeAreaView>
    );
  }

  // Success state — full UI with actions enabled
  const { task, poster } = data;

  const handleAccept = async () => {
    if (isActing) return;
    setIsActing(true);
    setActionError(null);
    try {
      await TRPCClient.shared.call<{ taskId: string }, any>('task', 'accept', 'mutation', { taskId });
      navigation.navigate('TaskInProgress', { taskId });
    } catch (e) {
      setActionError(e instanceof Error ? e.message : 'Failed to accept task');
    } finally {
      setIsActing(false);
    }
  };

  const handleDecline = async () => {
    if (isActing) return;
    setIsActing(true);
    setActionError(null);
    try {
      await TRPCClient.shared.call<{ taskId: string; reason: string | null }, any>('task', 'cancel', 'mutation', {
        taskId,
        reason: null,
      });
      navigation.goBack();
    } catch (e) {
      setActionError(e instanceof Error ? e.message : 'Failed to decline task');
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
        <TaskCard
          title={task.title}
          priceLabel={`$${task.priceAmount}`}
          metaLabel={`${task.location.distance ?? 0} mi · ${task.estimatedDuration} min`}
          emphasis="default"
        />

        <View style={styles.spacer} />
        <View style={styles.divider} />
        <View style={styles.spacer} />

        <Text style={styles.detailsTitle}>Task details</Text>
        <View style={styles.detailsSpacer} />
        <Text style={styles.detailsBody}>{task.description}</Text>

        <View style={styles.spacer} />

        <Text style={styles.detailsTitle}>Posted by</Text>
        <View style={styles.detailsSpacer} />
        <Text style={styles.detailsBody}>
          {poster.name} · {poster.rating} rating · {poster.taskCount} tasks
        </Text>

        <View style={styles.spacer} />
      </ScrollView>

      <ActionBar
        primary={{ label: 'Accept task', loading: isActing, disabled: false }}
        secondary={{ label: 'Decline', disabled: false }}
        onPrimary={handleAccept}
        onSecondary={handleDecline}
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
  detailsTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
  },
  detailsSpacer: {
    height: SPACING[2],
  },
  detailsBody: {
    fontSize: FONT_SIZE.base,
    color: GRAY[600],
    lineHeight: 22,
  },
  skeleton: {
    backgroundColor: GRAY[200],
    borderRadius: 8,
  },
});
