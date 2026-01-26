/**
 * TrustTierLadderScreen - Trust level progression
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, TrustBadge } from '../../components';
import { theme } from '../../theme';

const LEVELS = [
  { level: 1, name: 'Newcomer', xp: 0, perks: ['Basic task access', 'Standard fees'] },
  { level: 2, name: 'Rising', xp: 500, perks: ['Priority in search', '5% lower fees'] },
  { level: 3, name: 'Trusted', xp: 1500, perks: ['Verified badge', '10% lower fees', 'Higher-paying tasks'] },
  { level: 4, name: 'Expert', xp: 3000, perks: ['Featured profile', '15% lower fees', 'Early task access'] },
  { level: 5, name: 'Elite', xp: 5000, perks: ['Elite badge', '20% lower fees', 'VIP support', 'Exclusive tasks'] },
  { level: 6, name: 'Legend', xp: 10000, perks: ['Legend status', '25% lower fees', 'Community recognition'] },
];

export function TrustTierLadderScreen() {
  const insets = useSafeAreaInsets();
  const currentLevel = 3;
  const currentXP = 2600;

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">Trust Levels</Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary">
          Level up by completing tasks and earning great reviews
        </Text>

        <Spacing size={24} />

        {/* Current Level */}
        <Card variant="elevated" padding="lg">
          <View style={styles.currentLevel}>
            <TrustBadge level={currentLevel} xp={currentXP} size="lg" showProgress nextLevelXp={3000} />
            <Spacing size={12} />
            <Text variant="headline" color="primary">Level {currentLevel}: {LEVELS[currentLevel - 1].name}</Text>
            <Text variant="body" color="secondary">{3000 - currentXP} XP to Level {currentLevel + 1}</Text>
          </View>
        </Card>

        <Spacing size={24} />

        {/* Level Ladder */}
        {LEVELS.map((lvl, idx) => (
          <React.Fragment key={lvl.level}>
            <LevelCard
              {...lvl}
              isCurrent={lvl.level === currentLevel}
              isUnlocked={lvl.level <= currentLevel}
            />
            {idx < LEVELS.length - 1 && <View style={styles.connector} />}
          </React.Fragment>
        ))}
      </ScrollView>
    </View>
  );
}

function LevelCard({ level, name, xp, perks, isCurrent, isUnlocked }: {
  level: number;
  name: string;
  xp: number;
  perks: string[];
  isCurrent: boolean;
  isUnlocked: boolean;
}) {
  return (
    <Card variant={isCurrent ? 'elevated' : 'default'} padding="md" style={!isUnlocked ? styles.locked : undefined}>
      <View style={styles.levelHeader}>
        <View style={[styles.levelBadge, isUnlocked && styles.levelBadgeUnlocked]}>
          <Text variant="headline" color={isUnlocked ? 'inverse' : 'tertiary'}>{level}</Text>
        </View>
        <View style={styles.levelInfo}>
          <Text variant="headline" color={isUnlocked ? 'primary' : 'tertiary'}>{name}</Text>
          <Text variant="caption" color="secondary">{xp.toLocaleString()} XP required</Text>
        </View>
        {isCurrent && <Text variant="caption" color="brand">Current</Text>}
        {isUnlocked && !isCurrent && <Text variant="body">✅</Text>}
        {!isUnlocked && <Text variant="body">🔒</Text>}
      </View>
      <Spacing size={8} />
      <View style={styles.perks}>
        {perks.map((perk, i) => (
          <Text key={i} variant="footnote" color={isUnlocked ? 'secondary' : 'tertiary'}>• {perk}</Text>
        ))}
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  currentLevel: { alignItems: 'center' },
  levelHeader: { flexDirection: 'row', alignItems: 'center' },
  levelBadge: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  levelBadgeUnlocked: { backgroundColor: theme.colors.brand.primary },
  levelInfo: { flex: 1, marginLeft: theme.spacing[3] },
  perks: { marginLeft: 52 },
  connector: { width: 2, height: 20, backgroundColor: theme.colors.surface.tertiary, marginLeft: 19 },
  locked: { opacity: 0.6 },
});

export default TrustTierLadderScreen;
