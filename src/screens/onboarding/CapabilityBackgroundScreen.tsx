/**
 * CapabilityBackgroundScreen - Ready for a background check?
 * 
 * CHOSEN-STATE: Unlocking trust, not gatekeeping
 * One decision: Start check or skip
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { HScreen, HText, HButton, HCard, HBadge, HTextButton } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type VerifyOption = {
  id: string;
  emoji: string;
  label: string;
  hint: string;
  badge?: string;
};

const OPTIONS: VerifyOption[] = [
  { 
    id: 'yes', 
    emoji: '✅', 
    label: 'Let\'s do it', 
    hint: 'Unlock premium tasks',
    badge: 'Recommended'
  },
  { 
    id: 'later', 
    emoji: '⏳', 
    label: 'Maybe later', 
    hint: 'You can start anytime' 
  },
];

export function CapabilityBackgroundScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string | null>(null);

  const handleContinue = () => {
    if (selected === 'yes') {
      // Would start background check flow
    }
    navigation.goBack();
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <HButton 
          variant="primary" 
          size="lg" 
          fullWidth 
          onPress={handleContinue}
        >
          Continue
        </HButton>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="hero" center>🔒</HText>
          <View style={styles.headerSpacer} />
          <HText variant="title1" center>
            Want to get verified?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Verified hustlers earn more and get first dibs
          </HText>
        </View>

        <View style={styles.spacer} />

        <View style={styles.list}>
          {OPTIONS.map((option) => (
            <OptionCard
              key={option.id}
              emoji={option.emoji}
              label={option.label}
              hint={option.hint}
              badge={option.badge}
              selected={selected === option.id}
              onPress={() => setSelected(option.id)}
            />
          ))}
        </View>

        <View style={styles.perks}>
          <HText variant="caption" color="tertiary" center>
            ⭐ Verified badge • 💰 Premium tasks • 🚀 Priority matching
          </HText>
        </View>
      </View>
    </HScreen>
  );
}

function OptionCard({ 
  emoji, 
  label, 
  hint,
  badge,
  selected, 
  onPress 
}: { 
  emoji: string; 
  label: string; 
  hint: string;
  badge?: string;
  selected: boolean; 
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSpring(0.98, { damping: 20, stiffness: 400 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15, stiffness: 400 });
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={styles.cardWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="lg"
        >
          <View style={styles.cardContent}>
            <HText variant="title2">{emoji}</HText>
            <View style={styles.cardText}>
              <View style={styles.labelRow}>
                <HText 
                  variant="headline" 
                  color={selected ? 'primary' : 'secondary'}
                >
                  {label}
                </HText>
                {badge && (
                  <HBadge variant="purple" size="sm">{badge}</HBadge>
                )}
              </View>
              <HText variant="caption" color="tertiary">
                {hint}
              </HText>
            </View>
            {selected && (
              <HText variant="body" color="purple">✓</HText>
            )}
          </View>
        </HCard>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing['2xl'],
  },
  list: {
    gap: hustleSpacing.md,
  },
  cardWrapper: {
    marginBottom: hustleSpacing.xs,
  },
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.lg,
  },
  cardText: {
    flex: 1,
    gap: hustleSpacing.xs,
  },
  labelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.sm,
  },
  perks: {
    marginTop: hustleSpacing.xl,
  },
});

export default CapabilityBackgroundScreen;
