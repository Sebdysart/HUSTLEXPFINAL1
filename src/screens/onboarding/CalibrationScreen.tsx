/**
 * CalibrationScreen - App learns your vibe
 * 
 * CHOSEN-STATE: Not "tell us about you" - "we're calibrating to you"
 * One decision: What kind of work resonates?
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

type InterestOption = {
  id: string;
  emoji: string;
  label: string;
};

const INTERESTS: InterestOption[] = [
  { id: 'delivery', emoji: '📦', label: 'Delivery' },
  { id: 'cleaning', emoji: '🧹', label: 'Cleaning' },
  { id: 'moving', emoji: '🚚', label: 'Moving' },
  { id: 'assembly', emoji: '🔧', label: 'Assembly' },
  { id: 'tech', emoji: '💻', label: 'Tech' },
  { id: 'yard', emoji: '🌱', label: 'Yard' },
  { id: 'pet', emoji: '🐕', label: 'Pets' },
  { id: 'other', emoji: '✨', label: 'Other' },
];

export function CalibrationScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggleInterest = (id: string) => {
    setSelected(prev => 
      prev.includes(id) 
        ? prev.filter(i => i !== id)
        : [...prev, id]
    );
  };

  const handleContinue = () => {
    // Proceed regardless of selection - no forced choices
    navigation.navigate('OnboardingComplete');
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
          {selected.length > 0 ? "I'm ready" : "Continue"}
        </HButton>
      }
    >
      <View style={styles.content}>
        {/* Header - calibrating, not interrogating */}
        <View style={styles.header}>
          <HText variant="title1" center>
            Quick calibration
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Tap what resonates — we'll surface relevant tasks
          </HText>
        </View>

        <View style={styles.spacer} />

        {/* Interest grid */}
        <View style={styles.grid}>
          {INTERESTS.map((interest) => (
            <InterestChip
              key={interest.id}
              emoji={interest.emoji}
              label={interest.label}
              selected={selected.includes(interest.id)}
              onPress={() => toggleInterest(interest.id)}
            />
          ))}
        </View>

        {/* Subtle feedback */}
        {selected.length > 0 && (
          <View style={styles.feedback}>
            <HText variant="caption" color="purple" center>
              {selected.length} selected — nice choices
            </HText>
          </View>
        )}
      </View>
    </HScreen>
  );
}

function InterestChip({ 
  emoji, 
  label, 
  selected, 
  onPress 
}: { 
  emoji: string; 
  label: string; 
  selected: boolean; 
  onPress: () => void;
}) {
  const scale = useSharedValue(1);

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 20, stiffness: 400 });
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
      style={styles.chipWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="md"
        >
          <View style={styles.chipContent}>
            <HText variant="title2">{emoji}</HText>
            <View style={styles.chipSpacer} />
            <HText 
              variant="callout" 
              color={selected ? 'primary' : 'secondary'}
              center
            >
              {label}
            </HText>
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
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  chipWrapper: {
    width: '48%',
    marginBottom: hustleSpacing.md,
  },
  chipContent: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.sm,
  },
  chipSpacer: {
    height: hustleSpacing.xs,
  },
  feedback: {
    marginTop: hustleSpacing.lg,
  },
});

export default CalibrationScreen;
