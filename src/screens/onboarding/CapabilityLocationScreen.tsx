/**
 * CapabilityLocationScreen - Service area setup
 */

import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing, Input, Card } from '../../components';
import { theme } from '../../theme';

export function CapabilityLocationScreen() {
  const insets = useSafeAreaInsets();
  const [zipCode, setZipCode] = useState('');
  const [radius, setRadius] = useState('10');

  const handleContinue = () => {
    console.log('Location:', { zipCode, radius });
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="title1" color="primary" align="center">
          Where do you operate?
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Set your service area to find nearby tasks
        </Text>

        <Spacing size={32} />

        <Card variant="default" padding="lg">
          <Input
            label="ZIP Code"
            placeholder="Enter your ZIP code"
            value={zipCode}
            onChangeText={setZipCode}
            keyboardType="number-pad"
            maxLength={5}
          />

          <Spacing size={20} />

          <Text variant="headline" color="primary">Service radius</Text>
          <Spacing size={12} />
          
          <View style={styles.radiusOptions}>
            {['5', '10', '25', '50'].map(r => (
              <Button
                key={r}
                variant={radius === r ? 'primary' : 'secondary'}
                size="sm"
                onPress={() => setRadius(r)}
              >
                {`${r} mi`}
              </Button>
            ))}
          </View>
        </Card>

        <Spacing size={16} />

        <View style={styles.infoBox}>
          <Text variant="footnote" color="secondary" align="center">
            📍 You can also enable location services for automatic detection
          </Text>
        </View>
      </View>

      <View style={styles.footer}>
        <Button
          variant="primary"
          size="lg"
          onPress={handleContinue}
          disabled={zipCode.length < 5}
        >
          Continue
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.colors.surface.primary },
  content: { flex: 1, paddingHorizontal: theme.spacing[4], paddingTop: theme.spacing[8] },
  radiusOptions: { 
    flexDirection: 'row', 
    justifyContent: 'space-between',
    gap: theme.spacing[2],
  },
  infoBox: {
    backgroundColor: theme.colors.surface.secondary,
    padding: theme.spacing[4],
    borderRadius: theme.radii.md,
  },
  footer: { paddingHorizontal: theme.spacing[4], paddingBottom: theme.spacing[4] },
});

export default CapabilityLocationScreen;
