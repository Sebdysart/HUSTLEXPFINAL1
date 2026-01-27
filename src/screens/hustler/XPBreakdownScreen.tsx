/**
 * XPBreakdownScreen - Detailed XP earnings breakdown
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Text, Spacing, Card, TrustBadge } from '../../components';
import { theme } from '../../theme';

export function XPBreakdownScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text variant="title1" color="primary">XP & Levels</Text>
        
        <Spacing size={20} />

        {/* Current Level */}
        <Card variant="elevated" padding="lg">
          <View style={styles.levelHeader}>
            <TrustBadge level={3} xp={2600} size="lg" showProgress nextLevelXp={3000} />
          </View>
          <Spacing size={16} />
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <Text variant="title2" color="primary">2,600</Text>
              <Text variant="caption" color="secondary">Total XP</Text>
            </View>
            <View style={styles.stat}>
              <Text variant="title2" color="primary">400</Text>
              <Text variant="caption" color="secondary">To Next Level</Text>
            </View>
          </View>
        </Card>

        <Spacing size={24} />

        {/* How to Earn */}
        <Text variant="headline" color="primary">How to Earn XP</Text>
        <Spacing size={12} />
        <XPSource emoji="✅" title="Complete a task" xp="+100-200" />
        <XPSource emoji="⭐" title="5-star rating" xp="+50" />
        <XPSource emoji="🔥" title="Complete streak (3+)" xp="+25" />
        <XPSource emoji="⏱️" title="On-time completion" xp="+20" />
        <XPSource emoji="🆕" title="First task in category" xp="+50" />

        <Spacing size={24} />

        {/* Recent XP */}
        <Text variant="headline" color="primary">Recent XP</Text>
        <Spacing size={12} />
        <XPHistoryItem title="Moving help" xp={175} date="Today" breakdown="Task: +150, Rating: +25" />
        <XPHistoryItem title="Furniture assembly" xp={120} date="Yesterday" breakdown="Task: +100, On-time: +20" />
        <XPHistoryItem title="Dog walking" xp={80} date="2 days ago" breakdown="Task: +80" />

        <Spacing size={24} />

        {/* Level Benefits */}
        <Text variant="headline" color="primary">Level Benefits</Text>
        <Spacing size={12} />
        <LevelBenefit level={4} benefit="Priority task matching" unlocked={false} />
        <LevelBenefit level={5} benefit="Lower platform fees" unlocked={false} />
        <LevelBenefit level={6} benefit="Featured profile badge" unlocked={false} />
      </ScrollView>
    </View>
  );
}

function XPSource({ emoji, title, xp }: { emoji: string; title: string; xp: string }) {
  return (
    <Card variant="default" padding="sm" style={styles.xpSource}>
      <Text variant="body">{emoji}</Text>
      <Text variant="body" color="primary" style={styles.xpSourceTitle}>{title}</Text>
      <Text variant="headline" color="brand">{xp}</Text>
    </Card>
  );
}

function XPHistoryItem({ title, xp, date, breakdown }: { title: string; xp: number; date: string; breakdown: string }) {
  return (
    <Card variant="default" padding="md" style={styles.historyItem}>
      <View style={styles.historyRow}>
        <View>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="caption" color="secondary">{date} • {breakdown}</Text>
        </View>
        <Text variant="title2" color="brand">+{xp}</Text>
      </View>
    </Card>
  );
}

function LevelBenefit({ level, benefit, unlocked }: { level: number; benefit: string; unlocked: boolean }) {
  return (
    <Card variant="default" padding="sm" style={[styles.benefit, !unlocked ? styles.benefitLocked : undefined]}>
      <Text variant="body" color={unlocked ? 'primary' : 'tertiary'}>Lvl {level}</Text>
      <Text variant="body" color={unlocked ? 'primary' : 'tertiary'} style={styles.benefitText}>{benefit}</Text>
      <Text variant="caption">{unlocked ? '✅' : '🔒'}</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  scroll: { padding: theme.spacing[4] },
  levelHeader: { alignItems: 'center' },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  stat: { alignItems: 'center' },
  xpSource: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[2] },
  xpSourceTitle: { flex: 1, marginLeft: theme.spacing[3] },
  historyItem: { marginBottom: theme.spacing[2] },
  historyRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  benefit: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[2] },
  benefitLocked: { opacity: 0.6 },
  benefitText: { flex: 1, marginLeft: theme.spacing[3] },
});

export default XPBreakdownScreen;
