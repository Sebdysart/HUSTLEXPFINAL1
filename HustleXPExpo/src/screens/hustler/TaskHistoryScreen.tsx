import React, { useEffect, useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TRPCClient } from '../../network/trpcClient';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';
import { TaskCard, EmptyState } from '../../components/molecules';
import type { TaskStatus } from '../../data/types';

type BackendTask = {
  id?: string;
  title?: string;
  payment?: number;
  price?: number;
  estimatedDuration?: string | number;
  estimated_duration?: string | number;
  location?: { distance?: number; address?: string } | string;
  completedAt?: string;
  completed_at?: string;
  state?: string;
};

function normalizeTask(t: BackendTask) {
  const id = t.id ?? '';
  const title = t.title ?? 'Untitled task';

  // backend may return either dollars in `payment` or cents in `price`
  const priceCentsOrDollars = typeof t.payment === 'number' ? t.payment : (typeof t.price === 'number' ? t.price / 100 : 0);

  // estimatedDuration is string-ish in the SwiftUI model; RN UI expects minutes number.
  const estimated =
    typeof t.estimatedDuration === 'number'
      ? t.estimatedDuration
      : typeof t.estimatedDuration === 'string'
        ? Number.parseFloat(t.estimatedDuration) || 0
        : typeof t.estimated_duration === 'number'
          ? t.estimated_duration
          : typeof t.estimated_duration === 'string'
            ? Number.parseFloat(t.estimated_duration) || 0
            : 0;

  const distance =
    typeof t.location === 'object' && t.location
      ? (t.location.distance ?? 0)
      : 0;

  const completedAt = t.completedAt ?? t.completed_at ?? null;

  const state = (t.state ?? '').toLowerCase();
  const status: TaskStatus = state.includes('completed') ? 'completed' : 'open';

  return {
    id,
    title,
    priceAmount: typeof priceCentsOrDollars === 'number' ? priceCentsOrDollars : 0,
    estimatedDuration: estimated,
    distance,
    completedAt,
    status,
  };
}

export default function TaskHistoryScreen() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tasks, setTasks] = useState<BackendTask[]>([]);

  useEffect(() => {
    let mounted = true;

    (async () => {
      try {
        setLoading(true);
        setError(null);

        // SwiftUI uses TaskService.getTaskHistory(role: .hustler) which calls listByWorker.
        const response = await TRPCClient.shared.call<{ state: string | null }, BackendTask[]>(
          'task',
          'listByWorker',
          'query',
          { state: null } as any
        );

        if (!mounted) return;
        setTasks(Array.isArray(response) ? response : []);
      } catch (e) {
        if (!mounted) return;
        setError(e instanceof Error ? e.message : 'Failed to load task history');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const completed = useMemo(() => {
    return tasks
      .filter((t) => (t.state ?? '').toLowerCase() === 'completed' || (t.state ?? '').toLowerCase().includes('completed'))
      .map(normalizeTask);
  }, [tasks]);

  const earned = useMemo(() => {
    return completed.reduce((sum, t) => sum + (t.priceAmount ?? 0), 0);
  }, [completed]);

  if (loading) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <Text style={styles.header}>History</Text>
          <Text style={styles.subtle}>Loading...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <Text style={styles.header}>History</Text>
          <Text style={styles.error}>{error}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Text style={styles.header}>History</Text>
          <Text style={styles.subtle}>{completed.length} completed</Text>
        </View>

        <View style={styles.statsRow}>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{completed.length}</Text>
            <Text style={styles.statLabel}>Completed</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>${Math.round(earned)}</Text>
            <Text style={styles.statLabel}>Earned</Text>
          </View>
        </View>

        <View style={styles.spacerLg} />

        {completed.length === 0 ? (
          <EmptyState icon="clock.arrow.circlepath" title="No Completed Tasks Yet" description="Your completed tasks will appear here." />
        ) : (
          <View>
            {completed.map((t) => (
              <View key={t.id} style={styles.listItem}>
                <TaskCard
                  title={t.title}
                  priceLabel={`$${t.priceAmount}`}
                  metaLabel={t.completedAt ? `Completed · ${new Date(t.completedAt).toLocaleDateString()}` : 'Completed'}
                  badge="COMPLETED"
                  emphasis="default"
                />
              </View>
            ))}
          </View>
        )}

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: GRAY[50],
  },
  content: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
  },
  scrollContent: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: SPACING[10] ?? 32,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    marginBottom: SPACING[3],
  },
  header: {
    fontSize: 22,
    fontWeight: '800',
    color: GRAY[900],
  },
  subtle: {
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '600',
  },
  error: {
    marginTop: SPACING[2],
    color: '#EF4444',
    fontWeight: '700',
  },
  statsRow: {
    flexDirection: 'row',
    gap: SPACING[3],
  },
  statCard: {
    flex: 1,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
    backgroundColor: '#fff',
  },
  statValue: {
    fontSize: 24,
    fontWeight: '800',
    color: GRAY[900],
  },
  statLabel: {
    marginTop: SPACING[1],
    color: GRAY[600],
    fontSize: 13,
    fontWeight: '600',
  },
  spacerLg: {
    height: SPACING[6],
  },
  listItem: {
    marginBottom: SPACING[4],
  },
  bottomSpacer: {
    height: SPACING[8],
  },
});
