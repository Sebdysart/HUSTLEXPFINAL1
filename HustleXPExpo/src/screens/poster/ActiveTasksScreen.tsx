import React, { useEffect, useMemo, useState } from 'react';
import { Alert, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TRPCClient } from '../../network/trpcClient';
import { SPACING } from '../../../constants';
import { GRAY } from '../../../constants/colors';
import { StatusBanner } from '../../components/molecules';
import type { AdapterState } from '../../data/types';

export default function ActiveTasksScreen() {
  const [state, setState] = useState<AdapterState>('loading');
  const [tasks, setTasks] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [actingId, setActingId] = useState<string | null>(null);

  const canReview = useMemo(() => state === 'success' && tasks.length > 0, [state, tasks.length]);

  useEffect(() => {
    let mounted = true;
    (async () => {
      setState('loading');
      setError(null);
      try {
        // List tasks posted by current user.
        // Backend may include multiple states; UI will still allow review actions.
        const response = await TRPCClient.shared.call<{ state: string | null }, any>(
          'task',
          'listByPoster',
          'query',
          { state: null }
        );
        if (!mounted) return;
        // Backend may return either an array or { items: [] } — normalize best-effort.
        const items = Array.isArray(response) ? response : response?.items ?? [];
        setTasks(items);
        setState('success');
      } catch (e) {
        if (!mounted) return;
        setState('error');
        setError(e instanceof Error ? e.message : 'Failed to load active tasks');
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  const refresh = async () => {
    setState('loading');
    setError(null);
    try {
      const response = await TRPCClient.shared.call<{ state: string | null }, any>(
        'task',
        'listByPoster',
        'query',
        { state: null }
      );
      const items = Array.isArray(response) ? response : response?.items ?? [];
      setTasks(items);
      setState('success');
    } catch (e) {
      setState('error');
      setError(e instanceof Error ? e.message : 'Failed to load active tasks');
    }
  };

  const review = async (taskId: string, approved: boolean) => {
    if (actingId) return;
    setActingId(taskId);
    setError(null);
    try {
      await TRPCClient.shared.call<{ taskId: string; approved: boolean; feedback: string | null }, any>(
        'task',
        'reviewProof',
        'mutation',
        { taskId, approved, feedback: null }
      );
      await refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to review proof');
      Alert.alert('Review failed', e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setActingId(null);
    }
  };

  if (state === 'loading') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <StatusBanner tone="info" text="Loading active tasks..." />
        </View>
      </SafeAreaView>
    );
  }

  if (state === 'error') {
    return (
      <SafeAreaView style={styles.root} edges={['top']}>
        <View style={styles.content}>
          <StatusBanner tone="danger" text={error ?? 'Something went wrong.'} />
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <StatusBanner tone={canReview ? 'info' : 'warning'} text={canReview ? 'Review pending proofs' : 'No active tasks'} />

        <View style={{ height: SPACING[4] }} />

        {tasks.length === 0 ? (
          <Text style={styles.emptyText}>Nothing to review right now.</Text>
        ) : (
          tasks.map((t) => (
            <View key={t.id} style={styles.taskCard}>
              <Text style={styles.taskTitle} numberOfLines={2}>
                {t.title ?? 'Untitled task'}
              </Text>
              <Text style={styles.taskMeta}>Task ID: {t.id}</Text>

              <View style={styles.row} />

              <View style={styles.buttonsRow}>
                <TouchableOpacity
                  style={[styles.approveButton, actingId === t.id ? { opacity: 0.7 } : null]}
                  disabled={actingId !== null}
                  onPress={() => review(t.id, true)}
                >
                  <Text style={styles.approveText}>{actingId === t.id ? 'Approving...' : 'Approve'}</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.rejectButton, actingId === t.id ? { opacity: 0.7 } : null]}
                  disabled={actingId !== null}
                  onPress={() => review(t.id, false)}
                >
                  <Text style={styles.rejectText}>{actingId === t.id ? 'Rejecting...' : 'Reject'}</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: GRAY[50] },
  content: {
    paddingHorizontal: SPACING[4],
    paddingTop: SPACING[3],
    paddingBottom: SPACING[8],
  },
  taskCard: {
    borderRadius: 14,
    backgroundColor: 'white',
    padding: SPACING[4],
    marginBottom: SPACING[4],
    borderWidth: 1,
    borderColor: GRAY[200],
  },
  taskTitle: { fontSize: 16, fontWeight: '800', color: GRAY[900], marginBottom: 6 },
  taskMeta: { fontSize: 12, color: GRAY[600], marginBottom: SPACING[3] },
  row: { height: 1 },
  buttonsRow: { flexDirection: 'row', gap: SPACING[3] },
  approveButton: {
    flex: 1,
    height: 44,
    borderRadius: 12,
    backgroundColor: '#16A34A',
    alignItems: 'center',
    justifyContent: 'center',
  },
  rejectButton: {
    flex: 1,
    height: 44,
    borderRadius: 12,
    backgroundColor: '#EF4444',
    alignItems: 'center',
    justifyContent: 'center',
  },
  approveText: { color: 'white', fontWeight: '900' },
  rejectText: { color: 'white', fontWeight: '900' },
  emptyText: { color: GRAY[600], fontSize: 14, fontWeight: '600' },
});
