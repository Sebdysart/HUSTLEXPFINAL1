import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function EligibilityMismatchScreen() {
  const navigation = useNavigation();

  // Stub data
  const task = {
    title: 'Licensed Electrician Needed',
  };
  const requirements = [
    { id: 'trust', name: 'Trust Tier', met: false, current: 'Tier 2', needed: 'Tier 3' },
    { id: 'location', name: 'Location', met: true, current: 'California', needed: 'California' },
    { id: 'license', name: 'License', met: false, current: 'Not added', needed: 'Electrician License' },
    { id: 'insurance', name: 'Insurance', met: true, current: 'Verified', needed: 'Verified' },
  ];

  const handleUpgrade = (requirementId: string) => {
    console.log(`Upgrade ${requirementId} button pressed`);
    // In real app, would navigate to relevant upgrade screen
    if (requirementId === 'trust') {
      navigation.navigate('TrustTierLadder' as never);
    } else if (requirementId === 'license') {
      navigation.navigate('S6' as never); // Navigate to Verification screen
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Task Requirements Not Met</Text>
      <Text style={styles.subtitle}>
        You're not eligible for this task yet, but you can become eligible!
      </Text>

      <View style={styles.taskCard}>
        <Text style={styles.taskTitle}>{task.title}</Text>
      </View>

      <View style={styles.requirementsCard}>
        <Text style={styles.requirementsTitle}>Requirements Status:</Text>
        {requirements.map((req) => (
          <View key={req.id} style={styles.requirementRow}>
            <Text style={styles.requirementIcon}>{req.met ? '✅' : '❌'}</Text>
            <View style={styles.requirementInfo}>
              <Text style={styles.requirementName}>{req.name}</Text>
              <Text style={styles.requirementStatus}>
                You have: {req.current} | Required: {req.needed}
              </Text>
            </View>
          </View>
        ))}
      </View>

      <View style={styles.upgradeCard}>
        <Text style={styles.upgradeTitle}>To become eligible:</Text>
        {requirements
          .filter((req) => !req.met)
          .map((req) => (
            <TouchableOpacity
              key={req.id}
              style={styles.upgradeButton}
              onPress={() => handleUpgrade(req.id)}
            >
              <Text style={styles.upgradeButtonText}>
                {req.id === 'trust' && 'Complete more tasks to reach Tier 3'}
                {req.id === 'license' && 'Add your Electrician License in Settings'}
              </Text>
            </TouchableOpacity>
          ))}
      </View>
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
    marginBottom: SPACING[6],
  },
  taskTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
  },
  requirementsCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[6],
  },
  requirementsTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  requirementRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: SPACING[3],
  },
  requirementIcon: {
    fontSize: FONT_SIZE.xl,
    marginRight: SPACING[3],
  },
  requirementInfo: {
    flex: 1,
  },
  requirementName: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[1],
  },
  requirementStatus: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  upgradeCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: '#10B981',
  },
  upgradeTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[3],
  },
  upgradeButton: {
    padding: SPACING[3],
    backgroundColor: NEUTRAL.BACKGROUND,
    borderRadius: RADIUS.md,
    marginBottom: SPACING[2],
    alignItems: 'center',
  },
  upgradeButtonText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    fontWeight: FONT_WEIGHT.semibold,
  },
});
