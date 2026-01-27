/**
 * CapabilityInsuranceScreen - Got insurance?
 * 
 * CHOSEN-STATE: Calibrating access, not gatekeeping
 * One decision: Do you have liability coverage?
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
import { HScreen, HText, HButton, HCard } from '../../components/atoms';
import { hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type InsuranceOption = {
  id: string;
  emoji: string;
  label: string;
  hint: string;
};

const OPTIONS: InsuranceOption[] = [
  { 
    id: 'yes', 
    emoji: '🛡️', 
    label: 'Yes, I\'m covered', 
    hint: 'Unlock premium tasks' 
  },
  { 
    id: 'no', 
    emoji: '👋', 
    label: 'Not yet', 
    hint: 'Plenty of tasks still available' 
  },
];

export function CapabilityInsuranceScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string | null>(null);

  const handleContinue = () => {
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
          <HText variant="title1" center>
            Got liability insurance?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Some tasks need it — most don't
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
              selected={selected === option.id}
              onPress={() => setSelected(option.id)}
            />
          ))}
        </View>

        <View style={styles.note}>
          <HText variant="caption" color="tertiary" center>
            💡 You can add insurance info anytime in settings
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
  selected, 
  onPress 
}: { 
  emoji: string; 
  label: string; 
  hint: string;
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
              <HText 
                variant="headline" 
                color={selected ? 'primary' : 'secondary'}
              >
                {label}
              </HText>
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
  },
  note: {
    marginTop: hustleSpacing.xl,
  },
});

export default CapabilityInsuranceScreen;
