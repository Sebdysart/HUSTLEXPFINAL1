/**
 * TrustChangeExplanationScreen - Explains trust score changes
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, Spacing, Card, Button, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function TrustChangeExplanationScreen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <View style={styles.header}>
          <Text variant="hero">📊</Text>
          <Spacing size={16} />
          <Text variant="title1" color="primary" align="center">Your Trust Score Changed</Text>
        </View>

        <Spacing size={24} />

        {/* Change Summary */}
        <Card variant="elevated" padding="lg">
          <View style={styles.changeRow}>
            <View style={styles.changeItem}>
              <Text variant="caption" color="secondary">Before</Text>
              <TrustBadge level={3} xp={2400} size="sm" />
            </View>
            <Text variant="title2" color="brand">→</Text>
            <View style={styles.changeItem}>
              <Text variant="caption" color="secondary">After</Text>
              <TrustBadge level={3} xp={2600} size="sm" />
            </View>
          </View>
          <Spacing size={12} />
          <Text variant="headline" color="success" align="center">+200 XP</Text>
        </Card>

        <Spacing size={24} />

        {/* Breakdown */}
        <Text variant="headline" color="primary">What happened</Text>
        <Spacing size={12} />
        
        <ChangeItem emoji="✅" title="Task Completed" xp={150} desc="Help moving furniture" />
        <ChangeItem emoji="⭐" title="5-Star Rating" xp={50} desc="From Sarah M." />

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            💡 Your trust score is based on completed tasks, ratings, response time, and profile completeness.
          </Text>
        </Card>
      </ScrollView>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log('done')}>
          Got it
        </Button>
      </View>
    </View>
  );
}

function ChangeItem({ emoji, title, xp, desc }: { emoji: string; title: string; xp: number; desc: string }) {
  return (
    <Card variant="default" padding="md" style={styles.changeCard}>
      <View style={styles.changeCardRow}>
        <Text variant="title2">{emoji}</Text>
        <View style={styles.changeCardInfo}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="footnote" color="secondary">{desc}</Text>
        </View>
        <Text variant="headline" color="success">+{xp}</Text>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  header: { alignItems: 'center' },
  changeRow: { flexDirection: 'row', justifyContent: 'space-around', alignItems: 'center' },
  changeItem: { alignItems: 'center' },
  changeCard: { marginBottom: theme.spacing[2] },
  changeCardRow: { flexDirection: 'row', alignItems: 'center' },
  changeCardInfo: { flex: 1, marginLeft: theme.spacing[3] },
  footer: { padding: theme.spacing[4] },
});

export default TrustChangeExplanationScreen;
