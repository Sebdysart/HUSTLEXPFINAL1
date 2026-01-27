/**
 * CapabilityVehicleScreen - How do you get around?
 * 
 * CHOSEN-STATE: Calibrating your mobility
 * One decision: What's your ride?
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

type VehicleOption = {
  id: string;
  emoji: string;
  label: string;
  hint: string;
};

const VEHICLES: VehicleOption[] = [
  { id: 'none', emoji: '🚶', label: 'On foot', hint: 'Local tasks' },
  { id: 'bike', emoji: '🚲', label: 'Bike', hint: 'Quick deliveries' },
  { id: 'car', emoji: '🚗', label: 'Car', hint: 'Most tasks' },
  { id: 'suv', emoji: '🚙', label: 'SUV/Truck', hint: 'Big hauls' },
  { id: 'van', emoji: '🚐', label: 'Van', hint: 'Moving jobs' },
];

export function CapabilityVehicleScreen() {
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
            How do you get around?
          </HText>
          <View style={styles.headerSpacer} />
          <HText variant="body" color="secondary" center>
            Bigger vehicle = more task types
          </HText>
        </View>

        <View style={styles.spacer} />

        <View style={styles.list}>
          {VEHICLES.map((vehicle) => (
            <VehicleCard
              key={vehicle.id}
              emoji={vehicle.emoji}
              label={vehicle.label}
              hint={vehicle.hint}
              selected={selected === vehicle.id}
              onPress={() => setSelected(vehicle.id)}
            />
          ))}
        </View>
      </View>
    </HScreen>
  );
}

function VehicleCard({ 
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
  cardWrapper: {},
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hustleSpacing.lg,
  },
  cardText: {
    flex: 1,
  },
});

export default CapabilityVehicleScreen;
