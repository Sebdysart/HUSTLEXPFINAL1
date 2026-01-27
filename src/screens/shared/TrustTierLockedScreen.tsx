/**
 * TrustTierLockedScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - "Level up" not "Next tier"
 * - Never feels far away
 * - Encouraging, not shaming
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HButton, HTrustBadge } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function TrustTierLockedScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  const handleFindTasks = () => {
    navigation.navigate('TaskFeed');
  };

  const handleGoBack = () => {
    navigation.goBack();
  };

  // These would come from route params in real usage
  const currentTier = 2;
  const currentXP = 850;
  const requiredTier = 4;
  const xpToGo = 2150;

  return (
    <HScreen ambient>
      <View style={[styles.content, { paddingTop: insets.top + hustleSpacing['3xl'] }]}>
        <HText variant="hero" style={styles.icon}>🔒</HText>
        
        <HText variant="title1" color="primary" align="center">
          Almost there
        </HText>
        <HText variant="body" color="secondary" align="center" style={styles.subtitle}>
          Level up to unlock this feature
        </HText>

        {/* Current vs Required - Encouraging framing */}
        <HCard variant="elevated" padding="xl" style={styles.comparisonCard}>
          <View style={styles.levelRow}>
            <View style={styles.levelItem}>
              <HText variant="caption" color="secondary">You're at</HText>
              <View style={styles.badgeWrapper}>
                <HTrustBadge tier={currentTier} xp={currentXP} size="md" />
              </View>
            </View>
            
            <HText variant="title2" color="muted">→</HText>
            
            <View style={styles.levelItem}>
              <HText variant="caption" color="secondary">You need</HText>
              <View style={styles.badgeWrapper}>
                <HTrustBadge tier={requiredTier} size="md" />
              </View>
            </View>
          </View>
        </HCard>

        {/* How to level up - Positive framing */}
        <HCard variant="default" padding="lg" style={styles.howToCard}>
          <HText variant="headline" color="primary">How to level up:</HText>
          <View style={styles.howToList}>
            <HText variant="body" color="secondary">• Complete more tasks (+100-200 XP each)</HText>
            <HText variant="body" color="secondary">• Earn 5-star ratings (+50 XP each)</HText>
            <HText variant="body" color="secondary">• Keep your completion rate high</HText>
          </View>
          <HText variant="caption" color={hustleColors.xp.primary} style={styles.xpToGo}>
            {xpToGo.toLocaleString()} XP to go
          </HText>
        </HCard>
      </View>

      {/* Footer Actions */}
      <View style={[styles.footer, { paddingBottom: insets.bottom + hustleSpacing.lg }]}>
        <HButton variant="primary" size="lg" onPress={handleFindTasks}>
          Find tasks to level up
        </HButton>
        <HButton variant="ghost" size="sm" onPress={handleGoBack} style={styles.backBtn}>
          Go back
        </HButton>
      </View>
    </HScreen>
  );
}

const styles = StyleSheet.create({
  content: { 
    flex: 1, 
    padding: hustleSpacing.lg, 
    alignItems: 'center',
  },
  icon: {
    marginBottom: hustleSpacing.xl,
  },
  subtitle: {
    marginTop: hustleSpacing.sm,
    marginBottom: hustleSpacing['2xl'],
  },
  comparisonCard: {
    width: '100%',
    marginBottom: hustleSpacing.xl,
  },
  levelRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-around', 
    alignItems: 'center',
  },
  levelItem: { 
    alignItems: 'center',
  },
  badgeWrapper: {
    marginTop: hustleSpacing.sm,
  },
  howToCard: {
    width: '100%',
  },
  howToList: {
    marginTop: hustleSpacing.md,
    gap: hustleSpacing.xs,
  },
  xpToGo: {
    marginTop: hustleSpacing.lg,
  },
  footer: { 
    padding: hustleSpacing.lg,
  },
  backBtn: {
    marginTop: hustleSpacing.md,
  },
});

export default TrustTierLockedScreen;
