/**
 * CapabilityTradesScreen - Trades/certifications
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

const TRADES = [
  { id: 'plumber', emoji: '🔧', label: 'Licensed Plumber' },
  { id: 'electrician', emoji: '⚡', label: 'Licensed Electrician' },
  { id: 'hvac', emoji: '❄️', label: 'HVAC Certified' },
  { id: 'contractor', emoji: '🏗️', label: 'General Contractor' },
  { id: 'painter', emoji: '🎨', label: 'Professional Painter' },
  { id: 'locksmith', emoji: '🔐', label: 'Locksmith' },
  { id: 'appliance', emoji: '🔌', label: 'Appliance Repair' },
  { id: 'none', emoji: '✨', label: 'No certifications' },
];

export function CapabilityTradesScreen() {
  const insets = useSafeAreaInsets();
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
      <View style={styles.header}>
        <Text variant="title1" color="primary" align="center">
          Any professional certifications?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Certified pros get access to specialized, higher-paying tasks
        </Text>
      </View>

      <ScrollView style={styles.scroll} contentContainerStyle={styles.list}>
        {TRADES.map((t) => (
          <TouchableOpacity
            key={t.id}
            style={[styles.option, selected.includes(t.id) && styles.optionSelected]}
            onPress={() => toggle(t.id)}
          >
            <Text variant="title2">{t.emoji}</Text>
            <Text variant="body" color="primary" style={styles.optionLabel}>{t.label}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <View style={styles.footer}>
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
  list: { paddingHorizontal: theme.spacing[4] },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
    marginBottom: theme.spacing[3],
    borderWidth: 2,
    borderColor: 'transparent',
  },
  optionSelected: { borderColor: theme.colors.brand.primary },
  optionLabel: { marginLeft: theme.spacing[4] },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityTradesScreen;
