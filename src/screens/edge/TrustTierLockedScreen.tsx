import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TrustTierLockedScreen() {
  const navigation = useNavigation();

  // Stub data
  const task = {
    title: 'Premium Plumbing Task',
    requiredTier: 3,
  };
  const currentTier = 2;
  const currentXP = 1250;
  const xpNeeded = 2500 - currentXP; // XP needed for tier 3
  const estimatedTasks = Math.ceil(xpNeeded / 50); // Assuming ~50 XP per task

  const handleViewLadder = () => {
    console.log('View Trust Tier Ladder');
    navigation.navigate('TrustTierLadder' as never);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Trust Tier Required</Text>
      <Text style={styles.subtitle}>
        This task requires a higher trust tier
      </Text>

      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>{task.title}</Text>
        <Text style={styles.requiredTier}>Required: Tier {task.requiredTier}</Text>
      </View>

      <View style={styles.tierComparisonCard}>
        <View style={styles.tierItem}>
          <Text style={styles.tierLabel}>Your Current Tier</Text>
          <Text style={styles.tierValue}>Tier {currentTier}</Text>
        </View>
        <View style={styles.tierItem}>
          <Text style={styles.tierLabel}>Required Tier</Text>
          <Text style={styles.tierValueRequired}>Tier {task.requiredTier}</Text>
        </View>
      </View>

      <View style={styles.progressCard}>
        <Text style={styles.progressTitle}>Progress to Tier {task.requiredTier}</Text>
        <Text style={styles.xpNeeded}>{xpNeeded} XP needed</Text>
        <Text style={styles.estimatedTasks}>
          Estimated {estimatedTasks} tasks to complete
        </Text>
        <View style={styles.progressBarBackground}>
          <View
            style={[
              styles.progressBarFill,
              { width: `${(currentXP / 2500) * 100}%` },
            ]}
          />
        </View>
      </View>

      <View style={styles.opportunityCard}>
        <Text style={styles.opportunityTitle}>This is an opportunity!</Text>
        <Text style={styles.opportunityText}>
          Complete more tasks to increase your trust tier and unlock access to premium tasks like this one.
        </Text>
      </View>

      <TouchableOpacity style={styles.ladderButton} onPress={handleViewLadder}>
        <Text style={styles.ladderButtonText}>View Trust Tier Ladder</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  contentContainer: {
    padding: SPACING[4],
  },
  title: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
    textAlign: 'center',
  },
  subtitle: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    textAlign: 'center',
    marginBottom: SPACING[6],
  },
  taskCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
  },
  taskTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  requiredTier: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  tierComparisonCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
  },
  tierItem: {
    flex: 1,
    alignItems: 'center',
  },
  tierLabel: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[1],
  },
  tierValue: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  tierValueRequired: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: '#10B981',
  },
  progressCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
  },
  progressTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  xpNeeded: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  estimatedTasks: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[3],
  },
  progressBarBackground: {
    height: SPACING[2],
    backgroundColor: NEUTRAL.BACKGROUND_TERTIARY,
    borderRadius: RADIUS.sm,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: '#10B981',
    borderRadius: RADIUS.sm,
  },
  opportunityCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
    borderWidth: 1,
    borderColor: '#10B981',
  },
  opportunityTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  opportunityText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
  },
  ladderButton: {
    width: '100%',
    padding: SPACING[3],
    backgroundColor: '#3B82F6',
    borderRadius: RADIUS.md,
    alignItems: 'center',
  },
  ladderButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
