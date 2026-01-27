/**
 * OnboardingCompleteScreen - You're in. Micro-win.
 * 
 * CHOSEN-STATE: "The system has accepted you. Now let's move."
 * One decision: Step into your new reality.
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  FadeIn,
  FadeInDown,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HSignal } from '../../components/atoms';
import { TrustBadge } from '../../components';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import { useAuthStore } from '../../store';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export function OnboardingCompleteScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { user, updateOnboarding } = useAuthStore();

  const handleStart = () => {
    updateOnboarding(true);
    
    navigation.reset({
      index: 0,
      routes: [{ name: 'MainTabs' }],
    });
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <HButton variant="primary" size="lg" fullWidth onPress={handleStart}>
          Let's go
        </HButton>
      }
    >
      <View style={styles.content}>
        {/* Activity signals - world is moving */}
        <Animated.View 
          entering={FadeIn.delay(200).duration(600)}
          style={styles.signalRow}
        >
          <HSignal text="Task posted" icon="📋" delay={0} />
          <HSignal text="$28 earned" icon="💵" delay={300} />
          <HSignal text="5★ review" icon="⭐" delay={600} />
        </Animated.View>

        {/* Celebration - understated */}
        <Animated.View 
          entering={FadeInDown.delay(100).duration(500)}
          style={styles.celebration}
        >
          <HText variant="hero" center>✨</HText>
          <View style={styles.spacerMd} />
          <HText variant="hero" center>
            You're in
          </HText>
          <View style={styles.spacerSm} />
          <HText variant="body" color="secondary" center>
            Your profile is live. Tasks are waiting.
          </HText>
        </Animated.View>

        <View style={styles.spacerXl} />

        {/* Trust badge - you already have status */}
        <Animated.View 
          entering={FadeInDown.delay(300).duration(500)}
          style={styles.badgeSection}
        >
          <TrustBadge level={user?.trustTier || 1} xp={user?.xp || 0} size="lg" />
        </Animated.View>

        <View style={styles.spacerLg} />

        {/* Stats card - implies trajectory */}
        <Animated.View entering={FadeInDown.delay(400).duration(500)}>
          <HCard variant="default" padding="lg">
            <View style={styles.statsRow}>
              <StatItem value="1" label="Level" />
              <View style={styles.statDivider} />
              <StatItem value="0" label="XP" />
              <View style={styles.statDivider} />
              <StatItem value="New" label="Status" highlight />
            </View>
          </HCard>
        </Animated.View>

        <View style={styles.spacerLg} />

        {/* Forward momentum hint */}
        <Animated.View entering={FadeIn.delay(600).duration(400)}>
          <HText variant="callout" color="tertiary" center>
            First task = first XP. Simple as that.
          </HText>
        </Animated.View>
      </View>
    </HScreen>
  );
}

function StatItem({ 
  value, 
  label, 
  highlight 
}: { 
  value: string; 
  label: string; 
  highlight?: boolean;
}) {
  return (
    <View style={styles.statItem}>
      <HText 
        variant="title2" 
        color={highlight ? 'purple' : 'primary'}
        bold
      >
        {value}
      </HText>
      <HText variant="caption" color="tertiary">{label}</HText>
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  signalRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    marginBottom: hustleSpacing.xl,
  },
  celebration: {
    alignItems: 'center',
  },
  spacerSm: {
    height: hustleSpacing.sm,
  },
  spacerMd: {
    height: hustleSpacing.md,
  },
  spacerLg: {
    height: hustleSpacing.lg,
  },
  spacerXl: {
    height: hustleSpacing.xl,
  },
  badgeSection: {
    alignItems: 'center',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statDivider: {
    width: 1,
    height: 32,
    backgroundColor: hustleColors.glass.border,
  },
});

export default OnboardingCompleteScreen;
