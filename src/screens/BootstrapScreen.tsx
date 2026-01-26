/**
 * BootstrapScreen - The blocking first screen
 * Must build, launch, and run stable for 30 seconds before proceeding.
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button, Text, Spacing } from '../components';
import { theme } from '../theme';

export function BootstrapScreen() {
  const insets = useSafeAreaInsets();

  const handlePress = () => {
    console.log('Button pressed');
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <View style={styles.content}>
        <Text variant="hero" color="primary" align="center">
          HustleXP
        </Text>
        <Spacing size={8} />
        <Text variant="body" color="secondary" align="center">
          Trust-based gig marketplace
        </Text>
        <Spacing size={32} />
        <Button
          variant="primary"
          size="lg"
          onPress={handlePress}
        >
          Get Started
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
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: theme.spacing[6],
  },
});

export default BootstrapScreen;
