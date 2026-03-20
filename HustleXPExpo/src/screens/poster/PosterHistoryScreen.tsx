import React, { useEffect, useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TRPCClient } from '../../network/trpcClient';
import { GRAY } from '../../../constants/colors';
import { SPACING } from '../../../constants';
import { EmptyState, TaskCard } from '../../components/molecules';

type BackendTask = {
  id?: string;
  title?: string;
  payment?: number;
  price?: number;
  estimatedDuration?: string | number;
  estimated_duration?: string | number;
  completedAt?: string;
  completed_at?: string;
  state?: string;
};

type HistoryFilter = 'all' | 'completed' | 'cancelled';

function normalizePrice(t: BackendTask) {
  if (typeof t.payment === 'number') return t.payment;
  if (typeof t.price === 'number') return t.price / 100;
  return 0;
}

function normalizeEstimatedDuration(t: BackendTask) {
  const raw = t.estimatedDuration ?? t.estimated_duration;
  if (typeof raw === 'number') return raw;
  if (typeof raw === 'string') return Number.parseFloat(raw) || 0;
  return 0;
}

function normalizeState(t: BackendTask) {
  const s = (t.state ?? '').toLowerCase();
  if (s.includes('completed')) return 'completed';
  if (s.includes('cancelled')) return 'cancelled';
  if (s.includes('disputed')) return 'cancelled';
  return s || 'open';
}

export default function PosterHistoryScreen() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tasks, setTasks] = useState<BackendTask[]>([]);
  const [filter, setFilter] = useState<HistoryFilter>('all');

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError(null);

        // SwiftUI PosterHistoryScreen uses completedTasks from LiveDataService (postedTasks + completed filter).
        // We use listByPoster with null state so backend can return all relevant states.
        const response = await TRPCClient.shared.call<{ state: string | null }, BackendTask[]>(
          'task',
          'listByPoster',
          'query',
          { state: null } as any
        );

        if (!mounted) return;
        setTasks(Array.isArray(response) ? response : []);
      } catch (e) {
        if (!mounted) return;
        setError(e instanceof Error ? e.message : 'Failed to load history');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const filtered = useMemo(() => {
    return tasks
      .map((t) => ({ t, normalizedState: normalizeState(t) }))
      .filter(({ normalizedState }) => {
        if (filter === 'all') return true;
        if (filter === 'completed') return normalizedState === 'completed';
        if (filter === 'cancelled') return normalizedState === 'cancelled';
        return true;
      })
      .map(({ t }) => t);
  }, [tasks, filter]);

  const totalPaid = useMemo(() => {
    const completed = filtered.filter((t) => normalizeState(t) === 'completed');
    return completed.reduce((sum, t) => sum + normalizePrice(t), 0);
  }, [filtered]);

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
          <Text style={styles.subtle}>
            {filter === 'completed'
              ? 'Completed'
              : filter === 'cancelled'
                ? 'Cancelled'
                : 'All'}{' '}
            · {filtered.length}
          </Text>
        </View>

        <View style={styles.filterRow}>
          <FilterButton active={filter === 'all'} title="All" onPress={() => setFilter('all')} />
          <FilterButton active={filter === 'completed'} title="Completed" onPress={() => setFilter('completed')} />
          <FilterButton active={filter === 'cancelled'} title="Cancelled" onPress={() => setFilter('cancelled')} />
        </View>

        <View style={styles.statsRow}>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>${Math.round(totalPaid)}</Text>
            <Text style={styles.statLabel}>Paid (completed)</Text>
          </View>
        </View>

        <View style={styles.spacerLg} />

        {filtered.length === 0 ? (
          <EmptyState
            icon="clock.arrow.circlepath"
            title={filter === 'all' ? 'No Tasks Yet' : `No ${filter} tasks yet`}
            description="Your task history will appear here."
          />
        ) : (
          <View>
            {filtered.map((t) => {
              const priceAmount = normalizePrice(t);
              const estimated = normalizeEstimatedDuration(t);
              const completedAt = t.completedAt ?? t.completed_at ?? null;
              const stateLabel = normalizeState(t).toUpperCase();

              return (
                <View key={t.id} style={styles.listItem}>
                  <TaskCard
                    title={t.title ?? 'Untitled task'}
                    priceLabel={`$${priceAmount}`}
                    metaLabel={
                      completedAt
                        ? `Completed · ${new Date(completedAt).toLocaleDateString()}`
                        : estimated
                          ? `Duration · ${estimated} min`
                          : undefined
                    }
                    badge={stateLabel}
                    emphasis="default"
                  />
                </View>
              );
            })}
          </View>
        )}

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </SafeAreaView>
  );
}

function FilterButton({
  active,
  title,
  onPress,
}: {
  active: boolean;
  title: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity
      style={[styles.filterButton, active ? styles.filterButtonActive : styles.filterButtonInactive]}
      activeOpacity={0.8}
      onPress={onPress}
    >
      <Text style={[styles.filterButtonText, active ? styles.filterButtonTextActive : null]}>{title}</Text>
    </TouchableOpacity>
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
  filterRow: {
    flexDirection: 'row',
    gap: SPACING[2],
    marginBottom: SPACING[3],
  },
  filterButton: {
    flex: 1,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    borderWidth: 1,
  },
  filterButtonActive: {
    backgroundColor: '#5B2DFF',
    borderColor: '#5B2DFF',
  },
  filterButtonInactive: {
    backgroundColor: '#fff',
    borderColor: GRAY[200],
  },
  filterButtonText: {
    fontSize: 13,
    fontWeight: '700',
    color: GRAY[700],
  },
  filterButtonTextActive: {
    color: '#fff',
  },
  statsRow: {
    marginBottom: SPACING[2],
  },
  statCard: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: GRAY[200],
    padding: SPACING[4],
    backgroundColor: '#fff',
  },
  statValue: {
    fontSize: 22,
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
