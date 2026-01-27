/**
 * CalibrationScreen - User preferences setup
 * Helps personalize the experience
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing, Card } from '../../components';
import { theme } from '../../theme';

type InterestOption = {
  id: string;
  emoji: string;
  label: string;
};

const INTERESTS: InterestOption[] = [
  { id: 'delivery', emoji: '📦', label: 'Delivery & Errands' },
  { id: 'cleaning', emoji: '🧹', label: 'Cleaning' },
  { id: 'moving', emoji: '🚚', label: 'Moving & Lifting' },
  { id: 'assembly', emoji: '🔧', label: 'Assembly' },
  { id: 'tech', emoji: '💻', label: 'Tech Help' },
  { id: 'yard', emoji: '🌱', label: 'Yard Work' },
  { id: 'pet', emoji: '🐕', label: 'Pet Care' },
  { id: 'other', emoji: '✨', label: 'Other' },
];

export function CalibrationScreen() {
  const insets = useSafeAreaInsets();
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
    console.log('Selected interests:', selected);
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <Text variant="title1" color="primary" align="center">
            What interests you?
          </Text>
          <Spacing size={8} />
          <Text variant="body" color="secondary" align="center">
            Select all that apply. You can change these later.
          </Text>
        </View>

        <Spacing size={32} />

        {/* Interest Grid */}
        <View style={styles.grid}>
          {INTERESTS.map((interest) => (
            <TouchableOpacity
              key={interest.id}
              style={[
                styles.interestCard,
                selected.includes(interest.id) && styles.interestCardSelected,
              ]}
              onPress={() => toggleInterest(interest.id)}
              activeOpacity={0.7}
            >
              <Text variant="title2">{interest.emoji}</Text>
              <Spacing size={8} />
              <Text 
                variant="caption" 
                color={selected.includes(interest.id) ? 'primary' : 'secondary'}
                align="center"
              >
                {interest.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* CTA */}
      <View style={styles.footer}>
        <Text variant="footnote" color="tertiary" align="center">
          {selected.length} selected
        </Text>
        <Spacing size={12} />
        <Button
          variant="primary"
          size="lg"
          onPress={handleContinue}
          disabled={selected.length === 0}
        >
          Continue
        </Button>
        <Spacing size={12} />
        <Button
          variant="ghost"
          size="sm"
          onPress={handleContinue}
        >
          Skip for now
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.surface.primary,
  },
  content: {
    flex: 1,
    paddingHorizontal: theme.spacing[4],
  },
  header: {
    marginTop: theme.spacing[8],
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  interestCard: {
    width: '48%',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
    alignItems: 'center',
    marginBottom: theme.spacing[3],
    borderWidth: 2,
    borderColor: 'transparent',
  },
  interestCardSelected: {
    borderColor: theme.colors.brand.primary,
    backgroundColor: theme.colors.surface.tertiary,
  },
  footer: {
    paddingHorizontal: theme.spacing[4],
    paddingBottom: theme.spacing[4],
  },
});

export default CalibrationScreen;
