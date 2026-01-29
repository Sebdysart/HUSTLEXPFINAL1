/**
 * CapabilityLocationScreen - Where do you hustle?
 * 
 * CHOSEN-STATE: System finding tasks near you
 * One decision: How far will you go?
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

type RadiusOption = {
  id: string;
  label: string;
  hint: string;
};

const RADIUS_OPTIONS: RadiusOption[] = [
  { id: '5', label: '5 miles', hint: 'Nearby only' },
  { id: '10', label: '10 miles', hint: 'Most popular' },
  { id: '25', label: '25 miles', hint: 'More options' },
  { id: '50', label: '50+ miles', hint: 'Will travel' },
];

export function CapabilityLocationScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string>('10');

  const handleContinue = () => {
    navigation.navigate('CapabilityVehicle');
  };

  const handleBack = () => navigation.goBack();

  return (
    <HScreen
      ambient
      scroll={false}
      header={
        <Pressable onPress={handleBack}>
          <HText variant="body" color="secondary">← Back</HText>
        </Pressable>
      }
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
            How far will you go?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Set your range — we'll find tasks nearby
          </HText>
        </View>

        <View style={styles.spacer} />

        <View style={styles.grid}>
          {RADIUS_OPTIONS.map((option) => (
            <RadiusCard
              key={option.id}
              label={option.label}
              hint={option.hint}
              selected={selected === option.id}
              onPress={() => setSelected(option.id)}
            />
          ))}
        </View>

        <View style={styles.note}>
          <HText variant="caption" color="tertiary" center>
            📍 Using your current location
          </HText>
        </View>
      </View>
    </HScreen>
  );
}

function RadiusCard({ 
  label, 
  hint,
  selected, 
  onPress 
}: { 
  label: string; 
  hint: string;
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
      style={styles.cardWrapper}
    >
      <Animated.View style={animatedStyle}>
        <HCard 
          variant={selected ? 'outlined' : 'default'} 
          padding="lg"
        >
          <View style={styles.cardContent}>
            <HText 
              variant="headline" 
              color={selected ? 'primary' : 'secondary'}
              center
            >
              {label}
            </HText>
            <HText variant="caption" color="tertiary" center>
              {hint}
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
  cardWrapper: {
    width: '48%',
    marginBottom: hustleSpacing.md,
  },
  cardContent: {
    alignItems: 'center',
    paddingVertical: hustleSpacing.sm,
    gap: hustleSpacing.xs,
  },
  note: {
    marginTop: hustleSpacing.lg,
  },
});

export default CapabilityLocationScreen;
