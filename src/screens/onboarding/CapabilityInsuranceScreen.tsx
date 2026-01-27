/**
 * CapabilityInsuranceScreen - Insurance/liability info
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

export function CapabilityInsuranceScreen() {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<NavigationProp>();
  const [hasInsurance, setHasInsurance] = useState<boolean | null>(null);

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="title1" color="primary" align="center">
          Do you have liability insurance?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Some tasks require proof of insurance
        </Text>

        <Spacing size={32} />

        <TouchableOpacity
          style={[styles.option, hasInsurance === true && styles.optionSelected]}
          onPress={() => setHasInsurance(true)}
        >
          <Text variant="title2">✅</Text>
          <View style={styles.optionText}>
            <Text variant="headline" color="primary">Yes, I have insurance</Text>
            <Text variant="footnote" color="secondary">Access to premium tasks</Text>
          </View>
        </TouchableOpacity>

        <Spacing size={12} />

        <TouchableOpacity
          style={[styles.option, hasInsurance === false && styles.optionSelected]}
          onPress={() => setHasInsurance(false)}
        >
          <Text variant="title2">❌</Text>
          <View style={styles.optionText}>
            <Text variant="headline" color="primary">No insurance</Text>
            <Text variant="footnote" color="secondary">Standard tasks available</Text>
          </View>
        </TouchableOpacity>

        <Spacing size={24} />

        <Card variant="default" padding="md">
          <Text variant="footnote" color="secondary">
            💡 Not having insurance doesn't disqualify you. Many tasks don't require it. You can add insurance info later.
          </Text>
        </Card>
      </View>

      <View style={styles.footer}>
        <Button variant="primary" size="lg" onPress={() => console.log(hasInsurance)} disabled={hasInsurance === null}>
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

export default CapabilityInsuranceScreen;
