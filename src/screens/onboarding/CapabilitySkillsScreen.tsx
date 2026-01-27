/**
 * CapabilitySkillsScreen - What are you good at?
 * 
 * CHOSEN-STATE: Surfacing your strengths
 * One decision: What resonates?
 */

import React, { useState } from 'react';
import { View, StyleSheet, Pressable, ScrollView } from 'react-native';
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

type SkillOption = {
  id: string;
  emoji: string;
  label: string;
};

const SKILLS: SkillOption[] = [
  { id: 'handyman', emoji: '🔨', label: 'Handyman' },
  { id: 'cleaning', emoji: '✨', label: 'Cleaning' },
  { id: 'organizing', emoji: '📦', label: 'Organizing' },
  { id: 'tech', emoji: '💻', label: 'Tech' },
  { id: 'driving', emoji: '🚗', label: 'Driving' },
  { id: 'lifting', emoji: '💪', label: 'Lifting' },
  { id: 'painting', emoji: '🎨', label: 'Painting' },
  { id: 'plumbing', emoji: '🔧', label: 'Plumbing' },
  { id: 'electrical', emoji: '⚡', label: 'Electrical' },
  { id: 'gardening', emoji: '🌿', label: 'Gardening' },
  { id: 'pets', emoji: '🐕', label: 'Pets' },
  { id: 'errands', emoji: '🛒', label: 'Errands' },
];

export function CapabilitySkillsScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggleSkill = (id: string) => {
    setSelected(prev => 
      prev.includes(id) 
        ? prev.filter(i => i !== id)
        : [...prev, id]
    );
  };

  const handleContinue = () => {
    navigation.goBack();
  };

  return (
    <HScreen
      ambient
      scroll={false}
      footer={
        <View style={styles.footer}>
          {selected.length > 0 && (
            <HText variant="caption" color="purple" center>
              {selected.length} skills — nice range
            </HText>
          )}
          <HButton 
            variant="primary" 
            size="lg" 
            fullWidth 
            onPress={handleContinue}
          >
            Continue
          </HButton>
        </View>
      }
    >
      <View style={styles.content}>
        <View style={styles.header}>
          <HText variant="title1" center>
            What are you good at?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Tap any that resonate
          </HText>
        </View>

        <View style={styles.spacer} />

        <ScrollView 
          style={styles.scroll} 
          contentContainerStyle={styles.grid}
          showsVerticalScrollIndicator={false}
        >
          {SKILLS.map((skill) => (
            <SkillChip
              key={skill.id}
              emoji={skill.emoji}
              label={skill.label}
              selected={selected.includes(skill.id)}
              onPress={() => toggleSkill(skill.id)}
            />
          ))}
        </ScrollView>
      </View>
    </HScreen>
  );
}

function SkillChip({ 
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
  },
  header: {
    alignItems: 'center',
    paddingTop: hustleSpacing.lg,
  },
  headerSpacer: {
    height: hustleSpacing.sm,
  },
  spacer: {
    height: hustleSpacing.xl,
  },
  scroll: {
    flex: 1,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    paddingBottom: hustleSpacing['2xl'],
  },
  chipWrapper: {
    width: '31%',
    marginBottom: hustleSpacing.md,
  },
  chipContent: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.sm,
    gap: hustleSpacing.xs,
  },
  footer: {
    gap: hustleSpacing.md,
  },
});

export default CapabilitySkillsScreen;
