/**
 * TrustTierLadderScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - Current tier prominent
 * - "Level up" not "Next tier"
 * - "{X} to go" not "{X} remaining"
 * - Progress feels inevitable
 */

import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HTrustBadge, HBadge } from '../../components/atoms';
import { hustleColors, hustleSpacing, hustleRadii } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface TierInfo {
  tier: number;
  name: string;
  xpRequired: number;
  platformFee: string;
  perks: string[];
  color: string;
}

const TIERS: TierInfo[] = [
  { 
    tier: 1, 
    name: 'Newcomer', 
    xpRequired: 0, 
    platformFee: '15%',
    perks: ['Access to basic tasks', 'Standard support'],
    color: hustleColors.text.tertiary,
  },
  { 
    tier: 2, 
    name: 'Rising', 
    xpRequired: 500, 
    platformFee: '14%',
    perks: ['Access to $50+ tasks', 'Priority matching'],
    color: hustleColors.semantic.success,
  },
  { 
    tier: 3, 
    name: 'Trusted', 
    xpRequired: 2000, 
    platformFee: '12%',
    perks: ['Access to $100+ tasks', 'Verified badge', 'Priority support'],
    color: hustleColors.semantic.info,
  },
  { 
    tier: 4, 
    name: 'Expert', 
    xpRequired: 5000, 
    platformFee: '10%',
    perks: ['Access to premium tasks', 'Featured profile', 'Early access'],
    color: hustleColors.purple.soft,
  },
  { 
    tier: 5, 
    name: 'Elite', 
    xpRequired: 10000, 
    platformFee: '8%',
    perks: ['All task access', 'Elite badge', 'VIP support', 'Exclusive events'],
    color: hustleColors.xp.primary,
  },
];

export function TrustTierLadderScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const { user } = useAuthStore();
  
  const currentTier = user?.trustTier || 1;
  const currentXP = user?.xp || 0;
  const currentTierInfo = TIERS.find(t => t.tier === currentTier) || TIERS[0];
  const nextTierInfo = TIERS.find(t => t.tier === currentTier + 1);
  const xpToNext = nextTierInfo ? nextTierInfo.xpRequired - currentXP : 0;
  const progress = nextTierInfo 
    ? Math.min((currentXP / nextTierInfo.xpRequired) * 100, 100) 
    : 100;

  const handleBack = () => navigation.goBack();

  return (
    <HScreen ambient>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + hustleSpacing.md }]}>
        <TouchableOpacity onPress={handleBack} style={styles.backBtn}>
          <HText variant="body" color="primary">←</HText>
        </TouchableOpacity>
        <HText variant="title2" color="primary">Trust Tiers</HText>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView 
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
      >
        {/* Current Tier Card - Prominent */}
        <HCard variant="elevated" padding="xl">
          <View style={styles.currentTier}>
            <HTrustBadge tier={currentTier} xp={currentXP} size="lg" />
            
            <HText variant="title2" color="primary" style={styles.tierTitle}>
              {currentTierInfo.name}
            </HText>
            <HText variant="body" color="secondary">
              Current fee: {currentTierInfo.platformFee}
            </HText>
            
            {nextTierInfo && (
              <>
                <View style={styles.progressContainer}>
                  <View style={styles.progressBar}>
                    <View style={[styles.progressFill, { width: `${progress}%` }]} />
                  </View>
                </View>
                <HText variant="caption" color="secondary">
                  {xpToNext.toLocaleString()} XP to level up
                </HText>
              </>
            )}
          </View>
        </HCard>

        {/* All Tiers */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">All Tiers</HText>
        </View>

        {TIERS.map((tier, idx) => (
          <React.Fragment key={tier.tier}>
            <TierCard
              tier={tier}
              isCurrent={tier.tier === currentTier}
              isUnlocked={tier.tier <= currentTier}
            />
            {idx < TIERS.length - 1 && (
              <View style={styles.connectorContainer}>
                <View style={[
                  styles.connector, 
                  tier.tier < currentTier && styles.connectorUnlocked
                ]} />
              </View>
            )}
          </React.Fragment>
        ))}

        {/* How It Works */}
        <HCard variant="default" padding="lg" style={styles.infoCard}>
          <HText variant="headline" color="primary">How Trust Tiers Work</HText>
          <HText variant="body" color="secondary" style={styles.infoText}>
            • Complete tasks to earn XP{'\n'}
            • Higher tiers = lower platform fees{'\n'}
            • 5-star ratings give bonus XP{'\n'}
            • Level up to access better tasks
          </HText>
        </HCard>
      </ScrollView>
    </HScreen>
  );
}

interface TierCardProps {
  tier: TierInfo;
  isCurrent: boolean;
  isUnlocked: boolean;
}

function TierCard({ tier, isCurrent, isUnlocked }: TierCardProps) {
  return (
    <HCard 
      variant={isCurrent ? 'elevated' : 'default'} 
      padding="lg" 
      style={StyleSheet.flatten([
        styles.tierCard,
        !isUnlocked && styles.tierCardLocked, 
        isCurrent && styles.tierCardCurrent
      ])}
    >
      <View style={styles.tierHeader}>
        <View style={[styles.tierBadge, { backgroundColor: isUnlocked ? tier.color : hustleColors.glass.medium }]}>
          <HText variant="headline" color="primary" bold>{tier.tier}</HText>
        </View>
        <View style={styles.tierInfo}>
          <HText variant="headline" color={isUnlocked ? 'primary' : 'muted'}>
            {tier.name}
          </HText>
          <HText variant="caption" color="tertiary">
            {tier.xpRequired.toLocaleString()} XP • {tier.platformFee} fee
          </HText>
        </View>
        {isCurrent && (
          <HBadge variant="purple" size="sm">YOU</HBadge>
        )}
        {!isCurrent && isUnlocked && (
          <HText variant="body">✅</HText>
        )}
        {!isUnlocked && (
          <HText variant="body">🔒</HText>
        )}
      </View>
      
      <View style={styles.perks}>
        {tier.perks.map((perk, i) => (
          <HText key={i} variant="footnote" color={isUnlocked ? 'secondary' : 'muted'}>
            • {perk}
          </HText>
        ))}
      </View>
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
  currentTier: { 
    alignItems: 'center',
  },
  tierTitle: {
    marginTop: hustleSpacing.md,
    marginBottom: hustleSpacing.xs,
  },
  progressContainer: {
    width: '100%',
    marginTop: hustleSpacing.xl,
    marginBottom: hustleSpacing.sm,
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
  section: {
    marginTop: hustleSpacing.xl,
    marginBottom: hustleSpacing.md,
  },
  tierCard: {
    marginBottom: 0,
  },
  tierCardLocked: { 
    opacity: 0.5,
  },
  tierCardCurrent: { 
    borderLeftWidth: 3, 
    borderLeftColor: hustleColors.purple.core,
  },
  tierHeader: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  tierBadge: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  tierInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  perks: { 
    marginTop: hustleSpacing.sm,
    marginLeft: 56,
  },
  connectorContainer: { 
    paddingLeft: 21,
  },
  connector: { 
    width: 2, 
    height: 16, 
    backgroundColor: hustleColors.glass.medium,
  },
  connectorUnlocked: {
    backgroundColor: hustleColors.purple.core,
  },
  infoCard: {
    marginTop: hustleSpacing.xl,
  },
  infoText: {
    marginTop: hustleSpacing.sm,
  },
});

export default TrustTierLadderScreen;
