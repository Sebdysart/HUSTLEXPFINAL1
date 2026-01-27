/**
 * TaskReviewScreen - Approve completed task
 * 
 * Archetype C: Task Lifecycle (Review)
 * - Simple approval flow
 * - CTA: "Looks good"
 * - No anxiety, just confirmation
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import {
  HScreen,
  HCard,
  HText,
  HMoney,
  HBadge,
  HButton,
  HInput,
  HTrustBadge,
} from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useTaskStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type RouteProps = RouteProp<RootStackParamList, 'TaskReview'>;

export function TaskReviewScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProps>();
  const { taskId } = route.params || {};

  const { tasks } = useTaskStore();
  const task = taskId ? tasks.find(t => t.id === taskId) : null;

  const [rating, setRating] = useState(0);
  const [review, setReview] = useState('');

  const handleApprove = () => {
    console.log('Approve:', { rating, review });
    navigation.navigate('TaskCompletionPoster', { taskId: taskId || '' });
  };

  const handleDispute = () => {
    if (taskId) {
      navigation.navigate('DisputeEntry', { taskId });
    }
  };

  // Mock data
  const hustler = {
    name: 'John D.',
    tier: 3,
  };
  const amount = task?.maxPay || 75;
  const taskTitle = task?.title || 'Help moving furniture';
  const duration = '1h 45m';

  const footer = (
    <View style={styles.footerButtons}>
      <HButton variant="ghost" size="sm" onPress={handleDispute}>
        Report an issue
      </HButton>
      <HButton
        variant={rating > 0 ? 'success' : 'primary'}
        size="lg"
        fullWidth
        disabled={rating === 0}
        onPress={handleApprove}
      >
        Looks good
      </HButton>
    </View>
  );

  return (
    <HScreen ambient footer={footer}>
      {/* Header */}
      <View style={styles.header}>
        <HBadge variant="purple">Ready for review</HBadge>
        <View style={styles.spacerMd} />
        <HText variant="title2" color="primary">
          {hustler.name} finished
        </HText>
      </View>

      <View style={styles.spacerLg} />

      {/* Task Summary */}
      <HCard variant="default" padding="lg">
        <HText variant="headline" color="primary">{taskTitle}</HText>
        <View style={styles.spacerMd} />
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Payment</HText>
          <HMoney amount={amount} size="md" />
        </View>
        <View style={styles.spacerSm} />
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Duration</HText>
          <HText variant="body" color="primary">{duration}</HText>
        </View>
        <View style={styles.spacerSm} />
        <View style={styles.summaryRow}>
          <HText variant="body" color="secondary">Hustler</HText>
          <View style={styles.hustlerBadge}>
            <HText variant="body" color="primary">{hustler.name}</HText>
            <HTrustBadge tier={hustler.tier} size="sm" />
          </View>
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Proof Placeholder */}
      <HCard variant="default" padding="lg">
        <HText variant="headline" color="primary">Completion Photos</HText>
        <View style={styles.spacerMd} />
        <View style={styles.proofPlaceholder}>
          <HText variant="body" color="tertiary">📷</HText>
          <HText variant="caption" color="tertiary">Photo evidence</HText>
        </View>
      </HCard>

      <View style={styles.spacerLg} />

      {/* Rating */}
      <HCard variant="elevated" padding="lg">
        <HText variant="headline" color="primary" center>
          How was {hustler.name.split(' ')[0]}?
        </HText>
        <View style={styles.spacerMd} />
        <View style={styles.stars}>
          {[1, 2, 3, 4, 5].map(star => (
            <TouchableOpacity key={star} onPress={() => setRating(star)}>
              <HText variant="hero" color={star <= rating ? 'warning' : 'muted'}>
                {star <= rating ? '★' : '☆'}
              </HText>
            </TouchableOpacity>
          ))}
        </View>
        <View style={styles.spacerMd} />
        <HInput
          placeholder="Leave a note (optional)"
          value={review}
          onChangeText={setReview}
          multiline
        />
      </HCard>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  header: {
    paddingTop: hustleSpacing.lg,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  hustlerBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.sm,
  },
  proofPlaceholder: {
    height: 120,
    backgroundColor: hustleColors.dark.surface,
    borderRadius: hustleSpacing.md,
    justifyContent: 'center',
    alignItems: 'center',
  },
  stars: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: hustleSpacing.md,
  },
  footerButtons: {
    gap: hustleSpacing.md,
  },
  spacerSm: { height: hustleSpacing.sm },
  spacerMd: { height: hustleSpacing.md },
  spacerLg: { height: hustleSpacing.xl },
});

export default TaskReviewScreen;
