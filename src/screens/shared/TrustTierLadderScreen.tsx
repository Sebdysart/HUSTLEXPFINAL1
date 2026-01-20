import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { NEUTRAL, SPACING, FONT_SIZE, FONT_WEIGHT, RADIUS } from '../../constants';

export function TrustTierLadderScreen() {
  // Stub data
  const currentTier = 2;
  const currentXP = 1250;
  const tiers = [
    { tier: 0, name: 'Rookie', xpRequired: 0, benefits: ['Basic tasks'] },
    { tier: 1, name: 'Verified', xpRequired: 500, benefits: ['Standard tasks', 'Basic verification'] },
    { tier: 2, name: 'Trusted', xpRequired: 1000, benefits: ['Premium tasks', 'Priority matching'] },
    { tier: 3, name: 'Elite', xpRequired: 2500, benefits: ['Exclusive tasks', 'VIP support'] },
    { tier: 4, name: 'Master', xpRequired: 5000, benefits: ['All tasks', 'Master badge'] },
    { tier: 5, name: 'Legend', xpRequired: 10000, benefits: ['All tasks', 'Legend status'] },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Trust Tier Ladder</Text>
      
      {tiers.map((tierInfo) => {
        const isCurrentTier = tierInfo.tier === currentTier;
        const isUnlocked = currentXP >= tierInfo.xpRequired;
        
        return (
          <View
            key={tierInfo.tier}
            style={[
              styles.tierCard,
              isCurrentTier && styles.currentTierCard,
              !isUnlocked && styles.lockedTierCard,
            ]}
          >
            <View style={styles.tierHeader}>
              <Text style={styles.tierName}>Tier {tierInfo.tier}: {tierInfo.name}</Text>
              {isCurrentTier && <Text style={styles.currentBadge}>Current</Text>}
            </View>
            <Text style={styles.xpRequired}>XP Required: {tierInfo.xpRequired}</Text>
            <Text style={styles.benefitsLabel}>Benefits:</Text>
            {tierInfo.benefits.map((benefit, idx) => (
              <Text key={idx} style={styles.benefit}>• {benefit}</Text>
            ))}
            {!isUnlocked && (
              <Text style={styles.lockedText}>
                {tierInfo.xpRequired - currentXP} XP needed to unlock
              </Text>
            )}
          </View>
        );
      })}
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
  },
  tierCard: {
    backgroundColor: NEUTRAL.BACKGROUND_SECONDARY,
    padding: SPACING[4],
    borderRadius: RADIUS.lg,
    marginBottom: SPACING[4],
    borderWidth: 1,
    borderColor: NEUTRAL.BORDER,
  },
  currentTierCard: {
    borderColor: '#10B981',
    borderWidth: 2,
    backgroundColor: '#D1FAE5',
  },
  lockedTierCard: {
    opacity: 0.6,
  },
  tierHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING[2],
  },
  tierName: {
    fontSize: FONT_SIZE.lg,
    fontWeight: FONT_WEIGHT.bold,
    color: NEUTRAL.TEXT,
  },
  currentBadge: {
    fontSize: FONT_SIZE.sm,
    fontWeight: FONT_WEIGHT.semibold,
    color: '#10B981',
    backgroundColor: '#FFFFFF',
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[1],
    borderRadius: RADIUS.sm,
  },
  xpRequired: {
    fontSize: FONT_SIZE.base,
    color: NEUTRAL.TEXT_SECONDARY,
    marginBottom: SPACING[2],
  },
  benefitsLabel: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.semibold,
    color: NEUTRAL.TEXT,
    marginTop: SPACING[2],
    marginBottom: SPACING[1],
  },
  benefit: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_SECONDARY,
    marginLeft: SPACING[2],
  },
  lockedText: {
    fontSize: FONT_SIZE.sm,
    color: NEUTRAL.TEXT_TERTIARY,
    fontStyle: 'italic',
    marginTop: SPACING[2],
  },
});
