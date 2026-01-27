/**
 * TrustTierLadderScreen - Trust level progression
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
    color: '#6B7280', // gray
  },
  { 
    tier: 2, 
    name: 'Rising', 
    xpRequired: 500, 
    platformFee: '14%',
    perks: ['Access to $50+ tasks', 'Priority matching', '1% fee reduction'],
    color: '#10B981', // green
  },
  { 
    tier: 3, 
    name: 'Trusted', 
    xpRequired: 2000, 
    platformFee: '12%',
    perks: ['Access to $100+ tasks', 'Verified badge', '3% fee reduction', 'Priority support'],
    color: '#3B82F6', // blue
  },
  { 
    tier: 4, 
    name: 'Expert', 
    xpRequired: 5000, 
    platformFee: '10%',
    perks: ['Access to premium tasks', 'Featured profile', '5% fee reduction', 'Early access'],
    color: '#8B5CF6', // purple
  },
  { 
    tier: 5, 
    name: 'Elite', 
    xpRequired: 10000, 
    platformFee: '8%',
    perks: ['All task access', 'Elite badge', '7% fee reduction', 'VIP support', 'Exclusive events'],
    color: '#F59E0B', // gold
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

  const handleBack = () => navigation.goBack();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleBack}>
          <Text variant="body" color="primary">← Back</Text>
        </TouchableOpacity>
        <Text variant="title2" color="primary">Trust Tiers</Text>
        <View style={{ width: 50 }} />
      </View>

      <ScrollView contentContainerStyle={styles.scroll}>
        {/* Current Tier Card */}
        <Card variant="elevated" padding="lg">
          <View style={styles.currentTier}>
            <TrustBadge level={currentTier} xp={currentXP} size="lg" />
            <Spacing size={12} />
            <Text variant="title2" color="primary">
              {`Tier ${currentTier}: ${currentTierInfo.name}`}
            </Text>
            <Spacing size={4} />
            <Text variant="body" color="secondary">
              {`Current fee: ${currentTierInfo.platformFee}`}
            </Text>
            {nextTierInfo && (
              <>
                <Spacing size={12} />
                <View style={styles.progressBar}>
                  <View 
                    style={[
                      styles.progressFill, 
                      { width: `${Math.min((currentXP / nextTierInfo.xpRequired) * 100, 100)}%` }
                    ]} 
                  />
                </View>
                <Spacing size={8} />
                <Text variant="caption" color="secondary">
                  {`${xpToNext.toLocaleString()} XP to Tier ${nextTierInfo.tier}`}
                </Text>
              </>
            )}
          </View>
        </Card>

        <Spacing size={24} />

        {/* Tier Ladder */}
        <Text variant="headline" color="primary">All Tiers</Text>
        <Spacing size={12} />

        {TIERS.map((tier, idx) => (
          <React.Fragment key={tier.tier}>
            <TierCard
              tier={tier}
              isCurrent={tier.tier === currentTier}
              isUnlocked={tier.tier <= currentTier}
              currentXP={currentXP}
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

        <Spacing size={24} />

        {/* How Tiers Work */}
        <Card variant="default" padding="md">
          <Text variant="headline" color="primary">How Trust Tiers Work</Text>
          <Spacing size={12} />
          <Text variant="body" color="secondary">
            • Complete tasks to earn XP{'\n'}
            • Higher tiers = lower platform fees{'\n'}
            • Higher tiers = access to better tasks{'\n'}
            • 5-star ratings give bonus XP{'\n'}
            • Tiers can decrease if you have disputes or low ratings
          </Text>
        </Card>
      </ScrollView>
    </View>
  );
}

interface TierCardProps {
  tier: TierInfo;
  isCurrent: boolean;
  isUnlocked: boolean;
  currentXP: number;
}

function TierCard({ tier, isCurrent, isUnlocked, currentXP }: TierCardProps) {
  const progress = tier.tier > 1 ? Math.min((currentXP / tier.xpRequired) * 100, 100) : 100;
  
  return (
    <Card 
      variant={isCurrent ? 'elevated' : 'default'} 
      padding="md" 
      style={[!isUnlocked && styles.locked, isCurrent && { borderLeftWidth: 4, borderLeftColor: tier.color }]}
    >
      <View style={styles.tierHeader}>
        <View style={[styles.tierBadge, { backgroundColor: isUnlocked ? tier.color : theme.colors.surface.tertiary }]}>
          <Text variant="headline" color="inverse">{tier.tier}</Text>
        </View>
        <View style={styles.tierInfo}>
          <Text variant="headline" color={isUnlocked ? 'primary' : 'tertiary'}>{tier.name}</Text>
          <Text variant="caption" color="secondary">
            {tier.xpRequired.toLocaleString()} XP • {tier.platformFee} fee
          </Text>
        </View>
        {isCurrent && (
          <View style={styles.currentBadge}>
            <Text variant="caption" color="inverse">YOU</Text>
          </View>
        )}
        {!isCurrent && isUnlocked && <Text variant="body">✅</Text>}
        {!isUnlocked && <Text variant="body">🔒</Text>}
      </View>
      
      <Spacing size={8} />
      
      <View style={styles.perks}>
        {tier.perks.map((perk, i) => (
          <Text key={i} variant="footnote" color={isUnlocked ? 'secondary' : 'tertiary'}>
            • {perk}
          </Text>
        ))}
      </View>
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
  currentTier: { alignItems: 'center' },
  progressBar: {
    width: '100%',
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
  tierHeader: { flexDirection: 'row', alignItems: 'center' },
  tierBadge: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  tierInfo: { flex: 1, marginLeft: theme.spacing[3] },
  currentBadge: {
    backgroundColor: theme.colors.brand.primary,
    paddingHorizontal: theme.spacing[2],
    paddingVertical: 2,
    borderRadius: theme.radii.xs,
  },
  perks: { marginLeft: 56 },
  connectorContainer: { paddingLeft: 21 },
  connector: { 
    width: 2, 
    height: 16, 
    backgroundColor: theme.colors.surface.tertiary,
  },
  connectorUnlocked: {
    backgroundColor: theme.colors.brand.primary,
  },
  locked: { opacity: 0.6 },
});

export default TrustTierLadderScreen;
