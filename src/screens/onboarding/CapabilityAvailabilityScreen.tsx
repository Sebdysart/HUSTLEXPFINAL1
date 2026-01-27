/**
 * CapabilityAvailabilityScreen - When are you around?
 * 
 * CHOSEN-STATE: System calibrating to your rhythm
 * One decision: When can you work?
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
import { HScreen, HText, HButton, HCard, HTextButton } from '../../components/atoms';
import { hustleColors, hustleSpacing } from '../../theme/hustle-tokens';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

type TimeSlot = {
  id: string;
  emoji: string;
  label: string;
  hint: string;
};

const TIME_SLOTS: TimeSlot[] = [
  { id: 'morning', emoji: '🌅', label: 'Mornings', hint: '6am - 12pm' },
  { id: 'afternoon', emoji: '☀️', label: 'Afternoons', hint: '12pm - 6pm' },
  { id: 'evening', emoji: '🌙', label: 'Evenings', hint: '6pm - 12am' },
  { id: 'flexible', emoji: '✨', label: 'Flexible', hint: 'Whenever' },
];

export function CapabilityAvailabilityScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggleSlot = (id: string) => {
    if (id === 'flexible') {
      setSelected(['flexible']);
    } else {
      setSelected(prev => {
        const filtered = prev.filter(i => i !== 'flexible');
        return filtered.includes(id) 
          ? filtered.filter(i => i !== id)
          : [...filtered, id];
      });
    }
  };

  const handleContinue = () => {
    navigation.goBack();
  };

  const handleSkip = () => {
    navigation.goBack();
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <View style={styles.footer}>
          <HButton 
            variant="primary" 
            size="lg" 
            fullWidth 
            onPress={handleContinue}
          >
            Continue
          </HButton>
          <HTextButton onPress={handleSkip}>
            Set up later
          </HTextButton>
        </View>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="title1" center>
            When are you around?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            We'll match you with tasks that fit
          </HText>
        </View>

        <View style={styles.spacer} />

        <View style={styles.list}>
          {TIME_SLOTS.map((slot) => (
            <TimeSlotCard
              key={slot.id}
              emoji={slot.emoji}
              label={slot.label}
              hint={slot.hint}
              selected={selected.includes(slot.id)}
              onPress={() => toggleSlot(slot.id)}
            />
          ))}
        </View>

        {selected.length > 0 && (
          <View style={styles.feedback}>
            <HText variant="caption" color="purple" center>
              Perfect — we'll tune your feed
            </HText>
          </View>
        )}
      </View>
    </HScreen>
  );
}

function TimeSlotCard({ 
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
  feedback: {
    marginTop: hustleSpacing.xl,
  },
  footer: {
    gap: hustleSpacing.sm,
  },
});

export default CapabilityAvailabilityScreen;
