/**
 * XPBreakdownScreen - Detailed XP earnings breakdown
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Text, Spacing, Card, TrustBadge } from '../../components';
import { theme } from '../../theme';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

// XP thresholds for each tier
const TIER_THRESHOLDS = [0, 500, 2000, 5000, 10000, 25000];

export function XPBreakdownScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  
  const currentXP = user?.xp || 0;
  const currentTier = user?.trustTier || 1;
  const nextTierXP = TIER_THRESHOLDS[currentTier] || Infinity;
  const xpToNext = nextTierXP - currentXP;

  const handleBack = () => navigation.goBack();
  const handleTrustLadder = () => navigation.navigate('TrustTierLadder');

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleBack}>
          <Text variant="body" color="primary">← Back</Text>
        </TouchableOpacity>
        <Text variant="title2" color="primary">XP & Levels</Text>
        <View style={{ width: 50 }} />
      </View>

      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Current Level */}
        <TouchableOpacity onPress={handleTrustLadder}>
          <Card variant="elevated" padding="lg">
            <View style={styles.levelHeader}>
              <TrustBadge level={currentTier} xp={currentXP} size="lg" />
            </View>
            <Spacing size={16} />
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: `${Math.min((currentXP / nextTierXP) * 100, 100)}%` }]} />
            </View>
            <Spacing size={8} />
            <View style={styles.statsRow}>
              <View style={styles.stat}>
                <Text variant="title2" color="primary">{currentXP.toLocaleString()}</Text>
                <Text variant="caption" color="secondary">Total XP</Text>
              </View>
              <View style={styles.stat}>
                <Text variant="title2" color="primary">{xpToNext < Infinity ? xpToNext.toLocaleString() : '∞'}</Text>
                <Text variant="caption" color="secondary">To Next Tier</Text>
              </View>
            </View>
            <Spacing size={8} />
            <Text variant="caption" color="brand" align="center">Tap to view Trust Tier ladder →</Text>
          </Card>
        </TouchableOpacity>

        <Spacing size={24} />

        {/* How to Earn */}
        <Text variant="headline" color="primary">How to Earn XP</Text>
        <Spacing size={12} />
        <XPSource emoji="✅" title="Complete a task" xp="+100-200" desc="Based on task value" />
        <XPSource emoji="⭐" title="5-star rating" xp="+50" desc="Per completed task" />
        <XPSource emoji="🔥" title="Complete streak (3+)" xp="+25" desc="Bonus for consistency" />
        <XPSource emoji="⏱️" title="On-time completion" xp="+20" desc="Finish within estimate" />
        <XPSource emoji="🆕" title="First task in category" xp="+50" desc="Try new task types" />
        <XPSource emoji="📸" title="Quality proof photos" xp="+10" desc="Clear completion evidence" />

        <Spacing size={24} />

        {/* Recent XP */}
        <Text variant="headline" color="primary">Recent XP</Text>
        <Spacing size={12} />
        <XPHistoryItem title="Moving help" xp={175} date="Today" breakdown="Task: +150, Rating: +25" />
        <XPHistoryItem title="Furniture assembly" xp={120} date="Yesterday" breakdown="Task: +100, On-time: +20" />
        <XPHistoryItem title="Dog walking" xp={80} date="2 days ago" breakdown="Task: +80" />
        <XPHistoryItem title="Grocery delivery" xp={95} date="3 days ago" breakdown="Task: +75, Streak: +20" />

        <Spacing size={24} />

        {/* Tier Benefits */}
        <Text variant="headline" color="primary">Tier Benefits</Text>
        <Spacing size={12} />
        <TierBenefit tier={1} benefit="Access to basic tasks" unlocked={currentTier >= 1} />
        <TierBenefit tier={2} benefit="Access to $50+ tasks" unlocked={currentTier >= 2} />
        <TierBenefit tier={3} benefit="Priority in task matching" unlocked={currentTier >= 3} />
        <TierBenefit tier={4} benefit="Lower platform fees (12%)" unlocked={currentTier >= 4} />
        <TierBenefit tier={5} benefit="Featured profile + 10% fee" unlocked={currentTier >= 5} />

        <Spacing size={24} />

        {/* Tips */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">💡 Pro Tips</Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary">
            • Complete tasks quickly for on-time bonuses{'\n'}
            • Ask posters for 5-star reviews{'\n'}
            • Try different task categories for first-time bonuses{'\n'}
            • Keep a daily streak going for bonus XP
          </Text>
        </Card>
      </ScrollView>
    </View>
  );
}

function XPSource({ emoji, title, xp, desc }: { emoji: string; title: string; xp: string; desc: string }) {
  return (
    <Card variant="default" padding="md" style={styles.xpSource}>
      <Text variant="title2">{emoji}</Text>
      <View style={styles.xpSourceInfo}>
        <Text variant="headline" color="primary">{title}</Text>
        <Text variant="caption" color="secondary">{desc}</Text>
      </View>
      <Text variant="headline" color="success">{xp}</Text>
    </Card>
  );
}

function XPHistoryItem({ title, xp, date, breakdown }: { title: string; xp: number; date: string; breakdown: string }) {
  return (
    <Card variant="default" padding="md" style={styles.historyItem}>
      <View style={styles.historyRow}>
        <View style={styles.historyInfo}>
          <Text variant="headline" color="primary">{title}</Text>
          <Text variant="caption" color="secondary">{date}</Text>
          <Text variant="caption" color="tertiary">{breakdown}</Text>
        </View>
        <Text variant="title2" color="success">+{xp}</Text>
      </View>
    </Card>
  );
}

function TierBenefit({ tier, benefit, unlocked }: { tier: number; benefit: string; unlocked: boolean }) {
  return (
    <Card variant="default" padding="sm" style={[styles.benefit, !unlocked && styles.benefitLocked]}>
      <View style={[styles.tierBadge, unlocked && styles.tierBadgeUnlocked]}>
        <Text variant="caption" color={unlocked ? 'inverse' : 'tertiary'}>{tier}</Text>
      </View>
      <Text variant="body" color={unlocked ? 'primary' : 'tertiary'} style={styles.benefitText}>{benefit}</Text>
      <Text variant="body">{unlocked ? '✅' : '🔒'}</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    padding: theme.spacing[4],
  },
  scroll: { padding: theme.spacing[4], paddingTop: 0 },
  levelHeader: { alignItems: 'center' },
  progressBar: {
    height: 8,
    backgroundColor: theme.colors.surface.tertiary,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: theme.colors.brand.primary,
    borderRadius: 4,
  },
  statsRow: { flexDirection: 'row', justifyContent: 'space-around' },
  stat: { alignItems: 'center' },
  xpSource: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[2] },
  xpSourceInfo: { flex: 1, marginLeft: theme.spacing[3] },
  historyItem: { marginBottom: theme.spacing[2] },
  historyRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  historyInfo: { flex: 1 },
  benefit: { flexDirection: 'row', alignItems: 'center', marginBottom: theme.spacing[2] },
  benefitLocked: { opacity: 0.6 },
  tierBadge: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: theme.colors.surface.tertiary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  tierBadgeUnlocked: {
    backgroundColor: theme.colors.brand.primary,
  },
  benefitText: { flex: 1, marginLeft: theme.spacing[3] },
});

export default XPBreakdownScreen;
