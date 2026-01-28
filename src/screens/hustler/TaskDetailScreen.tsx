/**
 * TaskDetailScreen - Full task details and accept flow
 * 
 * CHOSEN-STATE: "I'll do this" / "Let's go" - confirmation not action
 * - Price displayed with HMoney (empowering)
 * - Requirements in soft HBadges
 * - Distance/time in tertiary colors
 * - Floating signals show system alive
 */

import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Pressable, Alert } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HScreen,
  HText,
  HCard,
  HButton,
  HBadge,
  HMoney,
  HSignal,
  HActivityIndicator,
} from '../../components/atoms';
import { TaskMap } from '../../components';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore, useAuthStore } from '../../store';
import { useTasks } from '../../hooks';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type TaskDetailRouteProp = RouteProp<RootStackParamList, 'TaskDetail'>;

export function TaskDetailScreen() {
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
      Alert.alert('Hmm', 'Couldn\'t grab this one. Try again?');
    }
  };

  const handleChat = () => {
    navigation.navigate('TaskConversation', { taskId });
  };

  // Loading state
  if (!task) {
    return (
      <HScreen ambient>
        <View style={styles.centered}>
          <HActivityIndicator active label="Loading task..." />
        </View>
      </HScreen>
    );
  }

  const formatDistance = (miles?: number) => {
    if (!miles) return 'Nearby';
    return miles < 1 ? `${(miles * 5280).toFixed(0)} ft away` : `${miles.toFixed(1)} mi away`;
  };
  
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `~${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return mins > 0 ? `~${hours}h ${mins}m` : `~${hours} hr${hours > 1 ? 's' : ''}`;
  };

  const canClaim = task.status === 'open' && (!user || user.trustTier >= task.requiredTrustTier);
  const hasRequirements = task.requiresVehicle || task.requiresTools.length > 0 || 
    task.requiresBackground || task.requiredTrustTier > 1;

  // Footer CTA
  const footer = task.status === 'open' ? (
    <View>
      {!canClaim && user && user.trustTier < task.requiredTrustTier ? (
        <HButton 
          variant="secondary" 
          size="lg"
          fullWidth
          onPress={() => navigation.navigate('TrustTierLocked', { feature: `Tier ${task.requiredTrustTier} tasks` })}
        >
          {`Unlock at Tier ${task.requiredTrustTier}`}
        </HButton>
      ) : (
        <HButton 
          variant="primary" 
          size="lg"
          fullWidth
          onPress={handleAcceptTask}
          loading={claiming}
        >
          {task.maxPay >= 50 ? "Let's go" : "I'll do this"}
        </HButton>
      )}
    </View>
  ) : undefined;

  return (
    <HScreen scroll ambient footer={footer}>
      {/* Back Button */}
      <Pressable onPress={handleBack} style={styles.backButton}>
        <HText variant="body" color="purple">← Back</HText>
      </Pressable>

      {/* Floating activity signal - system alive */}
      <View style={styles.signalFloat}>
        <HSignal 
          text="Others are viewing this task"
          icon="👀"
          delay={2000}
          duration={4000}
        />
      </View>

      {/* Header */}
      <HText variant="title1">{task.title}</HText>
      <View style={styles.spacer8} />
      
      {/* Meta - soft tertiary colors, not alarming */}
      <View style={styles.meta}>
        <HText variant="footnote" color="tertiary">📍 {formatDistance(task.distance)}</HText>
        <HText variant="footnote" color="tertiary">⏱️ {formatTime(task.estimatedMinutes)}</HText>
      </View>

      <View style={styles.spacer24} />

      {/* Price Card - the empowerment moment */}
      <HCard variant="success" padding="xl">
        <View style={styles.priceRow}>
          <HText variant="body" color="secondary">You'll earn</HText>
          <HMoney amount={task.maxPay} size="lg" />
        </View>
        {task.minPay !== task.maxPay && (
          <>
            <View style={styles.spacer4} />
            <HText variant="caption" color="muted">
              Range: ${task.minPay} – ${task.maxPay} based on complexity
            </HText>
          </>
        )}
        <View style={styles.spacer12} />
        <View style={styles.xpRow}>
          <HBadge variant="success" size="sm">+{task.baseXP} XP</HBadge>
          {task.bonusXP && (
            <HBadge variant="warning" size="sm">+{task.bonusXP} bonus</HBadge>
          )}
        </View>
        <View style={styles.spacer8} />
        <HText variant="caption" color="muted">
          Payment secured until you're done
        </HText>
      </HCard>

      <View style={styles.spacer24} />

      {/* Requirements - if any */}
      {hasRequirements && (
        <>
          <HText variant="headline">What you'll need</HText>
          <View style={styles.spacer12} />
          <View style={styles.requirementsList}>
            {task.requiresVehicle && (
              <HBadge variant="default" size="md">🚗 Vehicle</HBadge>
            )}
            {task.requiresTools.map(tool => (
              <HBadge key={tool} variant="default" size="md">🔧 {tool}</HBadge>
            ))}
            {task.requiresBackground && (
              <HBadge variant="default" size="md">✓ Background check</HBadge>
            )}
            {task.requiredTrustTier > 1 && (
              <HBadge variant="purple" size="md" pulsing>
                ⭐ Tier {task.requiredTrustTier}+
              </HBadge>
            )}
          </View>
          <View style={styles.spacer24} />
        </>
      )}

      {/* Description */}
      <HText variant="headline">About this task</HText>
      <View style={styles.spacer8} />
      <HText variant="body" color="secondary">{task.description}</HText>

      <View style={styles.spacer24} />

      {/* Details */}
      <HText variant="headline">Details</HText>
      <View style={styles.spacer12} />
      <HCard variant="default" padding="lg">
        <DetailRow label="Category" value={task.category.replace('_', ' ')} />
        <DetailRow label="Duration" value={formatTime(task.estimatedMinutes)} />
        <DetailRow label="Location" value={task.address} isLast />
      </HCard>

      <View style={styles.spacer24} />

      {/* Location Map */}
      {task.latitude && task.longitude && (
        <>
          <HText variant="headline">Location</HText>
          <View style={styles.spacer12} />
          <TaskMap
            location={{
              latitude: task.latitude,
              longitude: task.longitude,
              title: task.title,
              description: task.address,
            }}
            height={180}
          />
          <View style={styles.spacer24} />
        </>
      )}

      {/* Poster Info */}
      <HText variant="headline">Posted by</HText>
      <View style={styles.spacer12} />
      <HCard variant="default" padding="lg" onPress={handleChat}>
        <View style={styles.posterRow}>
          <View style={styles.avatar}>
            <HText variant="title2">👤</HText>
          </View>
          <View style={styles.posterInfo}>
            <HText variant="headline">{task.posterName}</HText>
            <HText variant="footnote" color="tertiary">Tap to chat</HText>
          </View>
          <HBadge variant="purple" size="sm">💬</HBadge>
        </View>
      </HCard>

      <View style={styles.spacer40} />
    </HScreen>
  );
}

function DetailRow({ label, value, isLast }: { label: string; value: string; isLast?: boolean }) {
  return (
    <View style={[styles.detailRow, !isLast && styles.detailRowBorder]}>
      <HText variant="body" color="tertiary">{label}</HText>
      <HText variant="body" color="secondary">{value}</HText>
    </View>
  );
}

const styles = StyleSheet.create({
  centered: { 
    flex: 1, 
    justifyContent: 'center', 
    alignItems: 'center',
  },
  backButton: { 
    marginBottom: hustleSpacing.md,
  },
  signalFloat: {
    position: 'absolute',
    top: 60,
    right: 20,
    zIndex: 10,
  },
  meta: { 
    flexDirection: 'row', 
    gap: hustleSpacing.lg,
  },
  priceRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  xpRow: { 
    flexDirection: 'row',
    gap: hustleSpacing.sm,
  },
  requirementsList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: hustleSpacing.sm,
  },
  detailRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
    paddingVertical: hustleSpacing.sm,
  },
  detailRowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: hustleColors.glass.border,
  },
  posterRow: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  avatar: { 
    width: 48, 
    height: 48, 
    borderRadius: 24, 
    backgroundColor: hustleColors.dark.surface, 
    justifyContent: 'center', 
    alignItems: 'center',
  },
  posterInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  spacer4: { height: 4 },
  spacer8: { height: 8 },
  spacer12: { height: 12 },
  spacer24: { height: 24 },
  spacer40: { height: 40 },
});

export default TaskDetailScreen;
