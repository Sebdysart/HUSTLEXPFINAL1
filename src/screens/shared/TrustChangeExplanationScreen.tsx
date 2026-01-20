import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TrustChangeExplanationScreen() {
  // Stub data
  const previousTier = 1;
  const newTier = 2;
  const changeReason = 'Completed 5 high-quality tasks';
  const factors = [
    'Task completion rate: 100%',
    'Average rating: 4.8/5',
    'On-time completion: 100%',
  ];
  const recommendations: string[] = []; // Empty for tier increase

  const isIncrease = newTier > previousTier;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>
        {isIncrease ? '🎉 Trust Tier Increased!' : 'Trust Tier Changed'}
      </Text>

      <View style={styles.tierChangeCard}>
        <Text style={styles.tierChangeText}>
          Tier {previousTier} → Tier {newTier}
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Change Reason</Text>
        <Text style={styles.sectionText}>{changeReason}</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Contributing Factors</Text>
        {factors.map((factor, idx) => (
          <Text key={idx} style={styles.factorText}>• {factor}</Text>
        ))}
      </View>

      {recommendations.length > 0 && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>What to Do Next</Text>
          {recommendations.map((rec, idx) => (
            <Text key={idx} style={styles.recommendationText}>• {rec}</Text>
          ))}
        </View>
      )}

      {isIncrease && (
        <View style={styles.celebrationCard}>
          <Text style={styles.celebrationText}>
            Congratulations! You've unlocked new benefits at Tier {newTier}.
          </Text>
        </View>
      )}
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
    marginBottom: SPACING[6],
    textAlign: 'center',
  },
  tierChangeCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[6],
    borderRadius: RADIUS.lg,
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  tierChangeText: {
    fontSize: FONT_SIZE['3xl'],
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  section: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginBottom: SPACING[2],
  },
  sectionText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
  },
  factorText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginLeft: SPACING[2],
    marginBottom: SPACING[1],
  },
  recommendationText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    marginLeft: SPACING[2],
    marginBottom: SPACING[1],
  },
  celebrationCard: {
    backgroundColor: '#D1FAE5',
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: '#10B981',
  },
  celebrationText: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT,
    textAlign: 'center',
  },
});
