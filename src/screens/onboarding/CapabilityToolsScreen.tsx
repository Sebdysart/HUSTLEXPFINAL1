/**
 * CapabilityToolsScreen - Tools/equipment capability
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

// type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

const TOOLS = [
  { id: 'basic', emoji: '🔧', label: 'Basic tools' },
  { id: 'power', emoji: '🔌', label: 'Power tools' },
  { id: 'cleaning', emoji: '🧹', label: 'Cleaning supplies' },
  { id: 'garden', emoji: '🌱', label: 'Garden equipment' },
  { id: 'none', emoji: '❌', label: 'No equipment' },
];

export function CapabilityToolsScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [selected, setSelected] = useState<string[]>([]);

  const toggle = (id: string) => {
    if (id === 'none') {
      setSelected(['none']);
    } else {
      setSelected(prev => {
        const filtered = prev.filter(i => i !== 'none');
        return filtered.includes(id) ? filtered.filter(i => i !== id) : [...filtered, id];
      });
    }
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="title1" color="primary" align="center">
          What tools do you have?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Select all that apply
        </Text>
        <Spacing size={32} />

        <View style={styles.grid}>
          {TOOLS.map((t) => (
            <TouchableOpacity
              key={t.id}
              style={[styles.chip, selected.includes(t.id) && styles.chipSelected]}
              onPress={() => toggle(t.id)}
            >
              <Text variant="title3">{t.emoji}</Text>
              <Spacing size={4} />
              <Text variant="caption" color={selected.includes(t.id) ? 'primary' : 'secondary'}>
                {t.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log(selected)}>
          Continue
        </Button>
        <Spacing size={12} />
        <Button variant="ghost" size="sm" onPress={() => console.log('skip')}>
          Skip
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  grid: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', gap: theme.spacing[3] },
  chip: {
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    paddingVertical: theme.spacing[4],
    paddingHorizontal: theme.spacing[5],
    borderRadius: theme.radii.md,
    borderWidth: 2,
    borderColor: 'transparent',
    minWidth: 100,
  },
  chipSelected: { borderColor: theme.colors.brand.primary },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityToolsScreen;
