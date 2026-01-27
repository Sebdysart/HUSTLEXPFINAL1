/**
 * TaskDetailScreen - Full task details and accept flow
 */

import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, MoneyDisplay, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';
import { useTaskStore, useAuthStore, Task } from '../../store';
import { useTasks } from '../../hooks';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type TaskDetailRouteProp = RouteProp<RootStackParamList, 'TaskDetail'>;

export function TaskDetailScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<TaskDetailRouteProp>();
  const { taskId } = route.params;
  
  const { tasks, setActiveTask } = useTaskStore();
  const { user } = useAuthStore();
  const { claimTask } = useTasks({ autoFetch: false });
  
  const [claiming, setClaiming] = useState(false);
  const task = tasks.find(t => t.id === taskId);

  useEffect(() => {
    if (task) {
      setActiveTask(task);
    }
  }, [task, setActiveTask]);

  const handleBack = () => {
    navigation.goBack();
  };

  const handleAcceptTask = async () => {
    if (!task || !user) return;
    
    // Check trust tier requirement
    if (user.trustTier < task.requiredTrustTier) {
      navigation.navigate('TrustTierLocked', { feature: `Tier ${task.requiredTrustTier} tasks` });
      return;
    }

    setClaiming(true);
    const success = await claimTask(taskId);
    setClaiming(false);

    if (success) {
      navigation.navigate('TaskInProgress', { taskId });
    } else {
      Alert.alert('Error', 'Failed to claim task. Please try again.');
    }
  };

  const handleChat = () => {
    navigation.navigate('TaskConversation', { taskId });
  };

  if (!task) {
    return (
      <View style={[styles.container, styles.centered, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color={theme.colors.brand.primary} />
        <Spacing size={12} />
        <Text variant="body" color="secondary">Loading task...</Text>
      </View>
    );
  }

  const formatDistance = (miles?: number) => {
    if (!miles) return 'Unknown';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft` : `${miles.toFixed(1)} mi`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return mins > 0 ? `${hours}h ${mins}m` : `${hours} hr${hours > 1 ? 's' : ''}`;
  };

  const canClaim = task.status === 'open' && (!user || user.trustTier >= task.requiredTrustTier);

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Back Button */}
      <TouchableOpacity style={styles.backButton} onPress={handleBack}>
        <Text variant="body" color="primary">← Back</Text>
      </TouchableOpacity>

      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Header */}
        <Text variant="title1" color="primary">{task.title}</Text>
        <Spacing size={4} />
        <View style={styles.meta}>
          <Text variant="footnote" color="secondary">📍 {formatDistance(task.distance)} away</Text>
          <Text variant="footnote" color="secondary">⏱️ Est. {formatTime(task.estimatedMinutes)}</Text>
        </View>

        <Spacing size={20} />

        {/* Price Card */}
        <Card variant="elevated" padding="lg">
          <View style={styles.priceRow}>
            <Text variant="body" color="secondary">Task Payment</Text>
            <MoneyDisplay amount={task.maxPay} size="lg" />
          </View>
          {task.minPay !== task.maxPay && (
            <>
              <Spacing size={4} />
              <Text variant="caption" color="tertiary">Range: ${task.minPay} - ${task.maxPay}</Text>
            </>
          )}
          <Spacing size={8} />
          <View style={styles.xpRow}>
            <Text variant="caption" color="success">+{task.baseXP} XP</Text>
            {task.bonusXP && (
              <Text variant="caption" color="success"> + {task.bonusXP} bonus XP</Text>
            )}
          </View>
          <Spacing size={8} />
          <Text variant="caption" color="tertiary">Payment held in escrow until completion</Text>
        </Card>

        <Spacing size={20} />

        {/* Requirements */}
        {(task.requiresVehicle || task.requiresTools.length > 0 || task.requiresBackground) && (
          <>
            <Text variant="headline" color="primary">Requirements</Text>
            <Spacing size={12} />
            <Card variant="default" padding="md">
              {task.requiresVehicle && (
                <View style={styles.requirementRow}>
                  <Text variant="body" color="secondary">🚗 Vehicle required</Text>
                </View>
              )}
              {task.requiresTools.length > 0 && (
                <View style={styles.requirementRow}>
                  <Text variant="body" color="secondary">🔧 Tools: {task.requiresTools.join(', ')}</Text>
                </View>
              )}
              {task.requiresBackground && (
                <View style={styles.requirementRow}>
                  <Text variant="body" color="secondary">✓ Background check required</Text>
                </View>
              )}
              {task.requiredTrustTier > 1 && (
                <View style={styles.requirementRow}>
                  <Text variant="body" color="secondary">⭐ Trust Tier {task.requiredTrustTier}+ required</Text>
                </View>
              )}
            </Card>
            <Spacing size={20} />
          </>
        )}

        {/* Description */}
        <Text variant="headline" color="primary">Description</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">{task.description}</Text>

        <Spacing size={20} />

        {/* Details */}
        <Text variant="headline" color="primary">Details</Text>
        <Spacing size={12} />
        <DetailRow label="Category" value={task.category.replace('_', ' ')} />
        <DetailRow label="Duration" value={`~${formatTime(task.estimatedMinutes)}`} />
        <DetailRow label="Location" value={task.address} />

        <Spacing size={20} />

        {/* Poster Info */}
        <Text variant="headline" color="primary">Posted by</Text>
        <Spacing size={12} />
        <Card variant="default" padding="md">
          <View style={styles.posterRow}>
            <View style={styles.avatar}>
              <Text variant="title2">👤</Text>
            </View>
            <View style={styles.posterInfo}>
              <Text variant="headline" color="primary">{task.posterName}</Text>
              <Text variant="footnote" color="secondary">Poster</Text>
            </View>
            <Button variant="ghost" size="sm" onPress={handleChat}>
              💬 Chat
            </Button>
          </View>
        </Card>

        <Spacing size={80} />
      </ScrollView>

      {/* CTA */}
      {task.status === 'open' && (
        <View style={styles.footer}>
          {!canClaim && user && user.trustTier < task.requiredTrustTier ? (
            <Button 
              variant="secondary" 
              size="lg" 
              onPress={() => navigation.navigate('TrustTierLocked', { feature: `Tier ${task.requiredTrustTier} tasks` })}
            >
              {`Requires Trust Tier ${task.requiredTrustTier}`}
            </Button>
          ) : (
            <Button 
              variant="primary" 
              size="lg" 
              onPress={handleAcceptTask}
              loading={claiming}
            >
              {`Accept Task — $${task.maxPay}`}
            </Button>
          )}
        </View>
      )}
    </View>
  );
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.detailRow}>
      <Text variant="body" color="secondary">{label}</Text>
      <Text variant="body" color="primary">{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  centered: { justifyContent: 'center', alignItems: 'center' },
  backButton: { padding: theme.spacing[4], paddingBottom: 0 },
  scroll: { padding: theme.spacing[4] },
  meta: { flexDirection: 'row', gap: theme.spacing[4] },
  priceRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  xpRow: { flexDirection: 'row' },
  requirementRow: { marginBottom: theme.spacing[2] },
  detailRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: theme.spacing[3] },
  posterRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 48, height: 48, borderRadius: 24, backgroundColor: theme.colors.surface.tertiary, justifyContent: 'center', alignItems: 'center' },
  posterInfo: { flex: 1, marginLeft: theme.spacing[3] },
  footer: { padding: theme.spacing[4], borderTopWidth: 1, borderTopColor: theme.colors.surface.secondary },
});

export default TaskDetailScreen;
