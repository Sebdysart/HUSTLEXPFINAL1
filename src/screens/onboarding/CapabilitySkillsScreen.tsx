/**
 * CapabilitySkillsScreen - Skills/expertise selection
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

const SKILLS = [
  { id: 'handyman', emoji: '🔨', label: 'Handyman' },
  { id: 'cleaning', emoji: '✨', label: 'Cleaning' },
  { id: 'organizing', emoji: '📦', label: 'Organizing' },
  { id: 'tech', emoji: '💻', label: 'Tech Support' },
  { id: 'driving', emoji: '🚗', label: 'Driving' },
  { id: 'heavy', emoji: '💪', label: 'Heavy Lifting' },
  { id: 'painting', emoji: '🎨', label: 'Painting' },
  { id: 'plumbing', emoji: '🔧', label: 'Basic Plumbing' },
  { id: 'electrical', emoji: '⚡', label: 'Basic Electrical' },
  { id: 'gardening', emoji: '🌿', label: 'Gardening' },
  { id: 'pet', emoji: '🐕', label: 'Pet Care' },
  { id: 'shopping', emoji: '🛒', label: 'Shopping/Errands' },
];

export function CapabilitySkillsScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [selected, setSelected] = useState<string[]>([]);

  const toggle = (id: string) => {
    setSelected(prev => 
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.header}>
        <Text variant="title1" color="primary" align="center">
          What are you good at?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Select your skills to get matched with relevant tasks
        </Text>
      </View>

      <ScrollView style={styles.scroll} contentContainerStyle={styles.grid}>
        {SKILLS.map((s) => (
          <TouchableOpacity
            key={s.id}
            style={[styles.chip, selected.includes(s.id) && styles.chipSelected]}
            onPress={() => toggle(s.id)}
          >
            <Text variant="title3">{s.emoji}</Text>
            <Text variant="caption" color={selected.includes(s.id) ? 'primary' : 'secondary'}>
              {s.label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <View style={styles.footer}>
        <Text variant="footnote" color="tertiary" align="center">
          {selected.length} skills selected
        </Text>
        <Spacing size={12} />
        <Button variant="primary" size="lg" onPress={() => console.log(selected)}>
          Continue
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  header: { paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  scroll: { flex: 1, marginTop: theme.spacing[6] },
  grid: { 
    flexDirection: 'row', 
    flexWrap: 'wrap', 
    justifyContent: 'center', 
    paddingHorizontal: theme.spacing[4],
    gap: theme.spacing[3],
  },
  chip: {
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    paddingVertical: theme.spacing[3],
    paddingHorizontal: theme.spacing[4],
    borderRadius: theme.radii.md,
    borderWidth: 2,
    borderColor: 'transparent',
    minWidth: 100,
  },
  chipSelected: { borderColor: theme.colors.brand.primary },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilitySkillsScreen;
