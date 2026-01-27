/**
 * TrustChangeExplanationScreen - Progress Archetype
 * 
 * EMOTIONAL CONTRACT: "Value is accumulating"
 * - Celebratory without being loud
 * - Numbers that feel earned
 * - Progress feels inevitable
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

import { HScreen, HText, HCard, HButton, HTrustBadge, HBadge } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function TrustChangeExplanationScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();

  const handleDone = () => {
    navigation.goBack();
  };

  // These would come from route params in real usage
  const beforeXP = 2400;
  const afterXP = 2600;
  const xpGained = afterXP - beforeXP;
  const tier = 3;

  return (
    <HScreen ambient>
      <ScrollView 
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + hustleSpacing['2xl'] }]}
        showsVerticalScrollIndicator={false}
      >
        {/* Celebratory Header */}
        <View style={styles.header}>
          <HText variant="hero" style={styles.icon}>🎉</HText>
          <HText variant="title1" color="primary" align="center">
            Nice work!
          </HText>
          <HText variant="body" color="secondary" align="center" style={styles.subtitle}>
            Your trust score just went up
          </HText>
        </View>

        {/* Change Summary - Visual */}
        <HCard variant="elevated" padding="xl">
          <View style={styles.changeRow}>
            <View style={styles.changeItem}>
              <HText variant="caption" color="muted">Before</HText>
              <View style={styles.badgeWrapper}>
                <HTrustBadge tier={tier} xp={beforeXP} size="sm" />
              </View>
            </View>
            
            <HText variant="title2" color={hustleColors.purple.soft}>→</HText>
            
            <View style={styles.changeItem}>
              <HText variant="caption" color="muted">Now</HText>
              <View style={styles.badgeWrapper}>
                <HTrustBadge tier={tier} xp={afterXP} size="sm" />
              </View>
            </View>
          </View>
          
          <View style={styles.xpGainedContainer}>
            <HText variant="title2" color={hustleColors.xp.primary} bold>
              +{xpGained} XP
            </HText>
          </View>
        </HCard>

        {/* What Happened - Breakdown */}
        <View style={styles.section}>
          <HText variant="headline" color="primary">What happened</HText>
        </View>
        
        <ChangeItem 
          emoji="✅" 
          title="Task Completed" 
          xp={150} 
          desc="Help moving furniture" 
        />
        <ChangeItem 
          emoji="⭐" 
          title="5-Star Rating" 
          xp={50} 
          desc="From Sarah M." 
        />

        {/* Tip */}
        <HCard variant="default" padding="lg" style={styles.tipCard}>
          <HText variant="footnote" color="secondary">
            💡 Your trust score is based on completed tasks, ratings, and response time. Keep hustling!
          </HText>
        </HCard>
      </ScrollView>

      {/* Footer */}
      <View style={[styles.footer, { paddingBottom: insets.bottom + hustleSpacing.lg }]}>
        <HButton variant="primary" size="lg" onPress={handleDone}>
          Got it
        </HButton>
      </View>
    </HScreen>
  );
}

interface ChangeItemProps {
  emoji: string;
  title: string;
  xp: number;
  desc: string;
}

function ChangeItem({ emoji, title, xp, desc }: ChangeItemProps) {
  return (
    <HCard variant="default" padding="lg" style={styles.changeCard}>
      <View style={styles.changeCardRow}>
        <HText variant="title2">{emoji}</HText>
        <View style={styles.changeCardInfo}>
          <HText variant="headline" color="primary">{title}</HText>
          <HText variant="footnote" color="tertiary">{desc}</HText>
        </View>
        <HText variant="headline" color={hustleColors.xp.primary} bold>
          +{xp}
        </HText>
      </View>
    </HCard>
  );
}

const styles = StyleSheet.create({
  scroll: { 
    padding: hustleSpacing.lg,
    paddingBottom: hustleSpacing['4xl'],
  },
  header: { 
    alignItems: 'center',
    marginBottom: hustleSpacing.xl,
  },
  icon: {
    marginBottom: hustleSpacing.md,
  },
  subtitle: {
    marginTop: hustleSpacing.xs,
  },
  changeRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-around', 
    alignItems: 'center',
  },
  changeItem: { 
    alignItems: 'center',
  },
  badgeWrapper: {
    marginTop: hustleSpacing.sm,
  },
  xpGainedContainer: {
    alignItems: 'center',
    marginTop: hustleSpacing.xl,
  },
  section: {
    marginTop: hustleSpacing.xl,
    marginBottom: hustleSpacing.md,
  },
  changeCard: { 
    marginBottom: hustleSpacing.sm,
  },
  changeCardRow: { 
    flexDirection: 'row', 
    alignItems: 'center',
  },
  changeCardInfo: { 
    flex: 1, 
    marginLeft: hustleSpacing.md,
  },
  tipCard: {
    marginTop: hustleSpacing.xl,
  },
  footer: { 
    padding: hustleSpacing.lg,
  },
});

export default TrustChangeExplanationScreen;
