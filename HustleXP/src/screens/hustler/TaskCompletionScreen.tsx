/**
 * TaskCompletionScreen — B3.10 Assembly
 *
 * Archetype: C — Task Lifecycle (terminal completion)
 * Composes: StatusBanner, GlassCard (molecule patterns)
 * Intent: Confirm task completion, reinforce success, present status.
 * Wired to: taskCompletion.adapter (mock data)
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GlassCard } from '../../../components';
import { StatusBanner } from '../../components/molecules';
import { SPACING, RADIUS } from '../../../constants';
import { DARK, STATUS, GRAY } from '../../../constants/colors';
import { FONT_SIZE } from '../../../constants/typography';
import { getTaskCompletionData } from '../../data/adapters';
import type { TaskCompletionProps } from '../../data/adapters';
import type { AdapterState } from '../../data/types';
import { logScreenMount, logError, ERROR_CODES } from '../../observability';

// Hardcoded task ID for now (no navigation changes allowed)
const TASK_ID = 'task-1';

// --- TaskCompletionScreen ---
export default function TaskCompletionScreen() {
  const [state, setState] = useState<AdapterState>('loading');
  const [data, setData] = useState<TaskCompletionProps | null>(null);

  useEffect(() => {
    logScreenMount('TaskCompletionScreen');

    getTaskCompletionData(TASK_ID).then((result) => {
      setState(result.state);
      setData(result.props);

      if (result.state === 'error') {
        logError('adapter', ERROR_CODES.INVALID_RESPONSE, 'Adapter returned error state', {
          screen: 'TaskCompletionScreen',
          adapter: 'taskCompletion',
        });
      }
    });
  }, []);

  // Loading state — skeleton placeholder
  if (state === 'loading') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.scrollContent}>
          <View style={[styles.skeleton, { height: 80 }]} />
          <View style={styles.spacer} />
          <View style={[styles.skeleton, { height: 120 }]} />
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

  // Success state — branch by submissionStatus
  const { task, submissionStatus, rejectionReason, xpAwarded, earningsAmount } = data;

  // Derive UI config from submissionStatus
  const getStatusConfig = (): {
    banner: { tone: 'info' | 'success' | 'warning' | 'danger'; text: string } | null;
    badgeText: string;
    badgeColor: string;
  } => {
    switch (submissionStatus) {
      case 'pending':
        return { banner: null, badgeText: 'Pending', badgeColor: GRAY[400] };
      case 'submitted':
        return { banner: { tone: 'info', text: 'Proof submitted' }, badgeText: 'Submitted', badgeColor: STATUS.INFO };
      case 'approved':
        return { banner: { tone: 'success', text: 'Task approved' }, badgeText: 'Completed', badgeColor: STATUS.SUCCESS };
      case 'rejected':
        return { banner: { tone: 'warning', text: rejectionReason || 'Submission rejected' }, badgeText: 'Rejected', badgeColor: STATUS.WARNING };
    }
  };

  const config = getStatusConfig();

  // Build meta string: earnings + XP (if present)
  const metaParts: string[] = [`$${earningsAmount}`];
  if (xpAwarded !== null) {
    metaParts.push(`+${xpAwarded} XP`);
  }
  const metaText = metaParts.join(' • ');

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {config.banner && (
          <>
            <StatusBanner tone={config.banner.tone} text={config.banner.text} />
            <View style={styles.spacer} />
          </>
        )}

        <GlassCard variant="secondary">
          <View style={styles.cardContent}>
            <View style={styles.cardHeader}>
              <Text style={styles.cardTitle} numberOfLines={2}>
                {task.title}
              </Text>
              <View style={[styles.badge, { backgroundColor: config.badgeColor }]}>
                <Text style={styles.badgeText}>{config.badgeText}</Text>
              </View>
            </View>
            <Text style={styles.cardMeta}>{metaText}</Text>
          </View>
        </GlassCard>

        {submissionStatus === 'rejected' && rejectionReason && (
          <>
            <View style={styles.spacer} />
            <Text style={styles.rejectionText}>{rejectionReason}</Text>
          </>
        )}

        <View style={styles.spacer} />
      </ScrollView>

      {/* ActionBar removed — actions always disabled post-submission */}
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
  cardContent: {
    padding: SPACING[4],
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING[2],
  },
  cardTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: '600' as const,
    color: GRAY[900],
    flex: 1,
  },
  badge: {
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[1],
    borderRadius: RADIUS.full,
    marginLeft: SPACING[2],
  },
  badgeText: {
    fontSize: FONT_SIZE.xs,
    fontWeight: '600' as const,
    color: DARK.TEXT,
  },
  cardMeta: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
  },
  skeleton: {
    backgroundColor: GRAY[200],
    borderRadius: 8,
  },
  rejectionText: {
    fontSize: FONT_SIZE.sm,
    color: GRAY[600],
    lineHeight: 20,
  },
});
