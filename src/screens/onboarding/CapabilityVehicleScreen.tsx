/**
 * CapabilityVehicleScreen - Vehicle capability selection
 */

import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../navigation/types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
import { Button, Text, Spacing } from '../../components';
import { theme } from '../../theme';

const VEHICLES = [
  { id: 'none', emoji: '🚶', label: 'No vehicle', desc: 'Walking/public transit' },
  { id: 'bike', emoji: '🚲', label: 'Bicycle', desc: 'Small items only' },
  { id: 'car', emoji: '🚗', label: 'Car/Sedan', desc: 'Medium items' },
  { id: 'suv', emoji: '🚙', label: 'SUV/Truck', desc: 'Large items welcome' },
  { id: 'van', emoji: '🚐', label: 'Van', desc: 'Moving jobs ready' },
];

export function CapabilityVehicleScreen() {
  const insets = useSafeAreaInsets();
  // Navigation available via useNavigation<NavigationProp>() when needed
  const [selected, setSelected] = useState<string | null>(null);

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="title1" color="primary" align="center">
          Do you have a vehicle?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          This helps match you with the right tasks
        </Text>
        <Spacing size={32} />

        {VEHICLES.map((v) => (
          <React.Fragment key={v.id}>
            <TouchableOpacity
              style={[styles.option, selected === v.id && styles.optionSelected]}
              onPress={() => setSelected(v.id)}
            >
              <Text variant="title2">{v.emoji}</Text>
              <View style={styles.optionText}>
                <Text variant="headline" color="primary">{v.label}</Text>
                <Text variant="footnote" color="secondary">{v.desc}</Text>
              </View>
            </TouchableOpacity>
            <Spacing size={12} />
          </React.Fragment>
        ))}
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log(selected)} disabled={!selected}>
          Continue
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  optionSelected: { borderColor: theme.colors.brand.primary },
  optionText: { marginLeft: theme.spacing[4], flex: 1 },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityVehicleScreen;
