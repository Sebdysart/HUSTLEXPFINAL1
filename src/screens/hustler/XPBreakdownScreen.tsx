/**
 * XPBreakdownScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - Current tier prominent
 * - Progress to next shown simply
 * - "Level up" not "Next tier"
 * - "{X} to go" not "{X} remaining"
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HTrustBadge, HBadge, HStatCard } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

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
  const progress = Math.min((currentXP / nextTierXP) * 100, 100);

  const handleBack = () => navigation.goBack();
  const handleTrustLadder = () => navigation.navigate('TrustTierLadder');

  return (
    <HScreen ambient>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.md }]}>
        <TouchableOpacity onPress={handleBack} style={styles.backBtn}>
          <HText variant="body" color="primary">←</HText>
        </TouchableOpacity>
        <HText variant="title2" color="primary">XP & Levels</HText>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView 
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
      >
        {/* Current Level - Prominent */}
        <TouchableOpacity onPress={handleTrustLadder} activeOpacity={0.8}>
          <HCard variant="elevated" padding="xl">
            <View style={styles.levelHeader}>
              <HTrustBadge tier={currentTier} xp={currentXP} size="lg" />
            </View>
            
            {/* Progress bar - Simple */}
            <View style={styles.progressContainer}>
              <View style={styles.progressBar}>
                <View style={[styles.progressFill, { width: `${progress}%` }]} />
              </View>
              <HText variant="caption" color="secondary" style={styles.progressLabel}>
                {xpToNext < Infinity ? `${xpToNext.toLocaleString()} to go` : 'Max level!'}
              </HText>
            </View>

            {/* Stats row */}
            <View style={styles.statsRow}>
              <View style={styles.stat}>
                <HText variant="title2" color={hustleColors.xp.primary} bold>
                  {currentXP.toLocaleString()}
                </HText>
                <HText variant="caption" color="tertiary">Total XP</HText>
              </View>
              <View style={styles.stat}>
                <HText variant="title2" color="primary" bold>
                  {currentTier}
                </HText>
                <HText variant="caption" color="tertiary">Current Tier</HText>
              </View>
            </View>
            
            <HText variant="caption" color="purple" align="center" style={styles.ladderHint}>
              Tap to view all tiers →
            </HText>
          </HCard>
        </TouchableOpacity>

        {/* How to Level Up */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">How to Level Up</HText>
        </View>

        <XPSource emoji="✅" title="Complete a task" xp="+100-200" desc="Based on task value" />
        <XPSource emoji="⭐" title="5-star rating" xp="+50" desc="Per completed task" />
        <XPSource emoji="🔥" title="Complete streak" xp="+25" desc="3+ tasks in a row" />
        <XPSource emoji="⏱️" title="On-time finish" xp="+20" desc="Within estimate" />
        <XPSource emoji="🆕" title="First in category" xp="+50" desc="Try new task types" />

        {/* Recent XP */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">Recent XP</HText>
        </View>

        <XPHistoryItem 
          title="Moving help" 
          xp={175} 
          date="Today" 
          breakdown="Task +150, Rating +25" 
        />
        <XPHistoryItem 
          title="Furniture assembly" 
          xp={120} 
          date="Yesterday" 
          breakdown="Task +100, On-time +20" 
        />
        <XPHistoryItem 
          title="Dog walking" 
          xp={80} 
          date="2 days ago" 
        />

        {/* Level Up Benefits */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">Level Up Benefits</HText>
        </View>

        <TierBenefit tier={2} benefit="Access to $50+ tasks" unlocked={currentTier >= 2} />
        <TierBenefit tier={3} benefit="Priority in matching" unlocked={currentTier >= 3} />
        <TierBenefit tier={4} benefit="Lower fees (12%)" unlocked={currentTier >= 4} />
        <TierBenefit tier={5} benefit="Featured profile + 10% fee" unlocked={currentTier >= 5} />

        {/* Pro tip */}
        <HCard variant="default" padding="lg" style={styles.tipCard}>
          <HText variant="headline" color="primary">💡 Pro Tip</HText>
          <HText variant="body" color="secondary" style={styles.tipText}>
            Complete tasks quickly for on-time bonuses. Keep a streak going for extra XP!
          </HText>
        </HCard>
      </ScrollView>
    </HScreen>
  );
}

interface XPSourceProps {
  emoji: string;
  title: string;
  xp: string;
  desc: string;
}

function XPSource({ emoji, title, xp, desc }: XPSourceProps) {
  return (
    <HCard variant="default" padding="md" style={styles.xpSource}>
      <HText variant="title2">{emoji}</HText>
      <View style={styles.xpSourceInfo}>
        <HText variant="headline" color="primary">{title}</HText>
        <HText variant="caption" color="tertiary">{desc}</HText>
      </View>
      <HText variant="headline" color={hustleColors.xp.primary} bold>{xp}</HText>
    </HCard>
  );
}

interface XPHistoryItemProps {
  title: string;
  xp: number;
  date: string;
  breakdown?: string;
}

function XPHistoryItem({ title, xp, date, breakdown }: XPHistoryItemProps) {
  return (
    <HCard variant="default" padding="md" style={styles.historyItem}>
      <View style={styles.historyRow}>
        <View style={styles.historyInfo}>
          <HText variant="headline" color="primary">{title}</HText>
          <HText variant="caption" color="tertiary">
            {date}{breakdown ? ` • ${breakdown}` : ''}
          </HText>
        </View>
        <HText variant="title2" color={hustleColors.xp.primary} bold>+{xp}</HText>
      </View>
    </HCard>
  );
}

interface TierBenefitProps {
  tier: number;
  benefit: string;
  unlocked: boolean;
}

function TierBenefit({ tier, benefit, unlocked }: TierBenefitProps) {
  return (
    <HCard 
      variant="default" 
      padding="md" 
      style={StyleSheet.flatten([styles.benefit, !unlocked && styles.benefitLocked])}
    >
      <View style={[styles.tierBadge, unlocked && styles.tierBadgeUnlocked]}>
        <HText variant="caption" color={unlocked ? 'primary' : 'muted'} bold>
          {tier}
        </HText>
      </View>
      <HText 
        variant="body" 
        color={unlocked ? 'primary' : 'muted'} 
        style={styles.benefitText}
      >
        {benefit}
      </HText>
      <HText variant="body">{unlocked ? '✅' : '🔒'}</HText>
    </HCard>
  );
}

const styles = StyleSheet.create({
  header: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
    paddingHorizontal: hustleSpacing.lg,
    paddingBottom: hustleSpacing.md,
  },
  backBtn: {
    width: 44,
    height: 44,
    justifyContent: 'center',
  },
  headerSpacer: { width: 44 },
  scroll: { 
    padding: hustleSpacing.lg, 
    paddingTop: 0,
    paddingBottom: hustleSpacing['4xl'],
  },
  levelHeader: { 
    alignItems: 'center',
    marginBottom: hustleSpacing.xl,
  },
  progressContainer: {
    marginBottom: hustleSpacing.xl,
  },
  progressBar: {
    height: 8,
    backgroundColor: hustleColors.glass.medium,
    borderRadius: hustleRadii.full,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: hustleColors.purple.core,
    borderRadius: hustleRadii.full,
  },
  progressLabel: {
    marginTop: hustleSpacing.sm,
    textAlign: 'center',
  },
  statsRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-around',
    marginBottom: hustleSpacing.lg,
  },
  stat: { 
    alignItems: 'center',
  },
  ladderHint: {
    marginTop: hustleSpacing.sm,
  },
  section: {
    marginTop: hustleSpacing.xl,
    marginBottom: hustleSpacing.md,
  },
  xpSource: { 
    flexDirection: 'row', 
    alignItems: 'center', 
    marginBottom: hustleSpacing.sm,
  },
  xpSourceInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  historyItem: { 
    marginBottom: hustleSpacing.sm,
  },
  historyRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center',
  },
  historyInfo: { 
    flex: 1,
  },
  benefit: { 
    flexDirection: 'row', 
    alignItems: 'center', 
    marginBottom: hustleSpacing.sm,
  },
  benefitLocked: { 
    opacity: 0.5,
  },
  tierBadge: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: hustleColors.glass.medium,
    justifyContent: 'center',
    alignItems: 'center',
  },
  tierBadgeUnlocked: {
    backgroundColor: hustleColors.purple.core,
  },
  benefitText: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  tipCard: {
    marginTop: hustleSpacing.xl,
  },
  tipText: {
    marginTop: hustleSpacing.sm,
  },
});

export default XPBreakdownScreen;
