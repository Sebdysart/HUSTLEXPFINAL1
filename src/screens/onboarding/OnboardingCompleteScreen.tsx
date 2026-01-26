/**
 * OnboardingCompleteScreen - Welcome to HustleXP!
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function OnboardingCompleteScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <View style={styles.celebration}>
          <Text variant="hero" align="center">🎉</Text>
          <Spacing size={24} />
          <Text variant="hero" color="primary" align="center">
            You're all set!
          </Text>
          <Spacing size={12} />
          <Text variant="body" color="secondary" align="center">
            Welcome to HustleXP. Your journey starts now.
          </Text>
        </View>

        <Spacing size={40} />

        <View style={styles.badgeContainer}>
          <TrustBadge level={1} xp={0} size="lg" />
        </View>

        <Spacing size={24} />

        <View style={styles.stats}>
          <StatItem label="Starting Level" value="1" />
          <StatItem label="Starting XP" value="0" />
          <StatItem label="Trust Status" value="New" />
        </View>

        <Spacing size={32} />

        <Text variant="callout" color="secondary" align="center">
          Complete your first task to start earning XP and building your reputation!
        </Text>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('go to home')}>
          Start Exploring
        </Button>
      </View>
    </View>
  );
}

function StatItem({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.statItem}>
      <Text variant="title2" color="primary">{value}</Text>
      <Text variant="caption" color="secondary">{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], justifyContent: 'center' },
  celebration: { alignItems: 'center' },
  badgeContainer: { alignItems: 'center' },
  stats: { 
    flexDirection: 'row', 
    justifyContent: 'space-around',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
  },
  statItem: { alignItems: 'center' },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default OnboardingCompleteScreen;
